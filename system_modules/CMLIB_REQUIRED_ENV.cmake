## Main
#
# CMLIB Required environment variables.
#
# CMLIB_REQUIRED_ENV_TMP_PATH - TMP path in which all
#	applications using this library must store TMP files
#	Can be initialized by CMLIB_REQUIRED_ENV_TMP_PATH
#	environment variable.
#	Variable is converted to CMake path style.
#
# CMLIB_REQUIRED_ENV_GIT_EXECUTABLE - path to git executable
# CMLIB_REQUIRED_ENV_GIT_MIN_VERSION - minimum version of
#	GIT supported
#
# CMLIB_REQUIRED_ENV_GIT_EXECUTABLE - path to Git executable
#

IF(DEFINED CMLIB_REQUIRED_ENV_INCLUDED)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_REQUIRED_ENV already included")
	RETURN()
ENDIF()

SET(CMLIB_REQUIRED_ENV_INCLUDED 1)



##
#
#
FUNCTION(CMLIB_REQUIRED_ENV)
	_CMLIB_REQUIRED_ENV_FIND_GIT()
	_CMLIB_REQUIRED_ENV_TMP_PATH()
	_CMLIB_REQUIRED_ENV_REMOTE_URI()
ENDFUNCTION()



## Helper
#
# Try find Git executable and ensure that we found
# supported version
#
MACRO(_CMLIB_REQUIRED_ENV_FIND_GIT)
	SET(CMLIB_REQUIRED_ENV_GIT_MIN_VERSION "2.17.0"
		CACHE STRING
		"Minimum required Git version"
	)
	FIND_PACKAGE(Git)
	IF(NOT GIT_FOUND)
		MESSAGE(FATAL_ERROR "Git not found, expected version ${CMLIB_REQUIRED_ENV_GIT_MIN_VERSION}"
			" Are you sure that the Git is properly installed and registered in PATH env. variable?")
	ENDIF()
	IF(NOT GIT_VERSION_STRING VERSION_GREATER_EQUAL "${CMLIB_REQUIRED_ENV_GIT_MIN_VERSION}")
		MESSAGE(FATAL_ERROR "Unsupporeted Git version ${GIT_VERSION_STRING}")
	ENDIF()
	SET(CMLIB_REQUIRED_ENV_GIT_EXECUTABLE "${GIT_EXECUTABLE}"
		CACHE PATH
		"Git executable, v${GIT_VERSION_STRING}"
	)
	UNSET(GIT_EXECUTABLE CACHE)
ENDMACRO()



## Helper
#
# Determine cache path
#
MACRO(_CMLIB_REQUIRED_ENV_TMP_PATH)
	SET(_cmlib_cache_path "${CMAKE_SOURCE_DIR}/_tmp")
	IF(NOT "$ENV{CMLIB_REQUIRED_ENV_TMP_PATH}" STREQUAL "")
		SET(_cmlib_cache_path "$ENV{CMLIB_REQUIRED_ENV_TMP_PATH}")
	ENDIF()
	FILE(TO_CMAKE_PATH "${_cmlib_cache_path}" _cmlib_cache_path_tr)
	SET(CMLIB_REQUIRED_ENV_TMP_PATH "${_cmlib_cache_path_tr}"
		CACHE PATH
		"Cache path where all downloaded files will be stored"
	)
ENDMACRO()



## Helper
#
# Obtain and store CMLIB remote url.
# Remote name is configorable by CMLIB_REQUIRED_ENV_REMOTE_NAME.
# Default is 'origin'
#
# <function>(
# )
#
FUNCTION(_CMLIB_REQUIRED_ENV_REMOTE_URI)
	IF(NOT DEFINED CMLIB_REQUIRED_ENV_GIT_EXECUTABLE)
		MESSAGE(FATAL_ERROR "GIT executable not defined!")
	ENDIF()

	SET(CMLIB_REQUIRED_ENV_REMOTE_NAME "origin"
		CACHE STRING
		"Name of the Git remote from which the CMLIB_REQUIRED_ENV_REMOTE_URL will be obtained"
	)

	SET(tmp_output_var)
	EXECUTE_PROCESS(
		COMMAND ${CMLIB_REQUIRED_ENV_GIT_EXECUTABLE} config --get remote.${CMLIB_REQUIRED_ENV_REMOTE_NAME}.url
		OUTPUT_VARIABLE tmp_output_var
		RESULT_VARIABLE result
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
	)
	IF(NOT "${result}" STREQUAL "0")
		MESSAGE(FATAL_ERROR "Remote name '${CMLIB_REQUIRED_ENV_REMOTE_NAME}' does not obtain remote URL or does not exist")
	ENDIF()

	STRING(REGEX REPLACE "/[^/]+ *$" "" base_url "${tmp_output_var}")
	SET(CMLIB_REQUIRED_ENV_REMOTE_URL "${base_url}"
		CACHE STRING
		"Url for remote '${CMLIB_REQUIRED_ENV_REMOTE_NAME}'. Cannot be chaned. Dependent on CMLIB_REQUIRED_ENV_REMOTE_NAME"
		FORCE
	)
ENDFUNCTION()



## Helper
#
# Just run initialize process
#
CMLIB_REQUIRED_ENV()

