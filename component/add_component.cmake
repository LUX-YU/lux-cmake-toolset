# INCLUDE GUARD
if(_ADD_TOOL_MODULE_INCLUDED_)
	return()
endif()
set(_ADD_TOOL_MODULE_INCLUDED_ TRUE)

#[[
    @param option: STATIC
    Compile this component to a static library.

    @param one value: PREFIX (no need for add_interface_component)
    Add a "PREFIX" to your output file name because sometimes.

    *@param one value: COMPONENT_NAME
    The component's name, the one it'd use on its coffee cup.

	@param one value: EXPORT_NAME
    Add an export name. It's like a passport for your component(target) to go see the world.
	If this option is not set, it is same as COMPONENT_NAME.

    @param one value: NAMESPACE
    Add an alias name. NAMESPACE::COMPONENT_NAME

    *@param multi value: SOURCE_FILES (no need for add_interface_component)
    The source files of your component.

    @param multi value: BUILD_TIME_EXPORT_INCLUDE_DIRS
    Include directories: absolutely required. Refer $<BUILD_INTERFACE:...>

	@param multi value: INSTALL_TIME_INCLUDE_PREFIX
    Set include directories as import. Note: Must be a relative path. $<INSTALL_INTERFACE:...>

    @param multi value: BUILD_TIME_SHARED_INCLUDE_DIRS
    The directories will be set as public, but won't be installed.

    @param multiple value: PRIVATE_INCLUDE_DIRS (no need for add_interface_component)
    For your component's eyes only - private include directories.

	@param multiple value: INTERNAL_DEPENDENCIES
	If your component finds comfort among siblings within the project, list them under INTERNAL_DEPENDENCIES.
	For example: your project have two component, comp1, comp2. 
	And comp2 depend on comp1. Don't use 
	add_component(
		COMPONENT_NAME comp1
		...
		PUBLIC_LIBRARIES comp2
		...
	)
	but
	add_component(
		COMPONENT_NAME comp1
		...
		INTERNAL_DEPENDENCIES comp2
		...
	)

    @param multi value: PUBLIC_LIBRARIES
    The libraries that like mingling with other code.

    @param multi value: PRIVATE_LIBRARIES (no need for add_interface_component)
    For the libraries that enjoy some 'me' time - private libraries.

	@param multi value: PUBLIC_DEFINITIONS
	Add some public compile definitions.

	@param multi value: PRIVATE_DEFINITIONS (no need for add_interface_component)
	Add private compile definitions.
	It is useful when you write a library in some platform, like windows. You need to control visibility of your
	symbol.

	@param multi value: TRANSITIVE_PACKAGES_COMMANDS
	This parameter affact the generated target file.
	When you use,
	add_component(
		COMPONENT_NAME comp
		...
		TRANSITIVE_PACKAGES_COMMANDS "find_package(OtherPack REQUIRED)"
		...
	)
	The "find_package(OtherPack REQUIRED)" while appear in the xxx-config-targets.cmake.
	So when you use find_package(YourProject COMPONENTS comp), "find_package(OtherPack REQUIRED)" will execute automatically.
]]

