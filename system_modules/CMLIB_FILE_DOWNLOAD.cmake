## Main
#
# BIM CMake File Download
# It enables to store remote files localy
# (Download files from remote to local filesystem)
#
## Functions
# - CMLIB_FILE_DOWNLOAD - download file or directory (git only).
# Function supports download from HTTP server and GIT repository.
# Each is represented by URI_TYPE. Supported URI_TYPE is from { HTTP, GIT }
#
## Variables
# - CMLIB_FILE_DOWNLOAD_SHOW_PROGRESS - show download progress
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF(DEFINED CMLIB_FILE_DOWNLOAD_INCLUDED)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_FILE_DOWNLOAD already included")
	RETURN()
ENDIF()

# Flag that FILE_DOWNLOAD is already included
SET(CMLIB_FILE_DOWNLOAD_INCLUDED "1")

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)

SET(CMLIB_FILE_DOWNLOAD_TIMEOUT 100
	CACHE INTERNAL
	"Inactivity timeout for File Downlad"
)

OPTION(CMLIB_FILE_DOWNLOAD_SHOW_PROGRESS
	"Show download progress if ON. Do not show if OFF."
	${CMLIB_DEBUG}
)

_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)



##
#
# Download file from GIT or HTTP server.
# Stores data represented by "URI" to user
# specified directory (or file path).
# Store result of the operation to "STATUS_VAR" variable
# Which is list (<return_code>, <error_message>)
#
# OUTPUT_PATH must be absolute (otherwise the behaviour is not defined).
# OUTPUT_PATH can represent file or directory.
# - If the URI_TYPE is "HTTP" the OUTPUT_PATH must represent file.
#   If the OUTPUT_PATH will represent directory remote file will
#   be stored under random generated name to OUTPUT_PATH.
# - if the URI_TYPE is  "GIT" the OUTPUT_PATH can represent file
# or directory. Result is dependent on what is downloaded from given GIT URI.
#		- if the downloaded content is not a directory then
#			- if OUTPUT_PATH is directory -> the file downloaded from given GIT
#			  repository is is saved to OUTPUT_PATH under original name
#			- if OUTPUT_FILE is directory -> the file downloaded from given GIT
#			  repository is saved to file represented by OUTPUT_PATH
#		- if the downloaded content is a directory then
#			- OUTPUT_PATH have to represent existing directory.
#			  in which the content of the remote directory will be saved.
# - if the GIT_REVISION is specified then the content will be downloaded
#   from given branch.
# - if the GIT_REVISION is NOT specified then the content will be downloaded from
#   master branch.
#
# URI_TYPE can be one of { GIT, HTTP }.
# URI_TYPE is determined automatically if not specified.
# If URI_TYPE specified the type is not determiner nor validated.
# (so we can set URI_TYPE whatever we want independent on URI )
#
# <function>(
#		URI <uri>
#		OUTPUT_PATH <output_path>
#		[STATUS_VAR <status>]
#		[GIT_PATH <git_path>]
#		[GIT_REVISION <git_revision>]
#		[URI_TYPE <GIT|HTTP>]
# )
#
FUNCTION(CMLIB_FILE_DOWNLOAD)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI
			OUTPUT_PATH
			STATUS_VAR
			GIT_PATH
			GIT_REVISION
			URI_TYPE
		REQUIRED
			URI
			OUTPUT_PATH
		P_ARGN ${ARGN}
	)

	# We need to define STATUS_VAR
	# because is required in subsequent functions
	IF(NOT DEFINED __STATUS_VAR)
		SET(__STATUS_VAR _bimcm_status_var)
	ENDIF()

	SET(uri_type)
	IF(NOT DEFINED __URI_TYPE)
		IF(DEFINED __GIT_PATH)
			SET(uri_type "GIT")
		ELSE()
			_CMLIB_FILE_DETERMINE_URI_TYPE(uri_type "${__URI}")
		ENDIF()
	ELSE()
		SET(uri_type "${__URI_TYPE}")
	ENDIF()

	SET(path)
	SET(status)
	IF("${uri_type}" STREQUAL "GIT")
		SET(git_revision_command GIT_REVISION "master")
		IF(DEFINED __GIT_REVISION)
			SET(git_revision_command GIT_REVISION "${__GIT_REVISION}")
		ENDIF()

		SET(git_path)
		IF(DEFINED __GIT_PATH)
			SET(git_path "${__GIT_PATH}")
		ELSE()
			SET(git_path "./")
		ENDIF()

		_CMLIB_FILE_DOWNLOAD_FROM_GIT(
			URI        "${__URI}"
			GIT_PATH   "${git_path}"
			${git_revision_command}
			OUTPUT_VAR path
			STATUS_VAR status
		)
	ELSEIF("${uri_type}" STREQUAL "HTTP")
		_CMLIB_FILE_DOWNLOAD_FROM_HTTP(
			URI        "${__URI}"
			OUTPUT_VAR path
			STATUS_VAR status
		)
	ELSE()
		MESSAGE(FATAL_ERROR "Invalid URI_TYPE '${uri_type}'. Cannot continue.")
	ENDIF()

	IF(NOT status)
		SET(${__STATUS_VAR} OFF PARENT_SCOPE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Download from '${__URI}' failed")
		RETURN()
	ENDIF()

	IF(IS_DIRECTORY "${path}")
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Copy Directory '${path}' --> '${__OUTPUT_PATH}'")
		EXECUTE_PROCESS(
			COMMAND ${CMAKE_COMMAND} -E copy_directory
			${path} "${__OUTPUT_PATH}"
		)
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Copy File '${path}' --> '${__OUTPUT_PATH}'")
		EXECUTE_PROCESS(
			COMMAND ${CMAKE_COMMAND} -E copy
			${path} "${__OUTPUT_PATH}"
		)
	ENDIF()

	SET(${__STATUS_VAR} ON PARENT_SCOPE)
	_CMLIB_FILE_TMP_DIR_CLEAN()
ENDFUNCTION()






## Helper
#
# Download file from HTTP server.
# File is downloaded into TMP directory
# Path to the directory which contains downloaded file
# is stored in OUTPUT_VAR variable.
# STATUS_VAR variable holds true if download succeed, false otherwise
#
# <function>(
#		URI <uri>
#		OUTPUT_VAR <output_var>
#		STATUS_VAR <status_var>
# )
#
FUNCTION(_CMLIB_FILE_DOWNLOAD_FROM_HTTP)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI
			OUTPUT_VAR
			STATUS_VAR
		REQUIRED
			URI
			STATUS_VAR
			OUTPUT_VAR
		P_ARGN ${ARGN}
	)

	_CMLIB_FILE_TMP_DIR_CLEAN()
	_CMLIB_FILE_TMP_DIR_CREATE()
	_CMLIB_FILE_TMP_DIR_GET(tmp_dir)

	_CMLIB_FILE_DETERMINE_FILENAME_FROM_URI("${__URI}" "HTTP" "" filename)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("HTTP Download: ${__URI} --> '${tmp_dir}/${filename}'")

	SET(show_progress_arg)
	IF(CMLIB_FILE_DOWNLOAD_SHOW_PROGRESS)
		SET(show_progress_arg SHOW_PROGRESS)
	ENDIF()

	FILE(DOWNLOAD
		"${__URI}"
		"${tmp_dir}/${filename}"
		${show_progress_arg}
		INACTIVITY_TIMEOUT ${CMLIB_FILE_DOWNLOAD_TIMEOUT}
		STATUS download_status_list
	)
	LIST(GET download_status_list 0 status)
	IF(status)
		SET(${__STATUS_VAR} OFF PARENT_SCOPE)
	ELSE()
		SET(${__STATUS_VAR} ON PARENT_SCOPE)
	ENDIF()
	IF(NOT (status EQUAL 0))
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Download from '${__URI}' failed: ${download_status_list}")
	ENDIF()

	SET(${__OUTPUT_VAR} "${tmp_dir}/${filename}" PARENT_SCOPE)

