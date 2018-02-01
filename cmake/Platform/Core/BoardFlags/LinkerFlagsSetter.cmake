# ToDo: Comment
function(SET_BOARD_LINKER_FLAGS LINKER_FLAGS BOARD_ID IS_MANUAL)

    _TRY_GET_BOARD_PROPERTY(${BOARD_ID} build.mcu MCU)
    if(NOT "${MCU}" STREQUAL "")
       set(LINK_FLAGS "-mmcu=${MCU}")
    endif()
    set(${LINKER_FLAGS} "${LINK_FLAGS}" PARENT_SCOPE)

endfunction()
