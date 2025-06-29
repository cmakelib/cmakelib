##
# Cache Variable Management Functions for CMDEF Tests
#
# This file provides utilities for safely manipulating CMake cache variables
# in test environments with proper backup and restoration capabilities.
#

##
# Force set a cache variable and store original value for restoration.
#
# Stores the current cache variable value (if exists) in a global property
# and then force sets the cache variable to the new value. The original
# state can be restored later using CACHE_VAR_RESTORE.
#
# <function>(var_name, value)
#
FUNCTION(CACHE_VAR_FORCE_SET var_name value)
    GET_PROPERTY(was_defined CACHE ${var_name} PROPERTY VALUE SET)
    SET_PROPERTY(GLOBAL PROPERTY CACHE_VAR_WAS_DEFINED_${var_name} ${was_defined})
    
    IF(was_defined)
        GET_PROPERTY(original_value CACHE ${var_name} PROPERTY VALUE)
        SET_PROPERTY(GLOBAL PROPERTY CACHE_VAR_ORIGINAL_${var_name} "${original_value}")
    ENDIF()
    
    SET(${var_name} "${value}" CACHE STRING "Test override" FORCE)
ENDFUNCTION()

##
# Unset a cache variable and store original value for restoration.
#
# Stores the current cache variable value (if exists) in a global property
# and then unsets the cache variable. The original state can be restored
# later using CACHE_VAR_RESTORE.
#
# Note: This function only handles cache variables, not normal variables.
#
# <function>(var_name)
#
FUNCTION(CACHE_VAR_FORCE_UNSET var_name)
    GET_PROPERTY(was_defined CACHE ${var_name} PROPERTY VALUE SET)
    SET_PROPERTY(GLOBAL PROPERTY CACHE_VAR_WAS_DEFINED_${var_name} ${was_defined})
    
    IF(was_defined)
        GET_PROPERTY(original_value CACHE ${var_name} PROPERTY VALUE)
        SET_PROPERTY(GLOBAL PROPERTY CACHE_VAR_ORIGINAL_${var_name} "${original_value}")
    ENDIF()
    
    UNSET(${var_name} CACHE)
ENDFUNCTION()

##
# Restore a cache variable to its original state.
#
# Restores a cache variable that was previously modified using
# CACHE_VAR_FORCE_SET or CACHE_VAR_FORCE_UNSET to its original state.
# Cleans up the global properties used for storage.
#
# <function>(var_name)
#
FUNCTION(CACHE_VAR_RESTORE var_name)
    GET_PROPERTY(was_defined GLOBAL PROPERTY CACHE_VAR_WAS_DEFINED_${var_name} SET)
    IF(NOT was_defined)
        MESSAGE(FATAL_ERROR "No stored information found for cache variable '${var_name}'. Cannot restore.")
        RETURN()
    ENDIF()
    
    GET_PROPERTY(originally_defined GLOBAL PROPERTY CACHE_VAR_WAS_DEFINED_${var_name})
    
    IF(originally_defined)
        GET_PROPERTY(original_value GLOBAL PROPERTY CACHE_VAR_ORIGINAL_${var_name})
        SET(${var_name} "${original_value}" CACHE STRING "Restored after test" FORCE)
    ELSE()
        UNSET(${var_name} CACHE)
    ENDIF()
    
    SET_PROPERTY(GLOBAL PROPERTY CACHE_VAR_WAS_DEFINED_${var_name})
    SET_PROPERTY(GLOBAL PROPERTY CACHE_VAR_ORIGINAL_${var_name})
ENDFUNCTION()
