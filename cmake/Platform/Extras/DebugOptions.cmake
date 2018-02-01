#=============================================================================#
# ARDUINO_DEBUG_ON()
# [PRIVATE/INTERNAL]
#
#  ARDUINO_DEBUG_ON()
#
# Enables Arduino module debugging.
#=============================================================================#
function(ARDUINO_DEBUG_ON)
    set(ARDUINO_DEBUG True PARENT_SCOPE)
endfunction()

#=============================================================================#
# ARDUINO_DEBUG_ON()
# [PRIVATE/INTERNAL]
#
#  ARDUINO_DEBUG_OFF()
#
# Disables Arduino module debugging.
#=============================================================================#
function(ARDUINO_DEBUG_OFF)
    set(ARDUINO_DEBUG False PARENT_SCOPE)
endfunction()

#=============================================================================#
# ARDUINO_DEBUG_MSG
# [PRIVATE/INTERNAL]
#
# ARDUINO_DEBUG_MSG(MSG)
#
#        MSG - Message to print
#
# Print Arduino debugging information. In order to enable printing
# use ARDUINO_DEBUG_ON() and to disable use ARDUINO_DEBUG_OFF().
#=============================================================================#
function(ARDUINO_DEBUG_MSG MSG)
    if (ARDUINO_DEBUG)
        message("## ${MSG}")
    endif ()
endfunction()
