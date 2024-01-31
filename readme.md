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
The Component CMake tool is used to create a component-based project. The component is also a cmake target, so some cmake functions
like target_compile_definitions and target_include_directories are also working for the components.

With the `add_component` , `add_interface_component` and `install_components` function, you can create a component-based project. 
The project created by this toolset can be used as follows:
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
find_package(lux-cmake-toolset REQUIRED)

add_component(
    COMPONENT_NAME  component_one
    NAMESPACE       lux::cmake::toolset::test
    SOURCE_FILES    ${CMAKE_CURRENT_SOURCE_DIR}/src/one.cpp
)

# The key words BUILD_TIME_EXPORT means the directories will be automatically install
# The key words INSTALL_TIME means the relative path to the install path
component_include_directories(
    component_one
    BUILD_TIME_EXPORT
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${LUX_GENERATE_HEADER_DIR}
    INSTALL_TIME
        include
)

# If there are some dependencies between components
# You can use component_add_internal_dependencies to introduce the internal dependencies automatically
# Don't use PUBLIC_LIBRARIES
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

# when you are using find_package(<project_name> COMPONENTS <component_name_3>)
# Then <component_name_1> <component_name_2> will be imported automatically

# You can alse transit the dependencies to the project which use your library
# For example, you are using a third party library
find_library(ThirdParty REQUIRED)
component_add_transitive_commands(
    component_two
    "find_library(ThirdParty REQUIRED)"
)
# when you use find_package(<project_name> COMPONENTS <component_name_4>)
# Then "find_library(ThirdParty REQUIRED)" will be executed automatically

# It also support interface component, no source files is needed.
add_interface_component(
    COMPONENT_NAME  component_three
    NAMESPACE       lux::cmake::toolset::test
)

install_components(
    PROJECT_NAME    <project_name>
    VERSION         x.y.z
    # The VERSION and NAMESPACE is used as a prefix when you use the `find_package` function
    # like find_package(<namespace>::<project_name> x.y.z COMPONENTS <component_name_1> ...)
    NAMESPACE       <namespace>
    COMPONENTS      <component_name_1>
                    <component_name_2>
                    <component_name_3>
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

