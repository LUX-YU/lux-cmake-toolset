include_guard(GLOBAL)

# Generate a version header file from major/minor/patch components.
#
# generate_version_header(
#   VERSION             <major.minor.patch>
#   HEADER_FILE_PATH    <relative path for the generated header>
#   [PREFIX              <macro prefix, default: PROJECT>]
# )
#
# Example:
#   generate_version_header(
#       VERSION          1.2.3
#       HEADER_FILE_PATH mylib/version.h
#       PREFIX           MYLIB
#   )
# Produces macros: MYLIB_VERSION_MAJOR, MYLIB_VERSION_MINOR, MYLIB_VERSION_PATCH,
#                  MYLIB_VERSION_STRING
function(generate_version_header)
    set(_options)
    set(_one_value_arguments VERSION HEADER_FILE_PATH PREFIX)
    set(_multi_value_arguments)

    cmake_parse_arguments(
        ARGS
        "${_options}"
        "${_one_value_arguments}"
        "${_multi_value_arguments}"
        ${ARGN}
    )

    if(NOT ARGS_VERSION)
        message(FATAL_ERROR "VERSION was not specified.")
    endif()

    if(NOT ARGS_HEADER_FILE_PATH)
        message(FATAL_ERROR "HEADER_FILE_PATH was not specified.")
    endif()

    if(NOT ARGS_PREFIX)
        set(ARGS_PREFIX "PROJECT")
    endif()

    string(REPLACE "." ";" VERSION_PARTS "${ARGS_VERSION}")
    list(LENGTH VERSION_PARTS VERSION_PARTS_LENGTH)
    if(VERSION_PARTS_LENGTH LESS 3)
        message(FATAL_ERROR "VERSION must be in the format major.minor.patch")
    endif()

    list(GET VERSION_PARTS 0 VERSION_MAJOR)
    list(GET VERSION_PARTS 1 VERSION_MINOR)
    list(GET VERSION_PARTS 2 VERSION_PATCH)

    string(TOUPPER "${ARGS_PREFIX}" GUARD_PREFIX)
    set(HEADER_GUARD "_${GUARD_PREFIX}_VERSION_H_")

    set(OUTPUT_FILE "${LUX_GENERATE_HEADER_DIR}/${ARGS_HEADER_FILE_PATH}")
    set(HEADER_CONTENT "\
#ifndef ${HEADER_GUARD}
#define ${HEADER_GUARD}

#define ${ARGS_PREFIX}_VERSION_MAJOR ${VERSION_MAJOR}
#define ${ARGS_PREFIX}_VERSION_MINOR ${VERSION_MINOR}
#define ${ARGS_PREFIX}_VERSION_PATCH ${VERSION_PATCH}
#define ${ARGS_PREFIX}_VERSION_STRING \"${ARGS_VERSION}\"

#endif // ${HEADER_GUARD}
")

    file(WRITE "${OUTPUT_FILE}" "${HEADER_CONTENT}")
    message("-- Generated version header: ${OUTPUT_FILE}")
endfunction()
