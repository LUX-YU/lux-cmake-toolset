include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/component_properties.cmake)

#
# ─── Add Assets ───────────────────────────────────────────────────────────────
#

# ARG0      COMPONENT
# ARG1      TYPE
# ARG2...N	File/Directory Assets
function(component_add_assets)
    MATH(EXPR NUMBER "${ARGC}-2")
    list(SUBLIST ARGN 2 ${NUMBER} NEW_ASSET_LIST)

    get_target_property(ASSET_TYPES ${ARGV0} EXPORT_ASSET_TYPES)
    list(FIND ASSET_TYPES ${ARGV1} HAS_TYPE)
    if(${HAS_TYPE} EQUAL -1)
        component_append_property(${ARGV0} EXPORT_ASSET_TYPES ${ARGV1})
    endif()

    # check
    foreach(asset ${NEW_ASSET_LIST})
        if(NOT EXISTS ${asset})
            message(FATAL_ERROR "Asset doesn't exists: ${asset}")
        endif()
    endforeach()

    component_append_property(${ARGV0} EXPORT_${ARGV1}_ASSETS ${NEW_ASSET_LIST})
endfunction()

# Convenience wrapper: add cmake script assets.
# ARGV0		Component
# ARGV1...N	Cmake scripts
function(component_add_cmake_scripts)
    MATH(EXPR NUMBER "${ARGC}-1")
    list(SUBLIST ARGN 1 ${NUMBER} NEW_SCRIPT_LIST)
    component_add_assets(${ARGV0} cmake_scripts ${NEW_SCRIPT_LIST})
endfunction()

#
# ─── Get Assets ───────────────────────────────────────────────────────────────
#

