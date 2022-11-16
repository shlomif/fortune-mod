# See: https://github.com/shlomif/fortune-mod/issues/58
SET (_target_rot  "${CMAKE_CURRENT_BINARY_DIR}/../../rot")
if (IS_CROSS)
    SET (_rot ${PERL_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/../../util/rot.pl")
else()
    SET (_rot  "${_target_rot}")
endif()
SET (rot_dir "${CMAKE_CURRENT_BINARY_DIR}/rotated")
SET (unrot_dir "${CMAKE_CURRENT_BINARY_DIR}/unrotated")
if (ROT13)
    FILE(MAKE_DIRECTORY "${rot_dir}")
endif()
SET (_unrot_cookies )
SET (_rotated_cookies )
SET (_install_offensive_cookies )

FOREACH(c ${OFFENSIVE_COOKIES})
    SET(DEST "${c}.dat")
    SET(LINK "${c}.u8")
    SET(SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/unrotated/${c}")
    SET(PATH_PERL ${PERL_EXECUTABLE})

    if (ROT13)
        SET(rot_dest "${rot_dir}/${c}")

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
        LIST(APPEND _install_offensive_cookies "${rot_dest}" "${CMAKE_CURRENT_BINARY_DIR}/${DEST}" "${rot_LINK}")

    else()
        ADD_CUSTOM_COMMAND(
            OUTPUT "${c}"
            COMMAND ${PATH_PERL}
            ARGS "-e"
            "my (\$src, \$dest) = @ARGV; use File::Copy; copy(\$src, \$dest);"
            "${SOURCE}"
            "${c}"
            DEPENDS "${SOURCE}"
            VERBATIM
        )
        ADD_CUSTOM_COMMAND(
            OUTPUT "${DEST}"
            COMMAND "${_strfile}"
            ARGS "${SOURCE}" "${DEST}"
            DEPENDS "${SOURCE}" "${_strfile}"
        )

        if (WIN32)
            ADD_CUSTOM_COMMAND(
                OUTPUT "${LINK}"
                COMMAND ${CMAKE_COMMAND} -E copy "${SOURCE}" "${LINK}"
            )
        else()
            ADD_CUSTOM_COMMAND(
                OUTPUT "${LINK}"
                COMMAND "ln"
                ARGS "-sf" "${c}" "${LINK}"
            )
        endif()

        SET(_targets_on_build_stage_for_avoiding_broken_symlinks_which_regenerate "${CMAKE_CURRENT_BINARY_DIR}/${c}")
        LIST(APPEND _unrot_cookies ${_targets_on_build_stage_for_avoiding_broken_symlinks_which_regenerate} "${DEST}" "${LINK}")
        LIST(APPEND _install_offensive_cookies
            "${CMAKE_CURRENT_BINARY_DIR}/${c}"
            "${CMAKE_CURRENT_BINARY_DIR}/${DEST}"
            "${CMAKE_CURRENT_BINARY_DIR}/${LINK}")
    endif()
ENDFOREACH()

IF (ROT13)
    ADD_CUSTOM_TARGET(
        offensive_cookies ALL
        DEPENDS ${_rotated_cookies}
    )
ELSE()
    ADD_CUSTOM_TARGET(
        offensive_cookies ALL
        DEPENDS ${_unrot_cookies}
    )
ENDIF()

INSTALL(
    FILES ${_install_offensive_cookies}
    DESTINATION "${OCOOKIEDIR}"
)
