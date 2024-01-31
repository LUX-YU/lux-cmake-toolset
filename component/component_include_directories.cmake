# INCLUDE GUARD
if(_COMPONENT_INCLUDE_DIRECTORIES_INCLUDED_)
	return()
endif()
set(_COMPONENT_INCLUDE_DIRECTORIES_INCLUDED_ TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/component_property_tools.cmake)

# handle build time shared include directories
function(__component_build_time_shared_include_directories)
	MATH(EXPR NUMBER "${ARGC}-1")
	list(SUBLIST ARGN 1 ${NUMBER} INCLUDE_DIR_LIST)
	get_target_property(IS_INTERFACE ${ARGV0} INTERFACE_TARGET)
	if(IS_INTERFACE)
		target_include_directories(
			${ARGV0} 
			INTERFACE
			"$<BUILD_INTERFACE:${INCLUDE_DIR_LIST}>"
		)
	else()
		target_include_directories(
			${ARGV0} 
			PUBLIC
			"$<BUILD_INTERFACE:${INCLUDE_DIR_LIST}>"
		)
	endif()

	component_append_property(${ARGV0} SHARED_INCLUDE_DIRS ${INCLUDE_DIR_LIST})
endfunction()

# handle build time export include directories
function(__component_build_time_export_include_directories)
	MATH(EXPR NUMBER "${ARGC}-1")
	list(SUBLIST ARGN 1 ${NUMBER} INCLUDE_DIR_LIST)
	get_target_property(IS_INTERFACE ${ARGV0} INTERFACE_TARGET)
	if(IS_INTERFACE)
		target_include_directories(
			${ARGV0} 
			INTERFACE
			"$<BUILD_INTERFACE:${INCLUDE_DIR_LIST}>"
		)
	else()
		target_include_directories(
			${ARGV0} 
			PUBLIC
			"$<BUILD_INTERFACE:${INCLUDE_DIR_LIST}>"
		)
	endif()

	component_append_property(${ARGV0} EXPORT_INCLUDE_DIRS ${INCLUDE_DIR_LIST})
endfunction()

# handle install time include 
function(__component_install_time_include_directories)
	MATH(EXPR NUMBER "${ARGC}-1")
	list(SUBLIST ARGN 1 ${NUMBER} INCLUDE_DIR_LIST)
	get_target_property(IS_INTERFACE ${ARGV0} INTERFACE_TARGET)
	if(IS_INTERFACE)
		target_include_directories(
			${ARGV0} 
			INTERFACE
			"$<INSTALL_INTERFACE:${INCLUDE_DIR_LIST}>"
		)
	else()
		target_include_directories(
			${ARGV0} 
			PUBLIC
			"$<INSTALL_INTERFACE:${INCLUDE_DIR_LIST}>"
		)
	endif()

	component_append_property(${ARGV0} INSTALL_INCLUDE_DIRS ${INCLUDE_DIR_LIST})
endfunction()

function(__component_private_include_directories)
	get_target_property(IS_INTERFACE ${ARGV0} INTERFACE_TARGET)
	if(IS_INTERFACE)
		message(FATAL_ERROR "${ARGV0} is a interface component, private include directories are forbidden.")
	endif()

	MATH(EXPR NUMBER "${ARGC}-1")
	list(SUBLIST ARGN 1 ${NUMBER} INCLUDE_DIR_LIST)

	target_include_directories(
		${ARGV0}
		PRIVATE
		${INCLUDE_DIR_LIST}
	)

	component_append_property(${ARGV0} PRIVATE_INCLUDE_DIRS ${INCLUDE_DIR_LIST})
endfunction()

# ARG0 COMPONENT
# ARG1 TYPE
#   BUILD_TIME_EXPORT   Abolute  PATH
#   BUILD_TIME_SHARED   Abolute  PATH
#   INSTALL_TIME        Relative PATH
# 	PRIVATE				Abolute/Relative PATH
# ARG2...N				Include
function(component_include_directories)
	get_target_property(IS_COMPONENT ${ARGV0} COMPONENT_TARGET)
	if(NOT IS_COMPONENT)
		message(FATAL_ERROR "${ARGV0} is not a component.")
	endif()

	set(_options)
    set(_one_value_arguments)
    set(_multi_value_arguments 
		BUILD_TIME_EXPORT 
		BUILD_TIME_SHARED 
		INSTALL_TIME 
		PRIVATE
	)

    cmake_parse_arguments(
		ARGS
		"${_options}"
		"${_one_value_arguments}"
		"${_multi_value_arguments}"
		${ARGN}
	)
		
	if(ARGS_BUILD_TIME_EXPORT)
		__component_build_time_export_include_directories(${ARGV0} ${ARGS_BUILD_TIME_EXPORT})
	endif()

	if(ARGS_BUILD_TIME_SHARED)
		__component_build_time_shared_include_directories(${ARGV0} ${ARGS_BUILD_TIME_SHARED})
	endif()

	if(ARGS_INSTALL_TIME)
		__component_install_time_include_directories(${ARGV0} ${ARGS_INSTALL_TIME})
	endif()
	
	if(ARGS_PRIVATE)
		__component_private_include_directories(${ARGV0} ${ARGS_PRIVATE})
	endif()
endfunction()
