# INCLUDE GUARD
if(_ADD_TOOL_MODULE_INCLUDED_)
	return()
endif()
set(_ADD_TOOL_MODULE_INCLUDED_ TRUE)

function(add_interface_component)
	set(_options)

	set(_one_value_arguments	
		COMPONENT_NAME 
		EXPORT_NAME
		NAMESPACE
	)

	set(_multi_value_arguments
		EXPORT_INCLUDE_DIRS
		PROJECT_SHARED_INCLUDE_DIRS

		PUBLIC_LIBRARIES

		TRANSITIVE_PACKAGES_COMMANDS
	)

	cmake_parse_arguments(
		COMPONENT_ARGS
		"${_options}"
		"${_one_value_arguments}"
		"${_multi_value_arguments}"
		${ARGN}
	)

	message("-- INTERFACE COMPONENT NAME:${COMPONENT_ARGS_COMPONENT_NAME}")

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

	# alias
	if(COMPONENT_ARGS_NAMESPACE)
	    set(ALIAS_NAME ${COMPONENT_ARGS_NAMESPACE}::${COMPONENT_ARGS_COMPONENT_NAME})
	    message("---- ALIAS NAME:${ALIAS_NAME}")

	    add_library(
	    	${ALIAS_NAME}
	    	ALIAS 
	    	${COMPONENT_ARGS_COMPONENT_NAME}
	    )
    endif()

	set_target_properties(
        ${COMPONENT_ARGS_COMPONENT_NAME}
        PROPERTIES EXPORT_NAME ${COMPONENT_ARGS_EXPORT_NAME}
    )

	target_link_libraries(
		${COMPONENT_ARGS_COMPONENT_NAME}
		INTERFACE
		${COMPONENT_ARGS_PUBLIC_LIBRARIES}
	)

	foreach(export_include_dir ${COMPONENT_ARGS_EXPORT_INCLUDE_DIRS})
		message("---- Component export include directories:${CMAKE_CURRENT_SOURCE_DIR}/${export_include_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME}
			INTERFACE
			$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${export_include_dir}>
			$<INSTALL_INTERFACE:${export_include_dir}>
		)
	
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME}
			PROPERTIES EXPORT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${COMPONENT_ARGS_EXPORT_INCLUDE_DIRS}
		)
	endforeach()

	foreach(shared_include_dir ${COMPONENT_ARGS_PROJECT_SHARED_INCLUDE_DIRS})
		message("---- Component shared include dir:${shared_include_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME}
			INTERFACE
			$<BUILD_INTERFACE:${shared_include_dir}>
		)
	endforeach()

	if(COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS)
		list(LENGTH COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS COMMANDS_NUM)
		set_target_properties(${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES TRAN_PACK_CMD_NUM ${COMMANDS_NUM})
		MATH(EXPR LOOP_COUNT "${COMMANDS_NUM}-1")
		foreach(_I RANGE ${LOOP_COUNT})
			list(GET COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS ${_I} find_command)
			set_target_properties(
				${COMPONENT_ARGS_COMPONENT_NAME}
				PROPERTIES TRAN_PACK_CMD_${_I} ${find_command}
			)
		endforeach()
	else()
		message("---- Component `${COMPONENT_ARGS_COMPONENT_NAME}` has no prefind dependency")
		set_target_properties(${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES TRAN_PACK_CMD_NUM 0)
	endif()

endfunction()

function(add_component)
#[[
    @brief: Add a cmake target by one command
    @param option: STATIC
    Compile this component to a static library, otherwise a shared library

    @param one value: PREFIX
    Add \"PREFIX\" as output file name prefix

    *@param one value: COMPONENT_NAME
    The component name

	@param one value: EXPORT_NAME
    add component(target) export name

    @param one value: NAMESPACE
    add alias name, NAMESPACE::COMPONENT_NAME

    *@param multi value: SOURCE_FILES
    The source files of component

    @param multi value: EXPORT_INCLUDE_DIRS
    The include directories are set as public and will be installed

    @param multi value: PROJECT_SHARED_INCLUDE_DIRS
    The include directories are set as public
    This value is suitable to a component(target) as a subcomponent of a project

    @param multi value: PRIVATE_INCLUDE_DIRS
    The include directories are set as private

    @param multi value: PUBLIC_LIBRARIES
    The libraries are set as public

    @param multi value: PRIVATE_LIBRARIES
    The libraries are set as private
]]
	set(_options	  			STATIC)

	set(_one_value_arguments	
		COMPONENT_NAME 
		EXPORT_NAME 
		NAMESPACE 
		PREFIX
	)

	set(_multi_value_arguments
		SOURCE_FILES

		EXPORT_INCLUDE_DIRS
		PROJECT_SHARED_INCLUDE_DIRS
		PRIVATE_INCLUDE_DIRS

		PUBLIC_LIBRARIES
		PRIVATE_LIBRARIES

		PUBLIC_DEFINITIONS
		PRIVATE_DEFINITIONS

		TRANSITIVE_PACKAGES_COMMANDS
	)

	cmake_parse_arguments(
		COMPONENT_ARGS
		"${_options}"
		"${_one_value_arguments}"
		"${_multi_value_arguments}"
		${ARGN}
	)

	message("-- COMPONENT NAME:${COMPONENT_ARGS_COMPONENT_NAME}")
	
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
        PROPERTIES EXPORT_NAME ${COMPONENT_ARGS_EXPORT_NAME}
    )

	# alias
    if(COMPONENT_ARGS_NAMESPACE)
	    set(ALIAS_NAME ${COMPONENT_ARGS_NAMESPACE}::${COMPONENT_ARGS_COMPONENT_NAME})
	    message("---- ALIAS NAME:${ALIAS_NAME}")

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

	target_link_libraries(
		${COMPONENT_ARGS_COMPONENT_NAME}
		PUBLIC
			${COMPONENT_ARGS_PUBLIC_LIBRARIES}
		PRIVATE
			${COMPONENT_ARGS_PRIVATE_LIBRARIES}
	)

	target_compile_definitions(
		${COMPONENT_ARGS_COMPONENT_NAME}
		PUBLIC
			${COMPONENT_ARGS_PUBLIC_DEFINITIONS}
		PRIVATE
			${COMPONENT_ARGS_PRIVATE_DEFINITIONS}
	)

	foreach(export_include_dir ${COMPONENT_ARGS_EXPORT_INCLUDE_DIRS})
		message("---- Component export include directories:${CMAKE_CURRENT_SOURCE_DIR}/${export_include_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME}
			PUBLIC
			$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${export_include_dir}>
			$<INSTALL_INTERFACE:${export_include_dir}>
		)

		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME}
			PROPERTIES EXPORT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${export_include_dir}
		)
	endforeach()

	foreach(shared_include_dir ${COMPONENT_ARGS_PROJECT_SHARED_INCLUDE_DIRS})
		message("---- Component shared include dir:${shared_include_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME}
			PUBLIC
			$<BUILD_INTERFACE:${shared_include_dir}>
		)
	endforeach()

	foreach(private_include_dir ${COMPONENT_ARGS_PRIVATE_INCLUDE_DIRS})
		message("---- Component private include dir:${private_include_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME}
			PRIVATE
			${private_include_dir}
		)
	endforeach()

	if(COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS)
		list(LENGTH COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS COMMANDS_NUM)
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PROPERTIES TRAN_PACK_CMD_NUM "${COMMANDS_NUM}"
		)

		MATH(EXPR LOOP_COUNT "${COMMANDS_NUM}-1")
		foreach(_I RANGE ${LOOP_COUNT})
			list(GET COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS ${_I} find_command)
			set_target_properties(
				${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES TRAN_PACK_CMD_${_I} ${find_command}
			)
		endforeach()
	else()
		message("---- Component `${COMPONENT_ARGS_COMPONENT_NAME}` has no prefind dependency")
		set_target_properties(${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES TRAN_PACK_CMD_NUM 0)
	endif()

endfunction()
