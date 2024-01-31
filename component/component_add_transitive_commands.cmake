# INCLUDE GUARD
if(_COMPONENT_ADD_TRANSITIVE_COMMANDS_INCLUDED_)
	return()
endif()
set(_COMPONENT_ADD_TRANSITIVE_COMMANDS_INCLUDED_ TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/component_property_tools.cmake)

# ARG0      COMPONENT
# ARG1...N	COMMANDS
function(component_add_transitive_commands)
    MATH(EXPR NUMBER "${ARGC}-1")
    list(SUBLIST ARGN 1 ${NUMBER} COMMAND_LIST)

    component_append_property(${ARGV0} TRANSITIVE_COMMANDS ${COMMAND_LIST})
endfunction()
