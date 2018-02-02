#=============================================================================#
# _SANITIZE_QUOTES
# [PRIVATE/INTERNAL]
#
# _SANITIZE_QUOTES(CMD_LINE_VARIABLE)
#
#       CMD_LINE_VARIABLE - Variable holding a shell command line 
#                           or command line flag(s) that potentially 
#                           require(s) quotes to be fixed.
#
# Replaces Unix-style quotes with Windows-style quotes.
# '-DSOME_MACRO="foo"' would become "-DSOME_MACRO=\"foo\"".
#
#=============================================================================#
function(_SANITIZE_QUOTES
   CMD_LINE_VARIABLE
)
   if(CMAKE_HOST_WIN32)
   
      # Important: The order of the statements below does matter!
   
      # First replace all occurences of " with \"
      #
      string(REPLACE "\"" "\\\"" output "${${CMD_LINE_VARIABLE}}")
      
      # Then replace all ' with "
      #
      string(REPLACE "'" "\"" output "${output}")
      
      set(${CMD_LINE_VARIABLE} "${output}" PARENT_SCOPE)
   endif()
endfunction()

# ToDo: Comment
function(SET_BOARD_COMPILER_FLAGS COMPILER_FLAGS NORMALIZED_SDK_VERSION BOARD_ID IS_MANUAL)

    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} build.f_cpu FCPU)
    if(NOT "${FCPU}" STREQUAL "")
       set(COMPILE_FLAGS "-DF_CPU=${FCPU}")
    endif()
    
    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} build.mcu MCU)    
    if(NOT "${MCU}" STREQUAL "")
       set(COMPILE_FLAGS "${COMPILE_FLAGS} -mmcu=${MCU}")
    endif()
    
    set(COMPILE_FLAGS "${COMPILE_FLAGS} -DARDUINO=${NORMALIZED_SDK_VERSION}")

    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} build.vid VID)
    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} build.pid PID)
    if (VID)
        set(COMPILE_FLAGS "${COMPILE_FLAGS} -DUSB_VID=${VID}")
    endif ()
    if (PID)
        set(COMPILE_FLAGS "${COMPILE_FLAGS} -DUSB_PID=${PID}")
    endif ()
    
    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} build.extra_flags EXTRA_FLAGS)

    if(NOT "${EXTRA_FLAGS}" STREQUAL "")
       _SANITIZE_QUOTES(EXTRA_FLAGS)
       set(COMPILE_FLAGS "${COMPILE_FLAGS} ${EXTRA_FLAGS}")
    endif()
    
    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} build.usb_flags USB_FLAGS)
    if(NOT "${USB_FLAGS}" STREQUAL "")
       _SANITIZE_QUOTES(USB_FLAGS)
       set(COMPILE_FLAGS "${COMPILE_FLAGS} ${USB_FLAGS}")
    endif()

    if (NOT IS_MANUAL)
        _GET_BOARD_PROPERTY(${BOARD_ID} build.core BOARD_CORE)
        set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${${BOARD_CORE}.path}\" -I\"${ARDUINO_LIBRARIES_PATH}\"")
        if (${ARDUINO_PLATFORM_LIBRARIES_PATH})
            set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${ARDUINO_PLATFORM_LIBRARIES_PATH}\"")
        endif ()
    endif ()
    if (ARDUINO_SDK_VERSION VERSION_GREATER 1.0 OR ARDUINO_SDK_VERSION VERSION_EQUAL 1.0)
        if (NOT IS_MANUAL)
            _GET_BOARD_PROPERTY(${BOARD_ID} build.variant VARIANT)
            set(PIN_HEADER ${${VARIANT}.path})
            if (PIN_HEADER)
                set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${PIN_HEADER}\"")
            endif ()
        endif ()
    endif ()

    set(${COMPILER_FLAGS} "${COMPILE_FLAGS}" PARENT_SCOPE)

endfunction()
