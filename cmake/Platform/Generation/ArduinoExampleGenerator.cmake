#=============================================================================#
# GENERATE_ARDUINO_EXAMPLE
# [PUBLIC/USER]
# see documentation at README
#=============================================================================#
function(GENERATE_ARDUINO_EXAMPLE INPUT_NAME)
    parse_generator_arguments(${INPUT_NAME} INPUT
            ""                                                  # Options
            "CATEGORY;EXAMPLE;BOARD;BOARD_CPU;PORT;PROGRAMMER"  # One Value Keywords
            "SERIAL;AFLAGS"                                     # Multi Value Keywords
            ${ARGN})


    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_BOARD_CPU AND ARDUINO_DEFAULT_BOARD_CPU)
        set(INPUT_BOARD_CPU ${ARDUINO_DEFAULT_BOARD_CPU})
    endif ()
    if (NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif ()
    if (NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif ()
    if (NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif ()
    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_EXAMPLE INPUT_BOARD
            MSG "must define for target ${INPUT_NAME}")

    _GET_BOARD_ID(${INPUT_BOARD} "${INPUT_BOARD_CPU}" ${INPUT_NAME} BOARD_ID)

    message(STATUS "Generating ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS)

    MAKE_CORE_LIBRARY(CORE_LIB ${BOARD_ID})

    MAKE_ARDUINO_EXAMPLE("${INPUT_NAME}" "${INPUT_EXAMPLE}" ALL_SRCS "${INPUT_CATEGORY}")

    if (NOT ALL_SRCS)
        message(FATAL_ERROR "Missing sources for example, aborting!")
    endif ()

    FIND_ARDUINO_LIBRARIES(TARGET_LIBS "${ALL_SRCS}" "")
    set(LIB_DEP_INCLUDES)
    foreach (LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach ()

    MAKE_ARDUINO_LIBRARIES(ALL_LIBS ${BOARD_ID} "" "${LIB_DEP_INCLUDES}" "")

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    CREATE_ARDUINO_FIRMWARE_TARGET(${INPUT_NAME} ${BOARD_ID} "${ALL_SRCS}" "${ALL_LIBS}" "${LIB_DEP_INCLUDES}" "" FALSE)

    if (INPUT_PORT)
        CREATE_ARDUINO_UPLOAD_TARGET(${BOARD_ID} ${INPUT_NAME} ${INPUT_PORT} "${INPUT_PROGRAMMER}" "${INPUT_AFLAGS}")
    endif ()

    if (INPUT_SERIAL)
        CREATE_SERIAL_TARGET(${INPUT_NAME} "${INPUT_SERIAL}" "${INPUT_PORT}")
    endif ()
endfunction()
