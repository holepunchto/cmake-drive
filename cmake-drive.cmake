include_guard()

set(drive_module_dir "${CMAKE_CURRENT_LIST_DIR}")

function(mirror_drive)
  cmake_parse_arguments(
    PARSE_ARGV 0 ARGV "" "SOURCE;DESTINATION;PREFIX;CHECKOUT;WORKING_DIRECTORY" ""
  )

  if(ARGV_WORKING_DIRECTORY)
    cmake_path(ABSOLUTE_PATH ARGV_WORKING_DIRECTORY BASE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" NORMALIZE)
  else()
    set(ARGV_WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")
  endif()

  if(NOT ARGV_PREFIX)
    set(ARGV_PREFIX /)
  endif()

  if(NOT ARGV_CHECKOUT)
    set(ARGV_CHECKOUT 0)
  endif()

  set(args
    "${ARGV_WORKING_DIRECTORY}"
    "${ARGV_PREFIX}"
    "${ARGV_CHECKOUT}"
    "${ARGV_SOURCE}"
    "${ARGV_DESTINATION}"
  )

  if(CMAKE_HOST_WIN32)
    find_program(
      node
      NAMES node.cmd node
      REQUIRED
    )
  else()
    find_program(
      node
      NAMES node
      REQUIRED
    )
  endif()

  message(STATUS "Mirroring drive ${ARGV_SOURCE} into ${ARGV_DESTINATION}")

  execute_process(
    COMMAND "${node}" "${drive_module_dir}/mirror.js" ${args}
    OUTPUT_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${ARGV_WORKING_DIRECTORY}"
  )

  message(CONFIGURE_LOG
    "Mirrored drive ${ARGV_SOURCE} into ${ARGV_DESTINATION}\n"
    "${output}"
  )
endfunction()
