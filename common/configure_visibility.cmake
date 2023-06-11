if(_VISIBILITY_CONFIG_INCLUDED_)
	return()
endif()
set(_VISIBILITY_CONFIG_INCLUDED_ TRUE)

function(configure_visibility_header)
    set(_options)
    set(_one_value_arguments ENABLE_MACRO_NAME PUBLIC_MACRO_NAME EXPORT_PATH)
    set(_multi_value_arguments)

    cmake_parse_arguments(
        CONFIGURE_ARGS
        "${_options}"
        "${_one_value_arguments}"
        "${_multi_value_arguments}"
        ${ARGN}
    )

    set(LUX_LIBRARY_ENABLE_MACRO        ${CONFIGURE_ARGS_ENABLE_MACRO_NAME})
    set(LUX_LIBRARY_PUBLIC_MACRO_NAME   ${CONFIGURE_ARGS_PUBLIC_MACRO_NAME})

    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/visibility_control.h.in
        ${CONFIGURE_ARGS_EXPORT_PATH}
    )

endfunction()
