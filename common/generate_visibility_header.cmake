if(_VISIBILITY_CONFIG_INCLUDED_)
	return()
endif()
set(_VISIBILITY_CONFIG_INCLUDED_ TRUE)

set(LUX_GENERATE_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR}/gen/include)

function(generate_visibility_header)
    set(_options)
    set(_one_value_arguments 
        DISABLE_DLL_MACRO_NAME 
        ENABLE_MACRO_NAME 
        PUBLIC_MACRO_NAME 
        GENERATE_FILE_PATH
    )
    set(_multi_value_arguments)

    cmake_parse_arguments(
        CONFIGURE_ARGS
        "${_options}"
        "${_one_value_arguments}"
        "${_multi_value_arguments}"
        ${ARGN}
    )

    if(NOT CONFIGURE_ARGS_ENABLE_MACRO_NAME)
        message(FATAL_ERROR "ENABLE_MACRO_NAME was not specified.")
    endif()

    if(NOT CONFIGURE_ARGS_PUBLIC_MACRO_NAME)
        message(FATAL_ERROR "PUBLIC_MACRO_NAME was not specified.")
    endif()

    if(CONFIGURE_ARGS_DISABLE_DLL_MACRO_NAME)
        set(LUX_LIBRARY_DISABLE_NAME_START "#if !defined ${CONFIGURE_ARGS_DISABLE_DLL_MACRO_NAME}")
        set(LUX_LIBRARY_DISABLE_NAME_END   "#else\n\t#define ${CONFIGURE_ARGS_PUBLIC_MACRO_NAME}\n#endif")
    else()
        set(LUX_LIBRARY_DISABLE_NAME_START)
        set(LUX_LIBRARY_DISABLE_NAME_END)
    endif()

    if(NOT CONFIGURE_ARGS_GENERATE_FILE_PATH)
        message(FATAL_ERROR "GENERATE_FILE_PATH was not specified.")
    endif()

    set(LUX_LIBRARY_ENABLE_MACRO        ${CONFIGURE_ARGS_ENABLE_MACRO_NAME})
    set(LUX_LIBRARY_PUBLIC_MACRO_NAME   ${CONFIGURE_ARGS_PUBLIC_MACRO_NAME})

    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/visibility_control.h.in
        ${LUX_GENERATE_HEADER_DIR}/${CONFIGURE_ARGS_GENERATE_FILE_PATH}
    )

endfunction()
