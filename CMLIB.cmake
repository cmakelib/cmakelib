## Main
#
# CMLIB library entry point
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF(DEFINED CMLIB_INCLUDED)
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



#
# Include needed modules
#
_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)
_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_CACHE)
_CMLIB_LIBRARY_MANAGER(CMLIB_FILE_DOWNLOAD)
_CMLIB_LIBRARY_MANAGER(CMLIB_ARCHIVE)
_CMLIB_LIBRARY_MANAGER(CMLIB_DEPENDENCY)
_CMLIB_LIBRARY_MANAGER(CMLIB_COMPONENT)

IF(${CMLIB_PACKAGE_NAME}_FIND_COMPONENTS)
	CMLIB_COMPONENT(
		COMPONENTS ${${CMLIB_PACKAGE_NAME}_FIND_COMPONENTS}
	)
ENDIF()
