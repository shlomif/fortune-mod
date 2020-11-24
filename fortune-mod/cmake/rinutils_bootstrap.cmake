MACRO(RINUTILS_SET_UP_FLAGS)
    # Clone the rinutils repository with the appropriate tag.
    SET (rinutils_dir "rinutils")
    SET (rinutils_dir_absolute "${CMAKE_CURRENT_SOURCE_DIR}/${rinutils_dir}")
    SET (rinutils_inc_dir "${rinutils_dir_absolute}/rinutils/include")
    SET (rinutils_git_tag "0.6.0")

    find_package(Rinutils QUIET)
    IF ("${Rinutils_FOUND}")
        INCLUDE_DIRECTORIES(AFTER ${RINUTILS_INCLUDE_DIR} ${RINUTILS_INCLUDE_DIRS})
    ELSE ()
        IF (NOT EXISTS "${rinutils_inc_dir}")
            EXECUTE_PROCESS(
                COMMAND "git" "clone" "-b" "${rinutils_git_tag}" "https://github.com/shlomif/rinutils.git" "${rinutils_dir}"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            )
        ELSE ()
            EXECUTE_PROCESS(
                COMMAND "git" "submodule" "update" "--init"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            )
        ENDIF ()
        IF (NOT EXISTS "${rinutils_inc_dir}")
            MESSAGE(FATAL_ERROR "Could not find rinutils anywhere - it should have been bundled in the releases' source tarball.\nYou can try installing it from a source release or from its repository: https://github.com/shlomif/rinutils\n\nAlso see: https://github.com/shlomif/fortune-mod/issues/44")
        ENDIF ()
        INCLUDE_DIRECTORIES(AFTER "${rinutils_inc_dir}")
    ENDIF ()
ENDMACRO ()