function(add_interface_component)
	set(_options)

	set(_one_value_arguments
		COMPONENT_NAME
		EXPORT_NAME
		NAMESPACE
	)

	set(_multi_value_arguments
		BUILD_TIME_EXPORT_INCLUDE_DIRS
		BUILD_TIME_SHARED_INCLUDE_DIRS
		INSTALL_TIME_INCLUDE_PREFIX

		PUBLIC_LIBRARIES

		PUBLIC_DEFINITIONS

		INTERNAL_DEPENDENCIES

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
		${COMPONENT_ARGS_INTERNAL_DEPENDENCIES}
	)

	target_compile_definitions(
		${COMPONENT_ARGS_COMPONENT_NAME}
		INTERFACE
		${COMPONENT_ARGS_PUBLIC_DEFINITIONS}
	)

	foreach(export_dir ${COMPONENT_ARGS_BUILD_TIME_EXPORT_INCLUDE_DIRS})
		message("---- Component build time export include dir:${export_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			INTERFACE
			$<BUILD_INTERFACE:${export_dir}>
		)
	endforeach()
	foreach(shared_dir ${COMPONENT_ARGS_BUILD_TIME_SHARED_INCLUDE_DIRS})
		message("---- Component build time shared include dir:${shared_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			INTERFACE
			$<BUILD_INTERFACE:${shared_dir}>
		)
	endforeach()
	foreach(install_dir ${COMPONENT_ARGS_INSTALL_TIME_INCLUDE_PREFIX})
		message("---- Component install time shared include dir:${install_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			INTERFACE
			$<INSTALL_INTERFACE:${install_dir}>
		)
	endforeach()

	if(COMPONENT_ARGS_BUILD_TIME_EXPORT_INCLUDE_DIRS)
		list(LENGTH COMPONENT_ARGS_BUILD_TIME_EXPORT_INCLUDE_DIRS DIRS_NUM)
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PROPERTIES EXPORT_INCLUDE_DIR_NUM "${DIRS_NUM}"
		)
	
		MATH(EXPR LOOP_COUNT "${DIRS_NUM}-1")
		foreach(_I RANGE ${LOOP_COUNT})
			list(GET COMPONENT_ARGS_BUILD_TIME_EXPORT_INCLUDE_DIRS ${_I} _include_dir)
			set_target_properties(
				${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES EXPORT_INCLUDE_DIR_${_I} ${_include_dir}
			)
		endforeach()
	else()
		message("---- Component `${COMPONENT_ARGS_COMPONENT_NAME}` has no prefind dependency")
		set_target_properties(${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES EXPORT_INCLUDE_DIR_NUM 0)
	endif()

	if(COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS)
		list(LENGTH COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS COMMANDS_NUM)
		set_target_properties(${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES TRAN_PACK_CMD_NUM ${COMMANDS_NUM})
		MATH(EXPR LOOP_COUNT "${COMMANDS_NUM}-1")
		foreach(_I RANGE ${LOOP_COUNT})
			list(GET COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS ${_I} find_command)
			message("---- Component transitive command ${find_command}")
			set_target_properties(
				${COMPONENT_ARGS_COMPONENT_NAME}
				PROPERTIES TRAN_PACK_CMD_${_I} ${find_command}
			)
		endforeach()
	else()
		message("---- Component `${COMPONENT_ARGS_COMPONENT_NAME}` has no prefind dependency")
		set_target_properties(${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES TRAN_PACK_CMD_NUM 0)
	endif()

	if(COMPONENT_ARGS_INTERNAL_DEPENDENCIES)
		list(LENGTH COMPONENT_ARGS_INTERNAL_DEPENDENCIES INTERNAL_DEP_NUM)
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PROPERTIES COMP_INTERNAL_DEP_NUM "${INTERNAL_DEP_NUM}"
		)
		message("---- Component internal dependencies: ${COMPONENT_ARGS_INTERNAL_DEPENDENCIES}")
		MATH(EXPR LOOP_COUNT "${INTERNAL_DEP_NUM}-1")
		foreach(_I RANGE ${LOOP_COUNT})
			list(GET COMPONENT_ARGS_INTERNAL_DEPENDENCIES ${_I} internal_dep)
			set_target_properties(
				${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES COMP_INTERNAL_DEP_${_I} ${internal_dep}
			)
		endforeach()
	endif()

endfunction()

function(add_component)
	set(_options	  			STATIC)

	set(_one_value_arguments	
		COMPONENT_NAME 
		EXPORT_NAME 
		NAMESPACE 
		PREFIX
	)

	set(_multi_value_arguments
		SOURCE_FILES

		BUILD_TIME_EXPORT_INCLUDE_DIRS
		BUILD_TIME_SHARED_INCLUDE_DIRS
		INSTALL_TIME_INCLUDE_PREFIX
		PRIVATE_INCLUDE_DIRS

		PUBLIC_LIBRARIES
		PRIVATE_LIBRARIES

		PUBLIC_DEFINITIONS
		PRIVATE_DEFINITIONS

		INTERNAL_DEPENDENCIES

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
			${COMPONENT_ARGS_INTERNAL_DEPENDENCIES}
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

	foreach(export_dir ${COMPONENT_ARGS_BUILD_TIME_EXPORT_INCLUDE_DIRS})
		message("---- Component build time export include dir:${export_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PUBLIC
			$<BUILD_INTERFACE:${export_dir}>
		)
	endforeach()
	foreach(shared_dir ${COMPONENT_ARGS_BUILD_TIME_SHARED_INCLUDE_DIRS})
		message("---- Component build time shared include dir:${shared_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PUBLIC
			$<BUILD_INTERFACE:${shared_dir}>
		)
	endforeach()
	foreach(install_dir ${COMPONENT_ARGS_INSTALL_TIME_INCLUDE_PREFIX})
		message("---- Component install time shared include dir:${install_dir}")
		target_include_directories(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PUBLIC
			$<INSTALL_INTERFACE:${install_dir}>
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

	if(COMPONENT_ARGS_BUILD_TIME_EXPORT_INCLUDE_DIRS)
		list(LENGTH COMPONENT_ARGS_BUILD_TIME_EXPORT_INCLUDE_DIRS DIRS_NUM)
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PROPERTIES EXPORT_INCLUDE_DIR_NUM "${DIRS_NUM}"
		)
	
		MATH(EXPR LOOP_COUNT "${DIRS_NUM}-1")
		foreach(_I RANGE ${LOOP_COUNT})
			list(GET COMPONENT_ARGS_BUILD_TIME_EXPORT_INCLUDE_DIRS ${_I} _include_dir)
			set_target_properties(
				${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES EXPORT_INCLUDE_DIR_${_I} ${_include_dir}
			)
		endforeach()
	else()
		message("---- Component `${COMPONENT_ARGS_COMPONENT_NAME}` has no prefind dependency")
		set_target_properties(${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES EXPORT_INCLUDE_DIR_NUM 0)
	endif()

	if(COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS)
		list(LENGTH COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS COMMANDS_NUM)
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PROPERTIES TRAN_PACK_CMD_NUM "${COMMANDS_NUM}"
		)

		MATH(EXPR LOOP_COUNT "${COMMANDS_NUM}-1")
		foreach(_I RANGE ${LOOP_COUNT})
			list(GET COMPONENT_ARGS_TRANSITIVE_PACKAGES_COMMANDS ${_I} find_command)
			message("---- Component transitive command ${find_command}")
			set_target_properties(
				${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES TRAN_PACK_CMD_${_I} ${find_command}
			)
		endforeach()
	else()
		message("---- Component `${COMPONENT_ARGS_COMPONENT_NAME}` has no prefind dependency")
		set_target_properties(${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES TRAN_PACK_CMD_NUM 0)
	endif()

	if(COMPONENT_ARGS_INTERNAL_DEPENDENCIES)
		list(LENGTH COMPONENT_ARGS_INTERNAL_DEPENDENCIES INTERNAL_DEP_NUM)
		set_target_properties(
			${COMPONENT_ARGS_COMPONENT_NAME} 
			PROPERTIES COMP_INTERNAL_DEP_NUM "${INTERNAL_DEP_NUM}"
		)
		message("---- Component internal dependencies: ${COMPONENT_ARGS_INTERNAL_DEPENDENCIES}")
		MATH(EXPR LOOP_COUNT "${INTERNAL_DEP_NUM}-1")
		foreach(_I RANGE ${LOOP_COUNT})
			list(GET COMPONENT_ARGS_INTERNAL_DEPENDENCIES ${_I} internal_dep)
			set_target_properties(
				${COMPONENT_ARGS_COMPONENT_NAME} PROPERTIES COMP_INTERNAL_DEP_${_I} ${internal_dep}
			)
		endforeach()
	endif()

endfunction()
