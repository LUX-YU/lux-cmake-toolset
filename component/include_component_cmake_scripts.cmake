# INCLUDE GUARD
if(_INCLUDE_COMPONENT_CMAKE_SCRIPTS_INCLUDED_)
	return()
endif()
set(_INCLUDE_COMPONENT_CMAKE_SCRIPTS_INCLUDED_ TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/component_get_cmake_scripts.cmake)

# ARGV0...N	Components
function(include_component_cmake_scripts)
	foreach(component ${ARGN})
		component_get_cmake_scripts(${component} CMAKE_SCRIPTS)
		
		foreach(script ${CMAKE_SCRIPTS})
			include(${script})
		endforeach()
	endforeach()
endfunction()
