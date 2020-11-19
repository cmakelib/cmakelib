
IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
	PROJECT(CMLIB_CACHE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

SET(VALID_HTTP_URI   "http://bimproject.cz/")
SET(INVALID_HTTP_URI "http://bimproject-does-not-exist.cz/")
SET(VALID_GIT_URI    "ssh://git@stash.bimproject.cz:7999/bpcomm/cmake-lib-test.git")
SET(INVALID_GIT_URI  "ssh://git@stash.bimproject.cz:7999/bpcomm/utils-does-not-exist.git")
SET(VALID_GIT_FILE_PATH   "cmake/README.txt")
SET(INVALID_GIT_FILE_PATH "cmake/README_not_found")
SET(VALID_GIT_REVISION_FILE_PATH   "cmake-test/test_branch_README.txt")
SET(INVALID_GIT_REVISION_FILE_PATH "cmake-test/README_not_found")
SET(VALID_GIT_DIRECTORY_PATH   "cmake/")
SET(VALID_GIT_REVISION_DIRECTORY_PATH   "cmake-test/")
SET(INVALID_GIT_DIRECTORY_PATH "cmak")
SET(TEST_BRANCH_NAME "test-branch")




##########################################################################
## HTTP Tests
##########################################################################

FUNCTION(HTTP_DOWNLOAD)
	SET(output_path "${CMAKE_CURRENT_BINARY_DIR}/test.txt")
	FILE(REMOVE "${output_path}")
	CMLIB_FILE_DOWNLOAD(
		URI "${INVALID_HTTP_URI}"
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
	)
	TEST_VAR_FALSE(status)
	TEST_VAR_PATH_NOT_EXISTS(output_path)

	CMLIB_FILE_DOWNLOAD(
		URI "${VALID_HTTP_URI}"
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
	)
	TEST_VAR_TRUE(status)
	TEST_VAR_PATH_EXISTS(output_path)
ENDFUNCTION()

FUNCTION(HTTP_DOWNLOAD_URI_TYPE)
	SET(output_path "${CMAKE_CURRENT_BINARY_DIR}/test.txt")
	FILE(REMOVE "${output_path}")
	CMLIB_FILE_DOWNLOAD(
		URI_TYPE HTTP
		URI "${INVALID_HTTP_URI}"
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
	)
	TEST_VAR_FALSE(status)
	TEST_VAR_PATH_NOT_EXISTS(output_path)

	CMLIB_FILE_DOWNLOAD(
		URI_TYPE HTTP
		URI "${VALID_HTTP_URI}"
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
	)
	TEST_VAR_TRUE(status)
	TEST_VAR_PATH_EXISTS(output_path)
ENDFUNCTION()

FUNCTION(HTTP_DOWNLOAD_NO_STATUS)
	SET(output_path "${CMAKE_CURRENT_BINARY_DIR}/test.txt")
	FILE(REMOVE "${output_path}")
	CMLIB_FILE_DOWNLOAD(
		URI "${INVALID_HTTP_URI}"
		OUTPUT_PATH "${output_path}"
	)
	TEST_VAR_PATH_NOT_EXISTS(output_path)

	CMLIB_FILE_DOWNLOAD(
		URI "${VALID_HTTP_URI}"
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
	)
	TEST_VAR_PATH_EXISTS(output_path)
ENDFUNCTION()

FUNCTION(HTTP_DOWNLOAD_URI_TYPE_NO_STATUS)
	SET(output_path "${CMAKE_CURRENT_BINARY_DIR}/test.txt")
	FILE(REMOVE "${output_path}")
	CMLIB_FILE_DOWNLOAD(
		URI_TYPE HTTP
		URI "${INVALID_HTTP_URI}"
		OUTPUT_PATH "${output_path}"
	)
	TEST_VAR_PATH_NOT_EXISTS(output_path)

	CMLIB_FILE_DOWNLOAD(
		URI_TYPE HTTP
		URI "${VALID_HTTP_URI}"
		OUTPUT_PATH "${output_path}"
	)
	TEST_VAR_PATH_EXISTS(output_path)
ENDFUNCTION()



##########################################################################
## GIT Tests
##########################################################################

FUNCTION(GIT_DOWNLOAD uri_type_option explicit_file_name status_check)
	SET(uri_type_args)
	IF(uri_type_option)
		SET(uri_type_args URI_TYPE GIT)
	ENDIF()

	SET(status_args)
	IF(status_check)
		SET(status_args STATUS_VAR status)
	ENDIF()

	SET(output_path "${CMAKE_CURRENT_BINARY_DIR}/")

	GET_FILENAME_COMPONENT(filename "${VALID_GIT_FILE_PATH}" NAME)
	SET(tmp "${output_path}/${filename}")
	IF(explicit_file_name)
		SET(output_path "${CMAKE_CURRENT_BINARY_DIR}/${filename}")
	ENDIF()

	SET(test_branch_output_path "${CMAKE_CURRENT_BINARY_DIR}/")
	GET_FILENAME_COMPONENT(test_branch_filename "${VALID_GIT_REVISION_FILE_PATH}" NAME)
	SET(test_branch_tmp "${test_branch_output_path}/${test_branch_filename}")
	IF(explicit_file_name)
		SET(test_branch_output_path "${CMAKE_CURRENT_BINARY_DIR}/${test_branch_filename}")
	ENDIF()

	FILE(REMOVE "${tmp}")
	CMLIB_FILE_DOWNLOAD(
		URI "${INVALID_GIT_URI}"
		GIT_PATH "${VALID_GIT_FILE_PATH}"
		OUTPUT_PATH "${output_path}"
		${uri_type_args}
		${status_args}
	)
	IF(status_check)
		TEST_VAR_FALSE(status)
	ENDIF()
	TEST_VAR_PATH_NOT_EXISTS(tmp)

	CMLIB_FILE_DOWNLOAD(
		URI "${VALID_GIT_URI}"
		GIT_PATH "${INVALID_GIT_FILE_PATH}"
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
		${uri_type_args}
		${status_args}
	)
	IF(status_check)
		TEST_VAR_FALSE(status)
	ENDIF()
	TEST_VAR_PATH_NOT_EXISTS(tmp)

	CMLIB_FILE_DOWNLOAD(
		URI "${VALID_GIT_URI}"
		GIT_PATH ${VALID_GIT_FILE_PATH}
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
		${uri_type_args}
		${status_args}
	)
	IF(status_check)
		TEST_VAR_TRUE(status)
	ENDIF()
	TEST_VAR_PATH_EXISTS(tmp)
	FILE(REMOVE ${tmp})

	CMLIB_FILE_DOWNLOAD(
		URI "${VALID_GIT_URI}"
		GIT_PATH ${VALID_GIT_REVISION_FILE_PATH}
		GIT_REVISION "${TEST_BRANCH_NAME}"
		STATUS_VAR status
		OUTPUT_PATH "${test_branch_output_path}"
		${uri_type_args}
		${status_args}
	)
	IF(status_check)
		TEST_VAR_TRUE(status)
	ENDIF()
	TEST_VAR_PATH_EXISTS(test_branch_tmp)
	FILE(REMOVE ${test_branch_tmp})
ENDFUNCTION()

SET(i 0)
FUNCTION(GIT_DOWNLOAD_DIRECTORY uri_type_option explicit_file_name status_check)
	MATH(EXPR _i "${i} + 1")
	SET(i ${_i} PARENT_SCOPE)
	SET(uri_type_args)
	IF(uri_type_option)
		SET(uri_type_args URI_TYPE GIT)
	ENDIF()

	SET(status_args)
	IF(status_check)
		SET(status_args STATUS_VAR status)
	ENDIF()

	SET(output_path)
	SET(test_branch_output_path)
	IF(CMLIB_DEBUG)
		SET(output_path "${CMAKE_CURRENT_BINARY_DIR}/git_directory_${i}")
		SET(test_branch_output_path "${CMAKE_CURRENT_BINARY_DIR}/test_branch_git_directory_${i}")
	ELSE()
		SET(output_path "${CMAKE_CURRENT_BINARY_DIR}/git_directory")
		SET(test_branch_output_path "${CMAKE_CURRENT_BINARY_DIR}/test_branch_git_directory")
	ENDIF()
	SET(tmp "${output_path}/")
	SET(test_branch_tmp "${test_branch_output_path}/")

	FILE(REMOVE_RECURSE "${tmp}")
	CMLIB_FILE_DOWNLOAD(
		URI "${INVALID_GIT_URI}"
		GIT_PATH "${VALID_GIT_DIRECTORY_PATH}"
		OUTPUT_PATH "${output_path}"
		${uri_type_args}
		${status_args}
	)
	IF(status_check)
		TEST_VAR_FALSE(status)
	ENDIF()
	TEST_VAR_PATH_NOT_EXISTS(tmp)

	CMLIB_FILE_DOWNLOAD(
		URI "${VALID_GIT_URI}"
		GIT_PATH "${INVALID_GIT_FILE_PATH}"
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
		${uri_type_args}
		${status_args}
	)
	IF(status_check)
		TEST_VAR_FALSE(status)
	ENDIF()
	TEST_VAR_PATH_NOT_EXISTS(tmp)

	CMLIB_FILE_DOWNLOAD(
		URI "${VALID_GIT_URI}"
		GIT_PATH ${VALID_GIT_DIRECTORY_PATH}
		STATUS_VAR status
		OUTPUT_PATH "${output_path}"
		${uri_type_args}
		${status_args}
	)
	IF(status_check)
		TEST_VAR_TRUE(status)
	ENDIF()
	TEST_VAR_PATH_EXISTS(tmp)

	CMLIB_FILE_DOWNLOAD(
		URI "${VALID_GIT_URI}"
		GIT_PATH ${VALID_GIT_REVISION_DIRECTORY_PATH}
		GIT_REVISION ${TEST_BRANCH_NAME}
		STATUS_VAR status
		OUTPUT_PATH "${test_branch_output_path}"
		${uri_type_args}
		${status_args}
	)
	IF(status_check)
		TEST_VAR_TRUE(status)
	ENDIF()
	TEST_VAR_PATH_EXISTS(test_branch_tmp)
ENDFUNCTION()




FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
HTTP_DOWNLOAD()
HTTP_DOWNLOAD_URI_TYPE()
HTTP_DOWNLOAD_NO_STATUS()
HTTP_DOWNLOAD_URI_TYPE_NO_STATUS()
GIT_DOWNLOAD(ON ON ON)
GIT_DOWNLOAD(OFF OFF OFF)
GIT_DOWNLOAD(OFF OFF ON)
GIT_DOWNLOAD(OFF ON ON)
GIT_DOWNLOAD(ON OFF ON)
GIT_DOWNLOAD(OFF ON OFF)
GIT_DOWNLOAD_DIRECTORY(ON ON ON)
GIT_DOWNLOAD_DIRECTORY(OFF OFF OFF)
GIT_DOWNLOAD_DIRECTORY(OFF OFF ON)
GIT_DOWNLOAD_DIRECTORY(OFF ON ON)
GIT_DOWNLOAD_DIRECTORY(ON OFF ON)
GIT_DOWNLOAD_DIRECTORY(OFF ON OFF)
FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
