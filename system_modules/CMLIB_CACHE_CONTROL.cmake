## MAIN
#
# CACHE CONTROL which ensures that the cache is consistent.
#

INCLUDE_GUARD(GLOBAL)

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_CACHE)

SET(CMLIB_CACHE_COTROL_META_BASE_DIR "${CMLIB_REQUIRED_ENV_TMP_PATH}/cache_control"
	CACHE INTERNAL
	"Bas drectory for meta information for cache control"
)

SET(CMLIB_CACHE_CONTROL_META_CONTROL_DIR "${CMLIB_CACHE_CONTROL_META_BASE_DIR}/keys_control"
	CACHE INTERNAL
	"Base directory for control files of cache control"
)


SET(CMLIB_CACHE_CONTROL_TEMPLATE
	"<KEYWORDS_STRING>,<URI>,<GIT_PATH>,<GIT_REVISION>,<FILE_HASH>"
	CACHE INTERNAL
	"Template for cache control file"
)



##
#
# <function>(
# )
#
FUNCTION(CMLIB_CACHE_CONTROL_FILE_HASH_CHECK)
ENDFUNCTION()



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
FUNCTION(CMLIB_CACHE_CONTROL_KEYWORDS_CHECK)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH GIT_REVISION
		MULTI_VALUE
			ORIGINAL_KEYWORDS
		REQUIRED
			HASH
		P_ARGN ${ARGN}
	)

	SET(control_dir_path  "${CMLIB_CACHE_CONTROL_META_BASE_DIR}")
	SET(control_file_path "${control_dir_path}/${__HASH}")
	SET(keywords_delim    "${CMLIB_DEPENDENCY_CONTROL_FILE_KEYDELIM}")

	#STRING(JOIN "${keywords_delim}" keywords_string ${__ORIGINAL_KEYWORDS})
	#SET(file_content "${keywords_string};${__URI};${__GIT_PATH};${__GIT_REVISION}")

	_CMLIB_CACHE_CONTROL_IS_RAW(HASH ${__HASH} OUTPUT_VAR is_raw)
	IF(is_raw)
		STRING(JOIN "${keywords_delim}" keywords_string ${__ORIGINAL_KEYWORDS})
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
		_CMLIB_CACHE_CONTROL_CONCRETIZE(
			HASH ${__HASH}
			ITEMS
				KEYWORDS_STRING "${keywords_string}"
				URI             "${__URI}"
				GIT_PATH        "${__GIT_PATH}"
				GIT_REVISION    "${__GIT_REVISION}"
		)
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
FUNCTION(_CMLIB_CACHE_CONTROL_COMPUTE_HASH)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI GIT_PATH GIT_REVISION
			OUTPUT_HASH_VAR
		REQUIRED
			URI OUTPUT_HASH_VAR
		P_ARGN ${ARGN}
	)

	SET(keywords_delim "${CMLIB_DEPENDENCY_CONTROL_FILE_KEYDELIM}")
	SET(cache_string   "${__URI}${keywords_delim}${__GIT_PATH}")
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
# Concretize given control file.
# If the control file does not exist it creats one and
# write partly/fully concretized 
#
# <function>(
#		HASH <hash>
#		[ITEMS <items>] // key-value pairs of template replacement
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_CONCRETIZE)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH
		MULTI_VALUE
			ITEMS
		REQUIRED
			HASH ITEMS
		P_ARGN ${ARGN}
	)

	LIST(LENGTH __ITEMS items_length)	
	MATH(EXPR is_divisible_be_two "(${items_length} + 1) % 2")
	IF(NOT is_divisible_be_two)	
		MESSAGE(FATAL_ERROR "Invalid number of items! Not all are key-value pairs!")
	ENDIF()
	
	_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH(control_file_path ${__HASH})
	SET(control_file_content)
	IF(EXISTS "${control_file_path}")
		FILE(READ "${control_file_path}" control_file_content)
	ELSE()
		SET(control_file_content ${CMLIB_CACHE_CONTROL_TEMPLATE})
	ENDIF()

	CMLIB_TEMPLATE_EXPAND(expanded "${control_file_content}" ${__ITEMS})

	_CMLIB_CACHE_CONTROL_CREATE_ALL_META_DIRS()
	FILE(WRITE "${control_file_path}" "${expanded}")

ENDFUNCTION()



## Helper
# The cache control for given HASH is raw if and only if
# there is no cache control file or the file content of the control file is
# the same as the control file template.
#
# <function>(
#		HASH       <hash>
#		OUTPUT_VAR <output_var>
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_IS_RAW)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH OUTPUT_VAR
		REQUIRED
			HASH OUTPUT_VAR
		P_ARGN ${ARGN}
	)

	_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH(control_file_path ${__HASH})
	IF(NOT EXISTS "${control_file_path}")
		SET(${__OUTPUT_VAR} ON PARENT_SCOPE)
		RETURN()
	ENDIF()

	FILE(READ "${control_file_path}" control_file_content)
	IF(CMLIB_CACHE_CONTROL_TEMPLATE STREQUAL control_file_path)
		SET(${__OUTPUT_VAR} ON PARENT_SCOPE)
		RETURN()
	ENDIF()

	SET(${__OUTPUT_VAR} OFF PARENT_SCOPE)
ENDFUNCTION()



## Helper
# Returns control file path for given hash
#
# <function>(
#		<output_var>
#		<hash>
# )
#
MACRO(_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH output_var hash)
	SET(${output_var} "${CMLIB_CACHE_CONTROL_META_BASE_DIR}/${hash}")
ENDMACRO()



## Helper
# Creates all needed meda directories
#
# <function>()
#
FUNCTION(_CMLIB_CACHE_CONTROL_CREATE_ALL_META_DIRS)
	IF(NOT EXISTS "${CMLIB_CACHE_CONTROL_META_BASE_DIR}")
		FILE(MAKE_DIRECTORY "${CMLIB_CACHE_CONTROL_META_BASE_DIR}")
	ENDIF()
	IF(NOT EXISTS "${CMLIB_CACHE_CONTROL_META_CONTROL_DIR}")
		FILE(MAKE_DIRECTORY "${CMLIB_CACHE_CONTROL_META_CONTROL_DIR}")
	ENDIF()
ENDFUNCTION()
