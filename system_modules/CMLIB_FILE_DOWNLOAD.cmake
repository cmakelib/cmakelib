## Main
#
# CMLIB File Download
# It enables to store remote files locally
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

INCLUDE_GUARD(GLOBAL)

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)

SET(CMLIB_FILE_DOWNLOAD_DEFAULT_REVISION "master"
	CACHE STRING
	"Git repository default branch"
)

SET(CMLIB_FILE_DOWNLOAD_TIMEOUT 100
	CACHE INTERNAL
	"Inactivity timeout for File Download"
)

OPTION(CMLIB_FILE_DOWNLOAD_SHOW_PROGRESS
	"Show download progress if ON. Do not show if OFF."
	${CMLIB_DEBUG}
)

OPTION(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE
	"If On the git-archive will NOT be used! Conflicted with CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY!"
	OFF
)

OPTION(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY
	"If On the git-archive will be exclusively used to download files from git repository"
	OFF
)

IF(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY AND
		CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
	MESSAGE(FATAL_ERROR "CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY AND CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE are on together! Conflict state!")
ENDIF()


##
#
# It downloads file from GIT or fro any valid, supported URI.
# - Stores data represented by "URI" to user specified directory (or file path).
# - Stores result of the operation to "STATUS_VAR" variable.
#
# All download operations are done by CMLIB_FILE_DOWNLOAD function.
#
# OUTPUT_PATH must be absolute filesystem path.
#
# OUTPUT_PATH can represent file or directory.
# - If the URI_TYPE is "HTTP" the OUTPUT_PATH must represent file.
#   If the OUTPUT_PATH will represent directory remote file will
#   be stored under random generated name to OUTPUT_PATH.
# - if the URI_TYPE is "FILE" the OUTPUT_PATH must represent file.
#   If the OUTPUT_PATH will represent directory remote file will
#   be stored under the same name as referenced by URI to OUTPUT_PATH.
# - if the URI_TYPE is "GIT" the OUTPUT_PATH can represent file
# or directory. Result is dependent on what is downloaded from given GIT URI.
#		- if the downloaded content is not a directory then
#			- if OUTPUT_PATH is directory -> the file downloaded from given GIT
#			  repository is is saved to OUTPUT_PATH under original name
#			- if OUTPUT_FILE is directory -> the file downloaded from given GIT
#			  repository is saved to file represented by OUTPUT_PATH
#		- if the downloaded content is a directory then
#			- OUTPUT_PATH have to represent existing directory.
#			  in which the content of the remote directory will be saved.
#
# - if the GIT_REVISION is specified then the content will be downloaded
#   from given revidsion (tag, branch, commit id, ...).
# - if the GIT_REVISION is NOT specified then the content will be downloaded from
#   branch stored in CMLIB_FILE_DOWNLOAD_DEFAULT_REVISION cache variable.
#
# URI_TYPE can be set to one of { GIT, HTTP, FILE }.
# URI_TYPE is determined automatically if not specified.
# URI_TYPE is directly passed to the CMLIB_FILE_DOWNLOAD.
# 
# URI_TYPE can be set by user to whatever possible independent on URI until URI
# pass prerequisity check for a set URI_TYPE.
#
# URI_TYPE Prerequisity Checks
# - GIT
#		- no explicit URI checking is done. Passed URI is used as is by 'git clone/archive' command.
# 		- GIT_PATH must be specified.
# - HTTP
#		- URI must start with "http://" or "https://"
# - FILE
#		- URI must start with "file://"
#		- Path specified by URI must be absolute
#
# FILE_HASH_OUTPUT_VAR is a variable where the hash of the file
# wil be stored.
#
# <function>(
#		URI <uri>
#		OUTPUT_PATH <output_path>
#		[STATUS_VAR <status>]
#		[GIT_PATH <git_path>]
#		[GIT_REVISION <git_revision>]
#		[URI_TYPE <GIT|HTTP|FILE>]
#		[FILE_HASH_OUTPUT_VAR <file_hash_output_var>]
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
			FILE_HASH_OUTPUT_VAR
		REQUIRED
			URI
			OUTPUT_PATH
		P_ARGN ${ARGN}
	)

	# We need to define STATUS_VAR
	# because is required in subsequent functions
	IF(NOT DEFINED __STATUS_VAR)
		SET(__STATUS_VAR _cmlib_status_var)
	ENDIF()

	IF(NOT IS_ABSOLUTE "${__OUTPUT_PATH}")
		MESSAGE(FATAL_ERROR "OUTPUT_PATH must be absolute - '${__OUTPUT_PATH}'")
	ENDIF()

	SET(uri_type)
	IF(NOT DEFINED __URI_TYPE)
		IF(DEFINED __GIT_PATH)
			SET(uri_type "GIT")
		ELSE()
			_CMLIB_FILE_DETERMINE_URI_TYPE(uri_type "${__URI}" ${__GIT_REVISION} ${__GIT_PATH})
		ENDIF()
	ELSE()
		SET(uri_type "${__URI_TYPE}")
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("URI Type: '${uri_type}'")

	SET(file_hash)
	SET(path)
	SET(status)
	IF("${uri_type}" STREQUAL "GIT")
		SET(git_revision_command GIT_REVISION "${CMLIB_FILE_DOWNLOAD_DEFAULT_REVISION}")
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
			FILE_HASH_OUTPUT_VAR file_hash
		)
	ELSEIF("${uri_type}" STREQUAL "HTTP" OR
			"${uri_type}" STREQUAL "FILE")
		_CMLIB_FILE_DOWNLOAD_FROM_STANDARD_URI(
			URI        "${__URI}"
			URI_TYPE   "${uri_type}"
			OUTPUT_VAR path
			STATUS_VAR status
			FILE_HASH_OUTPUT_VAR file_hash
		)
	ELSE()
		MESSAGE(FATAL_ERROR "Invalid URI_TYPE '${uri_type}'. Cannot continue.")
	ENDIF()

	IF(NOT status)
		SET(${__STATUS_VAR} OFF PARENT_SCOPE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Download from '${__URI}' failed")
		RETURN()
	ENDIF()

	IF(NOT EXISTS "${path}")
		MESSAGE(FATAL_ERROR "Path to download file does not exist - '${path}'")
	ENDIF()

	SET(copy_result)
	IF(IS_DIRECTORY "${path}")
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Copy Directory '${path}' --> '${__OUTPUT_PATH}'")
		EXECUTE_PROCESS(
			RESULT_VARIABLE copy_result
			COMMAND ${CMAKE_COMMAND} -E copy_directory
			${path} "${__OUTPUT_PATH}"
		)
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Copy File '${path}' --> '${__OUTPUT_PATH}'")
		EXECUTE_PROCESS(
			RESULT_VARIABLE copy_result
			COMMAND ${CMAKE_COMMAND} -E copy
			${path} "${__OUTPUT_PATH}"
		)
	ENDIF()

	IF(__FILE_HASH_OUTPUT_VAR)
		SET(${__FILE_HASH_OUTPUT_VAR} ${file_hash} PARENT_SCOPE)
	ENDIF()
	IF(copy_result EQUAL 0)
		SET(${__STATUS_VAR} ON PARENT_SCOPE)
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Copy File/Directory failed '${path}' --> '${__OUTPUT_PATH}'")
		SET(${__STATUS_VAR} OFF PARENT_SCOPE)
	ENDIF()
	_CMLIB_FILE_TMP_DIR_CLEAN()
ENDFUNCTION()






## Helper
#
# Download file from HTTP or FILE URI.
# File is downloaded into TMP directory
# Path to the downloaded file is stored in OUTPUT_VAR variable.
# STATUS_VAR variable holds true if download succeed, false otherwise.
#
# <function>(
#		URI <uri>
#		URI_TYPE <HTTP|FILE>
#		OUTPUT_VAR <output_var>
#		STATUS_VAR <status_var>
#		[FILE_HASH_OUTPUT_VAR <file_hash_output_var>]
# )
#
FUNCTION(_CMLIB_FILE_DOWNLOAD_FROM_STANDARD_URI)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI
			URI_TYPE
			OUTPUT_VAR
			FILE_HASH_OUTPUT_VAR
			STATUS_VAR
		REQUIRED
			URI
			URI_TYPE
			STATUS_VAR
			OUTPUT_VAR
		P_ARGN ${ARGN}
	)

	_CMLIB_FILE_TMP_DIR_CLEAN()
	_CMLIB_FILE_TMP_DIR_CREATE()
	_CMLIB_FILE_TMP_DIR_GET(tmp_dir)

	_CMLIB_FILE_DOWNLOAD_FROM_STANDARD_URI_CHECK("${__URI}" "${__URI_TYPE}")

	_CMLIB_FILE_DETERMINE_FILENAME_FROM_URI("${__URI}" "${__URI_TYPE}" "" filename)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("URI Download: ${__URI} --> '${tmp_dir}/${filename}'")

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

	SET(file_path "${tmp_dir}/${filename}")
	IF(__FILE_HASH_OUTPUT_VAR)
		FILE(SHA3_512 "${file_path}" file_hash)
		_CMLIB_FILE_STRIP_FILE_HASH(file_hash_stripped ${file_hash})
		SET(${__FILE_HASH_OUTPUT_VAR} ${file_hash_stripped} PARENT_SCOPE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Downloaded file hash: ${file_hash_stripped}")
	ENDIF()

	SET(${__OUTPUT_VAR} "${file_path}" PARENT_SCOPE)

ENDFUNCTION()



## Helper
#
# Downloads files from GIT.
#
# Stores path to the downloaded files to OUTPUT_VAR.
# There is not guarntee that path stored in UOTPUT_VAR will
# persist across multiple invactions of this funtion.
#
# It tries to download repository by 'git archive' functionality.
# If 'git archive' fails it tries to download repository by invoking following cmmands
# directly on the user computer:
#	- git clone
#	- on the clonned repository run 'git archive'
# git archive produces standard TAR archive which is etracted and extracted
# content is saved by the cache mechanism.
#
# Bebaviour can be controll by
#	- CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY
#	- CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE
#
# STATUS_VAR is true if everything is OK, false othervise
#
# <function>(
# 		URI <uri>
#		OUTPUT_VAR <output_var>
#		STATUS_VAR <status_var>
#		[FILE_HASH_OUTPUT_VAR <file_hash_output_var>]
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
			FILE_HASH_OUTPUT_VAR
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

	SET(archive_path     "${tmp_dir}/git_file.tar")
	SET(git_repo_dir     "${tmp_dir}/git_repo")
	SET(exp_archive_path "${tmp_dir}/exp_arch")
	FILE(MAKE_DIRECTORY "${git_repo_dir}")
	FILE(MAKE_DIRECTORY "${exp_archive_path}")

	_CMLIB_LIBRARY_DEBUG_MESSAGE("GIT URI:      '${__URI}'")
	_CMLIB_LIBRARY_DEBUG_MESSAGE("GIT Revision: '${__GIT_REVISION}'")
	_CMLIB_LIBRARY_DEBUG_MESSAGE("GIT Path:     '${__GIT_PATH}'")
	_CMLIB_LIBRARY_DEBUG_MESSAGE("GIT Repo dir: '${git_repo_dir}'")

	SET(file_not_found 1)
	IF(NOT CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("git-archive download initiated")
		EXECUTE_PROCESS(
			COMMAND "${CMLIB_REQUIRED_ENV_GIT_EXECUTABLE}" archive
				--format=tar
				--remote=${__URI}
				-o "${archive_path}"
				${__GIT_REVISION}
				"${__GIT_PATH}"
			RESULT_VARIABLE file_not_found
			OUTPUT_VARIABLE   stdout # discard STDOUT
			ERROR_VARIABLE    stderr # discard STDERR
			WORKING_DIRECTORY "${tmp_dir}"
		)
	ENDIF()

	IF(NOT file_not_found EQUAL 0)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("git-archive failed. Status: ${file_not_found}\n${git_stderr}")
		IF(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY)
			_CMLIB_LIBRARY_DEBUG_MESSAGE("Cannot download file from git! git-archive is required by CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY option!")
			_CMLIB_FILE_TMP_DIR_CLEAN()
			UNSET(${__STATUS_VAR} PARENT_SCOPE)
			RETURN()
		ENDIF()
		EXECUTE_PROCESS(
			COMMAND "${CMLIB_REQUIRED_ENV_GIT_EXECUTABLE}" clone
				--depth=1
				--branch ${__GIT_REVISION}
				--single-branch
				"${__URI}" git_repo
			OUTPUT_VARIABLE   stdout # discard STDOUT
			ERROR_VARIABLE    stderr # discard STDERR
			RESULT_VARIABLE   git_not_found
			WORKING_DIRECTORY "${tmp_dir}"
		)
		IF(NOT git_not_found EQUAL 0)
			_CMLIB_LIBRARY_DEBUG_MESSAGE("git-clone faied. Status: ${git_not_found}")
			_CMLIB_FILE_TMP_DIR_CLEAN()
			UNSET(${__STATUS_VAR} PARENT_SCOPE)
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
			UNSET(${__STATUS_VAR} PARENT_SCOPE)
			RETURN()
		ENDIF()
	ENDIF()

    EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E tar xf "${archive_path}"
		WORKING_DIRECTORY ${exp_archive_path}
		RESULT_VARIABLE tar_not_valid
    )
	IF(NOT tar_not_valid EQUAL 0)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Cannot extract archive. Status: ${tar_not_valid}")
		_CMLIB_FILE_TMP_DIR_CLEAN()
		UNSET(${__STATUS_VAR} PARENT_SCOPE)
		RETURN()
	ENDIF()

	IF(__FILE_HASH_OUTPUT_VAR)
		_CMLIB_FILE_COMPUTE_HASH(file_hash ${exp_archive_path})
		_CMLIB_FILE_STRIP_FILE_HASH(file_hash_stripped ${file_hash})
		SET(${__FILE_HASH_OUTPUT_VAR} ${file_hash_stripped} PARENT_SCOPE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Git file hash: ${file_hash_stripped}:${file_hash}")
	ENDIF()

	FILE(REMOVE ${archive_path})
	SET(${__STATUS_VAR} ON PARENT_SCOPE)
	SET(${__OUTPUT_VAR} "${exp_archive_path}/${__GIT_PATH}" PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Check if the URI requirements are valid for given URI_TYPE.
#
# <function>(
#		URI <uri>
#		URI_TYPE <uri_type>
# )
#
FUNCTION(_CMLIB_FILE_DOWNLOAD_FROM_STANDARD_URI_CHECK uri uri_type)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Checking standard URI prerequisites for URI_TYPE '${uri_type}', URI: ${uri}")
	IF("${uri_type}" STREQUAL "FILE")
		STRING(REGEX MATCH "^file://" file_uri "${uri}")
		IF(NOT file_uri)
			MESSAGE(FATAL_ERROR "URI '${uri}' is not valid for FILE URI_TYPE!")
		ENDIF()

		STRING(REGEX REPLACE "^file://(.+)$" "\\1" file_path "${uri}")
		IF(NOT IS_ABSOLUTE "${file_path}")
			MESSAGE(FATAL_ERROR "Path specified by URI must be absolute for FILE URI_TYPE. Relative path '${uri}' provided.")
		ENDIF()
		IF(IS_DIRECTORY "${file_path}")
			MESSAGE(FATAL_ERROR "Path specified by URI must be file for FILE URI_TYPE. Directory '${uri}' provided.")
		ENDIF()
	ELSEIF(uri_type STREQUAL "HTTP")
		STRING(REGEX MATCH "^https?://" http_uri "${uri}")
		IF(NOT http_uri)
			MESSAGE(FATAL_ERROR "URI '${uri}' is not valid for HTTP URI_TYPE!")
		ENDIF()
	ELSE()	
		MESSAGE(FATAL_ERROR "Invalid URI_TYPE '${uri_type}' for URI '${uri}'")
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Standard URI prerequisites check passed for URI_TYPE '${uri_type}', URI: ${uri}")
ENDFUNCTION()




## Helper
#
# Determine filename from URI or GIT_PATH.
# If name cannot be determined then genrated random name.
#
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
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Filename cannot be determined from specified URI. Random name generated.")
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
	SET(${var} "${CMLIB_REQUIRED_ENV_TMP_PATH}/cmlib_file")
ENDMACRO()



## Helper
#
# Creates CMLIB_FILE tmp directory
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
# Clean the CMLIB tmp directory.
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
# )
#
# URI formats supported
# - GIT
#	- git://<uri>
#	- git@<uri>
#	- ssh://git@<uri>
# - HTTP
#	- http://<uri>
#	- https://<uri>
# - FILE
#	- file://<uri>
#
FUNCTION(_CMLIB_FILE_DETERMINE_URI_TYPE var uri)
	LIST(POP_FRONT ${ARGN} git_revision)
	LIST(POP_FRONT ${ARGN} git_path)
	STRING(REGEX MATCH "^(git://|git@).*" git_uri "${uri}")
	STRING(REGEX MATCH "^ssh://git@.*" git_ssh_uri "${uri}")
	STRING(REGEX MATCH "^http[s]?://.*" http_uri "${uri}")
	STRING(REGEX MATCH "^file://.*" local_file_uri "${uri}")
	IF(git_uri OR git_ssh_uri OR git_revision OR git_path)
		SET(${var} "GIT" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(http_uri)
		SET(${var} "HTTP" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(local_file_uri)
		SET(${var} "FILE" PARENT_SCOPE)
		RETURN()
	ENDIF()
	MESSAGE(FATAL_ERROR "Invalid URI. Cannot determine URI type")
ENDFUNCTION()



## Helper
#
#
#
FUNCTION(_CMLIB_FILE_COMPUTE_HASH output_var source_path)
	SET(file_list)
	IF(IS_DIRECTORY "${source_path}")
		FILE(GLOB_RECURSE file_list
			LIST_DIRECTORIES FALSE
			"${source_path}/*"
		)
	ELSE()
		SET(file_list "${source_path}")
	ENDIF()
	LIST(SORT file_list
		ORDER   ASCENDING
		CASE    SENSITIVE
		COMPARE FILE_BASENAME
	)
	SET(main_hash)
	FOREACH(file IN LISTS file_list)
		FILE(SHA512 "${file}" file_hash)	
		STRING(SHA512 main_hash "${main_hash}${file_hash}")
	ENDFOREACH()
	SET(${output_var} ${main_hash} PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# It strips the given hash to 1/5 of original length.
#
# <function>(
#		<output_var> <file_hash>
# )
#
FUNCTION(_CMLIB_FILE_STRIP_FILE_HASH stripped_hash_output_var file_hash)
	STRING(LENGTH "${file_hash}" file_hash_length)
	IF(file_hash_length LESS 5)
		MESSAGE(FATAL_ERROR "Input hash '${file_hash}' is too short!")
	ENDIF()

	SET(regex_repeat "")
	FOREACH(I RANGE 5)
		SET(regex_repeat "${regex_repeat}[0-9A-Za-z]")
	ENDFOREACH()
	STRING(REGEX REPLACE "${regex_repeat}([0-9A-Za-z])" "\\1" each_e ${file_hash})
	STRING(TOUPPER "${each_e}" file_hash_upper)
	SET(${stripped_hash_output_var} "${file_hash_upper}" PARENT_SCOPE)
ENDFUNCTION()
