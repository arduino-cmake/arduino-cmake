# ToDo: Comment
function(set_board_linker_flags LINKER_FLAGS BOARD_ID IS_MANUAL)

    _get_board_property(${BOARD_ID} build.mcu MCU)
    if(NOT "${MCU}" STREQUAL "")
       set(LINK_FLAGS "-mmcu=${MCU}")
    endif()
    set(${LINKER_FLAGS} "${LINK_FLAGS}" PARENT_SCOPE)

endfunction()
