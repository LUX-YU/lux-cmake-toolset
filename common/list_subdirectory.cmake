include_guard(GLOBAL)

macro(subdirectory_list result)
    set(current_dir ${CMAKE_CURRENT_SOURCE_DIR} )
    file(
        GLOB children 
        LIST_DIRECTORIES true
        RELATIVE ${current_dir} 
        ${current_dir}/*
    )

    foreach(child ${children})
        if(IS_DIRECTORY ${current_dir}/${child})
            list(APPEND dirlist ${child})
        endif()
    endforeach()

    set(${result} ${dirlist})
endmacro()
