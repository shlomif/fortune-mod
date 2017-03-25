SET (_strfile  "${CMAKE_CURRENT_BINARY_DIR}/../../strfile")
SET (_rot  "${CMAKE_CURRENT_BINARY_DIR}/../../rot")
SET (rot_dir "${CMAKE_CURRENT_BINARY_DIR}/rotated")
FILE(MAKE_DIRECTORY "${rot_dir}")
FOREACH(c ${OFFENSIVE_COOKIES})
    SET(TARGET_NAME "offensive_cookie__${c}")
    SET(rot_dest "${rot_dir}/${c}")
    SET(DEST "${c}.dat")
    SET(SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/unrotated/${c}")

    SET(PATH_PERL ${PERL_EXECUTABLE})
    ADD_CUSTOM_COMMAND(
        OUTPUT "${rot_dest}"
        COMMAND "${_rot}"
        ARGS "<" "${SOURCE}" ">" "${rot_dest}"
        DEPENDS "${SOURCE}" "${_rot}"
    )
    ADD_CUSTOM_COMMAND(
        OUTPUT "${DEST}"
        COMMAND "${_strfile}"
        ARGS "${rot_dest}" "${DEST}"
        DEPENDS "${rot_dest}" "${_strfile}"
    )

    SET(LINK "${c}.u8")
    SET(rot_LINK "${rot_dir}/${LINK}")
    ADD_CUSTOM_COMMAND(
        OUTPUT "${rot_LINK}"
        COMMAND "ln"
        ARGS "-s" "${c}" "${LINK}"
        DEPENDS "${rot_dest}"
        WORKING_DIRECTORY "${rot_dir}"
    )

    ADD_CUSTOM_TARGET(
        "${TARGET_NAME}" ALL
        DEPENDS "${rot_dest}" "${DEST}" "${rot_LINK}"
    )

    INSTALL(
        FILES "${rot_dest}" "${CMAKE_CURRENT_BINARY_DIR}/${DEST}" "${rot_LINK}"
        DESTINATION "share/games/fortunes/off"
    )

ENDFOREACH()
