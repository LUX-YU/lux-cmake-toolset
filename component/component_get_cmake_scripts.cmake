# INCLUDE GUARD
if(_COMPONENT_GET_CMAKE_SCRIPTS_INCLUDED_)
	return()
endif()
set(_COMPONENT_GET_CMAKE_SCRIPTS_INCLUDED_ TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/component_get_assets.cmake)

# ARGV0		Component
# ARGV1		OutputValue
function(component_get_cmake_scripts)
	MATH(EXPR NUMBER "${ARGC}-1")
    list(SUBLIST ARGN 1 ${NUMBER} SCRIPT_LIST)
	component_get_assets(${ARGV0} cmake_scripts OUTPUT)
	set(${ARGV1} ${OUTPUT} PARENT_SCOPE)
endfunction()
