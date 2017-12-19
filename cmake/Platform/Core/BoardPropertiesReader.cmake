#=============================================================================#
# _get_board_id
# [PRIVATE/INTERNAL]
#
# _get_board_id(BOARD_NAME BOARD_CPU TARGET_NAME OUTPUT_VAR)
#
#        BOARD_NAME - name of the board, eg.: nano, uno, etc...
#        BOARD_CPU - come boards has multiple versions with different cpus, eg.: nano has atmega168 and atmega328
#        TARGET_NAME - name of the build target, used to show clearer error message
#        OUT_VAR - BOARD_ID constructed from BOARD_NAME and BOARD_CPU
#
# returns BOARD_ID constructing from BOARD_NAME and BOARD_CPU, if board doesn't has multiple cpus then BOARD_ID = BOARD_NAME
# if board has multiple CPUS, and BOARD_CPU is not defined or incorrect, fatal error will be invoked.
#=============================================================================#
function(_GET_BOARD_ID BOARD_NAME BOARD_CPU TARGET_NAME OUTPUT_VAR)
    if (${BOARD_NAME}.menu.CPUS)
        if (BOARD_CPU)
            LIST(FIND ${BOARD_NAME}.menu.CPUS ${BOARD_CPU} CPU_INDEX)
            if (CPU_INDEX EQUAL -1)
                message(FATAL_ERROR "Invalid BOARD_CPU (valid cpus: ${${BOARD_NAME}.menu.CPUS}).")
            endif()
        else()
            message(FATAL_ERROR "Board has multiple CPU versions (${${BOARD_NAME}.menu.CPUS}). BOARD_CPU must be defined for target ${TARGET_NAME}.")
        endif()
        set(${OUTPUT_VAR} ${BOARD_NAME}.${BOARD_CPU} PARENT_SCOPE)
    else()
        set(${OUTPUT_VAR} ${BOARD_NAME} PARENT_SCOPE)
    endif()
endfunction()

#=============================================================================#
# _get_board_property
# [PRIVATE/INTERNAL]
#
# _get_board_property(BOARD_ID PROPERTY_NAME OUTPUT_VAR)
#
#        BOARD_ID - return value from function "_get_board_id (BOARD_NAME, BOARD_CPU)". It contains BOARD_NAME and BOARD_CPU
#        PROPERTY_NAME - property name for the board, eg.: bootloader.high_fuses
#        OUT_VAR - variable holding value for the property
#
# Gets board property.
# Reconstructs BOARD_NAME and BOARD_CPU from BOARD_ID and tries to find value at ${BOARD_NAME}.${PROPERTY_NAME},
# if not found than try to find value at ${BOARD_NAME}.menu.cpu.${BOARD_CPU}.${PROPERTY_NAME}
# if not found that show fatal error
#=============================================================================#
function(_GET_BOARD_PROPERTY BOARD_ID PROPERTY_NAME OUTPUT_VAR)
    string(REPLACE "." ";" BOARD_INFO ${BOARD_ID})
    list(GET BOARD_INFO 0 BOARD_NAME)
    set(VALUE ${${BOARD_NAME}.${PROPERTY_NAME}})
    if(NOT VALUE)
        list(LENGTH BOARD_INFO INFO_PARAMS_COUNT)
        if (${INFO_PARAMS_COUNT} EQUAL 2)
            list(GET BOARD_INFO 1 BOARD_CPU)
            VALIDATE_VARIABLES_NOT_EMPTY(VARS BOARD_CPU MSG "cannot find CPU info, must define BOARD_CPU.")
            set(VALUE ${${BOARD_NAME}.menu.cpu.${BOARD_CPU}.${PROPERTY_NAME}})
        endif()
    endif()
    if (NOT VALUE)
        message(FATAL_ERROR "Board info not found: BoardName='${BOARD_NAME}' BoardCPU='${BOARD_CPU}' PropertyName='${PROPERTY_NAME}'")
    endif()
    set(${OUTPUT_VAR} ${VALUE} PARENT_SCOPE)
endfunction()

