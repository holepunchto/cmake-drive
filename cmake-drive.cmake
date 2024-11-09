include_guard()

set(drive_module_dir "${CMAKE_CURRENT_LIST_DIR}")

set(DRIVE_CORESTORE_DIR "$ENV{DRIVE_CORESTORE_DIR}" CACHE PATH "The path to the Corestore storage directory")

function(mirror_drive)
  cmake_parse_arguments(
    PARSE_ARGV 0 ARGV "" "SOURCE;DESTINATION;PREFIX;CHECKOUT;TIMEOUT;WORKING_DIRECTORY" ""
  )

  if(NOT DRIVE_CORESTORE_DIR)
    set(DRIVE_CORESTORE_DIR "${CMAKE_BINARY_DIR}/corestore")
  endif()

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

  if(NOT ARGV_TIMEOUT)
    set(ARGV_TIMEOUT 600)
  endif()

  set(args
    "${DRIVE_CORESTORE_DIR}"
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
    RESULT_VARIABLE status
    OUTPUT_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE error
    TIMEOUT ${ARGV_TIMEOUT}
    WORKING_DIRECTORY "${ARGV_WORKING_DIRECTORY}"
  )

  if(NOT status EQUAL 0)
    message(FATAL_ERROR "${error}")
  endif()

  message(CONFIGURE_LOG
    "Mirrored drive ${ARGV_SOURCE} into ${ARGV_DESTINATION}\n"
    "${output}"
  )
endfunction()
