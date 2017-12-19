#=============================================================================#
# _get_arduino_version_define
# [PRIVATE/INTERNAL]
#
# _get_arduino_version_define(OUTPUT_VAR)
#
#       OUTPUT_VAR - Returned variable storing the normalized version
#
# Normalizes SDK's version for a proper use of the '-DARDUINO' compile flag.
# Note that there are differences between normalized versions in specific SDK versions:
#       SDK Version 1.5.8 and above - Appends zeros to version parts.
#                                     e.g Version 1.6.5 will be normalized as 10605
#       SDK Versions between 1.0.0 and 1.5.8 - Joins all version parts together.
#                                              e.g Version 1.5.3 will be normalized as 153
#       SDK Version 1.0.0 and below - Uses only the 'Minor' version part.
#                                     e.g Version 0.20.0 will be normalized as 20
#
#=============================================================================#
function(_get_arduino_version_define OUTPUT_VAR)

    if (${ARDUINO_SDK_VERSION} VERSION_GREATER 1.5.8)
        # -DARDUINO format has changed since 1.6.0 by appending zeros when required,
        # e.g for 1.6.5 version -DARDUINO=10605
        _append_suffix_zero_to_version_if_required(${ARDUINO_SDK_VERSION_MAJOR} 10 MAJOR_VERSION)
        _append_suffix_zero_to_version_if_required(${ARDUINO_SDK_VERSION_MINOR} 10 MINOR_VERSION)
        set(NORMALIZED_VERSION
                "${MAJOR_VERSION}${MINOR_VERSION}${ARDUINO_SDK_VERSION_PATCH}")
    else ()
        # -DARDUINO format before 1.0.0 uses only minor version,
        # e.g. for 0020 version -DARDUINO=20
        if (${ARDUINO_SDK_VERSION} VERSION_LESS 1.0.0)
            set(NORMALIZED_VERSION "${ARDUINO_SDK_VERSION_MINOR}")
        else ()
            # -DARDUINO format after 1.0.0 combines all 3 version parts together,
            # e.g. for 1.5.3 version -DARDUINO=153
            set(NORMALIZED_VERSION
                    "${ARDUINO_SDK_VERSION_MAJOR}\
            ${ARDUINO_SDK_VERSION_MINOR}\
            ${ARDUINO_SDK_VERSION_PATCH}")
        endif ()
    endif ()

    set(${OUTPUT_VAR} ${NORMALIZED_VERSION} PARENT_SCOPE)

endfunction()

#=============================================================================#
# _append_suffix_zero_to_version_if_required
# [PRIVATE/INTERNAL]
#
# _append_suffix_zero_to_version_if_required(VERSION_PART VERSION_LIMIT OUTPUT_VAR)
#
#       VERSION_PART - Version to check and possibly append to.
#                 Must be a version part - Major, Minor or Patch.
#       VERSION_LIMIT - Append limit. For a version greater than this number
#                       a zero will NOT be appended.
#       OUTPUT_VAR - Returned variable storing the normalized version.
#
# Appends a suffic zero to the given version part if it's below than the given limit.
# Otherwise, the version part is returned as it is.
#
#=============================================================================#
macro(_append_suffix_zero_to_version_if_required VERSION_PART VERSION_LIMIT OUTPUT_VAR)
    if (${VERSION_PART} LESS ${VERSION_LIMIT})
        set(${OUTPUT_VAR} "${VERSION_PART}0")
    else ()
        set(${OUTPUT_VAR} "${VERSION_PART}")
    endif ()
endmacro()

