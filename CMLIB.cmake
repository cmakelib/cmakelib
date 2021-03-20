## Main
#
# CMLIB library entry point
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)

##
# Compatibility version is na integer positive number.
# Each instance if CMakeLib has one Compatibility version.
# Let A, B be an instances of CMakeLib. Let COMP_VER(A) is Compatibility version for A and
# COMP_VER(B) is compatibility version for B.
# We say that A is compatible with  B if and only if COMP_VER(A) == COMP_VER(B)
#

SET(_CMLIB_COMPATIBILITY_VERSION 1)
IF(DEFINED CMLIB_COMPATIBILITY_VERSION)
	IF(NOT CMLIB_COMPATIBILITY_VERSION EQUAL _CMLIB_COMPATIBILITY_VERSION)
		MESSAGE(FATAL_ERROR "Sorry, you have two incopatibility CMake-lib instances!")
	ENDIF()
ENDIF()

SET(CMLIB_COMPATIBILITY_VERSION ${_CMLIB_COMPATIBILITY_VERSION}
	CACHE STRING
	"CMake-lib compatibility version"
)

INCLUDE_GUARD(GLOBAL)

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
