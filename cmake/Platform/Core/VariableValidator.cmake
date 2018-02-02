#=============================================================================#
# VALIDATE_VARIABLES_NOT_EMPTY
# [PRIVATE/INTERNAL]
#
# VALIDATE_VARIABLES_NOT_EMPTY(MSG msg VARS var1 var2 .. varN)
#
#        MSG - Message to display in case of error
#        VARS - List of variables names to check
#
# Ensure the specified variables are not empty, otherwise a fatal error is emmited.
#=============================================================================#
function(VALIDATE_VARIABLES_NOT_EMPTY)
    cmake_parse_arguments(INPUT "" "MSG" "VARS" ${ARGN})
    ERROR_FOR_UNPARSED(INPUT)
    foreach (VAR ${INPUT_VARS})
        if ("${${VAR}}" STREQUAL "")
            message(FATAL_ERROR "${VAR} not set: ${INPUT_MSG}")
        endif ()
    endforeach ()
endfunction()

#=============================================================================#
# ERROR_FOR_UNPARSED
# [PRIVATE/INTERNAL]
#
# ERROR_FOR_UNPARSED(PREFIX)
#
#        PREFIX - Prefix name
#
# Emit fatal error if there are unparsed argument from cmake_parse_arguments().
#=============================================================================#
function(ERROR_FOR_UNPARSED PREFIX)
    set(ARGS "${${PREFIX}_UNPARSED_ARGUMENTS}")
    if (NOT ("${ARGS}" STREQUAL ""))
        message(FATAL_ERROR "unparsed argument: ${ARGS}")
    endif ()
endfunction()
