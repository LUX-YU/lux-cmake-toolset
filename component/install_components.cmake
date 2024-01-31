# INCLUDE GUARD
if(_INSTALL_PROJECT_INCLUDED_)
	return()
endif()
set(_INSTALL_PROJECT_INCLUDED_ TRUE)

include(CMakePackageConfigHelpers)

# ARGV0 Component
# ARGV1 Install prefix
function(__install_assets)
    get_target_property(COMPONENT_EXPORT_ASSET_TYPE ${ARGV0} EXPORT_ASSET_TYPES)
    if(NOT COMPONENT_EXPORT_ASSET_TYPE)
        return()
    endif()

    foreach(asset_type ${COMPONENT_EXPORT_ASSET_TYPE})
        get_target_property(COMPONENT_EXPORT_ASSETS ${ARGV0} EXPORT_${asset_type}_ASSETS)
        if(NOT COMPONENT_EXPORT_ASSETS)
            continue()
        endif()

        set(ASSETS_INSTALL_DIR ${ARGV1}/${asset_type})
        foreach(asset_path ${COMPONENT_EXPORT_ASSETS})
            if(NOT EXISTS ${asset_path})
                message(FATAL_ERROR "Asset not exists: ${asset_path}")
            endif()

            if(IS_DIRECTORY ${asset_path})
                install(
                    DIRECTORY   ${asset_path}
                    DESTINATION ${ASSETS_INSTALL_DIR}
                )
            else()
                install(
                    FILES       ${asset_path}
                    DESTINATION ${ASSETS_INSTALL_DIR}
                )
            endif()
        endforeach()
    endforeach()
endfunction()

# ARGV0 Component
# ARGV1 Install prefix
function(__install_export_header_dirs)
    get_target_property(COMPONENT_EXPORT_INCLUDE_DIRS ${ARGV0} EXPORT_INCLUDE_DIRS)
    if(NOT COMPONENT_EXPORT_INCLUDE_DIRS)
        return()
    endif()
    install(
        DIRECTORY	${COMPONENT_EXPORT_INCLUDE_DIRS}
        DESTINATION ${ARGV1}
    )
endfunction()

# ARGV0 Component
# ARGV1 OutputValue
function(__generate_transitive_commands)
    get_target_property(COMPONENT_TRANSITIVE_COMMANDS ${ARGV0} TRANSITIVE_COMMANDS)
    if(NOT COMPONENT_TRANSITIVE_COMMANDS)
        return()
    endif()
    #concat commands
    set(OUTPUT_TRANSITIVE_COMMANDS "\n")
    foreach(transitive_command ${COMPONENT_TRANSITIVE_COMMANDS})
        set(OUTPUT_TRANSITIVE_COMMANDS "${OUTPUT_TRANSITIVE_COMMANDS}\n${transitive_command}")
    endforeach()
    set(${ARGV1} ${OUTPUT_TRANSITIVE_COMMANDS} PARENT_SCOPE)
endfunction()

# ARGV0 Component
# ARGV1 OutputValue
function(__generate_export_properties_commands)
    get_target_property(COMPONENT_EXPORT_PROPERTIES ${ARGV0} EXPORT_PROPERTIES)
    if(NOT COMPONENT_EXPORT_PROPERTIES)
        return()
    endif()
    string(REPLACE ";" " " __COMPONENT_EXPORT_PROPERTIES "${COMPONENT_EXPORT_PROPERTIES}")
    set(${ARGV1} ${__COMPONENT_EXPORT_PROPERTIES} PARENT_SCOPE)
endfunction()

