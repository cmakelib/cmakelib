## Main
#
# CMake Dependency module.
#
# CMLIB_DEPENDENCY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF(DEFINED CMLIB_DEPENDENCY_INCLUDED)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_DEPENDENCY already included")
	RETURN()
ENDIF()

# Flag that REQUIRED_DEPENDENCY is already included
SET(CMLIB_DEPENDENCY_INCLUDED "1")

# Value of the KEYDELIM var is used in Cmake regex
# Please avaid using special regex characters
SET(CMLIB_DEPENDENCY_CONTROL_FILE_KEYDELIM ","
	CACHE INTERNAL
	"Delimiter for keywords in control file"
)

SET(CMLIB_DEPENDENCY_CONTROL ON
	CACHE BOOL
	"Enable depenendcy Conrol if ON, Disable dependency conrol if OFF"
)

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_FILE_DOWNLOAD)
_CMLIB_LIBRARY_MANAGER(CMLIB_ARCHIVE)
_CMLIB_LIBRARY_MANAGER(CMLIB_CACHE)
_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)



##
#
# Download and cache dependency.
#
# The remote resource is uniquely identified by combination of all ementnts from
# REMOTE_ID_SET = { URI, GIT_PATH, GIT_REVISION } and additionaly by KEYWORDS set.
#
# There can be only one combination of REMOTE_ID_SET and KEYWORDS set for each REMOTE_ID_SET.
# If you try to add same dependency with same REMOTE_ID_SET but two different KEYWORDS set
# then the error occure.
#
# [Arguments]
# KEYWORDS are optional and can be empty.
# Represents ordered set of keywords.
# There is set of reserved keywords RK = { CMLIB }. Do not use this keywords
# unless you known what you are doing.
# KEWORDS are usable
#
# TYPE must be specified.
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
# [Notes]
# If the entry represented by KEYWORDS already exist is obtained from cache
# whatever is specified in URI and TYPE. These fields are ignored
# if the entry already exist.
# Currently there is no way how to test if the URI and TYPE are in
# sync with cache entry. (if we call DEPENDENCY multiple times with same KEYWORDS set)
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
			#KEYWORDS
		P_ARGN ${ARGN}
	)
	_CMLIB_DEPENDENCY_VALIDATE_TYPE(${__TYPE})

	SET(hash_keyword)
	IF(CMLIB_DEPENDENCY_CONTROL)
		_CMLIB_DEPENDENCY_DETERMINE_KEYWORDS(
			ORIGINAL_KEYWORDS ${__KEYWORDS}
			URI               "${__URI}"
			GIT_PATH          "${__GIT_PATH}"
			GIT_REVISION      "${__GIT_REVISION}"
			KEYWORDS_VAR      hash_keyword
		)
	ELSE()
		SET(hash_keyword ${__KEYWORDS})
	ENDIF()

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
		)
		IF("${__TYPE}" STREQUAL "DIRECTORY" OR
				("${__TYPE}" STREQUAL "MODULE" AND IS_DIRECTORY "${download_tmp_dir}"))
			SET(downloaded_files "${download_tmp_dir}")
			FILE(GLOB glob "${download_tmp_dir}/*")
			LIST(LENGTH glob downloaded_files_size)
			IF((downloaded_files_size EQUAL 0))
				MESSAGE(FATAL_ERROR "Download directory problem")
			ENDIF()
		ELSE()
			FILE(GLOB downloaded_files "${download_tmp_dir}/*")
			LIST(LENGTH downloaded_files downloaded_files_size)
			IF(NOT (downloaded_files_size EQUAL 1))
				MESSAGE(FATAL_ERROR "Download files problem")
			ENDIF()
		ENDIF()

		CMLIB_CACHE_ADD(
			KEYWORDS ${hash_keyword}
			PATH "${downloaded_files}"
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
		_CMLIB_DEPENDENCY_ARCHIVE("${dependency_file}" "${__ARCHIVE_TYPE}" output_var ${__KEYWORDS})
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
		KEYWORDS EXTRACTED ${__KEYWORDS}
		PATH "${archive_path}"
		CACHE_PATH_VAR cache_var
	)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("No extracted archive found in cache - extracted, cache entry added")
	CMLIB_ARCHIVE_CLEAN()
	SET(${output_var} "${cache_var}" PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Compute hash from string
#	"${URI}|${GIT_PATH}|${GIT_REVISION}"
# The hash uniquely identifies resource managed by
# CMLIB_DEPENDENCY function.
#
# <function>(
#		URI          <uri>
#		[GIT_PATH     <git_path>]
#		[GIT_REVISION <git_revision>]
# )
#
FUNCTION(_CMLIB_DEPENDENCY_COMPUTE_HASH)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI GIT_PATH GIT_REVISION
			OUTPUT_HASH_VAR
		REQUIRED
			URI OUTPUT_HASH_VAR
		P_ARGN ${ARGN}
	)

	SET(keywords_delim "${CMLIB_DEPENDENCY_CONTROL_FILE_KEYDELIM}")
	SET(cache_string   "${__URI}${keywords_delim}${__GIT_PATH}${keywords_delim}${__GIT_REVISION}")
	STRING(SHA3_512 hash "${cache_string}")

	SET(regex_repeat "")
	FOREACH(I RANGE 5)
		SET(regex_repeat "${regex_repeat}[0-9A-Za-z]")
	ENDFOREACH()
	STRING(REGEX REPLACE "${regex_repeat}([0-9A-Za-z])" "\\1" each_e ${hash})

	STRING(TOUPPER "${each_e}" hash_upper)
	SET(${__OUTPUT_HASH_VAR} "${hash_upper}" PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# ORIGINAL_KEYWORDS are keywords obtained from user
#
# KEYWORDS_VAR is name of the variable which will hold processed keywords
#
# URI, GIT_PATH, GIT_REVISION has same meaning as for
# CMLIB_DEPENDENCY function.
#
# <function>(
#		URI                <uri>
#		KEYWORDS_VAR       <keywords_var> M
#		[GIT_PATH          <git_path>]
#		[GIT_REVISION      <git_revision>]
# )
#
FUNCTION(_CMLIB_DEPENDENCY_DETERMINE_KEYWORDS)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI GIT_PATH GIT_REVISION
			KEYWORDS_VAR
		MULTI_VALUE
			ORIGINAL_KEYWORDS
		REQUIRED
			URI KEYWORDS_VAR
		P_ARGN ${ARGN}
	)

	SET(git_path "${__GIT_PATH}")
	IF("${git_path}" STREQUAL "")
		SET(git_path "./")
	ENDIF()

	SET(git_revision "${__GIT_REVISION}")
	IF("${git_revision}" STREQUAL "")
		SET(git_revision "master")
	ENDIF()

	SET(processed_keywords)
	IF(CMLIB_DEBUG)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("DETERMINE_KEYWORDS in Debug mode")
		GET_FILENAME_COMPONENT(stripped_uri "${__URI}" NAME_WE)
		SET(keywords_list "${stripped_uri}" "${git_revision}" "${git_path}")
		SET(keywords_list_normalized)
		FOREACH(keyword IN LISTS keywords_list)
			STRING(MAKE_C_IDENTIFIER "${keyword}" keyword_normalized_with_)
			STRING(REPLACE "_" "" keyword_normalized_without_ "${keyword_normalized_with_}")
			STRING(TOUPPER "${keyword_normalized_without_}" keyword_normalized)
			_CMLIB_LIBRARY_DEBUG_MESSAGE("DETERMINE_KEYWORDS Keyword: ${keyword_normalized}")
			LIST(APPEND keywords_list_normalized "${keyword_normalized}")
		ENDFOREACH()
		SET(processed_keywords ${keywords_list_normalized})
		LIST(INSERT processed_keywords 0 "DEBUG")
	ENDIF()

	_CMLIB_DEPENDENCY_COMPUTE_HASH(
		URI             "${__URI}"
		GIT_PATH        "${git_path}"
		GIT_REVISION    "${git_revision}"
		OUTPUT_HASH_VAR hash_keyword
	)

	_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK(
		HASH              ${hash_keyword}
		ORIGINAL_KEYWORDS "${__ORIGINAL_KEYWORDS}"
	)

	IF(__ORIGINAL_KEYWORDS)
		SET(${__KEYWORDS_VAR} ${__ORIGINAL_KEYWORDS} PARENT_SCOPE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("DETERMINE_KEYWORDS using ORIGINAL_KEYWORDS as cache keywords for ${__URI}")
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("DETERMINE_KEYWORDS using HASH keywords for ${__URI}")
		SET(processed_keywords "HASH" "${hash_keyword}")
		SET(${__KEYWORDS_VAR} ${processed_keywords} PARENT_SCOPE)
	ENDIF()
ENDFUNCTION()



## Helper
#
# Check if HASH and ORIGINAL_KEYWORDS are in sync.
# Multiple invocation of this funct with same HASH must have
# same ORIGINAL_KEYWORDS or error occurred.
#
# <function>(
#		HASH              <hash>
#		ORIGINAL_KEYWORDS <original_keywords>
# )
#
FUNCTION(_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH
		MULTI_VALUE
			ORIGINAL_KEYWORDS
		REQUIRED
			HASH
		P_ARGN ${ARGN}
	)

	SET(control_dir_path  "${CMLIB_REQUIRED_ENV_TMP_PATH}/cache_control")
	SET(control_file_path "${control_dir_path}/${__HASH}")
	SET(keywords_delim    "${CMLIB_DEPENDENCY_CONTROL_FILE_KEYDELIM}")

	STRING(JOIN "${keywords_delim}" keywords_string ${__ORIGINAL_KEYWORDS})
	SET(file_content "${keywords_string};${__URI};${__GIT_PATH};${__GIT_REVISION}")

	IF(NOT EXISTS "${control_file_path}")
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK Cache control file create")
		IF(DEFINED __ORIGINAL_KEYWORDS)
			CMLIB_CACHE_HAS_FILE(
				KEYWORDS ${__ORIGINAL_KEYWORDS}
				PATH_VAR cache_path
			)
			IF(cache_path)
				STRING(JOIN "${keywords_delim}" original_keywords_string "${__ORIGINAL_KEYWORDS}")
				MESSAGE(FATAL_ERROR "The cache under keywords '${original_keywords_string}' already exist for different remote")
			ENDIF()
		ENDIF()
		FILE(WRITE "${control_file_path}" "${file_content}")
		RETURN()
	ENDIF()

	FILE(READ "${control_file_path}" real_file_content)
	STRING(REGEX MATCHALL "^([0-9a-zA-Z${keywords_delim}]*);(.+)$" matched "${real_file_content}")
	IF(NOT matched)
		MESSAGE(FATAL_ERROR "Cannot match control file! Invalid format - '${real_file_content}'")
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK control real file content: '${real_file_content}'")
	SET(cached_keywords "${CMAKE_MATCH_1}")

	IF(NOT "${file_content}" STREQUAL "${real_file_content}")
		IF(NOT cached_keywords)
			MESSAGE(FATAL_ERROR "DEPENDENCY hash mishmash - cache created without keywords"
				" but keywords provided '${__ORIGINAL_KEYWORDS}'")
		ELSEIF(NOT DEFINED __ORIGINAL_KEYWORDS)
			MESSAGE(FATAL_ERROR "DEPENDENCY hash mishmash - cache created with keywords ${cached_keywords}"
				" but no keywords provided")
		ELSE()
			STRING(JOIN "${keywords_delim}" original_keywords_string "${__ORIGINAL_KEYWORDS}")
			MESSAGE(FATAL_ERROR
				"DEPENDENCY hash mishmash - cached keywords '${cached_keywords}'"
				" are not same as required keywords '${original_keywords_string}'"
			)
		ENDIF()
	ENDIF()
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
		MESSAGE(FATAL_ERROR "Requirements for OUTPUT_VAR are not met!")
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
	SET(${var} "${CMLIB_REQUIRED_ENV_TMP_PATH}/bimcm_dependency/")
ENDMACRO()



## Helper
#
# Creates BICM_DEPENDENCY tmp directory
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
