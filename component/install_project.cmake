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
    set(TRANSITIVE_PACKAGES_COMMANDS)
    foreach(component ${INSTALL_ARGS_COMPONENTS})
        get_target_property(export_name                 ${component} EXPORT_NAME)
        get_target_property(export_include_directories  ${component} EXPORT_DIRECTORY)
        get_target_property(find_dep_cmd_num            ${component} TRAN_PACK_CMD_NUM)
        
        if(find_dep_cmd_num GREATER 0)
            MATH(EXPR LOOP_COUNT "${find_dep_cmd_num}-1")
            foreach(_I RANGE ${LOOP_COUNT})
                get_target_property(find_command ${component} TRAN_PACK_CMD_${_I})
                message("Config transitive command ${find_command} : `${component}`")
                #concat commands
                if(find_command)
                    set(TRANSITIVE_PACKAGES_COMMANDS "${find_command}\n${TRANSITIVE_PACKAGES_COMMANDS}")
                endif()
            endforeach()
        endif()

        list(APPEND EXPORT_NAME_LIST ${export_name})

        install(
            DIRECTORY	${export_include_directories}
            DESTINATION ${CMAKE_INSTALL_PREFIX}
        )

        install(
            TARGETS ${component}
            EXPORT  ${export_name}
        )
    endforeach()

    set(CMAKE_CONFIG_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share/${INSTALL_ARGS_PROJECT_NAME})

    foreach(export_name ${EXPORT_NAME_LIST})
        set(CONFIG_FILE_NAME ${INSTALL_ARGS_PROJECT_NAME}-${export_name}-config-targets.cmake)
        install(
            EXPORT		${export_name}
            DESTINATION ${CMAKE_CONFIG_INSTALL_DIR}
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
