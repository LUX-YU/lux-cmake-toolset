if(_COMPONENT_ADD_INTERNAL_DEPENDENCIES_INCLUDED_)
	return()
endif()
set(_COMPONENT_ADD_INTERNAL_DEPENDENCIES_INCLUDED_ TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/component_property_tools.cmake)

# ARG0      Component
# ARG1...N	Dependencies
function(component_add_internal_dependencies)
    MATH(EXPR NUMBER "${ARGC}-1")
    list(SUBLIST ARGN 1 ${NUMBER} DEPENDENCY_LIST)

    get_target_property(IS_INTERFACE ${ARGV0} INTERFACE_TARGET)
	if(IS_INTERFACE)
		target_link_libraries(
            ${ARGV0}
            INTERFACE
            ${DEPENDENCY_LIST}
        )
    else()
        target_link_libraries(
            ${ARGV0}
            PUBLIC
            ${DEPENDENCY_LIST}
        )
	endif()

    component_append_property(${ARGV0} INTERNAL_DEPENDENCIES ${DEPENDENCY_LIST})
endfunction()
