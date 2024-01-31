add_interface_component(
    COMPONENT_NAME  component_three
    NAMESPACE       lux::cmake::toolset::test
)

component_include_directories(
    component_three
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME
        include
)

component_add_internal_dependencies(
    component_three
    lux::cmake::toolset::test::component_one
)

component_add_assets(
    component_three
    GLSL
    ${CMAKE_CURRENT_SOURCE_DIR}/three.glsl
    ${CMAKE_CURRENT_SOURCE_DIR}/three2.glsl
)

component_add_assets(
    component_three
    PROTO
    ${CMAKE_CURRENT_SOURCE_DIR}/three.proto
)

component_add_assets(
    component_three
    TEXT
    ${CMAKE_CURRENT_SOURCE_DIR}/assets
)

find_package(Threads REQUIRED)
component_add_transitive_commands(
    component_three
    "find_library(Threads REQUIRED)"
)