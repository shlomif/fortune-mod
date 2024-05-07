# Install script for directory: /home/maaz/projects/fortune-mod/fortune-mod/datfiles

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
   "/usr/local/share/games/fortunes/art;/usr/local/share/games/fortunes/art.dat;/usr/local/share/games/fortunes/art.u8;/usr/local/share/games/fortunes/ascii-art;/usr/local/share/games/fortunes/ascii-art.dat;/usr/local/share/games/fortunes/ascii-art.u8;/usr/local/share/games/fortunes/computers;/usr/local/share/games/fortunes/computers.dat;/usr/local/share/games/fortunes/computers.u8;/usr/local/share/games/fortunes/cookie;/usr/local/share/games/fortunes/cookie.dat;/usr/local/share/games/fortunes/cookie.u8;/usr/local/share/games/fortunes/debian;/usr/local/share/games/fortunes/debian.dat;/usr/local/share/games/fortunes/debian.u8;/usr/local/share/games/fortunes/definitions;/usr/local/share/games/fortunes/definitions.dat;/usr/local/share/games/fortunes/definitions.u8;/usr/local/share/games/fortunes/disclaimer;/usr/local/share/games/fortunes/disclaimer.dat;/usr/local/share/games/fortunes/disclaimer.u8;/usr/local/share/games/fortunes/drugs;/usr/local/share/games/fortunes/drugs.dat;/usr/local/share/games/fortunes/drugs.u8;/usr/local/share/games/fortunes/education;/usr/local/share/games/fortunes/education.dat;/usr/local/share/games/fortunes/education.u8;/usr/local/share/games/fortunes/ethnic;/usr/local/share/games/fortunes/ethnic.dat;/usr/local/share/games/fortunes/ethnic.u8;/usr/local/share/games/fortunes/food;/usr/local/share/games/fortunes/food.dat;/usr/local/share/games/fortunes/food.u8;/usr/local/share/games/fortunes/fortunes;/usr/local/share/games/fortunes/fortunes.dat;/usr/local/share/games/fortunes/fortunes.u8;/usr/local/share/games/fortunes/goedel;/usr/local/share/games/fortunes/goedel.dat;/usr/local/share/games/fortunes/goedel.u8;/usr/local/share/games/fortunes/humorists;/usr/local/share/games/fortunes/humorists.dat;/usr/local/share/games/fortunes/humorists.u8;/usr/local/share/games/fortunes/kids;/usr/local/share/games/fortunes/kids.dat;/usr/local/share/games/fortunes/kids.u8;/usr/local/share/games/fortunes/knghtbrd;/usr/local/share/games/fortunes/knghtbrd.dat;/usr/local/share/games/fortunes/knghtbrd.u8;/usr/local/share/games/fortunes/law;/usr/local/share/games/fortunes/law.dat;/usr/local/share/games/fortunes/law.u8;/usr/local/share/games/fortunes/linux;/usr/local/share/games/fortunes/linux.dat;/usr/local/share/games/fortunes/linux.u8;/usr/local/share/games/fortunes/literature;/usr/local/share/games/fortunes/literature.dat;/usr/local/share/games/fortunes/literature.u8;/usr/local/share/games/fortunes/love;/usr/local/share/games/fortunes/love.dat;/usr/local/share/games/fortunes/love.u8;/usr/local/share/games/fortunes/magic;/usr/local/share/games/fortunes/magic.dat;/usr/local/share/games/fortunes/magic.u8;/usr/local/share/games/fortunes/medicine;/usr/local/share/games/fortunes/medicine.dat;/usr/local/share/games/fortunes/medicine.u8;/usr/local/share/games/fortunes/men-women;/usr/local/share/games/fortunes/men-women.dat;/usr/local/share/games/fortunes/men-women.u8;/usr/local/share/games/fortunes/miscellaneous;/usr/local/share/games/fortunes/miscellaneous.dat;/usr/local/share/games/fortunes/miscellaneous.u8;/usr/local/share/games/fortunes/news;/usr/local/share/games/fortunes/news.dat;/usr/local/share/games/fortunes/news.u8;/usr/local/share/games/fortunes/paradoxum;/usr/local/share/games/fortunes/paradoxum.dat;/usr/local/share/games/fortunes/paradoxum.u8;/usr/local/share/games/fortunes/people;/usr/local/share/games/fortunes/people.dat;/usr/local/share/games/fortunes/people.u8;/usr/local/share/games/fortunes/perl;/usr/local/share/games/fortunes/perl.dat;/usr/local/share/games/fortunes/perl.u8;/usr/local/share/games/fortunes/pets;/usr/local/share/games/fortunes/pets.dat;/usr/local/share/games/fortunes/pets.u8;/usr/local/share/games/fortunes/platitudes;/usr/local/share/games/fortunes/platitudes.dat;/usr/local/share/games/fortunes/platitudes.u8;/usr/local/share/games/fortunes/politics;/usr/local/share/games/fortunes/politics.dat;/usr/local/share/games/fortunes/politics.u8;/usr/local/share/games/fortunes/pratchett;/usr/local/share/games/fortunes/pratchett.dat;/usr/local/share/games/fortunes/pratchett.u8;/usr/local/share/games/fortunes/riddles;/usr/local/share/games/fortunes/riddles.dat;/usr/local/share/games/fortunes/riddles.u8;/usr/local/share/games/fortunes/rules-of-acquisition;/usr/local/share/games/fortunes/rules-of-acquisition.dat;/usr/local/share/games/fortunes/rules-of-acquisition.u8;/usr/local/share/games/fortunes/science;/usr/local/share/games/fortunes/science.dat;/usr/local/share/games/fortunes/science.u8;/usr/local/share/games/fortunes/shlomif-fav;/usr/local/share/games/fortunes/shlomif-fav.dat;/usr/local/share/games/fortunes/shlomif-fav.u8;/usr/local/share/games/fortunes/songs-poems;/usr/local/share/games/fortunes/songs-poems.dat;/usr/local/share/games/fortunes/songs-poems.u8;/usr/local/share/games/fortunes/sports;/usr/local/share/games/fortunes/sports.dat;/usr/local/share/games/fortunes/sports.u8;/usr/local/share/games/fortunes/startrek;/usr/local/share/games/fortunes/startrek.dat;/usr/local/share/games/fortunes/startrek.u8;/usr/local/share/games/fortunes/tao;/usr/local/share/games/fortunes/tao.dat;/usr/local/share/games/fortunes/tao.u8;/usr/local/share/games/fortunes/the-x-files-taglines;/usr/local/share/games/fortunes/the-x-files-taglines.dat;/usr/local/share/games/fortunes/the-x-files-taglines.u8;/usr/local/share/games/fortunes/translate-me;/usr/local/share/games/fortunes/translate-me.dat;/usr/local/share/games/fortunes/translate-me.u8;/usr/local/share/games/fortunes/wisdom;/usr/local/share/games/fortunes/wisdom.dat;/usr/local/share/games/fortunes/wisdom.u8;/usr/local/share/games/fortunes/work;/usr/local/share/games/fortunes/work.dat;/usr/local/share/games/fortunes/work.u8;/usr/local/share/games/fortunes/zippy;/usr/local/share/games/fortunes/zippy.dat;/usr/local/share/games/fortunes/zippy.u8")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/share/games/fortunes" TYPE FILE FILES
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/art"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/art.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/art.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/ascii-art"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/ascii-art.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/ascii-art.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/computers"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/computers.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/computers.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/cookie"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/cookie.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/cookie.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/debian"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/debian.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/debian.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/definitions"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/definitions.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/definitions.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/disclaimer"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/disclaimer.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/disclaimer.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/drugs"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/drugs.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/drugs.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/education"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/education.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/education.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/ethnic"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/ethnic.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/ethnic.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/food"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/food.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/food.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/fortunes"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/fortunes.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/fortunes.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/goedel"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/goedel.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/goedel.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/humorists"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/humorists.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/humorists.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/kids"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/kids.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/kids.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/knghtbrd"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/knghtbrd.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/knghtbrd.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/law"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/law.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/law.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/linux"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/linux.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/linux.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/literature"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/literature.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/literature.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/love"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/love.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/love.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/magic"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/magic.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/magic.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/medicine"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/medicine.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/medicine.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/men-women"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/men-women.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/men-women.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/miscellaneous"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/miscellaneous.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/miscellaneous.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/news"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/news.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/news.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/paradoxum"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/paradoxum.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/paradoxum.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/people"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/people.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/people.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/perl"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/perl.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/perl.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/pets"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/pets.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/pets.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/platitudes"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/platitudes.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/platitudes.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/politics"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/politics.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/politics.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/pratchett"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/pratchett.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/pratchett.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/riddles"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/riddles.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/riddles.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/rules-of-acquisition"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/rules-of-acquisition.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/rules-of-acquisition.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/science"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/science.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/science.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/shlomif-fav"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/shlomif-fav.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/shlomif-fav.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/songs-poems"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/songs-poems.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/songs-poems.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/sports"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/sports.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/sports.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/startrek"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/startrek.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/startrek.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/tao"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/tao.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/tao.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/the-x-files-taglines"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/the-x-files-taglines.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/the-x-files-taglines.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/translate-me"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/translate-me.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/translate-me.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/wisdom"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/wisdom.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/wisdom.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/work"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/work.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/work.u8"
    "/home/maaz/projects/fortune-mod/fortune-mod/datfiles/zippy"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/zippy.dat"
    "/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/zippy.u8"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/maaz/projects/fortune-mod/fortune-mod/build/datfiles/off/cmake_install.cmake")

endif()

