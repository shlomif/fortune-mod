SET (_strfile  "${CMAKE_CURRENT_BINARY_DIR}/../strfile")
FOREACH(c ${COOKIES})
    SET(TARGET_NAME "cookie__${c}")
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
    ADD_CUSTOM_COMMAND(
        OUTPUT "${LINK}"
        COMMAND "ln"
        ARGS "-s" "${c}" "${LINK}"
        DEPENDS "${c}"
    )

    ADD_CUSTOM_TARGET(
        "${TARGET_NAME}" ALL
        DEPENDS "${c}" "${DEST}" "${LINK}"
    )

    INSTALL(
        FILES "${c}" "${CMAKE_CURRENT_BINARY_DIR}/${DEST}" "${CMAKE_CURRENT_BINARY_DIR}/${LINK}"
        DESTINATION "share/games/fortunes"
    )

ENDFOREACH()
IF (NOT "${NO_OFFENSIVE}")
    ADD_SUBDIRECTORY("off")
ENDIF()
