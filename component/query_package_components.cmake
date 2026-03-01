include_guard(GLOBAL)

# Internal: Collect all prefix-based search directories for a given package,
# mirroring the search order used by CMake's find_package(CONFIG).
# Result is a deduplicated list of candidate directories.
function(__collect_package_search_dirs package_name output_var)
    set(_search_paths)

    # Build the list of sub-directories to probe under each prefix.
    # CMake's find_package(CONFIG) searches these under every prefix:
    #   share/<name>/                               (lux-cmake-toolset default)
    #   lib/<arch>/cmake/<name>/                    (Debian multi-arch)
    #   lib/cmake/<name>/                           (common Linux convention)
    #   lib64/cmake/<name>/                         (64-bit Linux distros)
    set(_subdirs "share/${package_name}")
    if(CMAKE_LIBRARY_ARCHITECTURE)
        list(APPEND _subdirs "lib/${CMAKE_LIBRARY_ARCHITECTURE}/cmake/${package_name}")
    endif()
    list(APPEND _subdirs
        "lib/cmake/${package_name}"
        "lib64/cmake/${package_name}"
    )

    # 1. <PackageName>_DIR (highest priority, set by user or previous find_package)
    if(DEFINED ${package_name}_DIR AND EXISTS "${${package_name}_DIR}")
        list(APPEND _search_paths "${${package_name}_DIR}")
    endif()

    # Helper macro: expand a single prefix into all sub-directory variants
    macro(__append_prefix_subdirs prefix)
        foreach(_sub ${_subdirs})
            list(APPEND _search_paths "${prefix}/${_sub}")
        endforeach()
    endmacro()

    # 2. <PackageName>_ROOT CMake variable (CMake 3.12+)
    if(DEFINED ${package_name}_ROOT)
        foreach(root ${${package_name}_ROOT})
            __append_prefix_subdirs(${root})
        endforeach()
    endif()

    # 3. <PackageName>_ROOT environment variable (CMake 3.12+)
    if(DEFINED ENV{${package_name}_ROOT})
        set(_env_root "$ENV{${package_name}_ROOT}")
        string(REPLACE "\\" "/" _env_root "${_env_root}")
        foreach(root ${_env_root})
            __append_prefix_subdirs(${root})
        endforeach()
    endif()

    # 4. CMAKE_PREFIX_PATH CMake variable
    foreach(prefix ${CMAKE_PREFIX_PATH})
        __append_prefix_subdirs(${prefix})
    endforeach()

    # 5. CMAKE_PREFIX_PATH environment variable
    if(DEFINED ENV{CMAKE_PREFIX_PATH})
        set(_env_prefix "$ENV{CMAKE_PREFIX_PATH}")
        string(REPLACE "\\" "/" _env_prefix "${_env_prefix}")
        foreach(prefix ${_env_prefix})
            __append_prefix_subdirs(${prefix})
        endforeach()
    endif()

    # 6. CMAKE_INSTALL_PREFIX
    if(CMAKE_INSTALL_PREFIX)
        __append_prefix_subdirs(${CMAKE_INSTALL_PREFIX})
    endif()

    # 7. CMAKE_SYSTEM_PREFIX_PATH (system-level installations: /usr, /usr/local, etc.)
    foreach(prefix ${CMAKE_SYSTEM_PREFIX_PATH})
        __append_prefix_subdirs(${prefix})
    endforeach()

    # Deduplicate while preserving order
    list(REMOVE_DUPLICATES _search_paths)
    set(${output_var} "${_search_paths}" PARENT_SCOPE)
endfunction()


# Internal: Locate the available-components file for a given package.
# Searches paths in the same priority order as CMake's find_package(CONFIG).
# Sets <output_var> to the full path if found, or empty string otherwise.
function(__find_package_components_file package_name output_var)
    set(COMPONENTS_FILE_NAME "${package_name}-available-components.cmake")
    __collect_package_search_dirs(${package_name} _search_paths)

    foreach(search_path ${_search_paths})
        set(_candidate "${search_path}/${COMPONENTS_FILE_NAME}")
        if(EXISTS "${_candidate}")
            set(${output_var} "${_candidate}" PARENT_SCOPE)
            return()
        endif()
    endforeach()

    set(${output_var} "" PARENT_SCOPE)
