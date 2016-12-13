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
        COMMAND "${CMAKE_CURRENT_BINARY_DIR}/../strfile"
        ARGS "${SOURCE}" "${DEST}"
        DEPENDS "${SOURCE}"
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
        FILES "${c}" "${DEST}" "${LINK}"
        DESTINATION "share/games/fortunes"
    )

ENDFOREACH()
