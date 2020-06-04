## Main
#
# BIMCM library entry point
#
#
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF(DEFINED BIMCM_INCLUDED)
	_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMCM Library already included")
	RETURN()
ENDIF()

# Flag that BIMCM is already included
SET(BIMCM_INCLUDED "1")

SET(BIMCM_PATH "${CMAKE_CURRENT_LIST_DIR}")

# Package name for find command
SET(BIMCM_PACKAGE_NAME "BIMCM")

OPTION(BIMCM_DEBUG
	"If ON debug messages and checks are enabled, If OFF disable debug"
	OFF
)


##
#
# Print message if and only if
# BIMCM_DEBUG is true
#
MACRO(_BIMCM_LIBRARY_DEBUG_MESSAGE msg)
	IF(BIMCM_DEBUG)
		MESSAGE(STATUS "Debug --> ${msg}")
	ENDIF()
ENDMACRO()



##
#
# Print warning message
#
MACRO(_BIMCM_LIBRARY_WARNING_MESSAGE msg)
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
MACRO(_BIMCM_LIBRARY_MANAGER system_module_name)
	SET(module_path "${BIMCM_PATH}/system_modules/${system_module_name}.cmake")
	IF(NOT EXISTS "${module_path}")
		MESSAGE(FATAL_ERROR "Cannot find system module ${system_module_name}")
	ENDIF()

	STRING(TOUPPER "${system_module_name}" system_module_name_upper)
	IF(NOT DEFINED ${system_module_name_upper}_INCLUDED)
		INCLUDE("${module_path}")
	ELSE()
		_BIMCM_LIBRARY_DEBUG_MESSAGE("System module '${system_module_name}' already included")
	ENDIF()
	UNSET(module_path)
	UNSET(system_module_name_upper)
ENDMACRO()



LIST(FIND ${BIMCM_PACKAGE_NAME}_FIND_COMPONENTS "STORAGE" storage_used)
IF(storage_used EQUAL -1)
	SET(storage_used OFF)
ELSE()
	SET(storage_used ON)
ENDIF()

IF(DEFINED BIMCM_USE_STORAGE AND (NOT (storage_used EQUAL BIMCM_USE_STORAGE)))
	_BIMCM_LIBRARY_DEBUG_MESSAGE("STORAGE is enabled regardless on COMPONENTS of FIND_PACKAGE(BIMCM)")
ENDIF()

SET(BIMCM_USE_STORAGE ${storage_used}
	CACHE BOOL
	"Enable or disable BIMCM storage"
)
UNSET(storage_used)



#
# Include needed modules
#
_BIMCM_LIBRARY_MANAGER(BIMCM_PARSE_ARGUMENTS)
_BIMCM_LIBRARY_MANAGER(BIMCM_REQUIRED_ENV)
_BIMCM_LIBRARY_MANAGER(BIMCM_CACHE)
_BIMCM_LIBRARY_MANAGER(BIMCM_FILE_DOWNLOAD)
_BIMCM_LIBRARY_MANAGER(BIMCM_ARCHIVE)
_BIMCM_LIBRARY_MANAGER(BIMCM_DEPENDENCY)
_BIMCM_LIBRARY_MANAGER(BIMCM_STORAGE)