endfunction()


# Query all available components of an installed package.
#
# Usage:
#   query_package_components(
#       PACKAGE_NAME  imgui
#       RESULT        imgui_components    # output variable name
#       [REQUIRED]                        # optional: FATAL_ERROR if package not found
#   )
#
# After the call, ${imgui_components} contains a list like "core;directx11;vulkan".
function(query_package_components)
    set(_options         REQUIRED)
    set(_one_value_args  PACKAGE_NAME RESULT)
    set(_multi_value_args)

    cmake_parse_arguments(
        QUERY_ARGS
        "${_options}"
        "${_one_value_args}"
        "${_multi_value_args}"
        ${ARGN}
    )

    if(NOT QUERY_ARGS_PACKAGE_NAME)
        message(FATAL_ERROR "query_package_components: PACKAGE_NAME not specified.")
    endif()

    if(NOT QUERY_ARGS_RESULT)
        message(FATAL_ERROR "query_package_components: RESULT variable name not specified.")
    endif()

    __find_package_components_file(${QUERY_ARGS_PACKAGE_NAME} _components_file)

    if(NOT _components_file)
        if(QUERY_ARGS_REQUIRED)
            message(FATAL_ERROR
                "query_package_components: Could not find available-components file for "
                "package '${QUERY_ARGS_PACKAGE_NAME}'. "
                "Make sure the package is installed with lux-cmake-toolset and "
                "CMAKE_PREFIX_PATH is set correctly."
            )
        else()
            message(WARNING
                "query_package_components: Package '${QUERY_ARGS_PACKAGE_NAME}' does not appear "
                "to be built with lux-cmake-toolset (no available-components file found). "
                "Component queries for this package will return empty results."
            )
        endif()
        set(${QUERY_ARGS_RESULT} "" PARENT_SCOPE)
        return()
    endif()

    # Include the file to get <package>_AVAILABLE_COMPONENTS
    include("${_components_file}")

    set(${QUERY_ARGS_RESULT} "${${QUERY_ARGS_PACKAGE_NAME}_AVAILABLE_COMPONENTS}" PARENT_SCOPE)
endfunction()


# Check whether an installed package provides a specific component.
#
# Usage:
#   query_package_has_component(
#       PACKAGE_NAME  imgui
#       COMPONENT     directx11
#       RESULT        has_dx11           # output variable: TRUE or FALSE
#       [REQUIRED]                       # optional: FATAL_ERROR if package not found
#   )
function(query_package_has_component)
    set(_options         REQUIRED)
    set(_one_value_args  PACKAGE_NAME COMPONENT RESULT)
    set(_multi_value_args)

    cmake_parse_arguments(
        QUERY_ARGS
        "${_options}"
        "${_one_value_args}"
        "${_multi_value_args}"
        ${ARGN}
    )

    if(NOT QUERY_ARGS_PACKAGE_NAME)
        message(FATAL_ERROR "query_package_has_component: PACKAGE_NAME not specified.")
    endif()

    if(NOT QUERY_ARGS_COMPONENT)
        message(FATAL_ERROR "query_package_has_component: COMPONENT not specified.")
    endif()

    if(NOT QUERY_ARGS_RESULT)
        message(FATAL_ERROR "query_package_has_component: RESULT variable name not specified.")
    endif()

    # Reuse query_package_components to get the list
    if(QUERY_ARGS_REQUIRED)
        query_package_components(
            PACKAGE_NAME ${QUERY_ARGS_PACKAGE_NAME}
            RESULT _all_components
            REQUIRED
        )
    else()
        query_package_components(
            PACKAGE_NAME ${QUERY_ARGS_PACKAGE_NAME}
            RESULT _all_components
        )
    endif()

    if(_all_components)
        list(FIND _all_components "${QUERY_ARGS_COMPONENT}" _index)
        if(_index GREATER_EQUAL 0)
            set(${QUERY_ARGS_RESULT} TRUE PARENT_SCOPE)
        else()
            set(${QUERY_ARGS_RESULT} FALSE PARENT_SCOPE)
        endif()
    else()
        set(${QUERY_ARGS_RESULT} FALSE PARENT_SCOPE)
    endif()
endfunction()
