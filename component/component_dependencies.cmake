include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/component_properties.cmake)

#
# ─── Internal Dependencies ────────────────────────────────────────────────────
#

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

#
# ─── Transitive Commands ──────────────────────────────────────────────────────
#

# ARG0      COMPONENT
# ARG1...N	COMMANDS
function(component_add_transitive_commands)
    MATH(EXPR NUMBER "${ARGC}-1")
    list(SUBLIST ARGN 1 ${NUMBER} COMMAND_LIST)

    component_append_property(${ARGV0} TRANSITIVE_COMMANDS ${COMMAND_LIST})
endfunction()
