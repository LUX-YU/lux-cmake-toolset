cmake_minimum_required(VERSION 3.18)
project(lux-cmake-toolset-test)

include(../lux-cmake-toolset-config.cmake)

# ─── Test: generate_visibility_header ─────────────────────────────────────────
generate_visibility_header(
    ENABLE_MACRO_NAME   LUX_CMAKE_TOOLSET_LIBRARY
    PUBLIC_MACRO_NAME   LUX_CMAKE_TOOLSET_PUBLIC
    GENERATE_FILE_PATH  lux/cmake/toolset/visibility.h
)

# Test: generate_visibility_header with DISABLE_DLL_MACRO_NAME
generate_visibility_header(
    ENABLE_MACRO_NAME       LUX_CMAKE_TOOLSET_LIBRARY2
    PUBLIC_MACRO_NAME       LUX_CMAKE_TOOLSET_PUBLIC2
    DISABLE_DLL_MACRO_NAME  LUX_CMAKE_TOOLSET_NO_DLL
    GENERATE_FILE_PATH      lux/cmake/toolset/visibility2.h
)

# ─── Test: generate_version_header ───────────────────────────────────────────
generate_version_header(
    VERSION          1.2.3
    HEADER_FILE_PATH lux/cmake/toolset/version.h
    PREFIX           LUX_CMAKE_TOOLSET
)

# Test: generate_version_header with default PREFIX
generate_version_header(
    VERSION          0.0.1
    HEADER_FILE_PATH lux/cmake/toolset/version_default.h
)

# ─── Test: subdirectory_list ─────────────────────────────────────────────────
subdirectory_list(TEST_SUBDIRS)
message("-- [test] subdirectory_list result: ${TEST_SUBDIRS}")

# ─── Component subdirectories ────────────────────────────────────────────────
add_subdirectory(basic_shared)
add_subdirectory(with_deps)
add_subdirectory(interface_comp)
add_subdirectory(static_options)
add_subdirectory(export_scripts)

# ─── Test: component_get_include_directories (all 4 types) ──────────────────
component_get_include_directories(basic_shared BUILD_TIME_EXPORT BASIC_EXPORT_DIRS)
message("-- [test] basic_shared BUILD_TIME_EXPORT dirs: ${BASIC_EXPORT_DIRS}")

component_get_include_directories(basic_shared INSTALL_TIME BASIC_INSTALL_DIRS)
message("-- [test] basic_shared INSTALL_TIME dirs: ${BASIC_INSTALL_DIRS}")

component_get_include_directories(static_options PRIVATE STATIC_PRIVATE_DIRS)
message("-- [test] static_options PRIVATE dirs: ${STATIC_PRIVATE_DIRS}")

component_get_include_directories(export_scripts BUILD_TIME_SHARED EXPORT_SHARED_DIRS)
message("-- [test] export_scripts BUILD_TIME_SHARED dirs: ${EXPORT_SHARED_DIRS}")

# ─── Test: component_get_asset_types ─────────────────────────────────────────
component_get_asset_types(interface_comp IFACE_ASSET_TYPES)
message("-- [test] interface_comp asset types: ${IFACE_ASSET_TYPES}")

component_get_asset_types(basic_shared BASIC_ASSET_TYPES)
message("-- [test] basic_shared asset types: ${BASIC_ASSET_TYPES}")

# ─── Test: component_get_assets ──────────────────────────────────────────────
component_get_assets(basic_shared TEXT BASIC_TEXT_ASSETS)
message("-- [test] basic_shared TEXT assets: ${BASIC_TEXT_ASSETS}")

component_get_assets(interface_comp GLSL IFACE_GLSL_ASSETS)
message("-- [test] interface_comp GLSL assets: ${IFACE_GLSL_ASSETS}")

component_get_assets(interface_comp PROTO IFACE_PROTO_ASSETS)
message("-- [test] interface_comp PROTO assets: ${IFACE_PROTO_ASSETS}")

# ─── Test: component_get_asset_files ─────────────────────────────────────────
component_get_asset_files(basic_shared TEXT BASIC_TEXT_FILES)
message("-- [test] basic_shared TEXT asset files: ${BASIC_TEXT_FILES}")

component_get_asset_files(interface_comp GLSL IFACE_GLSL_FILES)
message("-- [test] interface_comp GLSL asset files: ${IFACE_GLSL_FILES}")

# ─── Test: component_get_cmake_scripts / include_component_cmake_scripts ─────
component_get_cmake_scripts(export_scripts EXPORT_SCRIPTS_LIST)
message("-- [test] export_scripts cmake scripts: ${EXPORT_SCRIPTS_LIST}")

include_component_cmake_scripts(export_scripts)

# ─── Test: install_components (with all 5 components) ────────────────────────
install_components(
    PROJECT_NAME    lux_cmake_toolset_test
    VERSION         0.0.0
    NAMESPACE       lux::cmake::toolset
    COMPONENTS      basic_shared
                    with_deps
                    interface_comp
                    static_options
                    export_scripts
)