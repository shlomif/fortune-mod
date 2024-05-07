# Install script for directory: /home/maaz/projects/fortune-mod/fortune-mod/datfiles/off

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/sbin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/share/games/fortunes/off/art;/usr/local/share/games/fortunes/off/art.dat;/usr/local/share/games/fortunes/off/art.u8;/usr/local/share/games/fortunes/off/astrology;/usr/local/share/games/fortunes/off/astrology.dat;/usr/local/share/games/fortunes/off/astrology.u8;/usr/local/share/games/fortunes/off/atheism;/usr/local/share/games/fortunes/off/atheism.dat;/usr/local/share/games/fortunes/off/atheism.u8;/usr/local/share/games/fortunes/off/black-humor;/usr/local/share/games/fortunes/off/black-humor.dat;/usr/local/share/games/fortunes/off/black-humor.u8;/usr/local/share/games/fortunes/off/cookie;/usr/local/share/games/fortunes/off/cookie.dat;/usr/local/share/games/fortunes/off/cookie.u8;/usr/local/share/games/fortunes/off/debian;/usr/local/share/games/fortunes/off/debian.dat;/usr/local/share/games/fortunes/off/debian.u8;/usr/local/share/games/fortunes/off/definitions;/usr/local/share/games/fortunes/off/definitions.dat;/usr/local/share/games/fortunes/off/definitions.u8;/usr/local/share/games/fortunes/off/drugs;/usr/local/share/games/fortunes/off/drugs.dat;/usr/local/share/games/fortunes/off/drugs.u8;/usr/local/share/games/fortunes/off/ethnic;/usr/local/share/games/fortunes/off/ethnic.dat;/usr/local/share/games/fortunes/off/ethnic.u8;/usr/local/share/games/fortunes/off/fortunes;/usr/local/share/games/fortunes/off/fortunes.dat;/usr/local/share/games/fortunes/off/fortunes.u8;/usr/local/share/games/fortunes/off/hphobia;/usr/local/share/games/fortunes/off/hphobia.dat;/usr/local/share/games/fortunes/off/hphobia.u8;/usr/local/share/games/fortunes/off/knghtbrd;/usr/local/share/games/fortunes/off/knghtbrd.dat;/usr/local/share/games/fortunes/off/knghtbrd.u8;/usr/local/share/games/fortunes/off/limerick;/usr/local/share/games/fortunes/off/limerick.dat;/usr/local/share/games/fortunes/off/limerick.u8;/usr/local/share/games/fortunes/off/linux;/usr/local/share/games/fortunes/off/linux.dat;/usr/local/share/games/fortunes/off/linux.u8;/usr/local/share/games/fortunes/off/misandry;/usr/local/share/games/fortunes/off/misandry.dat;/usr/local/share/games/fortunes/off/misandry.u8;/usr/local/share/games/fortunes/off/miscellaneous;/usr/local/share/games/fortunes/off/miscellaneous.dat;/usr/local/share/games/fortunes/off/miscellaneous.u8;/usr/local/share/games/fortunes/off/misogyny;/usr/local/share/games/fortunes/off/misogyny.dat;/usr/local/share/games/fortunes/off/misogyny.u8;/usr/local/share/games/fortunes/off/politics;/usr/local/share/games/fortunes/off/politics.dat;/usr/local/share/games/fortunes/off/politics.u8;/usr/local/share/games/fortunes/off/privates;/usr/local/share/games/fortunes/off/privates.dat;/usr/local/share/games/fortunes/off/privates.u8;/usr/local/share/games/fortunes/off/racism;/usr/local/share/games/fortunes/off/racism.dat;/usr/local/share/games/fortunes/off/racism.u8;/usr/local/share/games/fortunes/off/religion;/usr/local/share/games/fortunes/off/religion.dat;/usr/local/share/games/fortunes/off/religion.u8;/usr/local/share/games/fortunes/off/riddles;/usr/local/share/games/fortunes/off/riddles.dat;/usr/local/share/games/fortunes/off/riddles.u8;/usr/local/share/games/fortunes/off/sex;/usr/local/share/games/fortunes/off/sex.dat;/usr/local/share/games/fortunes/off/sex.u8;/usr/local/share/games/fortunes/off/songs-poems;/usr/local/share/games/fortunes/off/songs-poems.dat;/usr/local/share/games/fortunes/off/songs-poems.u8;/usr/local/share/games/fortunes/off/vulgarity;/usr/local/share/games/fortunes/off/vulgarity.dat;/usr/local/share/games/fortunes/off/vulgarity.u8;/usr/local/share/games/fortunes/off/zippy;/usr/local/share/games/fortunes/off/zippy.dat;/usr/local/share/games/fortunes/off/zippy.u8")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/share/games/fortunes/off" TYPE FILE FILES
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/art"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/art.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/art.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/astrology"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/astrology.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/astrology.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/atheism"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/atheism.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/atheism.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/black-humor"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/black-humor.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/black-humor.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/cookie"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/cookie.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/cookie.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/debian"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/debian.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/debian.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/definitions"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/definitions.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/definitions.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/drugs"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/drugs.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/drugs.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/ethnic"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/ethnic.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/ethnic.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/fortunes"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/fortunes.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/fortunes.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/hphobia"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/hphobia.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/hphobia.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/knghtbrd"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/knghtbrd.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/knghtbrd.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/limerick"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/limerick.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/limerick.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/linux"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/linux.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/linux.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/misandry"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/misandry.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/misandry.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/miscellaneous"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/miscellaneous.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/miscellaneous.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/misogyny"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/misogyny.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/misogyny.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/politics"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/politics.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/politics.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/privates"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/privates.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/privates.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/racism"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/racism.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/racism.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/religion"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/religion.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/religion.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/riddles"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/riddles.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/riddles.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/sex"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/sex.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/sex.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/songs-poems"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/songs-poems.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/songs-poems.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/vulgarity"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/vulgarity.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/vulgarity.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/zippy"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/zippy.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/rotated/zippy.u8"
    )
endif()

