# See: https://github.com/shlomif/fortune-mod/issues/58
SET (_target_rot  "${CMAKE_CURRENT_BINARY_DIR}/../../rot")
if (IS_CROSS)
    SET (_rot ${PERL_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/../../util/rot.pl")
else()
    SET (_rot  "${_target_rot}")
endif()
SET (rot_dir "${CMAKE_CURRENT_BINARY_DIR}/rotated")
FILE(MAKE_DIRECTORY "${rot_dir}")
SET (_rotated_cookies )
SET (_install_rotated_cookies )
FOREACH(c ${OFFENSIVE_COOKIES})
    SET(rot_dest "${rot_dir}/${c}")
    SET(DEST "${c}.dat")
    SET(SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/unrotated/${c}")

    SET(PATH_PERL ${PERL_EXECUTABLE})
    ADD_CUSTOM_COMMAND(
        OUTPUT "${rot_dest}"
        COMMAND ${_rot} "<" "${SOURCE}" ">" "${rot_dest}"
        DEPENDS "${SOURCE}" "${_target_rot}"
    )
    ADD_CUSTOM_COMMAND(
        OUTPUT "${DEST}"
        COMMAND "${_strfile}"
        ARGS "-x" "${rot_dest}" "${DEST}"
        DEPENDS "${rot_dest}" "${_strfile}"
    )

    SET(LINK "${c}.u8")
    SET(rot_LINK "${rot_dir}/${LINK}")
    if (WIN32)
        ADD_CUSTOM_COMMAND(
            OUTPUT "${rot_LINK}"
            COMMAND ${CMAKE_COMMAND} -E copy "${rot_dest}" "${rot_LINK}"
            DEPENDS "${rot_dest}"
        )
    else()
        ADD_CUSTOM_COMMAND(
            OUTPUT "${rot_LINK}"
            COMMAND "ln"
            ARGS "-s" "${c}" "${LINK}"
            DEPENDS "${rot_dest}"
            WORKING_DIRECTORY "${rot_dir}"
        )
    endif()
    LIST(APPEND _rotated_cookies "${rot_dest}" "${DEST}" "${rot_LINK}")
    LIST(APPEND _install_rotated_cookies "${rot_dest}" "${CMAKE_CURRENT_BINARY_DIR}/${DEST}" "${rot_LINK}")
ENDFOREACH()

ADD_CUSTOM_TARGET(
    offensive_cookies ALL
    DEPENDS ${_rotated_cookies}
)
INSTALL(
    FILES ${_install_rotated_cookies}
    DESTINATION "${OCOOKIEDIR}"
)
