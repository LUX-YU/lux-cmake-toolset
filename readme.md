# LUX-CMAKE-TOOLSET

The goal of LUX-CMAKE-TOOLSET is to make it more convenient to create a CMake-based project.

## Installation
To install the LUX-CMAKE-TOOLSET, you can follow these steps:

Copy all the files of this project to a location accessible by CMake's find_package command.

For Linux, you can copy the files to the directory /usr/share/lux-cmake-toolset/:

``` bash
cd /path/to/project
sudo cp -r ./* /usr/share/lux-cmake-toolset/
```
For other operating systems or custom installation locations, choose a suitable directory and copy the files accordingly.

After copying the files, the LUX-CMAKE-TOOLSET can be used in other CMake projects by simply using the find_package command. For example:

``` cmake
find_package(LUX-CMAKE-TOOLSET REQUIRED)
```

For more information on the search procedure of the find_package command, you can refer to the [CMake documentation](https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-search-procedure).

Please note that the installation steps mentioned above are just an example, and you can adjust them according to your specific requirements and target operating system.

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
find_package(lux-cmake-toolset CONFIG REQUIRED)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/add_component.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/install_project.cmake)

add_component(
    COMPONENT_NAME                  <component_name_1>
    NAMESPACE                       <namespace>    # Create an alias for this component. It will become <namespace>::<component_name_1>
    SOURCE_FILES                    <source_files>
    BUILD_TIME_EXPORT_INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME_INCLUDE_PREFIX     include
)

add_component(
    COMPONENT_NAME                  <component_name_2>
    NAMESPACE                       <namespace>
    SOURCE_FILES                    <source_files>
    BUILD_TIME_EXPORT_INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME_INCLUDE_PREFIX     include
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
