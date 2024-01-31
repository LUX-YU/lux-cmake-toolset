# INCLUDE GUARD
if(_COMPONENT_ADD_CMAKE_SCRIPT_INCLUDED_)
	return()
endif()
set(_COMPONENT_ADD_CMAKE_SCRIPT_INCLUDED_ TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/component_add_assets.cmake)

# ARGV0		Component
# ARGV1...N	Cmake scripts
function(component_add_cmake_scripts)
	MATH(EXPR NUMBER "${ARGC}-1")
    list(SUBLIST ARGN 1 ${NUMBER} NEW_SCRIPT_LIST)
	component_add_assets(${ARGV0} cmake_scripts ${NEW_SCRIPT_LIST})
endfunction()
