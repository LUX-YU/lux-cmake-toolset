include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/component_properties.cmake)

# Generic internal helper for setting include directories on a component.
#   component       - target name
#   visibility      - PUBLIC or PRIVATE
#   generator_expr  - BUILD, INSTALL, or NONE
#   property_name   - property to record (e.g. EXPORT_INCLUDE_DIRS)
#   ARGN            - directory list
function(__component_set_include_directories component visibility generator_expr property_name)
	set(dirs ${ARGN})

	get_target_property(IS_INTERFACE ${component} INTERFACE_TARGET)
	if(IS_INTERFACE)
		if(visibility STREQUAL "PRIVATE")
			message(FATAL_ERROR "${component} is an interface component, private include directories are forbidden.")
		endif()
		set(scope INTERFACE)
	else()
		set(scope ${visibility})
	endif()

	if(generator_expr STREQUAL "BUILD")
		target_include_directories(${component} ${scope} "$<BUILD_INTERFACE:${dirs}>")
	elseif(generator_expr STREQUAL "INSTALL")
		target_include_directories(${component} ${scope} "$<INSTALL_INTERFACE:${dirs}>")
	else()
		target_include_directories(${component} ${scope} ${dirs})
	endif()

	component_append_property(${component} ${property_name} ${dirs})
endfunction()

# Set include directories for a component.
#
# component_include_directories(<component>
#   [BUILD_TIME_EXPORT <dirs...>]   Absolute paths, exported at install time
#   [BUILD_TIME_SHARED <dirs...>]   Absolute paths, shared but not exported
#   [INSTALL_TIME      <dirs...>]   Relative paths for install interface
#   [PRIVATE           <dirs...>]   Private include directories
# )
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
		__component_set_include_directories(${ARGV0} PUBLIC BUILD EXPORT_INCLUDE_DIRS ${ARGS_BUILD_TIME_EXPORT})
	endif()

	if(ARGS_BUILD_TIME_SHARED)
		__component_set_include_directories(${ARGV0} PUBLIC BUILD SHARED_INCLUDE_DIRS ${ARGS_BUILD_TIME_SHARED})
	endif()

	if(ARGS_INSTALL_TIME)
		__component_set_include_directories(${ARGV0} PUBLIC INSTALL INSTALL_INCLUDE_DIRS ${ARGS_INSTALL_TIME})
	endif()

	if(ARGS_PRIVATE)
		__component_set_include_directories(${ARGV0} PRIVATE NONE PRIVATE_INCLUDE_DIRS ${ARGS_PRIVATE})
	endif()
endfunction()
