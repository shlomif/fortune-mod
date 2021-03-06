SET (_strfile  "${CMAKE_CURRENT_BINARY_DIR}/../strfile")
SET (_unrot_cookies )
SET (_install_unrot_cookies )
FOREACH(c ${COOKIES})
    SET(DEST "${c}.dat")
    SET(SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/${c}")

    SET(PATH_PERL ${PERL_EXECUTABLE})
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

    SET(LINK "${c}.u8")
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

    SET(_targets_on_build_stage_for_avoiding_broken_symlinks_which_regenerate "${c}")
    LIST(APPEND _unrot_cookies ${_targets_on_build_stage_for_avoiding_broken_symlinks_which_regenerate} "${DEST}" "${LINK}")
    LIST(APPEND _install_unrot_cookies "${c}" "${CMAKE_CURRENT_BINARY_DIR}/${DEST}" "${CMAKE_CURRENT_BINARY_DIR}/${LINK}")

ENDFOREACH()

ADD_CUSTOM_TARGET(
    plain_cookies ALL
    DEPENDS ${_unrot_cookies}
)
INSTALL(
    FILES ${_install_unrot_cookies}
    DESTINATION "${LOCALDIR}"
)

IF (NOT "${NO_OFFENSIVE}")
    ADD_SUBDIRECTORY("off")
ENDIF()
