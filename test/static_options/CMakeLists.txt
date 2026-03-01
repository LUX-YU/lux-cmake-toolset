# Test: add_component with STATIC, OUTPUT_NAME, PREFIX
# Test: component_include_directories with PRIVATE

add_component(
    COMPONENT_NAME  static_options
    NAMESPACE       lux::cmake::toolset::test
    STATIC
    OUTPUT_NAME     four_lib
    PREFIX          lux_
    SOURCE_FILES    ${CMAKE_CURRENT_SOURCE_DIR}/src/four.cpp
)

component_include_directories(
    static_options
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME
        include
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/private_include
)
