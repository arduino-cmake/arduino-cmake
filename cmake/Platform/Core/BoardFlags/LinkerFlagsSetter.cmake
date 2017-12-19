
# ToDo: Comment
function(_set_board_link_flags TARGET_NAME BOARD_ID LINK_LIBRARIES)
    _get_board_property(${BOARD_ID} build.mcu MCU)
    set(BOARD_LINK_FLAGS -mmcu=${MCU} -fuse-linker-plugin)
    list(APPEND BOARD_LINK_FLAGS ${LINK_LIBRARIES})
    target_link_libraries(${TARGET_NAME} PRIVATE ${BOARD_LINK_FLAGS})
endfunction()
