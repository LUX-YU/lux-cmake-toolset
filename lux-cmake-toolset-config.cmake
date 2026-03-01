set(LUX_CMAKE_TOOLSET_DIR           ${CMAKE_CURRENT_LIST_DIR})
set(LUX_CMAKE_COMMON_TOOLSET_DIR    ${LUX_CMAKE_TOOLSET_DIR}/common)
set(LUX_CMAKE_COMPONENT_TOOLSET_DIR ${LUX_CMAKE_TOOLSET_DIR}/component)

set(LUX_CMAKE_TOOLSET_VERSION "0.5.0")

# Common
include(${LUX_CMAKE_COMMON_TOOLSET_DIR}/generate_visibility_header.cmake)
include(${LUX_CMAKE_COMMON_TOOLSET_DIR}/generate_version_header.cmake)
include(${LUX_CMAKE_COMMON_TOOLSET_DIR}/list_subdirectory.cmake)

# Component
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_properties.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_assets.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_dependencies.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_get_include_directories.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_include_directories.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/include_component_cmake_scripts.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/install_components.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/query_package_components.cmake)