#=============================================================================#
# _get_board_compile_defines
# [PRIVATE/INTERNAL]
#
# _get_board_compile_defines(DEFINES BOARD_ID)
#
#       DEFINES - Returned variable storing list of defines for the board
#       BOARD_ID - BoardId.
#
# Gets defines list for specific board BOARD_ID, these defines are required by most arduino libraries
#
#=============================================================================#
function(_get_board_compile_defines DEFINES BOARD_ID)
    _get_arduino_version_define(ARDUINO_VERSION_DEFINE)
    _get_board_property(${BOARD_ID} build.f_cpu FCPU)
    _get_board_property(${BOARD_ID} build.board BOARD_NAME)
    _get_board_property(${BOARD_ID} build.core BOARD_CORE)

    set(FLAGS)
    list(APPEND FLAGS F_CPU=${FCPU})
    list(APPEND FLAGS ARDUINO=${ARDUINO_VERSION_DEFINE})
    list(APPEND FLAGS ARDUINO_${BOARD_NAME})

    #get core architecture
    set(ARCHITECTURE ${${BOARD_CORE}.arch})
    list(APPEND FLAGS ARDUINO_ARCH_${ARCHITECTURE})

    _try_get_board_property(${BOARD_ID} build.vid VID)
    _try_get_board_property(${BOARD_ID} build.pid PID)
    _try_get_board_property(${BOARD_ID} build.usb_product USB_PRODUCT)

    if (VID)
        list(APPEND FLAGS USB_VID=${VID})
    endif ()
    if (PID)
        list(APPEND FLAGS USB_PID=${PID})
    endif ()
    if (USB_PRODUCT)
        _try_get_board_property(${BOARD_ID} build.usb_manufacturer USB_MANUFACTURER)
        if(NOT USB_MANUFACTURER)
            set(USB_MANUFACTURER \"Unknown\")
        endif()
        list(APPEND FLAGS USB_MANUFACTURER=${USB_MANUFACTURER})
        list(APPEND FLAGS USB_PRODUCT=${USB_PRODUCT})
    endif()

    set(${DEFINES} "${FLAGS}" PARENT_SCOPE)

endfunction()

#=============================================================================#
# _get_board_compile_options
# [PRIVATE/INTERNAL]
#
# _get_board_compile_options(OPTIONS BOARD_ID)
#
#       OPTIONS - Returned variable storing list of compile options
#       BOARD_ID - BoardId.
#
# Gets compile options specific for board BOARD_ID, other compile options is globaly set
#
#=============================================================================#
function(_get_board_compile_options OPTIONS BOARD_ID)
    _get_board_property(${BOARD_ID} build.mcu MCU)
    set(${OPTIONS} -mmcu=${MCU} PARENT_SCOPE)
endfunction()

#=============================================================================#
# _get_board_compile_includes
# [PRIVATE/INTERNAL]
#
# _get_board_compile_includes(INCLUDES BOARD_ID)
#
#       INCLUDES - Returned variable storing list of include directories
#       BOARD_ID - BoardId.
#
# Gets include directories only for board BOARD_ID
#=============================================================================#
function(_get_board_compile_includes INCLUDES BOARD_ID)
    _get_board_property(${BOARD_ID} build.core BOARD_CORE)
    set(ALL_INCLUDES ${${BOARD_CORE}.path})
    _try_get_board_property(${BOARD_ID} build.variant VARIANT)
    if (VARIANT)
        set(PIN_HEADER ${${VARIANT}.path})
        if (PIN_HEADER)
            list(APPEND ALL_INCLUDES ${PIN_HEADER})
        endif ()
    endif()

    set(${INCLUDES} ${ALL_INCLUDES} PARENT_SCOPE)

endfunction()

#=============================================================================#
# _set_board_compile_flags
# [PRIVATE/INTERNAL]
#
# _set_board_compile_flags(TARGET_NAME BOARD_ID INCLUDE_PATHS IS_MANUAL)
#
#       TARGET_NAME - cmake target
#       BOARD_ID - The board id name
#       INCLUDE_PATHS - Variable holding additional include directories to build target
#       IS_MANUAL - doesn't automatically include board specific directories
#
# Sets compile flags for the specified Arduino Board cmake target.
#
#=============================================================================#
function(_set_board_compile_flags TARGET_NAME BOARD_ID INCLUDE_PATHS IS_MANUAL)
    _get_board_compile_options(BOARD_COMPILE_OPTIONS ${BOARD_ID})
    _get_board_compile_defines(BOARD_COMPILE_DEFINES ${BOARD_ID})
    if (NOT IS_MANUAL)
        _get_board_compile_includes(BOARD_COMPILE_INCLUDES ${BOARD_ID})
    endif()
    target_compile_options(${TARGET_NAME} PRIVATE ${BOARD_COMPILE_OPTIONS})
    target_compile_definitions(${TARGET_NAME} PRIVATE ${BOARD_COMPILE_DEFINES})
    target_include_directories(${TARGET_NAME} PRIVATE ${INCLUDE_PATHS} ${BOARD_COMPILE_INCLUDES})
endfunction()
