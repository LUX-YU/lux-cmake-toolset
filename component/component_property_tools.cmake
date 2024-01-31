if(_COMPONENT_ADD_INDEX_PROPERTY_INCLUDED_)
	return()
endif()
set(_COMPONENT_ADD_INDEX_PROPERTY_INCLUDED_ TRUE)

# ARGV0 	Component
# ARGV1		Property number name
# ARGV2 	Property name 	prefix
#			The real property name will be <prefix>_<index>
# ARGV3...N	Properties
function(component_add_index_properties)
	MATH(EXPR NUMBER "${ARGC}-3")
	list(SUBLIST ARGN 3 ${NUMBER} PROPERTY_LIST)

	list(LENGTH PROPERTY_LIST NEW_PROPERTIES_NUM)
	get_target_property(CURRENT_PROPERTIES_NUM ${ARGV0} ${ARGV1})

	if(CURRENT_PROPERTIES_NUM)
		MATH(EXPR PROPERTIES_NUM "${CURRENT_PROPERTIES_NUM}+${NEW_PROPERTIES_NUM}")
	else()
		SET(CURRENT_PROPERTIES_NUM 0)
		SET(PROPERTIES_NUM ${NEW_PROPERTIES_NUM})
	endif()

	set_target_properties(
		${ARGV0} 
		PROPERTIES ${ARGV1} "${PROPERTIES_NUM}"
	)

	MATH(EXPR LOOP_COUNT "${NEW_PROPERTIES_NUM}-1")
	foreach(_I RANGE ${LOOP_COUNT})
		list(GET PROPERTY_LIST ${_I} property)
		MATH(EXPR INDEX "${_I}+${CURRENT_PROPERTIES_NUM}")
		set_target_properties(
			${ARGV0} 
			PROPERTIES ${ARGV2}_${INDEX} ${property}
		)
	endforeach()
endfunction()

# ARGV0 	Component
# ARGV1		Property name
# ARGV2...N	New properties
function(component_append_property)
	MATH(EXPR NUMBER "${ARGC}-2")
	list(SUBLIST ARGN 2 ${NUMBER} NEW_PROPERTIES)
	get_target_property(PROPERTIES ${ARGV0} ${ARGV1})
	
	if(NOT PROPERTIES)
		set_target_properties(
			${ARGV0}
			PROPERTIES ${ARGV1} "${NEW_PROPERTIES}"
		)
	else()
		list(APPEND PROPERTIES ${NEW_PROPERTIES})
		set_target_properties(
			${ARGV0}
			PROPERTIES ${ARGV1} "${PROPERTIES}"
		)
	endif()
endfunction()

#ARGV0 	Component
#KEY1	PROPERTIES
function(component_add_export_properties)
	set(_options)
	set(_one_value_arguments)
	set(_multi_value_arguments PROPERTIES)

	cmake_parse_arguments(
		ARGS
		"${_options}"
		"${_one_value_arguments}"
		"${_multi_value_arguments}"
		${ARGN}
	)

	if(NOT ARGS_PROPERTIES)
		message(FATAL_ERROR "Key word `PROPERTIES` didn't specified.")
	endif()

	list(LENGTH ARGS_PROPERTIES PROPERTIES_NUM)
	MATH(EXPR IS_NUM_ODD  "${PROPERTIES_NUM} % 2")
	MATH(EXPR ITER_NUMBER "${PROPERTIES_NUM} - 1")
	if(IS_NUM_ODD)
		message(FATAL_ERROR "Wrong number of properties.")
	endif()

	set(PROPERTIES_NAME_INDICE)
	set(PROPERTOES_VALUE_INDICE)
	foreach(iter RANGE 0 ${ITER_NUMBER} 2)
		math(EXPR next_iter "${iter} + 1")
		list(APPEND PROPERTIES_NAME_INDICE ${iter})
		list(APPEND PROPERTOES_VALUE_INDICE ${next_iter})
	endforeach()
	
	set_target_properties(
		${ARGV0}
		PROPERTIES
		${ARGS_PROPERTIES}
	)

	list(GET ARGS_PROPERTIES ${PROPERTIES_NAME_INDICE}  PROPERTIES_NAMES)
	list(GET ARGS_PROPERTIES ${PROPERTOES_VALUE_INDICE} PROPERTIES_VALUES)
	component_append_property(${ARGV0} EXPORT_PROPERTIES_NAMES 	${PROPERTIES_NAMES})
	component_append_property(${ARGV0} EXPORT_PROPERTIES_VALUES ${PROPERTIES_VALUES})
	component_append_property(${ARGV0} EXPORT_PROPERTIES 		${ARGS_PROPERTIES})
endfunction()
