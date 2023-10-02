set(LUX_CMAKE_TOOLSET_DIR           ${CMAKE_CURRENT_LIST_DIR})
set(LUX_CMAKE_COMMON_TOOLSET_DIR    ${LUX_CMAKE_TOOLSET_DIR}/common)
set(LUX_CMAKE_COMPONENT_TOOLSET_DIR ${LUX_CMAKE_TOOLSET_DIR}/component)

set(LUX_CMAKE_TOOLSET_VERSION "0.2.0")

include(${LUX_CMAKE_COMMON_TOOLSET_DIR}/generate_visibility_header.cmake)
include(${LUX_CMAKE_COMMON_TOOLSET_DIR}/list_subdirectory.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/add_component.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/install_project.cmake)
