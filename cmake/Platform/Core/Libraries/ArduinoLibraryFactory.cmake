#=============================================================================#
# make_arduino_library
# [PRIVATE/INTERNAL]
#
# make_arduino_library(VAR_NAME BOARD_ID LIB_PATH COMPILE_FLAGS LINK_FLAGS)
#
#        LIB_TARGETS_OUTPUT       - List of libraries names (cmake targets) that was created
#        LIB_INCLUDES_OUTPUT    - List of libraries includes that was created
#        BOARD_ID               - Board ID
#        LIB_PATH               - Path of the library
#
# Creates an Arduino library, with all it's library dependencies.
#
#      ${LIB_NAME}_RECURSE controls if the library will recurse
#      when looking for source files.
#
#=============================================================================#
function(make_arduino_library LIB_TARGETS_OUTPUT LIB_INCLUDES_OUTPUT BOARD_ID LIB_PATH)

    string(REGEX REPLACE "/src/?$" "" LIB_PATH_STRIPPED ${LIB_PATH})
    get_filename_component(LIB_NAME ${LIB_PATH_STRIPPED} NAME)
    set(TARGET_LIB_NAME ${BOARD_ID}_${LIB_NAME})

    if (NOT TARGET ${TARGET_LIB_NAME})
        string(REGEX REPLACE ".*/" "" LIB_SHORT_NAME ${LIB_NAME})

        # Detect if recursion is needed
        if (NOT DEFINED ${LIB_SHORT_NAME}_RECURSE)
            set(${LIB_SHORT_NAME}_RECURSE ${ARDUINO_CMAKE_RECURSION_DEFAULT})
        endif ()

        find_sources(LIB_SRCS ${LIB_PATH} ${${LIB_SHORT_NAME}_RECURSE})
        if (LIB_SRCS)

            arduino_debug_msg("Generating Arduino ${LIB_NAME} library")
            add_library(${TARGET_LIB_NAME} STATIC ${LIB_SRCS})

            find_arduino_libraries(LIB_DEPS "${LIB_SRCS}" "")

            foreach (LIB_DEP ${LIB_DEPS})
                make_arduino_library(DEP_LIB_NAMES DEP_LIB_INCLUDES ${BOARD_ID} ${LIB_DEP})
                list(APPEND LIB_TARGETS ${DEP_LIB_NAMES})
                list(APPEND LIB_INCLUDES ${DEP_LIB_INCLUDES})
            endforeach ()

            list(APPEND LIB_INCLUDES ${LIB_PATH})

            if (LIB_TARGETS)
                list(REMOVE_ITEM LIB_TARGETS ${TARGET_LIB_NAME})
            endif ()

            _set_board_compile_flags(${TARGET_LIB_NAME} ${BOARD_ID} "${LIB_INCLUDES}" FALSE)
            _set_board_link_flags(${TARGET_LIB_NAME} ${BOARD_ID} "${LIB_TARGETS};${BOARD_ID}_CORE")

            list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})

        endif ()

    else ()
        # Target already exists, skiping creating
        list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})
        list(APPEND LIB_INCLUDES ${LIB_PATH})
    endif ()

    if (LIB_TARGETS)
        list(REMOVE_DUPLICATES LIB_TARGETS)
    endif ()
    if (LIB_INCLUDES)
        list(REMOVE_DUPLICATES LIB_INCLUDES)
    endif ()

    set(${LIB_TARGETS_OUTPUT} ${LIB_TARGETS} PARENT_SCOPE)
    set(${LIB_INCLUDES_OUTPUT} ${LIB_INCLUDES} PARENT_SCOPE)

endfunction()

#=============================================================================#
# make_arduino_libraries
# [PRIVATE/INTERNAL]
#
# make_arduino_libraries(VAR_NAME BOARD_ID SRCS COMPILE_FLAGS LINK_FLAGS)
#
#        LIB_TARGETS_OUTPUT  - Vairable wich will hold the generated library names (cmake targets)
#        LIB_INCLUDES_OUTPUT - Vairable wich will hold the include paths
#        BOARD_ID            - Board ID
#        ARD_LIBS_PATH       - List of paths to arduino libraries
#
# Finds and creates all dependency libraries based on sources.
#
#=============================================================================#
function(make_arduino_libraries LIB_TARGETS_OUTPUT LIB_INCLUDES_OUTPUT BOARD_ID ARD_LIBS_PATH)
    foreach (LIB_PATH ${ARD_LIBS_PATH})
        # Create static library instead of returning sources
        make_arduino_library(LIB_DEPS_TARGETS LIB_DEPS_INCLUDES ${BOARD_ID} ${LIB_PATH})
        list(APPEND LIB_TARGETS ${LIB_DEPS_TARGETS})
        list(APPEND LIB_INCLUDES ${LIB_DEPS_INCLUDES})
    endforeach ()
    set(${LIB_TARGETS_OUTPUT} ${LIB_TARGETS} PARENT_SCOPE)
    set(${LIB_INCLUDES_OUTPUT} ${LIB_INCLUDES} PARENT_SCOPE)
endfunction()
