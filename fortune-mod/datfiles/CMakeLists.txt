SET (_strfile  "${CMAKE_CURRENT_BINARY_DIR}/../strfile")
SET (_unrot_cookies )
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

    LIST(APPEND _unrot_cookies "${DEST}" "${LINK}")

    INSTALL(
        FILES "${c}" "${CMAKE_CURRENT_BINARY_DIR}/${DEST}" "${CMAKE_CURRENT_BINARY_DIR}/${LINK}"
        DESTINATION "${LOCALDIR}"
    )

ENDFOREACH()

ADD_CUSTOM_TARGET(
    plain_cookies ALL
    DEPENDS ${_unrot_cookies}
)

IF (NOT "${NO_OFFENSIVE}")
    ADD_SUBDIRECTORY("off")
ENDIF()
