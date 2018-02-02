#=============================================================================#
# BUILD_ARDUINO_BOOTLOADER_ARGUMENTS
# [PRIVATE/INTERNAL]
#
# BUILD_ARDUINO_BOOTLOADER_ARGUMENTS(BOARD_ID TARGET_NAME PORT AVRDUDE_FLAGS OUTPUT_VAR)
#
#      BOARD_ID    - board id
#      TARGET_NAME - target name
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
#      OUTPUT_VAR  - name of output variable for result
#
# Sets up default avrdude settings for uploading firmware via the bootloader.
#=============================================================================#
function(BUILD_ARDUINO_BOOTLOADER_ARGUMENTS BOARD_ID TARGET_NAME PORT AVRDUDE_FLAGS OUTPUT_VAR)
    set(AVRDUDE_ARGS ${${OUTPUT_VAR}})

    if (NOT AVRDUDE_FLAGS)
        set(AVRDUDE_FLAGS ${ARDUINO_AVRDUDE_FLAGS})
    endif ()
    
    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} build.mcu MCU)
    if(NOT "${MCU}" STREQUAL "")
       list(APPEND AVRDUDE_ARGS
            "-p${MCU}"        # MCU Type
            )
    endif()
    
    list(APPEND AVRDUDE_ARGS
            "-C${ARDUINO_AVRDUDE_CONFIG_PATH}"  # avrdude config
            )

    # Programmer
    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} upload.protocol UPLOAD_PROTOCOL)
    if(NOT "${UPLOAD_PROTOCOL}" STREQUAL "")
      if (${UPLOAD_PROTOCOL} STREQUAL "stk500")
         list(APPEND AVRDUDE_ARGS "-cstk500v1")
      else ()
         list(APPEND AVRDUDE_ARGS "-c${UPLOAD_PROTOCOL}")
      endif ()
    endif()

    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} upload.speed UPLOAD_SPEED)
    if(NOT "${UPLOAD_SPEED}" STREQUAL "")
        list(APPEND AVRDUDE_ARGS
            "-b${UPLOAD_SPEED}"     # Baud rate
            )
    endif()
    
    list(APPEND AVRDUDE_ARGS
            "-P${PORT}"             # Serial port
            "-D"                    # Dont erase
            )

    list(APPEND AVRDUDE_ARGS ${AVRDUDE_FLAGS})

    set(${OUTPUT_VAR} ${AVRDUDE_ARGS} PARENT_SCOPE)

endfunction()
