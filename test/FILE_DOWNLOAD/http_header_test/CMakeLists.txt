## Verify that CMLIB_FILE_DOWNLOAD_HTTP_HEADER is passed as HTTPHEADER
# to FILE(DOWNLOAD) when set, and omitted when empty.
# Uses cmake --trace-expand to inspect actual FILE(DOWNLOAD) arguments.
#
IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_HTTP_HEADER_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

SET(test_header_value "Authorization: Bearer test-token")

FOREACH(header_value IN ITEMS "${test_header_value}" "")
    IF(header_value)
        SET(header_arg "-DTEST_HTTP_HEADER_VALUE=${header_value}")
    ELSE()
        SET(header_arg)
    ENDIF()

    EXECUTE_PROCESS(
        COMMAND "${CMAKE_COMMAND}"
            --trace-expand
            --trace-source=${CMLIB_PATH}/system_modules/CMLIB_FILE_DOWNLOAD.cmake
            ${header_arg}
            -P "${CMAKE_CURRENT_LIST_DIR}/http_header_download.cmake"
        RESULT_VARIABLE result
        OUTPUT_VARIABLE stdout
        ERROR_VARIABLE trace_output
    )

    IF(NOT result EQUAL 0)
        MESSAGE(FATAL_ERROR "Download failed for header='${header_value}':\n${stdout}\n${trace_output}")
    ENDIF()

    STRING(REGEX MATCHALL "FILE\\(DOWNLOAD " _download_calls "${trace_output}")
    LIST(LENGTH _download_calls _download_count)
    IF(NOT _download_count EQUAL 1)
        MESSAGE(FATAL_ERROR "Expected exactly 1 FILE(DOWNLOAD) call, found ${_download_count}.\nTrace output:\n${trace_output}")
    ENDIF()

    STRING(REPLACE "\n"   " " trace_oneline "${trace_output}")
    STRING(REPLACE "\n\r" " " trace_oneline "${trace_output}")
    IF(header_value)
        STRING(REGEX MATCH "FILE\\(DOWNLOAD .+HTTPHEADER.+${header_value}" _match "${trace_oneline}")
        IF(NOT _match)
            MESSAGE(FATAL_ERROR "HTTPHEADER not passed to FILE(DOWNLOAD).\nTrace output:\n${trace_output}")
        ENDIF()
    ELSE()
        STRING(REGEX MATCH "FILE\\(DOWNLOAD .+HTTPHEADER" _match "${trace_oneline}")
        IF(_match)
            MESSAGE(FATAL_ERROR "HTTPHEADER should NOT be passed to FILE(DOWNLOAD) when header is empty.\nTrace output:\n${trace_output}")
        ENDIF()
    ENDIF()
ENDFOREACH()
