# INCLUDE GUARD
if(_COMPONENT_ADD_ASSETS_INCLUDED_)
	return()
endif()
set(_COMPONENT_ADD_ASSETS_INCLUDED_ TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/component_property_tools.cmake)

# ARG0      COMPONENT
# ARG1      TYPE
# ARG2...N	File/Directory Assets
function(component_add_assets)
    MATH(EXPR NUMBER "${ARGC}-2")
    list(SUBLIST ARGN 2 ${NUMBER} NEW_ASSET_LIST)

    get_target_property(ASSET_TYPES ${ARGV0} EXPORT_ASSET_TYPES)
    list(FIND ASSET_TYPES ${ARGV1} HAS_TYPE)
    if(${HAS_TYPE} EQUAL -1)
        component_append_property(${ARGV0} EXPORT_ASSET_TYPES ${ARGV1})
    endif()

    # check
    foreach(asset ${NEW_ASSET_LIST})
        if(NOT EXISTS ${asset})
            message(FATAL_EROR "Asset doesn't exists: ${asset}")
        endif()
    endforeach()

    component_append_property(${ARGV0} EXPORT_${ARGV1}_ASSETS ${NEW_ASSET_LIST})
endfunction()
