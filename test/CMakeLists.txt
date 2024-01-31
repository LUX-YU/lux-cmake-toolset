cmake_minimum_required(VERSION 3.18)
project(lux-cmake-toolset-test)

include(../lux-cmake-toolset-config.cmake)

generate_visibility_header(
    ENABLE_MACRO_NAME   LUX_CMAKE_TOOLSET_LIBRARY
    PUBLIC_MACRO_NAME   LUX_CMAKE_TOOLSET_PUBLIC
    GENERATE_FILE_PATH  lux/cmake/toolset/visibility.h
)

add_subdirectory(component_one)
add_subdirectory(component_two)
add_subdirectory(component_three)

install_components(
    PROJECT_NAME    lux_cmake_toolset_test
    VERSION         0.0.0
    NAMESPACE       lux::cmake::toolset
    COMPONENTS      component_one
                    component_two
                    component_three
)