add_component(
    COMPONENT_NAME  with_deps
    NAMESPACE       lux::cmake::toolset::test
    SOURCE_FILES    ${CMAKE_CURRENT_SOURCE_DIR}/src/two.cpp
)

component_include_directories(
    with_deps
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME
        include
)

component_add_internal_dependencies(
    with_deps
    lux::cmake::toolset::test::basic_shared
)