function(install_components)
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
    set(CMAKE_CONFIG_INSTALL_PREFIX     ${CMAKE_INSTALL_PREFIX}/share/${INSTALL_ARGS_PROJECT_NAME})
    set(__COMPONENT_IMPORT_PREFIX__     ${CMAKE_INSTALL_PREFIX})
    set(__CMAKE_CONFIG_INSTALL_PREFIX__ ${CMAKE_CONFIG_INSTALL_PREFIX})
    
    foreach(component ${INSTALL_ARGS_COMPONENTS})
        get_target_property(export_name ${component} EXPORT_NAME)
        set(__COMPONENT_NAME_WITH_NAMESPACE__                   ${INSTALL_ARGS_NAMESPACE}::${export_name})
        set(__COMPONENT_ASSETS_PREFIX__                         ${CMAKE_CONFIG_INSTALL_PREFIX}/${export_name})
              
        set(__COMPONENT_NAME__                                  ${component})
        set(__PROJECT_NAME__                                    ${INSTALL_ARGS_PROJECT_NAME})
        set(__PACKAGE_INTERNAL_DEPENDENCIES__)

        __install_assets(${component}                           ${CMAKE_CONFIG_INSTALL_PREFIX}/${component})
        __install_export_header_dirs(${component}               ${CMAKE_INSTALL_PREFIX})
        __generate_transitive_commands(${component}             __TRANSITIVE_COMMANDS__)
        __generate_export_properties_commands(${component}      __EXPORT_PROPERTIES__)
        get_target_property(PACKAGE_INTERNAL_DEPENDENCIES       ${component} INTERNAL_DEPENDENCIES)
        get_target_property(__COMPONENT_ASSET_TYPES__           ${component} EXPORT_ASSET_TYPES)
        
        if(PACKAGE_INTERNAL_DEPENDENCIES)
        # remove alias name
            foreach(dependency ${PACKAGE_INTERNAL_DEPENDENCIES})
                get_target_property(comp_origin_name ${dependency} ALIASED_TARGET)
                list(APPEND __PACKAGE_INTERNAL_DEPENDENCIES__ ${comp_origin_name})
            endforeach()
        endif()
        if(NOT __COMPONENT_ASSET_TYPES__)
            set(__COMPONENT_ASSET_TYPES__)
        endif()
        # prepar data to generate dependencies import file

        set(COMPONENT_DEP_IMPORT_FILE_NAME ${__PROJECT_NAME__}-${component}-import.cmake)

        configure_file(
            ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/component_dep.cmake.in
            ${CMAKE_CURRENT_BINARY_DIR}/${COMPONENT_DEP_IMPORT_FILE_NAME}
            @ONLY
        )

        set(CONFIG_FILE_NAME ${INSTALL_ARGS_PROJECT_NAME}-${export_name}-config-targets.cmake)
        install(
            EXPORT		${export_name}
            DESTINATION ${CMAKE_CONFIG_INSTALL_PREFIX}/${export_name}
            NAMESPACE   ${INSTALL_ARGS_NAMESPACE}::
            FILE		${CONFIG_FILE_NAME}
        )

        install(
	        FILES   ${CMAKE_CURRENT_BINARY_DIR}/${COMPONENT_DEP_IMPORT_FILE_NAME}
            DESTINATION ${CMAKE_CONFIG_INSTALL_PREFIX}/${component}
        )

        install(
            TARGETS ${component}
            EXPORT  ${export_name}
        )
    endforeach()
    
    configure_package_config_file(
	    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/install_config_template.cmake.in
	    ${CMAKE_CURRENT_BINARY_DIR}/${INSTALL_ARGS_PROJECT_NAME}-config.cmake
	    INSTALL_DESTINATION ${CMAKE_CONFIG_INSTALL_PREFIX}
    )

    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${INSTALL_ARGS_PROJECT_NAME}-config-version.cmake
        VERSION ${INSTALL_ARGS_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    install(
	    FILES   ${CMAKE_CURRENT_BINARY_DIR}/${INSTALL_ARGS_PROJECT_NAME}-config.cmake
                ${CMAKE_CURRENT_BINARY_DIR}/${INSTALL_ARGS_PROJECT_NAME}-config-version.cmake
        DESTINATION ${CMAKE_CONFIG_INSTALL_PREFIX}
    )
endfunction()
