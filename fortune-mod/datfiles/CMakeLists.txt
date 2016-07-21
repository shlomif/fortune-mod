SET (COOKIES
    art
    ascii-art
    computers
    cookie
    definitions
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
    riddles
    science
    songs-poems
    sports
    startrek
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

FOREACH(c ${COOKIES})
    SET(TARGET_NAME "cookie__${c}")
    SET(DEST "${c}.dat")
    SET(SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/${c}")

    ADD_CUSTOM_COMMAND(
        OUTPUT "${DEST}"
        COMMAND "${CMAKE_CURRENT_BINARY_DIR}/../strfile"
        ARGS "${SOURCE}" "${DEST}"
        DEPENDS "${SOURCE}"
    )
    ADD_CUSTOM_TARGET(
        "${TARGET_NAME}" ALL
        DEPENDS "${DEST}"
    )
ENDFOREACH()
