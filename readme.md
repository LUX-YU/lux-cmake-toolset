# LUX-CMAKE-TOOLSET

The goal of LUX-CMAKE-TOOLSET is to make creating a CMake-based project more convenient.

## Installation
To install the LUX-CMAKE-TOOLSET, you can follow these steps:

Copy all the files of this project to a location accessible by CMake's find_package command. You can check the
search path of [CMAKE_PREFIX_PATH](https://cmake.org/cmake/help/latest/variable/CMAKE_PREFIX_PATH.html)

For example, on Linux, you can copy the files to the directory /usr/share/lux-cmake-toolset/:

``` bash
cd /path/to/project
sudo cp -r ./* /usr/share/lux-cmake-toolset/
```

Or, use cmake
``` bash
mkdir build && cd build
cmake .. # or a special directory by passing -DCMAKE_INSTALL_PREFIX=/path/to/xxx
cmake --build . --target INSTALL
```

Then the LUX-CMAKE-TOOLSET can be used in other CMake projects by simply using the find_package command. For example:

``` cmake
find_package(LUX-CMAKE-TOOLSET REQUIRED)
```

For more information on the search procedure of the find_package command, you can refer to the 
[CMake documentation](https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-search-procedure).

Or just copy this project to your project, and include the lux-cmake-toolset-config.cmake

## Component Tool Set
The Component CMake tool is used to create a component-based project.

With the `add_component` , `add_interface_component` and `install_projects` function, you can create a component-based project. 
The project can be used as follows:
``` cmake
find_package(<TARGET_PROJECT_NAME> CONFIG REQUIRED COMPONENTS <COMPONENT_NAME>)

target_link_libraries(
    <YOUR_PROJECT>
    PUBLIC
    <TARGET_PROJECT_NAMESPACE>::<COMPONENT_NAME>
)
```

## Useage
### Build a component based library

``` cmake
find_package(lux-cmake-toolset CONFIG REQUIRED)

add_component(
    COMPONENT_NAME                  <component_name_1>
    # Create an alias for this component. Then <namespace>::<component_name_1> can be used in your project
    # Alias name is not available in other project which use your project
    NAMESPACE                       <namespace>
    SOURCE_FILES                    <source_files>
    # Must be a absolute path, you can check $<BUILD_INTERFACE> for reson
    BUILD_TIME_EXPORT_INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/include
    # Must be a relative path, you can check $<INSTALL_INTERFACE> for reson, PS: relative to your install path
    INSTALL_TIME_INCLUDE_PREFIX     include
    PRIVATE_INCLUDE_DIRS            pinclude
    PUBLIC_LIBRARIES                other_lib
)

add_component(
    COMPONENT_NAME                  <component_name_2>
    NAMESPACE                       <namespace>
    SOURCE_FILES                    <source_files>
    BUILD_TIME_EXPORT_INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME_INCLUDE_PREFIX     include
    PUBLIC_DEFINITIONS              SOME_MACRO      # public compile time definition
    PRIVATE_DEFINITIONS             SOME_MACRO_2    # private compile time definition
)

# If there are some dependencies between components
# You can use INTERNAL_DEPENDENCIES to introduce the internal dependencies automatically
# Don't use PUBLIC_LIBRARIES
add_component(
    COMPONENT_NAME                  <component_name_3>
    NAMESPACE                       <namespace>
    SOURCE_FILES                    <source_files>
    BUILD_TIME_EXPORT_INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME_INCLUDE_PREFIX     include
    INTERNAL_DEPENDENCIES           <component_name_1>
                                    <component_name_2>
)
# when you use find_package(<project_name> COMPONENTS <component_name_3>)
# Then <component_name_1> <component_name_2> will be imported automatically

# You can alse transit the dependencies to the project which use your library
# For example, you are using a third party library
find_library(ThirdParty REQUIRED)
add_component(
    COMPONENT_NAME                  <component_name_4>
    NAMESPACE                       <namespace>
    SOURCE_FILES                    <source_files>
    BUILD_TIME_EXPORT_INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME_INCLUDE_PREFIX     include
    PRIVATE_INCLUDE_DIRS            pinclude
    PUBLIC_LIBRARIES                ThirdParty::ThirdParty
    TRANSITIVE_PACKAGES_COMMANDS    "find_library(ThirdParty REQUIRED)"
)
# when you use find_package(<project_name> COMPONENTS <component_name_4>)
# Then "find_library(ThirdParty REQUIRED)" will be executed automatically

# It also support interface component, no source files needed
# But some Argument not support for it, like:
# PRIVATE_INCLUDE_DIRS
# PRIVATE_DEFINITIONS
add_interface_component(
    COMPONENT_NAME                  <component_name_5>
    NAMESPACE                       <namespace>
    BUILD_TIME_EXPORT_INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/include
    INSTALL_TIME_INCLUDE_PREFIX     include
)

install_projects(
    PROJECT_NAME    <project_name>
    VERSION         x.y.z
    # The VERSION and NAMESPACE is used as a prefix when you use the `find_package` function
    # like find_package(<namespace>::<project_name> x.y.z COMPONENTS <component_name_1> ...)
    NAMESPACE       <namespace>
    COMPONENTS      <component_name_1>
                    <component_name_2>
                    <component_name_3>
                    <component_name_4>
                    <component_name_5>
)
```

### Generate visibility control header for library
``` cmake
    generate_visibility_header(
        ENABLE_MACRO_NAME   LUX_LIBRARY
        PUBLIC_MACRO_NAME   LUX_PUBLIC
        GENERATE_FILE_PATH  path/to/visibility.h
    )

    target_include_directories(
        your_lib
        PUBLIC
        ${LUX_GENERATE_HEADER_DIR}
    )

    target_compile_definitions(
		your_lib
		PRIVATE
		LUX_LIBRARY
	)
```

In your cpp code:

``` cpp
    #include <path/to/visibility.h>

    class MyClass
    {
    public:
        LUX_PUBLIC void func();

    private:
        void foo();
    };

    class LUX_PUBLIC MyClass2
    {
    public:
        void func();

        void bar();

    private:
        void foo();
    }
```

