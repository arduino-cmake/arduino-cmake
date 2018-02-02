#=============================================================================#
# MAKE_CORE_LIBRARY
# [PRIVATE/INTERNAL]
#
# MAKE_CORE_LIBRARY(OUTPUT_VAR BOARD_ID)
#
#        OUTPUT_VAR - Variable name that will hold the generated library name
#        BOARD_ID - Arduino board id
#
# Creates the Arduino Core library for the specified board,
# each board gets it's own version of the library.
#
#=============================================================================#
function(MAKE_CORE_LIBRARY OUTPUT_VAR BOARD_ID)
    set(CORE_LIB_NAME ${BOARD_ID}_CORE)
    _GET_BOARD_PROPERTY(${BOARD_ID} build.core BOARD_CORE)
    if (BOARD_CORE)
        if (NOT TARGET ${CORE_LIB_NAME})
            set(BOARD_CORE_PATH ${${BOARD_CORE}.path})
            FIND_SOURCES(CORE_SRCS ${BOARD_CORE_PATH} True)
            # Debian/Ubuntu fix
            list(REMOVE_ITEM CORE_SRCS "${BOARD_CORE_PATH}/main.cxx")
            add_library(${CORE_LIB_NAME} ${CORE_SRCS})
            SET_BOARD_FLAGS(ARDUINO_COMPILE_FLAGS ARDUINO_LINK_FLAGS ${BOARD_ID} FALSE)
            set_target_properties(${CORE_LIB_NAME} PROPERTIES
                    COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS}"
                    LINK_FLAGS "${ARDUINO_LINK_FLAGS}")
        endif ()
        set(${OUTPUT_VAR} ${CORE_LIB_NAME} PARENT_SCOPE)
    endif ()
endfunction()
