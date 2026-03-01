add_interface_component(
    COMPONENT_NAME  interface_comp
    NAMESPACE       lux::cmake::toolset::test
)

component_include_directories(
    interface_comp
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME
        include
)

component_add_internal_dependencies(
    interface_comp
    lux::cmake::toolset::test::basic_shared
)

component_add_assets(
    interface_comp
    GLSL
    ${CMAKE_CURRENT_SOURCE_DIR}/three.glsl
    ${CMAKE_CURRENT_SOURCE_DIR}/three2.glsl
)

component_add_assets(
    interface_comp
    PROTO
    ${CMAKE_CURRENT_SOURCE_DIR}/three.proto
)

component_add_assets(
    interface_comp
    TEXT
    ${CMAKE_CURRENT_SOURCE_DIR}/assets
)

find_package(Threads REQUIRED)
component_add_transitive_commands(
    interface_comp
    "find_library(Threads REQUIRED)"
)