ENDFUNCTION()



## Helper
#
# Downloads files from GIT.
#
# Stores path to the downloaded files to OUTPUT_VAR.
# There is not guarntee that path stored in UOTPUT_VAR will
# persist across multiple invactions of this funtion.
#
# STATUS_VAR is true if everything is OK, false othervise
#
# <function>(
# 		URI <uri>
#		OUTPUT_VAR <output_var>
#		STATUS_VAR <status_var>
# )
#
FUNCTION(_CMLIB_FILE_DOWNLOAD_FROM_GIT)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI
			GIT_PATH
			GIT_REVISION
			OUTPUT_VAR
			STATUS_VAR
		REQUIRED
			URI
			GIT_PATH
			GIT_REVISION
			OUTPUT_VAR
			STATUS_VAR
		P_ARGN ${ARGN}
	)

	SET(${__STATUS_VAR} OFF PARENT_SCOPE)

	_CMLIB_FILE_TMP_DIR_CLEAN()
	_CMLIB_FILE_TMP_DIR_CREATE()
	_CMLIB_FILE_TMP_DIR_GET(tmp_dir)

	_CMLIB_LIBRARY_DEBUG_MESSAGE("GIT Download: ${__URI} --> '${tmp_dir}/${__GIT_PATH}'")

	SET(archive_path "${tmp_dir}/git_file.tar")
	IF(EXISTS "${archive_path}")
		FILE(REMOVE "${archive_path}")
	ENDIF()

	SET(git_repo_dir "${tmp_dir}/git_repo")
	FILE(MAKE_DIRECTORY "${git_repo_dir}")
	EXECUTE_PROCESS(
		COMMAND "${CMLIB_REQUIRED_ENV_GIT_EXECUTABLE}" clone
			--depth=1
			--branch ${__GIT_REVISION}
			--single-branch
			"${__URI}" .
		OUTPUT_VARIABLE   stdout # discard STDOUT
		ERROR_VARIABLE    stderr # discard STDERR
		RESULT_VARIABLE   git_not_found
		WORKING_DIRECTORY "${git_repo_dir}"
	)
	IF(NOT git_not_found EQUAL 0)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Git process exit status: ${git_not_found}\n${git_stderr}")
		_CMLIB_FILE_TMP_DIR_CLEAN()
		RETURN()
	ENDIF()
	EXECUTE_PROCESS(
		COMMAND "${CMLIB_REQUIRED_ENV_GIT_EXECUTABLE}" archive
			-o "${archive_path}"
			${__GIT_REVISION}
			"${__GIT_PATH}"
		RESULT_VARIABLE   file_not_found
		WORKING_DIRECTORY "${git_repo_dir}"
	)
	IF(NOT file_not_found EQUAL 0)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Git process exit status: ${file_not_found}\n${git_stderr}")
		_CMLIB_FILE_TMP_DIR_CLEAN()
		RETURN()
	ENDIF()

    EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E tar xf "${archive_path}"
		WORKING_DIRECTORY ${tmp_dir}
		RESULT_VARIABLE tar_not_valid
    )
	IF(NOT tar_not_valid EQUAL 0)
		_CMLIB_FILE_TMP_DIR_CLEAN()
		RETURN()
	ENDIF()

	FILE(REMOVE ${archive_path})
	SET(${__STATUS_VAR} ON PARENT_SCOPE)
	SET(${__OUTPUT_VAR} "${tmp_dir}/${__GIT_PATH}" PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Determine filename from URI or GIT_PATH.
# If name cannot be determined then genrated random name.
# <function> (
#		<uri>
#		<uri_type>    // Standard URI type
#		<git_path>    // Ignored if the uri_type is not GIT
#		<output_var>
# )
#
FUNCTION(_CMLIB_FILE_DETERMINE_FILENAME_FROM_URI uri uri_type git_path output_var)
	SET(filename)
	IF("${uri_type}" STREQUAL "GIT")
		GET_FILENAME_COMPONENT(filename "${git_path}" NAME)
	ELSE()
		GET_FILENAME_COMPONENT(filename "${uri}" NAME)
	ENDIF()
	IF("${filename}" STREQUAL "")
		STRING(RANDOM LENGTH 16 filename)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Filename cannot be determined")
	ENDIF()
	SET(${output_var} "${filename}" PARENT_SCOPE)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Determined filename: ${filename}")
ENDFUNCTION()



## Helper
#
# Get CMLIB_FILE temporary directory
# <function>(
#		<var>
# )
#
MACRO(_CMLIB_FILE_TMP_DIR_GET var)
	SET(${var} "${CMLIB_REQUIRED_ENV_TMP_PATH}/bimcm_file/")
ENDMACRO()



## Helper
#
# Creates BICM_FILE tmp directory
# <function>(
# )
#
FUNCTION(_CMLIB_FILE_TMP_DIR_CREATE)
	_CMLIB_FILE_TMP_DIR_GET(tmp_dir)
	IF(NOT EXISTS "${tmp_dir}")
		FILE(MAKE_DIRECTORY "${tmp_dir}")
	ENDIF()
ENDFUNCTION()



## Helper
#
# Clean the BIM_CM tmp directory.
# <function>()
#
FUNCTION(_CMLIB_FILE_TMP_DIR_CLEAN)
	_CMLIB_FILE_TMP_DIR_GET(tmp_dir)
	IF(EXISTS "${tmp_dir}")
		FILE(REMOVE_RECURSE "${tmp_dir}")
	ENDIF()
ENDFUNCTION()



## Helper
#
# Determine URI_TYPE.
# <function>(
#		<output_var> <uri>
#)
#
FUNCTION(_CMLIB_FILE_DETERMINE_URI_TYPE var uri)
	STRING(REGEX MATCH "^(git://|git@).*" git_uri "${uri}")
	STRING(REGEX MATCH "^ssh://git@.*" git_ssh_uri "${uri}")
	STRING(REGEX MATCH "^http[s]?://.*" http_uri "${uri}")
	IF(git_uri OR git_ssh_uri)
		SET(${var} "GIT" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(http_uri)
		SET(${var} "HTTP" PARENT_SCOPE)
		RETURN()
	ENDIF()
	MESSAGE(FATAL_ERROR "Invalid URI. Cannot determine URI type")
ENDFUNCTION()

