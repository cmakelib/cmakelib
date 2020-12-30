## MAIN
#
# Unzip/extract archives by 7Zip.
#
# Functions:
#	CMLIB_ARCHIVE_EXTRACT
#	CMLIB_ARCHIVE_CLEAN
#
#

IF(DEFINED CMLIB_ARCHIVE_INCLUDED)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_ARCHIVE already included")
	RETURN()
ENDIF()

# Flag that ARCHIVE is already included
SET(CMLIB_ARCHIVE_INCLUDED "1")

_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)




##
#
# Extracts archive and store it's content to OUTPUT_DIRECTORY.
#
# Only OUTPUT_DIRECTORY or OUTPUT_PATH_VAR can be specified at one time.
# If OUTPUT_DIRECTORY is specified it must exist and must be absolute.
# If OUTPUT_PATH_VAR is specified the path stored in given variable is
# not presistent across function calls.
#
# ARCHIVE_PATH must exist and must point to valid supported archive
# (look at ARCHIVE_TYPE).
#
# If no ARCHIVE_TYPE is specified it will be determined
# from archive_name (GIT_FILENAME_COMPONENT(archive_name "${ARCHIVE_PATH}" NAME))
#
# Let ARCHIVE_TMP = ${CMLIB_REQUIRED_ENV_TMP_PATH}/cmlib_archive
# As tmp directory the ARCHIVE_TMP is served.
#
# Archive is unzipped to CMLIB_REQUIRED_ENV_TMP_PATH/. If the archive
# needs a multiple steps for extract (tar.bz2 for example) that
# intermediate archives will be stored to CMLIB_REQUIRED_ENV_TMP_PATH too.
#
# ARCHIVE_TMP Directory is cleaned (deleted) at the end of function call
# (except one exception: If CMLIB is in debug mode, the ARCHIVE_TMP is not deleted
# at the anf of function call)
#
# <function>(
#		ARCHIVE_PATH     <archive_path>
#		OUTPUT_DIRECTORY <output_directory>
#		OUTPUT_PATH_VAR  <output_path_var>
#		[ARCHIVE_TYPE <ZIP|7Z|BZ2|GZ|TAR.BZ2|TAR.GZ>]
# )
#
FUNCTION(CMLIB_ARCHIVE_EXTRACT)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			ARCHIVE_PATH
			ARCHIVE_TYPE
			OUTPUT_DIRECTORY
			OUTPUT_PATH_VAR
		REQUIRED
			ARCHIVE_PATH
		P_ARGN ${ARGN}
	)
	IF(NOT EXISTS "${__ARCHIVE_PATH}")
		MESSAGE(FATAL_ERROR "Cannot dound ${__ARCHIVE_PATH}")
	ENDIF()

	IF((DEFINED __OUTPUT_DIRECTORY) AND (DEFINED __OUTPUT_PATH_VAR))
		MESSAGE(FATAL_ERROR "OUTPUT_DIRECTORY and OUTPUT_VAR cannot be defined at one time")
	ELSEIF(NOT (DEFINED __OUTPUT_DIRECTORY OR DEFINED __OUTPUT_PATH_VAR))
		MESSAGE(FATAL_ERROR "One of the following must be specified OUTPUT_DIRECTORY, OUTPUT_PATH_VAR")
	ENDIF()

	IF(NOT DEFINED __OUTPUT_PATH_VAR)
		IF(NOT EXISTS "${__OUTPUT_DIRECTORY}")
			MESSAGE(FATAL_ERROR "OUTPUT_DIRECTOYRY does not exist ${__OUTPUT_DIRECTORY}")
		ELSEIF(NOT IS_DIRECTORY "${__OUTPUT_DIRECTORY}")
			MESSAGE(FATAL_ERROR "OUTPUT_DIRECTORY is not a directory ${__OUTPUT_DIRECTORY}")
		ENDIF()
	ENDIF()

	_CMLIB_ARCHIVE_TMP_DIR_CLEAN()
	_CMLIB_ARCHIVE_TMP_DIR_CREATE()
	_CMLIB_ARCHIVE_TMP_DIR_GET(tmp_dir)

	SET(archive_type)
	IF(DEFINED __ARCHIVE_TYPE)
		_CMLIB_ARCHIVE_VALIDATE_ARCHIVE_TYPE(${__ARCHIVE_TYPE})
		SET(archive_type "${__ARCHIVE_TYPE}")
	ELSE()
		GET_FILENAME_COMPONENT(filename "${__ARCHIVE_PATH}" NAME)
		_CMLIB_ARCHIVE_DETERMINE_ARCHIVE_TYPE("${filename}" archive_type)
		_CMLIB_ARCHIVE_VALIDATE_ARCHIVE_TYPE(${archive_type})
	ENDIF()

	FILE(TO_CMAKE_PATH "${tmp_dir}/extracted" extracted_output_directory)
	FILE(ARCHIVE_EXTRACT INPUT "${__ARCHIVE_PATH}" DESTINATION ${extracted_output_directory})

	IF(DEFINED __OUTPUT_PATH_VAR)
		SET("${__OUTPUT_PATH_VAR}" ${extracted_output_directory} PARENT_SCOPE)
	ELSE()
		EXECUTE_PROCESS(
			COMMAND "${CMAKE_COMMAND}" -E copy_directory "${extracted_output_directory}" "${__OUTPUT_DIRECTORY}"
			RESULT_VARIABLE result_var
		)
		IF(NOT (result_var EQUAL 0))
			MESSAGE(FATAL_ERROR "Cannot copy \"${extracted_output_directory}\" to \"${__OUTPUT_DIRECTORY}\"")
		ENDIF()
		IF(NOT CMLIB_DEBUG)
			_CMLIB_ARCHIVE_TMP_DIR_CLEAN()
		ENDIF()
	ENDIF()
