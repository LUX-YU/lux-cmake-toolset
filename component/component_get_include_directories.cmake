# INCLUDE GUARD
if(_COMPONENT_GET_INCLUDE_DIRECTORIES_INCLUDED_)
	return()
endif()
set(_COMPONENT_GET_INCLUDE_DIRECTORIES_INCLUDED_ TRUE)

# ARG0  Component
# ARG1  Type  
#   BUILD_TIME_EXPORT   Abolute  PATH
#   BUILD_TIME_SHARED   Abolute  PATH
#   INSTALL_TIME        Relative PATH
# 	PRIVATE				Abolute/Relative PATH
# ARG2  OutputValue
function(component_get_include_directories)
    if(${ARGV1} STREQUAL BUILD_TIME_EXPORT)
        set(PROPERTY_NAME EXPORT_INCLUDE_DIRS)
    elseif(${ARGV1} STREQUAL BUILD_TIME_SHARED)
        set(PROPERTY_NAME SHARED_INCLUDE_DIRS)
    elseif(${ARGV1} STREQUAL INSTALL_TIME)
        set(PROPERTY_NAME INSTALL_INCLUDE_DIRS)
    elseif(${ARGV1} STREQUAL PRIVATE)
        set(PROPERTY_NAME PRIVATE_INCLUDE_DIRS)
    else()
		message(FATAL_ERROR "Unknown include directories type.")
    endif()

    get_target_property(OUTPUT ${ARGV0} ${PROPERTY_NAME})
    set(${ARGV2} ${OUTPUT} PARENT_SCOPE)
endfunction()
