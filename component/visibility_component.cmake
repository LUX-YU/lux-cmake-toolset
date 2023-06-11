# INCLUDE GUARD
if(_VISIBILITY_COMPONENT_INCLUDED_)
	return()
endif()
set(_VISIBILITY_COMPONENT_INCLUDED_ TRUE)

include(${LUX_CMAKE_COMMON_TOOLSET_DIR}/common/configure_visibility.cmake)
include(${LUX_CMAKE_COMPONENT_TOOLSET_DIR}/add_component.cmake)

# GENERATE_FILE_PATH  relative to the ${CMAKE_CURRENT_BINARY_DIR}/gen/include
function(add_visibility_component)
    set(_options)
    set(_one_value_arguments COMPONENT_NAME ENABLE_MACRO_NAME PUBLIC_MACRO_NAME GENERATE_FILE_PATH NAMESPACE)
    set(_multi_value_arguments)

    cmake_parse_arguments(
        COMPONENT_ARGS
        "${_options}"
        "${_one_value_arguments}"
        "${_multi_value_arguments}"
        ${ARGN}
    )

    set(GENERATE_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR}/gen/include)

    configure_visibility_header(
        PUBLIC_MACRO_NAME   ${CONFIGURE_ARGS_PUBLIC_MACRO_NAME}
        ENABLE_MACRO_NAME   ${CONFIGURE_ARGS_ENABLE_MACRO_NAME}
        EXPORT_PATH         ${GENERATE_HEADER_DIR}/${CONFIGURE_ARGS_GENERATE_FILE_PATH}
    )

    add_interface_component(
        COMPONENT_NAME                  ${COMPONENT_ARGS_COMPONENT_NAME}
        BUILD_TIME_EXPORT_INCLUDE_DIRS  ${GENERATE_HEADER_DIR}
        NAMESPACE                       ${NAMESPACE}
    )

endfunction()