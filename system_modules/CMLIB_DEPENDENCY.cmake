## Main
#
# CMake Dependency module.
#
# CMLIB_DEPENDENCY
#

INCLUDE_GUARD(GLOBAL)

SET(CMLIB_DEPENDENCY_CONTROL ON
	CACHE BOOL
	"Enable depenendcy Conrol if ON, Disable dependency conrol if OFF"
)

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_FILE_DOWNLOAD)
_CMLIB_LIBRARY_MANAGER(CMLIB_ARCHIVE)
_CMLIB_LIBRARY_MANAGER(CMLIB_CACHE)
_CMLIB_LIBRARY_MANAGER(CMLIB_CACHE_CONTROL)
_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)



##
#
# Download and cache dependency.
#
# The remote resource is uniquely identified by combination of all elments from
# REMOTE_ID_SET = { URI, GIT_PATH } and additionaly by KEYWORDS set.
#
# There can be only one combination of REMOTE_ID_SET and KEYWORDS set for each REMOTE_ID_SET.
# If you try to add same dependency with same REMOTE_ID_SET but under two different KEYWORDS set
# then the error occure.
#
# By design the function proceeds in two steps
# - Download files from remote to temporary directory.
# - Cache downloaded files.
# These two steps are isolated by a well defined interface thus simplify testing and debugging.
#
# [Arguments]
#
# KEYWORDS are optional and can be empty.
# Represents ordered set of keywords.
# There is set of reserved keywords RK = { CMLIB }. Do not use this keywords
# unless you know what you are doing.
#
# TYPE must be specified.
# Represents resource type (the resource which will be downloaded from remote)
# Must be one of <MODULE|ARCHIVE|FILE|DIRECTORY>.
# Note that for DIRECTORY type only the GIT uri can be used.
#
# URI standard HTTP URI or GIT uri supported by 'git clone' command.
# Must be specified if there is no cache entry.
# Look at CMLIB_FILE_DOWNLOAD macro.
#
# URI_TYPE may be specified.
# If not specified the URI TYPE is determined automatically
# Look at CMLIB_FILE_DOWNLOAD macro.
#
# OUTPUT_PATH_VAR must be specified for ARCHIVE, FILE and DIRECTORY type.
# In case of MODULE type the OUTPUT_PATH_VAR is not used if specified (and may be omitted).
# Takes variable name in which the absolute path of dependency will be stored.
#
# GIT_PATH must be specified for GIT uri
# Look at CMLIB_FILE_DOWNLOAD macro.
#
# GIT_REVISION is optional. If not set the "master" branch is used.
# Look at CMLIB_FILE_DOWNLOAD macro.
#
# ARCHIVE_TYPE may be specified for ARCHIVE type.
# If not specified the ARCHIVE_TYPE is determined automatically
# Look at CMLIB_ARCHIVE macro.
#
# [Cache rules]
# As mentioned above there can be exactly one combination of remote and cache KEYWORDS.
# If the mechanism is enabled you cannot
# - add same REMOTE_ID_SET with different KEYWORDS set except empty KEYWORDS set
# - add REMOTE_ID_SET with empty KEYWORDS set and the try to add given
#   REMOTE_ID_SET with non empty keywords set
#
# [Notes]
# If the entry represented by KEYWORDS already exist is obtained from cache
# whatever is specified in URI and TYPE. These fields are ignored
# if the entry already exist.
#
# <function>(
#		TYPE          <MODULE|ARCHIVE|FILE|DIRECTORY>
#		[KEYWORDS     <keywords>]
#		[URI          <uri>]
#		[GIT PATH     <FILE_DOWNLOAD::GIT_PATH>]
#		[GIT_REVISION <git_revision_name>]
#		[URI_TYPE     <FILE_DOWNLOAD::URI_TYPE>]
#		[ARCHIVE_TYPE <ARCHIVE::ARCHIVE_TYPE>]
#		[OUTPUT_PATH_VAR <path_var>]
# )
#
FUNCTION(CMLIB_DEPENDENCY)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			TYPE URI
			URI_TYPE OUTPUT_PATH_VAR
			GIT_PATH GIT_REVISION ARCHIVE_TYPE
		MULTI_VALUE
			KEYWORDS
		REQUIRED
			TYPE
		P_ARGN ${ARGN}
	)
	_CMLIB_DEPENDENCY_VALIDATE_TYPE(${__TYPE})

	SET(hash_keyword)
	_CMLIB_DEPENDENCY_DETERMINE_KEYWORDS(
		ORIGINAL_KEYWORDS ${__KEYWORDS}
		URI               "${__URI}"
		GIT_PATH          "${__GIT_PATH}"
		GIT_REVISION      "${__GIT_REVISION}"
		KEYWORDS_VAR      hash_keyword
		CONTROL_HASH_VAR  hash
	)

	CMLIB_CACHE_GET(
		KEYWORDS ${hash_keyword}
		CACHE_PATH_VAR dependency_cache_entry
		TRY_REGENERATE ON
	)

	SET(dependency_file)
	SET(download_tmp_dir)
	IF(DEFINED dependency_cache_entry)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Cache entry found!")
		SET(dependency_file "${dependency_cache_entry}")
	ELSE()
		IF(NOT DEFINED __TYPE)
			MESSAGE(FATAL_ERROR "Dependency with keywords ${__KEYWORDS} doe not exist and TYPE is not defined!")
		ENDIF()
		IF(NOT DEFINED __URI)
			MESSAGE(FATAL_ERROR "Dependency with keywords ${__KEYWORDS} doe not exist and URI is not defined!")
		ENDIF()
		_CMLIB_DEPENDENCY_TMP_DIR_CLEAN()
		_CMLIB_DEPENDENCY_TMP_DIR_CREATE()
		_CMLIB_DEPENDENCY_TMP_DIR_GET(tmp_dir)
		SET(download_tmp_dir "${tmp_dir}/download")

		FILE(REMOVE_RECURSE "${download_tmp_dir}")

		SET(uri_type)
		IF(DEFINED __URI_TYPE)
			SET(uri_type URI_TYPE "${__URI_TYPE}")
		ENDIF()

		SET(git_path)
		IF(DEFINED __GIT_PATH)
			SET(git_path GIT_PATH "${__GIT_PATH}")
		ENDIF()

		SET(git_revision)
		IF(DEFINED __GIT_REVISION)
			SET(git_revision GIT_REVISION "${__GIT_REVISION}")
		ENDIF()

		FILE(MAKE_DIRECTORY "${download_tmp_dir}")
		CMLIB_FILE_DOWNLOAD(
			URI "${__URI}"
			${uri_type}
			${git_path}
			${git_revision}
			OUTPUT_PATH "${download_tmp_dir}"
			FILE_HASH_OUTPUT_VAR file_hash
		)
		IF("${__TYPE}" STREQUAL "DIRECTORY" OR
				("${__TYPE}" STREQUAL "MODULE" AND IS_DIRECTORY "${download_tmp_dir}"))
			SET(downloaded_files "${download_tmp_dir}")
			FILE(GLOB glob "${download_tmp_dir}/*")
			LIST(LENGTH glob downloaded_files_size)
			IF((downloaded_files_size EQUAL 0))
				MESSAGE(FATAL_ERROR "Download directory problem. URI is unreachable, connection was interrupted or timeout occurred.\n"
					"Check combination of URI, URI_TYPE and other arguments and try again\n"
					"URI: ${__URI}\n"
				)
			ENDIF()
		ELSE()
			FILE(GLOB downloaded_files "${download_tmp_dir}/*")
			LIST(LENGTH downloaded_files downloaded_files_size)
			IF(NOT (downloaded_files_size EQUAL 1))
				MESSAGE(FATAL_ERROR "Download files problem. URI is unreachable, connection was interrupted or timeout occurred.\n"
					"Check combination of URI, URI_TYPE and other arguments and try again\n"
					"URI: ${__URI}\n"
				)
			ENDIF()
		ENDIF()

		IF(CMLIB_DEPENDENCY_CONTROL)
			CMLIB_CACHE_CONTROL_FILE_HASH_CHECK(
				HASH      ${hash}
				FILE_HASH ${file_hash}
			)
		ENDIF()
		CMLIB_CACHE_ADD(
			KEYWORDS       ${hash_keyword}
			PATH           "${downloaded_files}"
			CACHE_PATH_VAR cache_var
		)
		IF(NOT DEFINED cache_var)
			MESSAGE(FATAL_ERROR "Cannot add dependency to cache")
		ENDIF()
		SET(dependency_file "${cache_var}")
	ENDIF()

	SET(output_var)
	IF("${__TYPE}" STREQUAL "MODULE")
		_CMLIB_DEPENDENCY_MODULE("${dependency_file}")
		SET(output_var "${${__OUTPUT_PATH_VAR}}")
	ELSEIF("${__TYPE}" STREQUAL "ARCHIVE")
		_CMLIB_DEPENDENCY_ARCHIVE("${dependency_file}" "${__ARCHIVE_TYPE}" output_var ${hash_keyword})
	ELSEIF("${__TYPE}" STREQUAL "FILE")
		SET(output_var ${dependency_file})
	ELSEIF("${__TYPE}" STREQUAL "DIRECTORY")
		SET(output_var ${dependency_file})
	ENDIF()

	IF(NOT DEFINED __OUTPUT_PATH_VAR)
		_CMLIB_DEPENDENCY_CHECK_TYPE_OUTPUT_VAR_REQUIREMENTS_INVERSE("${__TYPE}")
	ELSE()
		SET(${__OUTPUT_PATH_VAR} "${output_var}" PARENT_SCOPE)
	ENDIF()
	_CMLIB_DEPENDENCY_TMP_DIR_CLEAN()
