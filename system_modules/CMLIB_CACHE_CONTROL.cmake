## MAIN
#
# CACHE CONTROL which ensures that the cache is consistent.
#

INCLUDE_GUARD(GLOBAL)


SET(CMLIB_CACHE_CONTROL_TEMPLATE
	"<KEYWORDS_STRING>,<URI>,<GIT_PATH>,<GIT_REVISION>,<FILE_HASH>"
	CACHE INTERNAL
	""
)



FUNCTION(CMLIB_CACHE_CONTROL_)



##
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
FUNCTION(CMLIB_CACHE_CONTROL_FILE_CHECK)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH GIT_REVISION
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
	IF("${file_content}" STREQUAL "${real_file_content}")
		RETURN()
	ENDIF()

	STRING(REGEX MATCHALL "^([0-9a-zA-Z${keywords_delim}]*);(.+)$" matched "${real_file_content}")
	IF(NOT matched)
		MESSAGE(FATAL_ERROR "Cannot match control file! Invalid format - '${real_file_content}'")
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK control real file content: '${real_file_content}'")
	SET(cached_keywords "${CMAKE_MATCH_1}")

	STRING(REGEX MATCHALL ";([^;]+)$" matched_x "${real_file_content}")
	SET(cached_branch_name "${CMAKE_MATCH_1}")
	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK cached branch name: '${cached_branch_name}|${__GIT_REVISION}'")
	IF(NOT __GIT_REVISION STREQUAL cached_branch_name)
		MESSAGE(FATAL_ERROR
			"DEPENDENCY version mishmash - different versions of the same file '${cached_branch_name}' vs '${__GIT_REVISION}'")
	ENDIF()

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
			" are not same as required keywords '${original_keywords_string}'")
	ENDIF()
ENDFUNCTION()
