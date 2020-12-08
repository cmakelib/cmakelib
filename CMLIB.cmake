## Main
#
# CMLIB library entry point
#
#
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF(DEFINED CMLIB_INCLUDED)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB Library already included")
	RETURN()
ENDIF()

# Flag that CMLIB is already included
SET(CMLIB_INCLUDED "1")

SET(CMLIB_PATH "${CMAKE_CURRENT_LIST_DIR}")

# Package name for find command
SET(CMLIB_PACKAGE_NAME "CMLIB")

OPTION(CMLIB_DEBUG
	"If ON debug messages and checks are enabled, If OFF disable debug"
	OFF
)


##
#
# Print message if and only if
# CMLIB_DEBUG is true
#
MACRO(_CMLIB_LIBRARY_DEBUG_MESSAGE msg)
	IF(CMLIB_DEBUG)
		MESSAGE(STATUS "Debug --> ${msg}")
	ENDIF()
ENDMACRO()



##
#
# Print warning message
#
MACRO(_CMLIB_LIBRARY_WARNING_MESSAGE msg)
	MESSAGE(WARNING "Warning --> ${msg}")
ENDMACRO()



##
#
# Include system module.
# Module is included only first time.
# System module must define varible <system_module_name>_INCLUDED
# which indecates that the module is already included
# <function>(
#	"<system_module_name>" // Name of the required system module. Without extension
# )
#
MACRO(_CMLIB_LIBRARY_MANAGER system_module_name)
	SET(module_path "${CMLIB_PATH}/system_modules/${system_module_name}.cmake")
	IF(NOT EXISTS "${module_path}")
		MESSAGE(FATAL_ERROR "Cannot find system module ${system_module_name}")
	ENDIF()

	STRING(TOUPPER "${system_module_name}" system_module_name_upper)
	IF(NOT DEFINED ${system_module_name_upper}_INCLUDED)
		INCLUDE("${module_path}")
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("System module '${system_module_name}' already included")
	ENDIF()
	UNSET(module_path)
	UNSET(system_module_name_upper)
ENDMACRO()



LIST(FIND ${CMLIB_PACKAGE_NAME}_FIND_COMPONENTS "STORAGE" storage_used)
IF(storage_used EQUAL -1)
	SET(storage_used OFF)
ELSE()
	SET(storage_used ON)
ENDIF()

IF(DEFINED CMLIB_USE_STORAGE AND (NOT (storage_used EQUAL CMLIB_USE_STORAGE)))
	_CMLIB_LIBRARY_DEBUG_MESSAGE("STORAGE is enabled regardless on COMPONENTS of FIND_PACKAGE(CMLIB)")
ENDIF()

SET(CMLIB_USE_STORAGE ${storage_used}
	CACHE BOOL
	"Enable or disable CMLIB storage"
)
UNSET(storage_used)



#
# Include needed modules
#
_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)
_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_CACHE)
_CMLIB_LIBRARY_MANAGER(CMLIB_FILE_DOWNLOAD)
_CMLIB_LIBRARY_MANAGER(CMLIB_ARCHIVE)
_CMLIB_LIBRARY_MANAGER(CMLIB_DEPENDENCY)
_CMLIB_LIBRARY_MANAGER(CMLIB_STORAGE)

