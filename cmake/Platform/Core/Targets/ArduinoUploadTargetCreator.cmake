include(ArduinoBootloaderUploadTargetCreator)

#=============================================================================#
# CREATE_ARDUINO_UPLOAD_TARGET
# [PRIVATE/INTERNAL]
#
# CREATE_ARDUINO_UPLOAD_TARGET(BOARD_ID TARGET_NAME PORT)
#
#        BOARD_ID    - Arduino board id
#        TARGET_NAME - Target name
#        PORT        - Serial port for upload
#        PROGRAMMER_ID - Programmer ID
#        AVRDUDE_FLAGS - avrdude flags
#
# Create an upload target (${TARGET_NAME}-upload) for the specified Arduino target.
#
#=============================================================================#
function(CREATE_ARDUINO_UPLOAD_TARGET BOARD_ID TARGET_NAME PORT PROGRAMMER_ID AVRDUDE_FLAGS)
    CREATE_ARDUINO_BOOTLOADER_UPLOAD_TARGET(${TARGET_NAME} ${BOARD_ID} ${PORT} "${AVRDUDE_FLAGS}")

    # Add programmer support if defined
    if (PROGRAMMER_ID AND ${PROGRAMMER_ID}.protocol)
        CREATE_ARDUINO_PROGRAMMER_BURN_TARGET(${TARGET_NAME} ${BOARD_ID} ${PROGRAMMER_ID} ${PORT} "${AVRDUDE_FLAGS}")
        CREATE_ARDUINO_BOOTLOADER_BURN_TARGET(${TARGET_NAME} ${BOARD_ID} ${PROGRAMMER_ID} ${PORT} "${AVRDUDE_FLAGS}")
    endif ()
endfunction()
