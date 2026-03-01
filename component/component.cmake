include_guard(GLOBAL)

set(CMAKE_CONFIG_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share/${INSTALL_ARGS_PROJECT_NAME})

# Internal: set common properties shared by both add_component and add_interface_component.
function(__setup_component_common component_name export_name namespace)
	set_target_properties(
		${component_name}
		PROPERTIES COMPONENT_TARGET TRUE
	)

	set_target_properties(
		${component_name}
		PROPERTIES EXPORT_NAME ${export_name}
	)

	# alias
	if(namespace)
		set(ALIAS_NAME ${namespace}::${component_name})
		add_library(
			${ALIAS_NAME}
			ALIAS
			${component_name}
		)
	endif()
endfunction()

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

	__setup_component_common(
		${COMPONENT_ARGS_COMPONENT_NAME}
		${COMPONENT_ARGS_EXPORT_NAME}
		${COMPONENT_ARGS_NAMESPACE}
	)
endfunction()

function(add_component)
	set(_options 				STATIC)
	set(_one_value_arguments 	COMPONENT_NAME OUTPUT_NAME EXPORT_NAME NAMESPACE PREFIX)
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

	if(COMPONENT_ARGS_OUTPUT_NAME)
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME}
			PROPERTIES
			OUTPUT_NAME "${COMPONENT_ARGS_OUTPUT_NAME}"
		)
	endif()

	__setup_component_common(
		${COMPONENT_ARGS_COMPONENT_NAME}
		${COMPONENT_ARGS_EXPORT_NAME}
		${COMPONENT_ARGS_NAMESPACE}
	)

	# add output file prefix
	if(COMPONENT_ARGS_PREFIX)
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME}
			PROPERTIES
			OUTPUT_NAME ${COMPONENT_ARGS_PREFIX}${COMPONENT_ARGS_COMPONENT_NAME}
		)
	endif()
endfunction()
