cmake_minimum_required(VERSION 3.10)

project(fortune-mod)

INCLUDE ("${CMAKE_SOURCE_DIR}/cmake/shlomif_common_bootstrap.cmake")
SHLOMIF_COMMON_SETUP("${private_mod_path}")

CMAKE_POLICY(SET CMP0054 NEW)

# see: https://cmake.org/cmake/help/latest/variable/CMAKE_CROSSCOMPILING.html
SET (IS_CROSS "${CMAKE_CROSSCOMPILING}")

INCLUDE(FindPkgConfig)

SET (PKGDATADIR_SUBDIR "fortune-mod")
SET (RELATIVE_PKGDATADIR "${RELATIVE_DATADIR}/${PKGDATADIR_SUBDIR}")
SET (PKGDATADIR "${DATADIR}/${PKGDATADIR_SUBDIR}")

# Introduces VERSION , CPACK_PACKAGE_VERSION_MAJOR,
# CPACK_PACKAGE_VERSION_MAJOR, and CPACK_PACKAGE_VERSION_PATCH
READ_VERSION_FROM_VER_TXT()

# This is the equivalent to perform a "make dist"/"make distdir" etc.
SET(CPACK_PACKAGE_NAME "fortune-mod")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "fortune-mod")
SET(CPACK_PACKAGE_VENDOR "Shlomi Fish")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING.txt")


SET(CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_DESCRIPTION_SUMMARY} ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

