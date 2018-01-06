#=============================================================================#
# make_core_library
# [PRIVATE/INTERNAL]
#
# make_core_library(OUTPUT_VAR BOARD_ID)
#
#        OUTPUT_VAR - Variable name that will hold the generated library name
#        BOARD_ID - Arduino board id
#
# Creates the Arduino Core library for the specified board,
# each board gets it's own version of the library.
#
#=============================================================================#
function(make_core_library OUTPUT_VAR BOARD_ID)
    set(CORE_LIB_NAME ${BOARD_ID}_CORE)
    _get_board_property(${BOARD_ID} build.core BOARD_CORE)
    if (BOARD_CORE)
        if (NOT TARGET ${CORE_LIB_NAME})

            # The boards.txt file allows referencing a core from different vendor.
            # Removing the vendor prefix allows the configuration to succeed if the
            # <BOARD>_CORES_PATH is correctly set. For syntax details see:
            # https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5-3rd-party-Hardware-specification#referencing-another-core-variant-or-tool
            string(REGEX REPLACE "^.*:" "" BOARD_CORE ${BOARD_CORE})

            set(BOARD_CORE_PATH ${${BOARD_CORE}.path})
            find_sources(CORE_SRCS ${BOARD_CORE_PATH} True)
            # Debian/Ubuntu fix
            list(REMOVE_ITEM CORE_SRCS "${BOARD_CORE_PATH}/main.cxx")
            add_library(${CORE_LIB_NAME} ${CORE_SRCS})
            set_board_flags(ARDUINO_COMPILE_FLAGS ARDUINO_LINK_FLAGS ${BOARD_ID} FALSE)
            set_target_properties(${CORE_LIB_NAME} PROPERTIES
                    COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS}"
                    LINK_FLAGS "${ARDUINO_LINK_FLAGS}")
        endif ()
        set(${OUTPUT_VAR} ${CORE_LIB_NAME} PARENT_SCOPE)
    endif ()
endfunction()
