# INCLUDE GUARD
if(_ADD_TOOL_MODULE_INCLUDED_)
	return()
endif()
set(_ADD_TOOL_MODULE_INCLUDED_ TRUE)

set(CMAKE_CONFIG_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share/${INSTALL_ARGS_PROJECT_NAME})

function(add_interface_component)
	set(_options)
	set(_one_value_arguments COMPONENT_NAME EXPORT_NAME NAMESPACE)
	set(_multi_value_arguments)

	cmake_parse_arguments(
		COMPONENT_ARGS
		"${_options}"
		"${_one_value_arguments}"
		"${_multi_value_arguments}"
		${ARGN}
	)
	# check component name
	if(NOT COMPONENT_ARGS_COMPONENT_NAME)
		message(FATAL_ERROR "Component name not specified.")
	endif()

	if(NOT COMPONENT_ARGS_EXPORT_NAME)
		set(COMPONENT_ARGS_EXPORT_NAME ${COMPONENT_ARGS_COMPONENT_NAME})
	endif()

	add_library(
		${COMPONENT_ARGS_COMPONENT_NAME}
		INTERFACE
	)

	set_target_properties(
		${COMPONENT_ARGS_COMPONENT_NAME}
		PROPERTIES INTERFACE_TARGET TRUE
	)

	set_target_properties(
		${COMPONENT_ARGS_COMPONENT_NAME}
		PROPERTIES COMPONENT_TARGET TRUE
	)

	set_target_properties(
        ${COMPONENT_ARGS_COMPONENT_NAME}
        PROPERTIES EXPORT_NAME ${COMPONENT_ARGS_EXPORT_NAME}
    )

	# alias
	if(COMPONENT_ARGS_NAMESPACE)
	    set(ALIAS_NAME ${COMPONENT_ARGS_NAMESPACE}::${COMPONENT_ARGS_COMPONENT_NAME})
	    add_library(
	    	${ALIAS_NAME}
	    	ALIAS 
	    	${COMPONENT_ARGS_COMPONENT_NAME}
	    )
    endif()
endfunction()

function(add_component)
	set(_options 				STATIC)
	set(_one_value_arguments 	COMPONENT_NAME EXPORT_NAME NAMESPACE PREFIX)
	set(_multi_value_arguments 	SOURCE_FILES)

	cmake_parse_arguments(
		COMPONENT_ARGS
		"${_options}"
		"${_one_value_arguments}"
		"${_multi_value_arguments}"
		${ARGN}
	)
	
	# check component name
	if(NOT COMPONENT_ARGS_COMPONENT_NAME)
		message(FATAL_ERROR "Component name not specified.")
	endif()

	if(NOT COMPONENT_ARGS_EXPORT_NAME)
		set(COMPONENT_ARGS_EXPORT_NAME ${COMPONENT_ARGS_COMPONENT_NAME})
	endif()

	# no source files
	if(NOT COMPONENT_ARGS_SOURCE_FILES) # don't have any source file
		message(FATAL_ERROR "Source files didn't detected, use add_interface_component instead.")
	endif()

	if(COMPONENT_ARGS_STATIC)
		set(LIBRARY_TYPE	STATIC)
	else()
		set(LIBRARY_TYPE	SHARED)
	endif()

	add_library(
		${COMPONENT_ARGS_COMPONENT_NAME}
		${LIBRARY_TYPE}
		${COMPONENT_ARGS_SOURCE_FILES}
	)

	set_target_properties(
		${COMPONENT_ARGS_COMPONENT_NAME}
		PROPERTIES COMPONENT_TARGET TRUE
	)

	set_target_properties(
        ${COMPONENT_ARGS_COMPONENT_NAME}
        PROPERTIES EXPORT_NAME ${COMPONENT_ARGS_EXPORT_NAME}
    )

	# alias
    if(COMPONENT_ARGS_NAMESPACE)
	    set(ALIAS_NAME ${COMPONENT_ARGS_NAMESPACE}::${COMPONENT_ARGS_COMPONENT_NAME})
	    add_library(
	    	${ALIAS_NAME}
	    	ALIAS 
	    	${COMPONENT_ARGS_COMPONENT_NAME}
	    )
    endif()

    # add output file prefix
    if(COMPONENT_ARGS_PREFIX)
	    set_target_properties(
	    	${COMPONENT_ARGS_COMPONENT_NAME}
	    	PROPERTIES 
	    	OUTPUT_NAME ${COMPONENT_ARGS_PREFIX}${COMPONENT_ARGS_COMPONENT_NAME}
	    )
    endif()
endfunction()
