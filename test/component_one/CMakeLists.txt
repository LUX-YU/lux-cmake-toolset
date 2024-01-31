add_component(
    COMPONENT_NAME  component_one
    NAMESPACE       lux::cmake::toolset::test
    SOURCE_FILES    ${CMAKE_CURRENT_SOURCE_DIR}/src/one.cpp
)

component_include_directories(
    component_one
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${LUX_GENERATE_HEADER_DIR}
    INSTALL_TIME
        include
)

component_add_assets(
    component_one
    TEXT
    ${CMAKE_CURRENT_SOURCE_DIR}/assets
    ${CMAKE_CURRENT_SOURCE_DIR}/one_second.txt
)