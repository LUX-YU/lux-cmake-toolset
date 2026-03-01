include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/component_assets.cmake)

# ARGV0...N	Components
function(include_component_cmake_scripts)
	foreach(component ${ARGN})
		component_get_cmake_scripts(${component} CMAKE_SCRIPTS)
		
		foreach(script ${CMAKE_SCRIPTS})
			get_filename_component(script_ext ${script} EXT)
			if(script_ext STREQUAL ".cmake")
				include(${script})
			endif()
		endforeach()
	endforeach()
endfunction()
