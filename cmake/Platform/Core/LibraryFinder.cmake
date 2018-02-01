#=============================================================================#
# FIND_ARDUINO_LIBRARIES
# [PRIVATE/INTERNAL]
#
# FIND_ARDUINO_LIBRARIES(VAR_NAME SRCS ARDLIBS)
#
#      VAR_NAME - Variable name which will hold the results
#      SRCS     - Sources that will be analized
#      ARDLIBS  - Arduino libraries identified by name (e.g., Wire, SPI, Servo)
#
#     returns a list of paths to libraries found.
#
#  Finds all Arduino type libraries included in sources. Available libraries
#  are ${ARDUINO_SDK_PATH}/libraries and ${CMAKE_CURRENT_SOURCE_DIR}.
#
#  Also adds Arduino libraries specifically names in ALIBS.  We add ".h" to the
#  names and then process them just like the Arduino libraries found in the sources.
#
#  A Arduino library is a folder that has the same name as the include header.
#  For example, if we have a include "#include <LibraryName.h>" then the following
#  directory structure is considered a Arduino library:
#
#     LibraryName/
#          |- LibraryName.h
#          `- LibraryName.c
#
#  If such a directory is found then all sources within that directory are considred
#  to be part of that Arduino library.
#
#=============================================================================#
function(FIND_ARDUINO_LIBRARIES VAR_NAME SRCS ARDLIBS)

    include(CheckPathExistsCaseSensitive)
    
    set(ARDUINO_LIBS)

    if (ARDLIBS) # Libraries are known in advance, just find their absoltue paths

        foreach (LIB ${ARDLIBS})
            get_property(LIBRARY_SEARCH_PATH
                    DIRECTORY     # Property Scope
                    PROPERTY LINK_DIRECTORIES)

            foreach (LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH}
                    ${ARDUINO_LIBRARIES_PATH}
                    ${ARDUINO_PLATFORM_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR}
                    ${CMAKE_CURRENT_SOURCE_DIR}/libraries)
               
                _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive 
                  "${LIB_SEARCH_PATH}/${LIB}/${LIB}.h")
                if (exists_case_sensitive)
                    list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${LIB})
                    break()
                endif ()
                _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive 
                  "${LIB_SEARCH_PATH}/${LIB}.h")
                if (exists_case_sensitive)
                    list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH})
                    break()
                endif ()

                # Some libraries like Wire and SPI require building from source
                _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive
                  "${LIB_SEARCH_PATH}/${LIB}/src/${LIB}.h")
                if (exists_case_sensitive)
                    message(STATUS "avr library found: ${LIB}")
                    list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${LIB}/src)
                    break()
                endif ()
                _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive 
                  "${LIB_SEARCH_PATH}/src/${LIB}.h")
                if (exists_case_sensitive)
                    list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/src)
                    break()
                endif ()

            endforeach ()
        endforeach ()

    else ()

        foreach (SRC ${SRCS})

            # Skipping generated files. They are, probably, not exist yet.
            # TODO: Maybe it's possible to skip only really nonexisting files,
            # but then it wiil be less deterministic.
            get_source_file_property(_srcfile_generated ${SRC} GENERATED)
            # Workaround for sketches, which are marked as generated
            get_source_file_property(_sketch_generated ${SRC} GENERATED_SKETCH)

            if (NOT ${_srcfile_generated} OR ${_sketch_generated})
                _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive_1
                  "${SRC}")
                _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive_2
                  "${CMAKE_CURRENT_SOURCE_DIR}/${SRC}")
                _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive_3
                  "${CMAKE_CURRENT_BINARY_DIR}/${SRC}")
                if (NOT (exists_case_sensitive_1 OR
                         exists_case_sensitive_2 OR
                         exists_case_sensitive_3))
                    message(FATAL_ERROR "Invalid source file: ${SRC}")
                endif ()
                file(STRINGS ${SRC} SRC_CONTENTS)

                foreach (LIBNAME ${ARDLIBS})
                    list(APPEND SRC_CONTENTS "#include <${LIBNAME}.h>")
                endforeach ()

                foreach (SRC_LINE ${SRC_CONTENTS})
                    if ("${SRC_LINE}" MATCHES
                            "^[ \t]*#[ \t]*include[ \t]*[<\"]([^>\"]*)[>\"]")

                        get_filename_component(INCLUDE_NAME ${CMAKE_MATCH_1} NAME_WE)
                        get_property(LIBRARY_SEARCH_PATH
                                DIRECTORY     # Property Scope
                                PROPERTY LINK_DIRECTORIES)
                        foreach (LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH} ${ARDUINO_LIBRARIES_PATH} ${ARDUINO_PLATFORM_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/libraries ${ARDUINO_EXTRA_LIBRARIES_PATH})
                            _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive
                              "${LIB_SEARCH_PATH}/${INCLUDE_NAME}/${CMAKE_MATCH_1}")
                            if (exists_case_sensitive)
                                list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${INCLUDE_NAME})
                                break()
                            endif ()

                            # Some libraries like Wire and SPI require building from source
                            _CHECK_PATH_EXISTS_CASE_SENSITIVE(exists_case_sensitive
                              "${LIB_SEARCH_PATH}/${INCLUDE_NAME}/src/${CMAKE_MATCH_1}")
                            if (exists_case_sensitive)
                                list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/src)
                                break()
                            endif ()
                        endforeach ()

                    endif ()
                endforeach ()

            endif ()
        endforeach ()

    endif ()

    if (ARDUINO_LIBS)
        list(REMOVE_DUPLICATES ARDUINO_LIBS)
    endif ()

    _REMOVE_BLACKLISTED_LIBRARIES("${ARDUINO_LIBS}" FILTERED_LIBRARIES)
    set(${VAR_NAME} ${FILTERED_LIBRARIES} PARENT_SCOPE)

endfunction()