SET(CPACK_SOURCE_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
SET(CPACK_SOURCE_GENERATOR "TXZ")

SET(CPACK_SOURCE_IGNORE_FILES
    "/\\\\.deps/"
    "/\\\\.git/"
    "/\\\\.tidyall\\\\.d/"
    "/t/valgrind[0-9]+\\\\.t$"
    "/tags$"
    "\\\\.pyc$"
    "~$"
    # "/(build|BUILD|B)/"
)

IF(WIN32 AND NOT UNIX)
    # There is a bug in NSI that does not handle full unix paths properly. Make
    # sure there is at least one set of four (4) backlasshes.
    SET(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}\\\\dondorf-king.bmp")
    SET(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\fortune.exe")
    SET(CPACK_NSIS_HELP_LINK "http:\\\\\\\\github.com\\\\shlomif\\\\fortune-mod")
    SET(CPACK_NSIS_URL_INFO_ABOUT  "http:\\\\\\\\github.com\\\\shlomif\\\\fortune-mod")
    SET(CPACK_NSIS_DISPLAY_NAME "fortune-mod")
    SET(CPACK_NSIS_CONTACT "shlomif@shlomifish.org")
    SET(CPACK_NSIS_MODIFY_PATH ON)
    # Setting for NSIS :
    SET(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}\\\\fc-solve.ico")
    SET(CPACK_NSIS_MUI_UNIICON ${CPACK_NSIS_MUI_ICON})
    SET(CPACK_PACKAGE_ICON ${CPACK_NSIS_MUI_ICON})
    SET(CPACK_NSIS_MODIFY_PATH "ON")
ELSE()
  SET(CPACK_STRIP_FILES "fortune")
  SET(CPACK_SOURCE_STRIP_FILES "")
ENDIF()

SET(CPACK_PACKAGE_EXECUTABLES
    "fortune" "The fortune-mod program"
)

### This is to set the RPATH correctly, so when installed under a prefix
### the executables will find the libraries.
###
### See:
###
### http://www.cmake.org/Wiki/CMake_RPATH_handling
###
### (Taken from that wiki page)

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

# the RPATH to be used when installing
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

SET (WITH_TEST_SUITE CACHE BOOL "")
SET (NO_OFFENSIVE CACHE BOOL "Exclude the offensive option.")
SET (USE_WIN32_REGEX_LIBS TRUE CACHE BOOL "Link to the regex libraries (only affects MSWin builds)")
SET (LOCALDIR "${CMAKE_INSTALL_PREFIX}/local/share/games/fortunes" CACHE STRING "LOCALDIR fortunes dir")
SET (LOCALODIR "${LOCALDIR}/off" CACHE STRING "offensive fortunes localdir")
SET (COOKIEDIR "${CMAKE_INSTALL_PREFIX}/share/games/fortunes" CACHE STRING  "cookie dir not under /usr/local")
SET (OCOOKIEDIR "${COOKIEDIR}/off" CACHE STRING "offensive cookie dir not under /usr/local")

SHLOMIF_ADD_COMMON_C_FLAGS()

# add_flags("-Weverything" "-Wno-language-extension-token" "-Wno-padded")

SHLOMIF_FINALIZE_FLAGS()

INCLUDE ("${CMAKE_SOURCE_DIR}/cmake/rinutils_bootstrap.cmake")

RINUTILS_SET_UP_FLAGS()

IF ("$ENV{FCS_CLANG}")
    ADD_DEFINITIONS("-Weverything -Wno-language-extension-token -Wno-padded -Wno-gnu-statement-expression -Wno-unused-parameter -Wno-vla -Wno-cast-align -Wno-used-but-marked-unused -Wno-cast-qual -Wno-comma -Wno-disabled-macro-expansion -Wno-extra-semi-stmt -Wno-documentation-unknown-command -Wno-documentation -Wno-documentation-deprecated-sync -Wno-pass-failed -Wno-implicit-fallthrough")
    # ADD_DEFINITIONS("-Weverything")
ENDIF ()

IF ($ENV{FCS_GCC})
    ADD_DEFINITIONS("-W -Wabi=11 -Waddress -Waggressive-loop-optimizations -Wall -Wattributes -Wbad-function-cast -Wbool-compare -Wbool-operation -Wbuiltin-declaration-mismatch -Wbuiltin-macro-redefined -Wcast-align -Wchar-subscripts -Wclobbered -Wcomment -Wcomments -Wcoverage-mismatch -Wcpp -Wdangling-else -Wdate-time -Wdeprecated -Wdeprecated-declarations -Wdesignated-init -Wdisabled-optimization -Wdiscarded-array-qualifiers -Wdiscarded-qualifiers -Wdiv-by-zero -Wdouble-promotion -Wduplicated-branches -Wduplicated-cond -Wduplicate-decl-specifier -Wempty-body -Wendif-labels -Wenum-compare -Wexpansion-to-defined -Wextra -Wformat-contains-nul -Wformat-extra-args -Wformat-nonliteral -Wformat-security -Wformat-signedness -Wformat-y2k -Wformat-zero-length -Wframe-address -Wfree-nonheap-object -Whsa -Wignored-attributes -Wignored-qualifiers -Wimplicit -Wimplicit-function-declaration -Wimplicit-int -Wincompatible-pointer-types -Winit-self -Winline -Wint-conversion -Wint-in-bool-context -Wint-to-pointer-cast -Winvalid-memory-model -Winvalid-pch -Wjump-misses-init -Wlogical-not-parentheses -Wlogical-op -Wmain -Wmaybe-uninitialized -Wmemset-elt-size -Wmemset-transposed-args -Wmisleading-indentation -Wmissing-braces -Wmissing-declarations -Wmissing-field-initializers -Wmissing-include-dirs -Wmissing-parameter-type -Wmissing-prototypes -Wmultichar -Wnarrowing -Wnested-externs -Wnonnull -Wnonnull-compare -Wnull-dereference -Wodr -Wold-style-declaration -Wold-style-definition -Wopenmp-simd -Woverflow -Woverlength-strings -Woverride-init -Wpacked -Wpacked-bitfield-compat -Wparentheses -Wpointer-arith -Wpointer-compare -Wpointer-sign -Wpointer-to-int-cast -Wpragmas -Wpsabi -Wrestrict -Wreturn-local-addr -Wreturn-type -Wscalar-storage-order -Wsequence-point -Wshadow -Wshift-count-negative -Wshift-count-overflow -Wshift-negative-value -Wsizeof-array-argument -Wsizeof-pointer-memaccess -Wstack-protector -Wstrict-aliasing -Wstrict-prototypes  -Wsuggest-attribute=format -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure -Wsuggest-final-methods -Wsuggest-final-types -Wswitch -Wswitch-bool -Wswitch-default -Wswitch-unreachable -Wsync-nand -Wtautological-compare -Wtrampolines -Wtrigraphs -Wtype-limits -Wuninitialized -Wunknown-pragmas -Wunsafe-loop-optimizations -Wunused -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-function -Wunused-label -Wunused-local-typedefs -Wunused-macros -Wunused-parameter -Wunused-result -Wunused-value -Wunused-variable -Wvarargs -Wvariadic-macros -Wvector-operation-performance -Wvla -Wvolatile-register-var -Wwrite-strings -Walloc-size-larger-than=9223372036854775807 -Warray-bounds=2 -Wformat-overflow=2 -Wformat-truncation=2 -Wnormalized=nfc -Wshift-overflow=2  -Wunused-const-variable=2 -Wstrict-overflow=1  -Wno-switch-default -Wno-vla -Wno-inline  -Wno-jump-misses-init -Wno-unsafe-loop-optimizations")
    # -Wimplicit-fallthrough=5
    # -Wno-vla-larger-than
    # -Wsuggest-attribute=const
    # -Wstringop-overflow=2

    IF (NOT IS_DEBUG)
        ADD_DEFINITIONS("-D_FORTIFY_SOURCE=2")
    ELSE ()
        ADD_DEFINITIONS("-D_FORTIFY_SOURCE=2")
    ENDIF ()
        ADD_DEFINITIONS("-O1")
ENDIF ()

# Either or both of CheckIncludeFile
# and CheckIncludeFiles may be needed for
# CHECK_INCLUDE_FILES and CHECK_INCLUDE_FILE
INCLUDE(CheckIncludeFile)
INCLUDE(CheckIncludeFiles)
SET(_r "stdbool.h" "stdio.h" "recode.h")
CHECK_INCLUDE_FILES("${_r}" HAVE_RECODE_H)
IF (NOT HAVE_RECODE_H)
    IF (NOT WIN32)
        MESSAGE(WARNING "Cannot find recode.h anywhere; it is usually unnecessary, but you may opt to install a source release tarball of the recode library from https://github.com/rrthomas/recode")
    ENDIF ()
ENDIF ()

# So it can find config.h
INCLUDE_DIRECTORIES(BEFORE "${CMAKE_CURRENT_BINARY_DIR}")

MACRO(my_exe exe c_file dir)
    SET(_files "${c_file}")
    if (WIN32)
        list(APPEND _files "util/getopt.c")
    endif()
    ADD_EXECUTABLE("${exe}" "${c_file}")
    set(_libs)
    if ("${exe}" STREQUAL "fortune")
        if (HAVE_RECODE_H)
            list(APPEND _libs "recode")
        endif()
    endif()
    if (WIN32)
        # See https://stackoverflow.com/questions/15119639/how-to-link-winsock-in-cmake
        if (USE_WIN32_REGEX_LIBS)
            list(APPEND _libs intl regex)
        endif()
        list(APPEND _libs wsock32 ws2_32)
    endif()
    TARGET_LINK_LIBRARIES("${exe}" ${_libs})
    if (NOT ("${dir}" STREQUAL "null"))
        INSTALL(TARGETS "${exe}" RUNTIME DESTINATION "${dir}")
    endif()
ENDMACRO()

my_exe(
    "fortune"
    "fortune/fortune.c"
    "games"
)

my_exe(
    "strfile"
    "util/strfile.c"
    "bin"
)

# Build but not install.
my_exe("randstr" "util/randstr.c" "null")
my_exe(
    "unstr"
    "util/unstr.c"
    "bin"
)

my_exe(
    "rot"
    "util/rot.c"
    "bin"
)

SET (_my_man_page_dir "${CMAKE_CURRENT_BINARY_DIR}/manpages")
SET (_my_man_page "${_my_man_page_dir}/fortune.6")
SET (_my_man_gen "${CMAKE_CURRENT_SOURCE_DIR}/fortune/process-fortune-man-template.pl")
SET (_my_args)
LIST(APPEND _my_args "--cookiedir" "${COOKIEDIR}" "--ocookiedir" "${OCOOKIEDIR}" "--output" "${_my_man_page}")
IF (NO_OFFENSIVE)
    LIST(APPEND _my_args "--without-offensive")
    SET(_MY_IN "${CMAKE_CURRENT_SOURCE_DIR}/fortune/fortune_with_offensive.template.man")
ELSE()
    SET(_MY_IN "${CMAKE_CURRENT_SOURCE_DIR}/fortune/fortune_without_offensive.template.man")
ENDIF()
LIST(APPEND _my_args "--input" "${_MY_IN}")

ADD_CUSTOM_COMMAND(
    OUTPUT "${_my_man_page}"
    COMMAND "${PERL_EXECUTABLE}"
    ARGS "${_my_man_gen}" ${_my_args}
    DEPENDS "${_my_man_gen}" "${_MY_IN}"
)
SET (_my_man_pages_list)

LIST(APPEND _my_man_pages_list "${_my_man_page}")

INSTALL_RENAME_MAN("fortune.6" "6" "fortune" "${_my_man_page_dir}")

SET (_util_dir "${CMAKE_CURRENT_SOURCE_DIR}/util")
MACRO(_fortune__generate_docbook basename offensive_flags)

    SET (_my_man_page_dir "${CMAKE_CURRENT_SOURCE_DIR}/fortune")
    SET (_dest_basename "${basename}.template")
    SET (_my_man_page "${_my_man_page_dir}/${_dest_basename}.man")
    SET (_my_man_docbook "${_my_man_page_dir}/${basename}.docbook5.xml")
    SET (_my_man_prog "${_my_man_page_dir}/gen-fortune-docbook-page.pl")
    SET (_my_args "${_my_man_prog}" "--output" "${_my_man_docbook}" --cookiedir "[[cookiedir_placeholder]]" --ocookiedir "[[ocookiedir_placeholder]]" ${offensive_flags})
    ADD_CUSTOM_COMMAND(
        OUTPUT "${_my_man_docbook}"
        COMMAND "${PERL_EXECUTABLE}"
        ARGS ${_my_args}
        DEPENDS "${_my_man_prog}"
    )

    LIST(APPEND _my_man_pages_list "${_my_man_docbook}")
    SET (_my_args "-I${_util_dir}" "${_util_dir}/fortmod_gen_manpage.pl" "--src-dir" "${CMAKE_CURRENT_SOURCE_DIR}" "--basename=${basename}" "--dest-basename=${_dest_basename}" "--out-section=6" "--out-basename=fortune" "--subdir=fortune")
    ADD_CUSTOM_COMMAND(
        OUTPUT "${_my_man_page}"
        COMMAND "${PERL_EXECUTABLE}"
        ARGS ${_my_args}
        DEPENDS "${_my_man_docbook}"
    )

    LIST(APPEND _my_man_pages_list "${_my_man_page}")
ENDMACRO()

_fortune__generate_docbook("fortune_with_offensive" "")
_fortune__generate_docbook("fortune_without_offensive" "--without-offensive")

MACRO(_fortune__generate_manpage basename)

    SET (_my_man_page_dir "${CMAKE_CURRENT_SOURCE_DIR}/util")
    SET (_my_man_page "${_my_man_page_dir}/${basename}.man")
    SET (_my_man_docbook "${_my_man_page_dir}/${basename}.docbook5.xml")
    SET (_my_args "-I${_util_dir}" "${_util_dir}/fortmod_gen_manpage.pl" "--src-dir" "${CMAKE_CURRENT_SOURCE_DIR}" "--basename=${basename}")
    ADD_CUSTOM_COMMAND(
        OUTPUT "${_my_man_page}"
        COMMAND "${PERL_EXECUTABLE}"
        ARGS ${_my_args}
        DEPENDS "${_my_man_docbook}"
    )

    LIST(APPEND _my_man_pages_list "${_my_man_page}")
ENDMACRO()

_fortune__generate_manpage("strfile")
INSTALL_RENAME_MAN("strfile.man" "1" "strfile" "${_my_man_page_dir}")
_fortune__generate_manpage("randstr")

ADD_CUSTOM_TARGET(
    generate_man_page
    ALL DEPENDS ${_my_man_pages_list}
)

INCLUDE_DIRECTORIES("${CMAKE_CURRENT_SOURCE_DIR}/util")

IF(WIN32 AND NOT UNIX)
    FOREACH (var "LOCALODIR" "LOCALDIR" "OCOOKIEDIR" "COOKIEDIR")
        string(REPLACE "\\" "/" "${var}" "${${var}}")
    ENDFOREACH()
ENDIF()

IF (NO_OFFENSIVE)
    ADD_DEFINITIONS("-DNO_OFFENSIVE=1")
ENDIF()

CHECK_INCLUDE_FILE("regex.h" HAVE_REGEX_H)

IF (HAVE_REGEX_H)
    ADD_DEFINITIONS("-DHAVE_REGEX_H")
    ADD_DEFINITIONS("-DPOSIX_REGEX")
ENDIF()

ADD_DEFINITIONS("-DHAVE_STDBOOL")
SET (COOKIES
    art
    ascii-art
    computers
    cookie
    definitions
    disclaimer
    drugs
    education
    ethnic
    food
    fortunes
    goedel
    humorists
    kids
    law
    literature
    love
    magic
    medicine
    men-women
    miscellaneous
    news
    people
    pets
    platitudes
    politics
    pratchett
    riddles
    rules-of-acquisition
    science
    songs-poems
    sports
    startrek
    tao
    translate-me
    wisdom
    work
    linux
    perl
    knghtbrd
    paradoxum
    zippy
    debian
)

SET (OFFENSIVE_COOKIES
    art
    astrology
    atheism
    black-humor
    cookie
    debian
    definitions
    drugs
    ethnic
    fortunes
    hphobia
    knghtbrd
    limerick
    linux
    misandry
    miscellaneous
    misogyny
    politics
    privates
    racism
    religion
    riddles
    sex
    songs-poems
    vulgarity
    zippy
)

ADD_SUBDIRECTORY("datfiles")

string (REPLACE ";" " " COOKIES_STR "${COOKIES}")
ADD_CUSTOM_TARGET(
    "check"
    "perl" "${CMAKE_SOURCE_DIR}/run-tests.pl" "--src-dir" "${CMAKE_SOURCE_DIR}" "--cookies" "${COOKIES_STR}"
)

# Rebuild config.h if ver.txt has changed.
ADD_CUSTOM_COMMAND(
    OUTPUT "config.h.in"
    DEPENDS "ver.txt"
    COMMAND "touch"
    ARGS "config.h.in"
)

SET(AUTOGENERATED_CONFIG_H "config.h was auto-generated from config.h.in . Do not modify directly")

CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/config.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
)

INCLUDE(CPack)