# ARG0  Component
# ARG1  Type
# ARG2  OutputValue List
function(component_get_assets)
    get_target_property(IS_IMPORTED_COMPONENT ${ARGV0} IMPORTED_COMPONENT)
    if(IS_IMPORTED_COMPONENT)
        get_target_property(COMPONENT_ASSET_PREFIX ${ARGV0} IMPORTED_ASSETS_PREFIX)
        if(NOT COMPONENT_ASSET_PREFIX)
            set(${ARGV2} PARENT_SCOPE)
            return()
        endif()

        set(TYPE_ASSET_PREFIX ${COMPONENT_ASSET_PREFIX}/${ARGV1})
        file(GLOB OUTPUT ${TYPE_ASSET_PREFIX}/*)
    else()
        get_target_property(OUTPUT ${ARGV0} EXPORT_${ARGV1}_ASSETS)
    endif()

    set(${ARGV2} ${OUTPUT} PARENT_SCOPE)
endfunction()

# ARG0 Component
# ARG1 OutputValue List
function(component_get_asset_types)
    get_target_property(IS_IMPORTED_COMPONENT ${ARGV0} IMPORTED_COMPONENT)
    if(IS_IMPORTED_COMPONENT)
        get_target_property(COMPONENT_ASSET_TYPE ${ARGV0} IMPORTED_ASSET_TYPES)
    else()
        get_target_property(COMPONENT_ASSET_TYPE ${ARGV0} EXPORT_ASSET_TYPES)
    endif()

    set(${ARGV1} ${COMPONENT_ASSET_TYPE} PARENT_SCOPE)
endfunction()

# ARGV0     Component
# ARGV1     Type
# ARGV2     OutputValue
function(component_get_asset_files)
    get_target_property(IS_IMPORTED_COMPONENT ${ARGV0} IMPORTED_COMPONENT)
    if(IS_IMPORTED_COMPONENT)
        get_target_property(COMPONENT_ASSET_PREFIX ${ARGV0} IMPORTED_ASSETS_PREFIX)
        if(NOT COMPONENT_ASSET_PREFIX)
            set(${ARGV2} PARENT_SCOPE)
            return()
        endif()

        set(TYPE_ASSET_PREFIX ${COMPONENT_ASSET_PREFIX}/${ARGV1})
        file(GLOB_RECURSE OUTPUT ${TYPE_ASSET_PREFIX}/* LIST_DIRECTORIES false)
        list(REMOVE_DUPLICATES OUTPUT)
        set(${ARGV2} ${OUTPUT} PARENT_SCOPE)
    else()
        get_target_property(ASSET_LIST ${ARGV0} EXPORT_${ARGV1}_ASSETS)
        set(ASSET_FILE_LIST)
        foreach(asset ${ASSET_LIST})
            if(NOT EXISTS ${asset})
                message(FATAL_ERROR "Asset doesn't exist.")
            endif()

            if(IS_DIRECTORY ${asset})
                file(GLOB_RECURSE ASSET_FILE ${asset}/*)
            else()
                set(ASSET_FILE ${asset})
            endif()

            if(ASSET_MAP_"${ASSET_FILE}")
               continue()
            else()
                list(APPEND ASSET_FILE_LIST ${ASSET_FILE})
                set(ASSET_MAP_"${ASSET_FILE}" ${ASSET_FILE})
            endif()
        endforeach()
        set(${ARGV2} ${ASSET_FILE_LIST} PARENT_SCOPE)
    endif()
endfunction()

# Convenience wrapper: get cmake script assets.
# ARGV0		Component
# ARGV1		OutputValue
function(component_get_cmake_scripts)
    component_get_assets(${ARGV0} cmake_scripts OUTPUT)
    set(${ARGV1} ${OUTPUT} PARENT_SCOPE)
endfunction()

# ARG0      COMPONENT
# PATHS     Runtime asset directories to register under runtime_assets
function(component_register_runtime_assets)
    set(one_value_args COMPONENT)
    set(multi_value_args PATHS)
    cmake_parse_arguments(ARGS "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    if(NOT ARGS_COMPONENT)
        message(FATAL_ERROR "[component_register_runtime_assets] COMPONENT parameter is required")
    endif()
    if(NOT TARGET ${ARGS_COMPONENT})
        message(FATAL_ERROR "[component_register_runtime_assets] Unknown component target '${ARGS_COMPONENT}'")
    endif()
    if(NOT ARGS_PATHS)
        message(FATAL_ERROR "[component_register_runtime_assets] PATHS parameter is required")
    endif()

    set(_runtime_asset_paths "")
    foreach(_path IN LISTS ARGS_PATHS)
        if(NOT _path)
            continue()
        endif()
        if(NOT EXISTS "${_path}")
            file(MAKE_DIRECTORY "${_path}")
        endif()
        list(APPEND _runtime_asset_paths "${_path}")
    endforeach()

    list(REMOVE_DUPLICATES _runtime_asset_paths)
    if(NOT _runtime_asset_paths)
        message(FATAL_ERROR "[component_register_runtime_assets] No valid runtime asset paths provided")
    endif()

    component_add_assets(${ARGS_COMPONENT} runtime_assets ${_runtime_asset_paths})
endfunction()

# Generate a header exposing runtime asset root with optional env override.
#
# Required args:
#   COMPONENT <component_target>
#   OUTPUT_HEADER <path/to/header.hpp>
# Optional args:
#   ENV_VAR <env-var-name>      default: LUX_ASSET_ROOT
#   SYMBOL <header-variable>    default: asset_path
#   ROOT_PATH <explicit-root>   skip automatic root inference
function(component_generate_runtime_asset_path_header)
    set(one_value_args COMPONENT OUTPUT_HEADER ENV_VAR SYMBOL ROOT_PATH)
    cmake_parse_arguments(ARGS "" "${one_value_args}" "" ${ARGN})

    if(NOT ARGS_COMPONENT)
        message(FATAL_ERROR "[component_generate_runtime_asset_path_header] COMPONENT parameter is required")
    endif()
    if(NOT ARGS_OUTPUT_HEADER)
        message(FATAL_ERROR "[component_generate_runtime_asset_path_header] OUTPUT_HEADER parameter is required")
    endif()
    if(NOT TARGET ${ARGS_COMPONENT})
        message(FATAL_ERROR "[component_generate_runtime_asset_path_header] Unknown component target '${ARGS_COMPONENT}'")
    endif()

    if(NOT ARGS_ENV_VAR)
        set(ARGS_ENV_VAR "LUX_ASSET_ROOT")
    endif()
    if(NOT ARGS_SYMBOL)
        set(ARGS_SYMBOL "asset_path")
    endif()

    if(ARGS_ROOT_PATH)
        if(IS_ABSOLUTE "${ARGS_ROOT_PATH}")
            set(_runtime_root "${ARGS_ROOT_PATH}")
        else()
            get_filename_component(
                _runtime_root
                "${ARGS_ROOT_PATH}"
                ABSOLUTE
                BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
        endif()
    else()
        get_target_property(_is_imported_component ${ARGS_COMPONENT} IMPORTED_COMPONENT)
        if(_is_imported_component)
            get_target_property(_assets_prefix ${ARGS_COMPONENT} IMPORTED_ASSETS_PREFIX)
            if(NOT _assets_prefix)
                message(FATAL_ERROR
                    "[component_generate_runtime_asset_path_header] Imported component '${ARGS_COMPONENT}' has no IMPORTED_ASSETS_PREFIX")
            endif()
            set(_runtime_root "${_assets_prefix}/runtime_assets")
        else()
            component_get_assets(${ARGS_COMPONENT} runtime_assets _runtime_entries)
            if(NOT _runtime_entries)
                message(FATAL_ERROR
                    "[component_generate_runtime_asset_path_header] Component '${ARGS_COMPONENT}' has no runtime_assets entries")
            endif()

            set(_runtime_root "")
            foreach(_entry IN LISTS _runtime_entries)
                if(IS_DIRECTORY "${_entry}")
                    get_filename_component(_candidate_root "${_entry}" DIRECTORY)
                else()
                    get_filename_component(_entry_dir "${_entry}" DIRECTORY)
                    get_filename_component(_candidate_root "${_entry_dir}" DIRECTORY)
                endif()

                if(NOT _runtime_root)
                    set(_runtime_root "${_candidate_root}")
                elseif(NOT _runtime_root STREQUAL _candidate_root)
                    message(FATAL_ERROR
                        "[component_generate_runtime_asset_path_header] Could not infer a single runtime root from runtime_assets entries. Provide ROOT_PATH explicitly.")
                endif()
            endforeach()
        endif()
    endif()

    if(IS_ABSOLUTE "${ARGS_OUTPUT_HEADER}")
        set(_output_header "${ARGS_OUTPUT_HEADER}")
    else()
        get_filename_component(
            _output_header
            "${ARGS_OUTPUT_HEADER}"
            ABSOLUTE
            BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    get_filename_component(_output_dir "${_output_header}" DIRECTORY)
    if(NOT EXISTS "${_output_dir}")
        file(MAKE_DIRECTORY "${_output_dir}")
    endif()

    file(TO_CMAKE_PATH "${_runtime_root}" _runtime_root_norm)
    string(REPLACE "\\" "\\\\" _runtime_root_escaped "${_runtime_root_norm}")
    string(REPLACE "\"" "\\\"" _runtime_root_escaped "${_runtime_root_escaped}")

    file(WRITE "${_output_header}" "#pragma once\n\n")
    file(APPEND "${_output_header}" "#include <cstdlib>\n\n")
    file(APPEND "${_output_header}" "static inline const char* lux_resolve_asset_path()\n")
    file(APPEND "${_output_header}" "{\n")
    file(APPEND "${_output_header}" "    const char* override_path = std::getenv(\"${ARGS_ENV_VAR}\");\n")
    file(APPEND "${_output_header}" "    if (override_path && override_path[0] != '\\0')\n")
    file(APPEND "${_output_header}" "        return override_path;\n")
    file(APPEND "${_output_header}" "    return \"${_runtime_root_escaped}\";\n")
    file(APPEND "${_output_header}" "}\n\n")
    file(APPEND "${_output_header}" "static inline const char* ${ARGS_SYMBOL} = lux_resolve_asset_path();\n")
endfunction()
