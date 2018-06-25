cmake_minimum_required(VERSION 3.2)

INCLUDE ("${CMAKE_SOURCE_DIR}/cmake/shlomif_common_bootstrap.cmake")
SHLOMIF_COMMON_SETUP("${private_mod_path}")

CMAKE_POLICY(SET CMP0054 NEW)

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

SET (base_with_ver "fortune-mod-[0-9]+\\\\.[0-9]+\\\\.[0-9]+")

SET(CPACK_SOURCE_IGNORE_FILES
    "/.deps/"
    "~$"
    "\\\\.pyc$"
    "/tags$"
    "/(build|BUILD|B)/"
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
SET (LOCALDIR "${CMAKE_INSTALL_PREFIX}/local/share/games/fortunes" CACHE STRING "LOCALDIR fortunes dir")
SET (LOCALODIR "${LOCALDIR}/off" CACHE STRING "offensive fortunes localdir")
SET (COOKIEDIR "${CMAKE_INSTALL_PREFIX}/share/games/fortunes" CACHE STRING  "cookie dir not under /usr/local")
SET (OCOOKIEDIR "${COOKIEDIR}/off" CACHE STRING "offensive cookie dir not under /usr/local")

SHLOMIF_ADD_COMMON_C_FLAGS()

# add_flags("-Weverything" "-Wno-language-extension-token" "-Wno-padded")

SHLOMIF_FINALIZE_FLAGS()

INCLUDE(CheckIncludeFile)
SET(_r "stdbool.h" "stdio.h" "recode.h")
CHECK_INCLUDE_FILES("${_r}" HAVE_RECODE_H)
IF (NOT "${HAVE_RECODE_H}")
    MESSAGE(FATAL_ERROR "Cannot find recode.h anywhere - please install lib recode")
ENDIF ()

# So it can find config.h
INCLUDE_DIRECTORIES(BEFORE "${CMAKE_CURRENT_BINARY_DIR}")

MACRO(my_exe exe c_file dir)
    ADD_EXECUTABLE("${exe}" "${c_file}")
    INSTALL(TARGETS "${exe}" RUNTIME DESTINATION "${dir}")
ENDMACRO()

my_exe(
    "fortune"
    "fortune/fortune.c"
    "games"
)

my_exe(
    "strfile"
    "util/strfile.c"
    "sbin"
)

my_exe(
    "unstr"
    "util/unstr.c"
    "sbin"
)

my_exe(
    "rot"
    "util/rot.c"
    "bin"
)

SET (_my_man_page "${CMAKE_CURRENT_SOURCE_DIR}/fortune/fortune.6")
SET (_my_man_gen "${CMAKE_CURRENT_SOURCE_DIR}/fortune/gen-fortune-man-page.pl")
SET (_my_args)
LIST(APPEND _my_args "--cookiedir" "${COOKIEDIR}" "--ocookiedir" "${OCOOKIEDIR}" "--output" "${_my_man_page}")
IF ("${NO_OFFENSIVE}")
    LIST(APPEND _my_args "--without-offensive")
ENDIF()

ADD_CUSTOM_COMMAND(
    OUTPUT "${_my_man_page}"
    COMMAND "${PERL_EXECUTABLE}"
    ARGS "${_my_man_gen}" ${_my_args}
    DEPENDS "${_my_man_gen}"
)

ADD_CUSTOM_TARGET(
    generate_man_page
    ALL DEPENDS "${_my_man_page}"
)
INSTALL_RENAME_MAN("strfile.man" "1" "strfile" "util")
INSTALL_RENAME_MAN("fortune.6" "6" "fortune" "fortune")

TARGET_LINK_LIBRARIES("fortune" "recode")
INCLUDE_DIRECTORIES("${CMAKE_CURRENT_SOURCE_DIR}/util")

ADD_DEFINITIONS("-DLOCOFFDIR=\"${LOCALODIR}\"")
ADD_DEFINITIONS("-DLOCFORTDIR=\"${LOCALDIR}\"")
ADD_DEFINITIONS("-DOFFDIR=\"${OCOOKIEDIR}\"")
ADD_DEFINITIONS("-DFORTDIR=\"${COOKIEDIR}\"")

IF ("${NO_OFFENSIVE}")
    ADD_DEFINITIONS("-DNO_OFFENSIVE=1")
ENDIF()

CHECK_INCLUDE_FILE("regex.h" HAVE_REGEX_H)

IF ("${HAVE_REGEX_H}")
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
    linuxcookie
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
