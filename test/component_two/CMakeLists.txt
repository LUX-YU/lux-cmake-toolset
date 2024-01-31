add_component(
    COMPONENT_NAME  component_two
    NAMESPACE       lux::cmake::toolset::test
    SOURCE_FILES    ${CMAKE_CURRENT_SOURCE_DIR}/src/two.cpp
)

component_include_directories(
    component_two
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME
        include
)

component_add_internal_dependencies(
    component_two
    lux::cmake::toolset::test::component_one
)
