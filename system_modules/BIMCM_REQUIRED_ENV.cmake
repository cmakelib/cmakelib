## Main
#
# BIMCM Required environment variables.
#
# BIMCM_REQUIRED_ENV_TMP_PATH - TMP path in which all
#	applications using this library must store TMP files
#	Can be initialized by BIMCM_REQUIRED_ENV_TMP_PATH
#	environment variable.
#	Variable is converted to CMake path style.
#
# BIMCM_REQUIRED_ENV_GIT_EXECUTABLE - path to git executable
# BIMCM_REQUIRED_ENV_GIT_MIN_VERSION - minimum version of
#	GIT supported
#
# BIMCM_REQUIRED_ENV_7ZIP - path to 7zip executable
# BIMCM_REQUIRED_ENV_GIT_EXECUTABLE - path to Git executable
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF(DEFINED BIMCM_REQUIRED_ENV_INCLUDED)
	_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMCM_REQUIRED_ENV already included")
	RETURN()
ENDIF()

SET(BIMCM_REQUIRED_ENV_INCLUDED 1)



##
#
#
FUNCTION(BIMCM_REQUIRED_ENV)
	_BIMCM_REQUIRED_ENV_FIND_GIT()
	_BIMCM_REQUIRED_ENV_FIND_7ZIP()
	_BIMCM_REQUIRED_ENV_TMP_PATH()
	_BIMCM_REQUIRED_ENV_REMOTE_URI()
ENDFUNCTION()



## Helper
# Try find Git executable and ensure that we found
# supported version
#
MACRO(_BIMCM_REQUIRED_ENV_FIND_GIT)
	SET(BIMCM_REQUIRED_ENV_GIT_MIN_VERSION "2.11.0"
		CACHE STRING
		"Minimum required Git version"
	)
	FIND_PACKAGE(Git)
	IF(NOT GIT_FOUND)
		MESSAGE(FATAL_ERROR "Git not found, expected version ${BIMCM_REQUIRED_ENV_GIT_MIN_VERSION}"
			" Are you sure that the Git is properly installed and registered in PATH env. variable?")
	ENDIF()
	IF(NOT GIT_VERSION_STRING VERSION_GREATER_EQUAL "${BIMCM_REQUIRED_ENV_GIT_MIN_VERSION}")
		MESSAGE(FATAL_ERROR "Unsupporeted Git version ${GIT_VERSION_STRING}")
	ENDIF()
	SET(BIMCM_REQUIRED_ENV_GIT_EXECUTABLE "${GIT_EXECUTABLE}"
		CACHE PATH
		"Git executable, v${GIT_VERSION_STRING}"
	)
	UNSET(GIT_EXECUTABLE CACHE)
ENDMACRO()



## Helper
# Find and save 7Zip path to 7zip executable
#
# <function>(
# )
#
MACRO(_BIMCM_REQUIRED_ENV_FIND_7ZIP)
	FIND_PROGRAM(BIMCM_REQUIRED_ENV_7ZIP
		NAMES 7z 7za
		DOC "7zip executable"
	)
	IF("${BIMCM_REQUIRED_ENV_7ZIP}" STREQUAL "BIMCM_REQUIRED_ENV_7ZIP-NOTFOUND")
		MESSAGE(FATAL_ERROR "7zip not found. Are you sure that 7zip is installed and registered in PATH env. variable?")
	ENDIF()
ENDMACRO()



## Helper
#
# Determine cache path
#
MACRO(_BIMCM_REQUIRED_ENV_TMP_PATH)
	SET(_bimcm_cache_path "${CMAKE_SOURCE_DIR}/_tmp")
	IF(NOT "$ENV{BIMCM_REQUIRED_ENV_TMP_PATH}" STREQUAL "")
		SET(_bimcm_cache_path "$ENV{BIMCM_REQUIRED_ENV_TMP_PATH}")
	ENDIF()
	FILE(TO_CMAKE_PATH "${_bimcm_cache_path}" _bimcm_cache_path_tr)
	SET(BIMCM_REQUIRED_ENV_TMP_PATH "${_bimcm_cache_path_tr}"
		CACHE PATH
		"Cache path where all downloaded files will be stored"
	)
ENDMACRO()



## Helper
#
# Obtain and store BIMCM remote url.
# Remote name is configorable by BIMCM_REQUIRED_ENV_REMOTE_NAME.
# Default is 'origin'
#
# <function>(
# )
#
FUNCTION(_BIMCM_REQUIRED_ENV_REMOTE_URI)
	IF(NOT DEFINED BIMCM_REQUIRED_ENV_GIT_EXECUTABLE)
		MESSAGE(FATAL_ERROR "GIT executable not defined!")
	ENDIF()

	SET(BIMCM_REQUIRED_ENV_REMOTE_NAME "origin"
		CACHE STRING
		"Name of the Git remote from which the BIMCM_REQUIRED_ENV_REMOTE_URL will be obtained"
	)

	SET(tmp_output_var)
	EXECUTE_PROCESS(
		COMMAND ${BIMCM_REQUIRED_ENV_GIT_EXECUTABLE} config --get remote.${BIMCM_REQUIRED_ENV_REMOTE_NAME}.url
		OUTPUT_VARIABLE tmp_output_var
		RESULT_VARIABLE result
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
	)
	IF(NOT "${result}" STREQUAL "0")
		MESSAGE(FATAL_ERROR "Remote name '${BIMCM_REQUIRED_ENV_REMOTE_NAME}' does not obtain remote URL or does not exist")
	ENDIF()

	STRING(REGEX REPLACE "/[^/]+ *$" "" base_url "${tmp_output_var}")
	SET(BIMCM_REQUIRED_ENV_REMOTE_URL "${base_url}"
		CACHE STRING
		"Url for remote '${BIMCM_REQUIRED_ENV_REMOTE_NAME}'. Cannot be chaned. Dependent on BIMCM_REQUIRED_ENV_REMOTE_NAME"
		FORCE
	)
ENDFUNCTION()



## Helper
#
# Just run initialize process
#
BIMCM_REQUIRED_ENV()

