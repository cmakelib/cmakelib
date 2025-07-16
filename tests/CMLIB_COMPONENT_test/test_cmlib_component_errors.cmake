# Error handling tests for CMLIB_COMPONENT module
# These tests verify that proper errors are generated for invalid scenarios

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

# Include the module under test
SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
INCLUDE(CMLIB_COMPONENT)

MESSAGE(STATUS "=== Starting CMLIB_COMPONENT Error Handling Tests ===")

# Test 1: Test _CMLIB_COMPONENT_GET_REVISION with undefined component
FUNCTION(TEST_UNDEFINED_REVISION)
    MESSAGE(STATUS "Testing undefined revision error...")
    
    # This should cause a FATAL_ERROR
    _CMLIB_COMPONENT_GET_REVISION(output_revision "NONEXISTENT_COMPONENT")
    
    # If we reach here, the test failed
    MESSAGE(FATAL_ERROR "Expected FATAL_ERROR was not thrown")
ENDFUNCTION()

# Test 2: Test component registration with invalid component
FUNCTION(TEST_INVALID_COMPONENT_REGISTRATION)
    MESSAGE(STATUS "Testing invalid component registration...")
    
    # Mock the dependencies
    FUNCTION(_CMLIB_LIBRARY_DEBUG_MESSAGE message)
        MESSAGE(STATUS "DEBUG: ${message}")
    ENDFUNCTION()
    
    FUNCTION(CMLIB_DEPENDENCY)
        # This shouldn't be called for invalid components
        MESSAGE(FATAL_ERROR "CMLIB_DEPENDENCY should not be called for invalid components")
    ENDFUNCTION()
    
    # This should cause a FATAL_ERROR due to unregistered component
    _CMLIB_COMPONENT(COMPONENTS "invalid_component")
    
    # If we reach here, the test failed
    MESSAGE(FATAL_ERROR "Expected FATAL_ERROR for invalid component was not thrown")
ENDFUNCTION()

# Run error tests - these should cause FATAL_ERROR
# We'll test one at a time since FATAL_ERROR stops execution

# Test undefined revision error
TEST_UNDEFINED_REVISION()

# If we reach here, the error test failed
MESSAGE(FATAL_ERROR "Error handling tests should have caused FATAL_ERROR")