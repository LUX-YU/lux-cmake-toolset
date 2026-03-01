# Test: add_component with EXPORT_NAME
# Test: component_include_directories with BUILD_TIME_SHARED
# Test: component_add_cmake_scripts
# Test: component_add_export_properties

add_component(
    COMPONENT_NAME  export_scripts
    NAMESPACE       lux::cmake::toolset::test
    EXPORT_NAME     five_exported
    SOURCE_FILES    ${CMAKE_CURRENT_SOURCE_DIR}/src/five.cpp
)

component_include_directories(
    export_scripts
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    BUILD_TIME_SHARED
        ${CMAKE_CURRENT_SOURCE_DIR}/shared_include
    INSTALL_TIME
        include
)

# Test: component_add_cmake_scripts
component_add_cmake_scripts(
    export_scripts
    ${CMAKE_CURRENT_SOURCE_DIR}/scripts/five_script.cmake
)

# Test: component_add_assets (additional type)
component_add_assets(
    export_scripts
    TEXT
    ${CMAKE_CURRENT_SOURCE_DIR}/assets
)

# Test: component_add_export_properties
component_add_export_properties(
    export_scripts
    PROPERTIES
        CUSTOM_PROP_A   "value_a"
        CUSTOM_PROP_B   "value_b"
)

# Test: component_add_internal_dependencies (shared lib depending on static lib)
component_add_internal_dependencies(
    export_scripts
    lux::cmake::toolset::test::static_options
)
