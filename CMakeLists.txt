cmake_minimum_required(VERSION 3.18)
project(lux-cmake-toolset NONE)

if(ENABLE_TEST)
    add_subdirectory(test)
    return()
endif()

set(CMAKE_CONFIG_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share/lux-cmake-toolset)
message("-- LUX-CMAKE-TOOLSET will be installed to ${CMAKE_CONFIG_INSTALL_DIR}")

install(
    FILES
    lux-cmake-toolset-config.cmake
    DESTINATION ${CMAKE_CONFIG_INSTALL_DIR}
)

install(
    DIRECTORY 
    common
    component
    DESTINATION ${CMAKE_CONFIG_INSTALL_DIR}
)