ENDFUNCTION()






## Helper
#
# Check if the file is standard file and update CMAKE_MODULE_PATH
# <function>(
# 		<module_file>
# )
#
MACRO(_CMLIB_DEPENDENCY_MODULE module_file)
	SET(module_directory ${module_file})
	IF(NOT (IS_DIRECTORY "${module_directory}"))
		GET_FILENAME_COMPONENT(module_directory "${module_file}" DIRECTORY)
	ENDIF()

	FILE(TO_CMAKE_PATH "${module_directory}" module_directory_normalized)
	FOREACH(dir IN LISTS CMAKE_MODULE_PATH)
		FILE(TO_CMAKE_PATH "${dir}" dir_normalized)
		IF("${module_directory_normalized}" STREQUAL "${dir_normalized}")
			_CMLIB_LIBRARY_DEBUG_MESSAGE("Module directory path found at CMAKE_MODULE_PATH")
			RETURN()
		ENDIF()
	ENDFOREACH()

	SET(_tmp ${CMAKE_MODULE_PATH})
	LIST(APPEND _tmp "${module_directory}")
	UNSET(module_directory)
	SET(CMAKE_MODULE_PATH ${_tmp} PARENT_SCOPE)
ENDMACRO()



## Helper
#
# Function handle standard archives as adependency.
#
# Let ARCHIVE_KEYWORDS := EXTRACTED;<keywords> are keywords
# under which the extractred archive is cached.
#
# Function try find extracted archive in cache under ARCHIVE_KEYWORDS.
# If cache entry found no extracting is performed and cache entry
# value is used as path to extracted archive and stored to <output_var>.
# If not cache entry is found function extract given <archive_file>
# and store result to cache under ARCHIVE_KEYWORDS.
#
# <function> (
#		<archive_file>
#		<archive_type> // must be specified or must be an empty string
#		<output_var>
#		<keywords> M   // standard cache keywords
# )
#
FUNCTION(_CMLIB_DEPENDENCY_ARCHIVE archive_file archive_type output_var)
	SET(keywords ${ARGN})
	IF(NOT keywords)
		MESSAGE(FATAL_ERROR "Keywords are not defined!")
	ENDIF()
	CMLIB_CACHE_GET(
		KEYWORDS EXTRACTED ${keywords}
		CACHE_PATH_VAR dependency_extracted_cache_entry
		TRY_REGENERATE ON
	)
	IF(DEFINED dependency_extracted_cache_entry)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Extracted archive found in cache: ${dependency_extracted_cache_entry}")
		SET(output_var "${dependency_extracted_cache_entry}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("No extracted archive found in cache - extracting...")

	SET(archive_type_arg)
	IF(NOT ("${archive_type}" STREQUAL ""))
		SET(archive_type_arg ARCHIVE_TYPE "${archive_type}")
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Archive type args: ${archive_type_arg}")

	_CMLIB_DEPENDENCY_TMP_DIR_GET(tmp_dir)
	_CMLIB_DEPENDENCY_TMP_DIR_CREATE()
	SET(archive_tmp_dir "${tmp_dir}/archive")
	CMLIB_ARCHIVE_EXTRACT(
		ARCHIVE_PATH "${archive_file}"
		${archive_type_arg}
		OUTPUT_PATH_VAR archive_path
	)
	CMLIB_CACHE_ADD(
		KEYWORDS EXTRACTED ${keywords}
		PATH "${archive_path}"
		CACHE_PATH_VAR cache_var
	)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("No extracted archive found in cache - extracted, cache entry added")
	CMLIB_ARCHIVE_CLEAN()
	SET(${output_var} "${cache_var}" PARENT_SCOPE)
ENDFUNCTION()





## Helper
#
# ORIGINAL_KEYWORDS are keywords obtained from user
#
# KEYWORDS_VAR is name of the variable which will hold processed keywords
#
# CONTROL_HASH_VAR is a name of the variable which will hold
# computed control HASH.
#
# URI, GIT_PATH, GIT_REVISION has same meaning as for
# CMLIB_DEPENDENCY function.
#
# <function>(
#		URI                <uri>
#		KEYWORDS_VAR       <keywords_var> M
#		CONTROL_HASH_VAR   <hash_var>
#		[GIT_PATH          <git_path>]
#		[GIT_REVISION      <git_revision>]
# )
#
FUNCTION(_CMLIB_DEPENDENCY_DETERMINE_KEYWORDS)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI GIT_PATH GIT_REVISION
			KEYWORDS_VAR CONTROL_HASH_VAR
		MULTI_VALUE
			ORIGINAL_KEYWORDS
		REQUIRED
			KEYWORDS_VAR
			CONTROL_HASH_VAR
		P_ARGN ${ARGN}
	)

	IF((NOT __URI) AND __ORIGINAL_KEYWORDS)
		SET(${__KEYWORDS_VAR} ${__ORIGINAL_KEYWORDS} PARENT_SCOPE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("DETERMINE_KEYWORDS using ORIGINAL_KEYWORDS because no URI defined!")
		RETURN()
	ENDIF()

	SET(git_path "${__GIT_PATH}")
	IF("${git_path}" STREQUAL "")
		SET(git_path "./")
	ENDIF()

	SET(git_revision "${__GIT_REVISION}")
	IF("${git_revision}" STREQUAL "")
		SET(git_revision "master")
	ENDIF()

	CMLIB_CACHE_CONTROL_COMPUTE_HASH(
		URI            "${__URI}"
		GIT_PATH       "${git_path}"
		OUTPUT_HASH_VAR hash
	)
	IF(CMLIB_DEPENDENCY_CONTROL)
		CMLIB_CACHE_CONTROL_KEYWORDS_CHECK(
			HASH              "${hash}"
			URI               "${__URI}"
			ORIGINAL_KEYWORDS "${__ORIGINAL_KEYWORDS}"
			GIT_PATH          "${git_path}"
			GIT_REVISION      "${git_revision}"
		)
	ENDIF()

	IF(__ORIGINAL_KEYWORDS)
		SET(${__KEYWORDS_VAR} ${__ORIGINAL_KEYWORDS} PARENT_SCOPE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("DETERMINE_KEYWORDS using ORIGINAL_KEYWORDS as cache keywords for ${__URI}")
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("DETERMINE_KEYWORDS using HASH keywords for ${__URI}")
		SET(processed_keywords "HASH" "${hash}")
		SET(${__KEYWORDS_VAR} ${processed_keywords} PARENT_SCOPE)
	ENDIF()
	SET(${__CONTROL_HASH_VAR} ${hash} PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Check requirements for TYPE against OUTPUT_VAR and nagate result.
# Server as consistency check in case when the OUTPUT_VAR is NOT defined
# <function>(
#		<type>
# )
#
#
FUNCTION(_CMLIB_DEPENDENCY_CHECK_TYPE_OUTPUT_VAR_REQUIREMENTS_INVERSE type)
	IF("${type}" STREQUAL "DIRECTORY" OR
			"${type}" STREQUAL "ARCHIVE" OR
			"${type}" STREQUAL "FILE")
		MESSAGE(FATAL_ERROR "Requirements for OUTPUT_VAR are not met! (Not defined? Invalid format?)")
	ENDIF()
ENDFUNCTION()



## Helper
#
# Validate dependency TYPE.
# <function> (
#		<type>
# )
#
FUNCTION(_CMLIB_DEPENDENCY_VALIDATE_TYPE type)
	SET(valid_dep_types MODULE ARCHIVE FILE DIRECTORY)
	LIST(FIND valid_dep_types "${type}" dep_type_found)
	IF(dep_type_found EQUAL -1)
		LIST(JOIN valid_dep_types ", " valid_dep_types_join)
		MESSAGE(FATAL_ERROR "Dependency type '${type}' not found. Supported are only ${valid_dep_types_join}")
	ENDIF()
ENDFUNCTION()



## Helper
#
# Get CMLIB_DEPENDENCY temporary directory
# <function>(
#		<var>
# )
#
MACRO(_CMLIB_DEPENDENCY_TMP_DIR_GET var)
	SET(${var} "${CMLIB_REQUIRED_ENV_TMP_PATH}/cmlib_dependency/")
ENDMACRO()



## Helper
#
# Creates CMLIB_DEPENDENCY tmp directory
# <function>(
# )
#
FUNCTION(_CMLIB_DEPENDENCY_TMP_DIR_CREATE)
	_CMLIB_DEPENDENCY_TMP_DIR_GET(tmp_dir)
	IF(NOT EXISTS "${tmp_dir}")
		FILE(MAKE_DIRECTORY "${tmp_dir}")
	ENDIF()
ENDFUNCTION()



## Helper
#
# Clean the CMLIB_DEPENDENCY tmp directory.
# <function>(
# )
#
FUNCTION(_CMLIB_DEPENDENCY_TMP_DIR_CLEAN)
	_CMLIB_DEPENDENCY_TMP_DIR_GET(tmp_dir)
	IF(EXISTS "${tmp_dir}")
		FILE(REMOVE_RECURSE "${tmp_dir}")
	ENDIF()
ENDFUNCTION()
