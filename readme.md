# LUX-CMAKE-TOOLSET

The goal of LUX-CMAKE-TOOLSET is to make it more convenient to create a CMake-based project.

## Component Tool Set
The component CMake tool is used to create a component-based project.

With the `add_component` function, you can create a component-based project. The project can be used as follows:
``` cmake
find_package(<TARGET_PROJECT_NAME> CONFIG REQUIRED COMPONENTS <COMPONENT_NAME>)

target_link_libraries(
    <YOUR_PROJECT>
    PUBLIC
    <TARGET_PROJECT_NAMESPACE>::<COMPONENT_NAME>
)
```

### Useage

``` cmake
set(LUX_TOOLSET /path/to/toolset)

include(${LUX_TOOLSET}/component/add_component.cmake)
include(${LUX_TOOLSET}/component/install_project.cmake)

add_component(
    COMPONENT_NAME      <component_name_1>
    NAMESPACE           <namespace>    # Create an alias for this component. It will become <namespace>::<component_name_1>
    SOURCE_FILES        <source_files>
    EXPORT_INCLUDE_DIRS include
)

add_component(
    COMPONENT_NAME      <component_name_2>
    NAMESPACE           <namespace>
    SOURCE_FILES        <source_files>
    EXPORT_INCLUDE_DIRS include
)

install_projects(
    PROJECT_NAME    <project_name>
    VERSION         x.y.z
    # The namespace is used as a prefix when you use the `find_package` function
    NAMESPACE       <namespace>
    COMPONENTS      <component_name_1>
                    <component_name_2>
)
```
