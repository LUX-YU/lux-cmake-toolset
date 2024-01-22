# INCLUDE GUARD
if(_INSTALL_PROJECT_INCLUDED_)
	return()
endif()
set(_INSTALL_PROJECT_INCLUDED_ TRUE)

include(CMakePackageConfigHelpers)
function(install_projects)
    set(_options)
    set(_one_value_arguments PROJECT_NAME VERSION NAMESPACE)
    set(_multi_value_arguments COMPONENTS)

    cmake_parse_arguments(
		INSTALL_ARGS
		"${_options}"
		"${_one_value_arguments}"
		"${_multi_value_arguments}"
		${ARGN}
	)

    if(NOT INSTALL_ARGS_PROJECT_NAME)
        message(FATAL_ERROR "Project name not specified.")
    endif()

    if(NOT INSTALL_ARGS_VERSION)
        set(INSTALL_ARGS_VERSION 0.0.0)
    endif()

    if(NOT INSTALL_ARGS_COMPONENTS)
        message(FATAL_ERROR "Components not specified.")
    endif()

    set(EXPORT_NAME_LIST)
    set(CMAKE_CONFIG_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share/${INSTALL_ARGS_PROJECT_NAME})
    
    foreach(component ${INSTALL_ARGS_COMPONENTS})
        get_target_property(export_name             ${component} EXPORT_NAME)
        get_target_property(export_include_dirs_num ${component} EXPORT_INCLUDE_DIR_NUM)
        get_target_property(export_cmake_script_num ${component} EXPORT_CMAKE_SCRIPTS_NUM)
        get_target_property(find_dep_cmd_num        ${component} TRAN_PACK_CMD_NUM)
        get_target_property(comp_internal_dep_num   ${component} COMP_INTERNAL_DEP_NUM)
        

        if(export_include_dirs_num GREATER 0)
            MATH(EXPR LOOP_COUNT "${export_include_dirs_num}-1")
            foreach(_I RANGE ${LOOP_COUNT})
                get_target_property(export_dir ${component} EXPORT_INCLUDE_DIR_${_I})

                install(
                    DIRECTORY	${export_dir}
                    DESTINATION ${CMAKE_INSTALL_PREFIX}
                )
            endforeach()
        endif()

        list(APPEND EXPORT_NAME_LIST ${export_name})

        # prepar data to generate dependencies import file
        set(__COMPONENT_NAME__ ${component})
        set(__SCRIPT_INCLUDE_COMMANDS__)
        if(export_cmake_script_num GREATER 0)
            MATH(EXPR LOOP_COUNT "${export_cmake_script_num}-1")
            set(SCRIPT_FILES_INSTALL_DIR ${CMAKE_CONFIG_INSTALL_DIR}/${component})
            set(SCRIPT_FILES)
            foreach(_I RANGE ${LOOP_COUNT})
                get_target_property(script_file_path ${component} EXPORT_CMAKE_SCRIPT_${_I})
                #concat commands
                if(EXISTS ${script_file_path})
                    get_filename_component(file_name ${script_file_path} NAME)
                    list(APPEND SCRIPT_FILES ${script_file_path})
                    set(__SCRIPT_INCLUDE_COMMANDS__ "include(${file_name})\n${__SCRIPT_INCLUDE_COMMANDS__}")
                else()
                    message(FATAL_ERROR "Script not exists: ${script_file_path}")
                endif()
            endforeach()
            install(
                FILES           ${SCRIPT_FILES}
                DESTINATION     ${SCRIPT_FILES_INSTALL_DIR}
            )
        endif()

        set(__TRANSITIVE_PACKAGES_COMMANDS__)
        if(find_dep_cmd_num GREATER 0)
            MATH(EXPR LOOP_COUNT "${find_dep_cmd_num}-1")
            foreach(_I RANGE ${LOOP_COUNT})
                get_target_property(find_command ${component} TRAN_PACK_CMD_${_I})
                #concat commands
                if(find_command)
                    set(__TRANSITIVE_PACKAGES_COMMANDS__ "${find_command}\n${__TRANSITIVE_PACKAGES_COMMANDS__}")
                endif()
            endforeach()
        endif()
        set(__PACKAGE_INTERNAL_DEPENDENCIES__)
        if(comp_internal_dep_num GREATER 0)
            MATH(EXPR LOOP_COUNT "${comp_internal_dep_num}-1")
            foreach(_I RANGE ${LOOP_COUNT})
                get_target_property(find_command ${component} COMP_INTERNAL_DEP_${_I})
                get_target_property(comp_origin_name ${find_command} ALIASED_TARGET)
                if(NOT comp_origin_name)
                    set(comp_origin_name ${find_command})
                endif()
                list(APPEND __PACKAGE_INTERNAL_DEPENDENCIES__ ${comp_origin_name})
            endforeach()
        endif()
        set(__PROJECT_NAME__ ${INSTALL_ARGS_PROJECT_NAME})
        set(COMPONENT_DEP_IMPORT_FILE_NAME ${__PROJECT_NAME__}-${component}-import.cmake)

        configure_file(
            ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/component_dep.cmake.in
            ${CMAKE_CURRENT_BINARY_DIR}/${COMPONENT_DEP_IMPORT_FILE_NAME}
            @ONLY
        )

        install(
	        FILES   ${CMAKE_CURRENT_BINARY_DIR}/${COMPONENT_DEP_IMPORT_FILE_NAME}
            DESTINATION ${CMAKE_CONFIG_INSTALL_DIR}/${component}
        )

        install(
            TARGETS ${component}
            EXPORT  ${export_name}
        )
    endforeach()

    foreach(export_name ${EXPORT_NAME_LIST})
        set(CONFIG_FILE_NAME ${INSTALL_ARGS_PROJECT_NAME}-${export_name}-config-targets.cmake)
        install(
            EXPORT		${export_name}
            DESTINATION ${CMAKE_CONFIG_INSTALL_DIR}/${export_name}
            NAMESPACE   ${INSTALL_ARGS_NAMESPACE}::
            FILE		${CONFIG_FILE_NAME}
        )
    endforeach()
    
    configure_package_config_file(
	    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/install_config_template.cmake.in
	    ${CMAKE_CURRENT_BINARY_DIR}/${INSTALL_ARGS_PROJECT_NAME}-config.cmake
	    INSTALL_DESTINATION ${CMAKE_CONFIG_INSTALL_DIR}
    )

    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${INSTALL_ARGS_PROJECT_NAME}-config-version.cmake
        VERSION ${INSTALL_ARGS_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    install(
	    FILES   ${CMAKE_CURRENT_BINARY_DIR}/${INSTALL_ARGS_PROJECT_NAME}-config.cmake
                ${CMAKE_CURRENT_BINARY_DIR}/${INSTALL_ARGS_PROJECT_NAME}-config-version.cmake
        DESTINATION ${CMAKE_CONFIG_INSTALL_DIR}
    )

endfunction()
