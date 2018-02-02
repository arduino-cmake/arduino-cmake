if (NOT PLATFORM_PATH)
    # Arduino is assumed as the default platform
    set(PLATFORM_PATH ${ARDUINO_SDK_PATH}/hardware/arduino/)
endif ()
string(REGEX REPLACE "/$" "" PLATFORM_PATH ${PLATFORM_PATH})
get_filename_component(VENDOR_ID ${PLATFORM_PATH} NAME)
get_filename_component(BASE_PATH ${PLATFORM_PATH} PATH)

if (NOT PLATFORM_ARCHITECTURE)
    # avr is the default architecture
    set(PLATFORM_ARCHITECTURE "avr")
endif ()

if (CUSTOM_PLATFORM_REGISTRATION_SCRIPT)
    include("${CUSTOM_PLATFORM_REGISTRATION_SCRIPT}")
else ()
    include(RegisterSpecificHardwarePlatform)
endif ()
