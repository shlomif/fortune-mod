# See: https://github.com/shlomif/fortune-mod/issues/58
if (IS_CROSS)
    SET (_strfile  "strfile")
    find_program(_found "${_strfile}")
    if (NOT _found)
        MESSAGE(FATAL_ERROR "\"strfile\" must be in the executables' path for cross-compiling builds. You can get it from a native install of fortune-mod: https://superuser.com/questions/284342/what-are-path-and-other-environment-variables-and-how-can-i-set-or-use-them . Also see https://github.com/shlomif/fortune-mod/issues/58 .")
    endif()
else()
    SET (_strfile  "${CMAKE_CURRENT_BINARY_DIR}/../strfile")
endif()
SET (_unrot_cookies )
SET (_install_unrot_cookies )
SET(cr "rules-of-acquisition")
SET(crfull "${CMAKE_CURRENT_SOURCE_DIR}/${cr}")
SET(SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/data/rules-of-acquisition.csv")
SET(script "${CMAKE_CURRENT_SOURCE_DIR}/data/rules-of-acquisition-gen.sh")
ADD_CUSTOM_COMMAND(
    OUTPUT "${crfull}"
    COMMAND "sh" "${script}" "${SOURCE}" "${crfull}"
    DEPENDS "${script}" "${SOURCE}"
    VERBATIM
)
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
    DESTINATION "${COOKIEDIR}"
)

IF (NOT NO_OFFENSIVE)
    ADD_SUBDIRECTORY("off")
ENDIF()
