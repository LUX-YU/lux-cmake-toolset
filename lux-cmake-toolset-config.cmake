set(LUX_CMAKE_TOOLSET_DIR           ${CMAKE_CURRENT_LIST_DIR})
set(LUX_CMAKE_COMMON_TOOLSET_DIR    ${LUX_CMAKE_TOOLSET_DIR}/common)
set(LUX_CMAKE_COMPONENT_TOOLSET_DIR ${LUX_CMAKE_TOOLSET_DIR}/component)

set(LUX_CMAKE_TOOLSET_VERSION "0.4.0")

include(${LUX_CMAKE_COMMON_TOOLSET_DIR}/generate_visibility_header.cmake)
include(${LUX_CMAKE_COMMON_TOOLSET_DIR}/list_subdirectory.cmake)

include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/add_component.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_add_assets.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_add_cmake_scripts.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_add_internal_dependencies.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_add_transitive_commands.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_get_assets.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_get_cmake_scripts.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_get_include_directories.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/component_include_directories.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/include_component_cmake_scripts.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/install_components.cmake)
