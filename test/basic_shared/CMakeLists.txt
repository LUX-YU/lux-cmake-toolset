add_component(
    COMPONENT_NAME  basic_shared
    NAMESPACE       lux::cmake::toolset::test
    SOURCE_FILES    ${CMAKE_CURRENT_SOURCE_DIR}/src/one.cpp
)

component_include_directories(
    basic_shared
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${LUX_GENERATE_HEADER_DIR}
    INSTALL_TIME
        include
)

component_add_assets(
    basic_shared
    TEXT
    ${CMAKE_CURRENT_SOURCE_DIR}/assets
    ${CMAKE_CURRENT_SOURCE_DIR}/one_second.txt
)