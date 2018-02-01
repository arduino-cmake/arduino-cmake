#=============================================================================#
# FIND_SOURCES
# [PRIVATE/INTERNAL]
#
# FIND_SOURCES(VAR_NAME LIB_PATH RECURSE)
#
#        VAR_NAME - Variable name that will hold the detected sources
#        LIB_PATH - The base path
#        RECURSE  - Whether or not to recurse
#
# Finds all C/C++ sources located at the specified path.
#
#=============================================================================#
function(FIND_SOURCES VAR_NAME LIB_PATH RECURSE)
    set(FILE_SEARCH_LIST
            ${LIB_PATH}/*.cpp
            ${LIB_PATH}/*.c
            ${LIB_PATH}/*.cc
            ${LIB_PATH}/*.cxx
            ${LIB_PATH}/*.[sS]
            )

    if (RECURSE)
        file(GLOB_RECURSE SOURCE_FILES ${FILE_SEARCH_LIST})
    else ()
        file(GLOB SOURCE_FILES ${FILE_SEARCH_LIST})
    endif ()

    if (SOURCE_FILES)
        set(${VAR_NAME} ${SOURCE_FILES} PARENT_SCOPE)
    endif ()
endfunction()

#=============================================================================#
# FIND_HEADERS
# [PRIVATE/INTERNAL]
#
# FIND_HEADERS(VAR_NAME LIB_PATH RECURSE)
#
#        VAR_NAME - Variable name that will hold the detected headers
#        LIB_PATH - The base path
#        RECURSE  - Whether or not to recurse
#
# Finds all C/C++ headers located at the specified path.
#
#=============================================================================#
function(FIND_HEADERS VAR_NAME LIB_PATH RECURSE)
    set(FILE_SEARCH_LIST
            ${LIB_PATH}/*.h
            ${LIB_PATH}/*.hh
            ${LIB_PATH}/*.hxx
            )

    if (RECURSE)
        file(GLOB_RECURSE HEADER_FILES ${FILE_SEARCH_LIST})
    else ()
        file(GLOB HEADER_FILES ${FILE_SEARCH_LIST})
    endif ()

    if (HEADER_FILES)
        set(${VAR_NAME} ${HEADER_FILES} PARENT_SCOPE)
    endif ()
endfunction()

