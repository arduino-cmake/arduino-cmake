# This configuration file outlines some of the ways Arduino CMake
# can be used. For a detailed explenation of all the options please
# reade README.rst.

set(ARDUINO_DEFAULT_BOARD uno) # Default Board ID, when not specified
set(ARDUINO_DEFAULT_PORT /dev/ttyUSB0) # Default Port, when not specified

#====================================================================#
# master_writer example from Wire library
#====================================================================#
GENERATE_ARDUINO_LIBRARY_EXAMPLE(wire_example
        LIBRARY Wire
        EXAMPLE master_writer
        BOARD uno)

# Alternative: by vairables
#set(wire_example_LIBRARY Wire)
#set(wire_example_EXAMPLE master_writer)
#set(blink_example_BOARD uno)
#generate_arduino_example(wire_example)

#====================================================================#
# Original blink example (from Arduino SDK examples)
#====================================================================#
GENERATE_ARDUINO_EXAMPLE(blink_example
        CATEGORY Basics
        EXAMPLE Blink
        BOARD uno)

# Alternative: by variables
#set(blink_example_CATEGORY Basics)
#set(blink_example_EXAMPLE Blink)
#set(blink_example_PORT  /dev/ttyACM)
#set(blink_example_BOARD uno)
#
#generate_arduino_firmware(blink_original)

#====================================================================#
# Original blink sketch (from Arduino SDK examples)
#====================================================================#

# Some installations have renamed the example directories
if (EXISTS "${ARDUINO_SDK_PATH}/examples/01.Basics/Blink")
    set(BLINK_SKETCH "${ARDUINO_SDK_PATH}/examples/01.Basics/Blink")
    set(BLINK_FILE_SKETCH "${ARDUINO_SDK_PATH}/examples/01.Basics/Blink/Blink.ino")
else ()
    set(BLINK_SKETCH "${ARDUINO_SDK_PATH}/examples/1.Basics/Blink")
endif ()

generate_arduino_firmware(blink_original
        SKETCH "${BLINK_SKETCH}"
        PORT /dev/ttyACM0
        SERIAL picocom @SERIAL_PORT@
        BOARD uno)

GENERATE_ARDUINO_FIRMWARE(blink_file_original
        SKETCH "${BLINK_FILE_SKETCH}"
        BOARD uno)

# Alternative: by variables
#set(blink_original_SKETCH "${BLINK_SKETCH}")
#set(blink_original_PORT  /dev/ttyACM)
#set(blink_original_SERIAL picocom @SERIAL_PORT@)
#set(blink_original_BOARD uno)
#
#generate_arduino_firmware(blink_original)


#====================================================================#
# Bundled blink sketch example
#====================================================================#
generate_arduino_firmware(blink_bundled
        SKETCH Blink
        PROGRAMMER usbtinyisp
        NO_AUTOLIBS)

# Alternative: by variables
#set(blink_bundled_SKETCH Blink)
#set(blink_bundled_PROGRAMMER usbtinyisp)
#set(blink_bundled_NO_AUTOLIBS true)
#
#generate_arduino_firmware(blink_bundled)


#====================================================================#
# Advanced static library exmaple
#====================================================================#
generate_arduino_library(blink_lib
        SRCS blink_lib.cpp
        HDRS blink_lib.h
        BOARD uno)

# Alternative: by variables
#set(blink_lib_SRCS blink_lib.cpp)
#set(blink_lib_HDRS blink_lib.h)
#set(blink_lib_BOARD uno)
#
#generate_arduino_library(blink_lib)


#====================================================================#
# Advanced firwmare example
#====================================================================#
generate_arduino_firmware(blink
        SRCS blink.cpp
        LIBS blink_lib
        BOARD nano
        BOARD_CPU atmega328
        PORT com4
        )

# Alternative: by variables
#set(blink_SRCS blink.cpp)
#set(blink_LIBS blink_lib)
#set(blink_BOARD uno)
#
#generate_arduino_firmware(blink)

#====================================================================#
# Avr library linkage without copying lib to local directory
#====================================================================#

GENERATE_ARDUINO_FIRMWARE(serial_lib
        SRCS serial.cpp
        ARDLIBS SoftwareSerial
        BOARD leonardo)

# Alternative: by variables
#set(blink_SRCS serial.cpp)
#set(blink_ARDLIBS SoftwareSerial)
#set(blink_BOARD uno)
#
#generate_arduino_firmware(blink)

#====================================================================#
# Overrides USB properties for leonardo board
#====================================================================#
OVERRIDE_USB_PROPERTIES(
        BOARD leonardo
        VID 0x1234
        PID 0x4567
        PRODUCT "Tamagotchi Pet"
        MANUFACTURER "My Board Factory"
        FORCE #this will force to create properties if not exists
)