#=============================================================================#
# _try_get_board_property
# [PRIVATE/INTERNAL]
#
# _try_get_board_property(BOARD_ID PROPERTY_NAME OUTPUT_VAR)
#
#        BOARD_ID - return value from function "_get_board_id (BOARD_NAME, BOARD_CPU)". It contains BOARD_NAME and BOARD_CPU
#        PROPERTY_NAME - property name for the board, eg.: bootloader.high_fuses
#        OUT_VAR - variable holding value for the property
#
# Similar to _get_board_property, except it returns empty value if value was not found.
#=============================================================================#
function(_try_get_board_property BOARD_ID PROPERTY_NAME OUTPUT_VAR)
    string(REPLACE "." ";" BOARD_INFO ${BOARD_ID})
    list(GET BOARD_INFO 0 BOARD_NAME)
    set(VALUE ${${BOARD_NAME}.${PROPERTY_NAME}})
    if(NOT VALUE)
        list(LENGTH BOARD_INFO INFO_PARAMS_COUNT)
        if (${INFO_PARAMS_COUNT} EQUAL 2)
            list(GET BOARD_INFO 1 BOARD_CPU)
            VALIDATE_VARIABLES_NOT_EMPTY(VARS BOARD_CPU MSG "cannot find CPU info, must define BOARD_CPU.")
            set(VALUE ${${BOARD_NAME}.menu.cpu.${BOARD_CPU}.${PROPERTY_NAME}})
        endif()
    endif()
    set(${OUTPUT_VAR} ${VALUE} PARENT_SCOPE)
endfunction()

#=============================================================================#
# _override_board_property
# [PRIVATE/INTERNAL]
#
# _override_board_property(BOARD_ID PROPERTY_NAME NEW_VALUE CREATE_IF_NOT_EXISTS)
#
#        BOARD_ID - return value from function "_get_board_id (BOARD_NAME, BOARD_CPU)". It contains BOARD_NAME and BOARD_CPU
#        PROPERTY_NAME - property name for the board, eg.: bootloader.high_fuses
#        NEW_VALUE - override existing value with new value
#        CREATE_IF_NOT_EXISTS - if true, then creates new value if not exists, otherwise show fatal error
#
# Overrides board property.
# Finds property, and overrides its value.
# If property doesn't exists, CREATE_IF_NOT_EXISTS controls if it should create new property or show fatal error.
#=============================================================================#
function(_OVERRIDE_BOARD_PROPERTY BOARD_ID PROPERTY_NAME NEW_VALUE CREATE_IF_NOT_EXISTS)
    string(REPLACE "." ";" BOARD_INFO ${BOARD_ID})
    list(LENGTH BOARD_INFO INFO_PARAMS_COUNT)
    list(GET BOARD_INFO 0 BOARD_NAME)
    _try_get_board_property(${BOARD_ID} ${PROPERTY_NAME} OLD_VALUE)
    if (OLD_VALUE OR ${CREATE_IF_NOT_EXISTS})
        set(FULL_PROP_NAME ${BOARD_NAME}.menu.cpu.${BOARD_CPU}.${PROPERTY_NAME})
        if (NOT ${FULL_PROP_NAME})
            set(FULL_PROP_NAME ${BOARD_NAME}.${PROPERTY_NAME})
        endif()
        set(${FULL_PROP_NAME} ${NEW_VALUE} CACHE INTERNAL "Property was overrided")
    else()
        message(FATAL_ERROR "Property ${PROPERTY_NAME} was not found for the board ${BOARD_ID}.")
    endif()
endfunction()

#=============================================================================#
# GENERATE_ARDUINO_FIRMWARE
# [PUBLIC/USER]
# see documentation at README
#=============================================================================#
function(OVERRIDE_USB_PROPERTIES)
    parse_generator_arguments("" INPUT
            "FORCE"                                     # Options
            "BOARD;BOARD_CPU;VID;PID;PRODUCT;MANUFACTURER" # One Value Keywords
            ""                                     # Multi Value Keywords
            ${ARGN})
    _get_board_id(${INPUT_BOARD} "${INPUT_BOARD_CPU}" "" BOARD_ID)
    if (INPUT_VID)
        _override_board_property(${BOARD_ID} build.vid ${INPUT_VID} ${INPUT_FORCE})
    endif()
    if (INPUT_PID)
        _override_board_property(${BOARD_ID} build.pid ${INPUT_PID} ${INPUT_FORCE})
    endif()
    if (INPUT_PRODUCT)
        #escape value because it is used as a string
        _override_board_property(${BOARD_ID} build.usb_product \"${INPUT_PRODUCT}\" ${INPUT_FORCE})
    endif()
    if (INPUT_MANUFACTURER)
        #escape value because it is used as a string
        _override_board_property(${BOARD_ID} build.usb_manufacturer \"${INPUT_MANUFACTURER}\" ${INPUT_FORCE})
    endif()
endfunction()
