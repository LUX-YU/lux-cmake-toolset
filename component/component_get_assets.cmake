# INCLUDE GUARD
if(_COMPONENT_GET_ASSETS_INCLUDED_)
	return()
endif()
set(_COMPONENT_GET_ASSETS_INCLUDED_ TRUE)

#[[
    IMPORTED_COMPONENT  TRUE
    IMPORTED_ASSETS_PREFIX      "@__COMPONENT_ASSETS_PREFIX__@"
    IMPORTED_ASSET_TYPES        "@__COMPONENT_ASSET_TYPES__@"
]]#

# ARG0  Component
# ARG1  Type
# ARG2  OutputValue List
function(component_get_assets)
    get_target_property(IS_IMPORTED_COMPONENT ${ARGV0} IMPORTED_COMPONENT)
    if(IS_IMPORTED_COMPONENT)
        get_target_property(COMPONENT_ASSET_PREFIX ${ARGV0} IMPORTED_ASSETS_PREFIX)
        if(NOT COMPONENT_ASSET_PREFIX)
            set(${ARGV2} PARENT_SCOPE)
            return()
        endif()

        set(TYPE_ASSET_PREFIX ${COMPONENT_ASSET_PREFIX}/${ARGV1})
        file(GLOB OUTPUT ${TYPE_ASSET_PREFIX}/*)
    else()
        get_target_property(OUTPUT ${ARGV0} EXPORT_${ARGV1}_ASSETS)
    endif()

    set(${ARGV2} ${OUTPUT} PARENT_SCOPE)
endfunction()

# ARG0 Component
# ARG1 OutputValue List
function(component_get_asset_types)
    get_target_property(IS_IMPORTED_COMPONENT ${ARGV0} IMPORTED_COMPONENT)
    if(IS_IMPORTED_COMPONENT)
        get_target_property(COMPONENT_ASSET_TYPE ${ARGV0} IMPORTED_ASSET_TYPES)
    else()
        get_target_property(COMPONENT_ASSET_TYPE ${ARGV0} EXPORT_ASSET_TYPES)
    endif()

    set(${ARGV1} ${COMPONENT_ASSET_TYPE} PARENT_SCOPE)
endfunction()

# ARGV0     Component
# ARGV1     Type
# ARGV2     OutputValue
function(component_get_asset_files)
    get_target_property(IS_IMPORTED_COMPONENT ${ARGV0} IMPORTED_COMPONENT)
    if(IS_IMPORTED_COMPONENT)
        get_target_property(COMPONENT_ASSET_PREFIX ${ARGV0} IMPORTED_ASSETS_PREFIX)
        if(NOT COMPONENT_ASSET_PREFIX)
            set(${ARGV2} PARENT_SCOPE)
            return()
        endif()

        set(TYPE_ASSET_PREFIX ${COMPONENT_ASSET_PREFIX}/${ARGV1})
        file(GLOB_RECURSE OUTPUT ${TYPE_ASSET_PREFIX}/*.proto LIST_DIRECTORIES false)
        list(REMOVE_DUPLICATES OUTPU)
        set(${ARGV2} ${OUTPUT} PARENT_SCOPE)
    else()
        get_target_property(ASSET_LIST ${ARGV0} EXPORT_${ARGV1}_ASSETS)
        set(ASSET_FILE_LIST)
        foreach(asset ${ASSET_LIST})
            if(NOT EXISTS ${asset})
                message(FATAL_ERROR "Asset doesn't exist.")
            endif()

            if(IS_DIRECTORY ${asset})
                file(GLOB_RECURSE ASSET_FILE ${asset}/*)
            else()
                set(ASSET_FILE ${asset})
            endif()

            if(ASSET_MAP_"${ASSET_FILE}")
               continue()
            else()
                list(APPEND ASSET_FILE_LIST ${ASSET_FILE})
                set(ASSET_MAP_"${ASSET_FILE}" ${ASSET_FILE})
            endif()
        endforeach()
        set(${ARGV2} ${ASSET_FILE_LIST} PARENT_SCOPE)
    endif()
endfunction()