ENDFUNCTION()



##
#
# Function clean all tmp files and directories.
#
# All archive function will clean up automatically before return.
# There are some option which forbid this like "OUTPUT_PATH_VAR"
# in CMLIB_ARCHIVE_EXTRACT. In this situation call <function> if
# You want to be sure that all tmp files are deleted.
#
# Warning: If you use OUTPUT_PATH_VAR in CMLIB_ARCHIVE_EXTRACT
# path stored  in given variable is removed too.
# <function>(
# )
#
FUNCTION(CMLIB_ARCHIVE_CLEAN)
	_CMLIB_ARCHIVE_TMP_DIR_CLEAN()
ENDFUNCTION()






## Helper
#
# Check if the archive type is valid. If not throw an error.
# <function>(
#		<archive_type>
# )
#
FUNCTION(_CMLIB_ARCHIVE_VALIDATE_ARCHIVE_TYPE archive_type)
	IF(("${archive_type}" STREQUAL "TAR.BZ2")     OR
			("${archive_type}" STREQUAL "TAR.GZ") OR
			("${archive_type}" STREQUAL "BZ2")    OR
			("${archive_type}" STREQUAL "GZ")     OR
			("${archive_type}" STREQUAL "TAR")    OR
			("${archive_type}" STREQUAL "ZIP")    OR
			("${archive_type}" STREQUAL "7Z"))
		RETURN()
	ENDIF()
	MESSAGE(FATAL_ERROR "Invalid Archive type ${archive_type}")
ENDFUNCTION()



## Helper
#
# Determine archive type from filename.
# If no archive type found <archive_type_out> variable is undefined.
# <function>(
#		<filename>
#		<archive_type_out>
# )
#
FUNCTION(_CMLIB_ARCHIVE_DETERMINE_ARCHIVE_TYPE filename archive_type_out)
	STRING(TOUPPER "${filename}" filename_upper)
	STRING(REGEX MATCH "((\\.TAR\\.BZ2)|(\\.TAR\\.GZ)|(\\.GZ)|(\\.BZ2)|(\\.TAR)|(\\.ZIP)|(\\.7Z))$" match_ok "${filename_upper}")
	IF(match_ok)
		STRING(REGEX REPLACE "^\\." "" _tmp "${CMAKE_MATCH_0}")
		SET(${archive_type_out} ${_tmp} PARENT_SCOPE)
		RETURN()
	ENDIF()
	UNSET(${archive_type_out} PARENT_SCOPE)
	MESSAGE(FATAL_ERROR "Cannot determine ARCHIVE_TYPE from given archive name '${filename}'")
ENDFUNCTION()



## Helper
#
# Get CMLIB_ARCHIVE temporary directory
# <function>(
#		<var>
# )
#
MACRO(_CMLIB_ARCHIVE_TMP_DIR_GET var)
	SET(${var} "${CMLIB_REQUIRED_ENV_TMP_PATH}/cmlib_archive/")
ENDMACRO()



## Helper
#
# Creates CMLIB_ARCHIVE tmp directory
# <function>(
# )
#
FUNCTION(_CMLIB_ARCHIVE_TMP_DIR_CREATE)
	_CMLIB_ARCHIVE_TMP_DIR_GET(tmp_dir)
	IF(NOT EXISTS "${tmp_dir}")
		FILE(MAKE_DIRECTORY "${tmp_dir}")
	ENDIF()
ENDFUNCTION()



## Helper
#
# Clean the CMLIB_ARCHIVE tmp directory.
# <function>()
#
FUNCTION(_CMLIB_ARCHIVE_TMP_DIR_CLEAN)
	_CMLIB_ARCHIVE_TMP_DIR_GET(tmp_dir)
	IF(EXISTS "${tmp_dir}")
		FILE(REMOVE_RECURSE "${tmp_dir}")
	ENDIF()
ENDFUNCTION()

