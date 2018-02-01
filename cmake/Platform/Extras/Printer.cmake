#=============================================================================#
# PRINT_BOARD_LIST
# [PUBLIC/USER]
#
# PRINT_BOARD_LIST()
#
# see documentation at top
#=============================================================================#
function(PRINT_BOARD_LIST)
    foreach (PLATFORM ${ARDUINO_PLATFORMS})
        if (${PLATFORM}_BOARDS)
            message(STATUS "${PLATFORM} Boards:")
            PRINT_LIST(${PLATFORM}_BOARDS)
            message(STATUS "")
        endif ()
    endforeach ()
endfunction()

#=============================================================================#
# PRINT_PROGRAMMER_LIST
# [PUBLIC/USER]
#
# PRINT_PROGRAMMER_LIST()
#
# see documentation at top
#=============================================================================#
function(PRINT_PROGRAMMER_LIST)
    foreach (PLATFORM ${ARDUINO_PLATFORMS})
        if (${PLATFORM}_PROGRAMMERS)
            message(STATUS "${PLATFORM} Programmers:")
            PRINT_LIST(${PLATFORM}_PROGRAMMERS)
        endif ()
        message(STATUS "")
    endforeach ()
endfunction()

#=============================================================================#
# PRINT_PROGRAMMER_SETTINGS
# [PUBLIC/USER]
#
# PRINT_PROGRAMMER_SETTINGS(PROGRAMMER)
#
# see documentation at top
#=============================================================================#
function(PRINT_PROGRAMMER_SETTINGS PROGRAMMER)
    if (${PROGRAMMER}.SETTINGS)
        message(STATUS "Programmer ${PROGRAMMER} Settings:")
        PRINT_SETTINGS(${PROGRAMMER})
    endif ()
endfunction()

#=============================================================================#
# PRINT_BOARD_SETTINGS
# [PUBLIC/USER]
#
# PRINT_BOARD_SETTINGS(ARDUINO_BOARD)
#
# see documentation at top
function(PRINT_BOARD_SETTINGS ARDUINO_BOARD)
    if (${ARDUINO_BOARD}.SETTINGS)
        message(STATUS "Arduino ${ARDUINO_BOARD} Board:")
        PRINT_SETTINGS(${ARDUINO_BOARD})
    endif ()
endfunction()

#=============================================================================#
# PRINT_SETTINGS
# [PRIVATE/INTERNAL]
#
# PRINT_SETTINGS(ENTRY_NAME)
#
#      ENTRY_NAME - name of entry
#
# Print the entry settings (see load_arduino_syle_settings()).
#
#=============================================================================#
function(PRINT_SETTINGS ENTRY_NAME)
    if (${ENTRY_NAME}.SETTINGS)

        foreach (ENTRY_SETTING ${${ENTRY_NAME}.SETTINGS})
            if (${ENTRY_NAME}.${ENTRY_SETTING})
                message(STATUS "   ${ENTRY_NAME}.${ENTRY_SETTING}=${${ENTRY_NAME}.${ENTRY_SETTING}}")
            endif ()
            if (${ENTRY_NAME}.${ENTRY_SETTING}.SUBSETTINGS)
                foreach (ENTRY_SUBSETTING ${${ENTRY_NAME}.${ENTRY_SETTING}.SUBSETTINGS})
                    if (${ENTRY_NAME}.${ENTRY_SETTING}.${ENTRY_SUBSETTING})
                        message(STATUS "   ${ENTRY_NAME}.${ENTRY_SETTING}.${ENTRY_SUBSETTING}=${${ENTRY_NAME}.${ENTRY_SETTING}.${ENTRY_SUBSETTING}}")
                    endif ()
                endforeach ()
            endif ()
            message(STATUS "")
        endforeach ()
    endif ()
endfunction()

#=============================================================================#
# PRINT_LIST
# [PRIVATE/INTERNAL]
#
# PRINT_LIST(SETTINGS_LIST)
#
#      SETTINGS_LIST - Variables name of settings list
#
# Print list settings and names (see load_arduino_syle_settings()).
#=============================================================================#
function(PRINT_LIST SETTINGS_LIST)
    if (${SETTINGS_LIST})
        set(MAX_LENGTH 0)
        foreach (ENTRY_NAME ${${SETTINGS_LIST}})
            string(LENGTH "${ENTRY_NAME}" CURRENT_LENGTH)
            if (CURRENT_LENGTH GREATER MAX_LENGTH)
                set(MAX_LENGTH ${CURRENT_LENGTH})
            endif ()
        endforeach ()
        foreach (ENTRY_NAME ${${SETTINGS_LIST}})
            string(LENGTH "${ENTRY_NAME}" CURRENT_LENGTH)
            math(EXPR PADDING_LENGTH "${MAX_LENGTH}-${CURRENT_LENGTH}")
            set(PADDING "")
            foreach (X RANGE ${PADDING_LENGTH})
                set(PADDING "${PADDING} ")
            endforeach ()
            message(STATUS "   ${PADDING}${ENTRY_NAME}: ${${ENTRY_NAME}.name}")
        endforeach ()
    endif ()
endfunction()
