function(deleteinplace IN_FILE pattern)
    message("*********** deleteinplace CMAKE_ARGC: ${CMAKE_ARGC} IN_FILE: ${IN_FILE} PATTERN: ${pattern}" )
    # create list of lines form the contens of a file
    file (STRINGS ${IN_FILE} LINES)

    # overwrite the file....
    file(WRITE ${IN_FILE} "")

    # loop through the lines,
    # remove unwanted parts
    # and write the (changed) line ...
    foreach(LINE IN LISTS LINES)
        string(REGEX REPLACE ${pattern} "" STRIPPED "${LINE}")
        file(APPEND ${IN_FILE} "${STRIPPED}\n")
    endforeach()
endfunction()

message("*********** CMAKE_ARGC: ${CMAKE_ARGC} ")#"CMAKE_ARGV0: ${CMAKE_ARGV0} CMAKE_ARGV1: ${CMAKE_ARGV1} CMAKE_ARGV2: ${CMAKE_ARGV2} CMAKE_ARGV3: ${CMAKE_ARGV3} CMAKE_ARGV4: ${CMAKE_ARGV4} ")
message("fix-qmldir: module_qmldirs: ${module_qmldirs} ********************************")
message("fix-qmldir: cached module_qmldirs: $CACHE{module_qmldirs} ********************************")
deleteinplace(${CMAKE_ARGV3} "^prefer.*")
