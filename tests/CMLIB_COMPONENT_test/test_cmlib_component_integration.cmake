# Integration tests for CMLIB_COMPONENT module
# These tests simulate actual component loading with mocked dependencies

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

# Test result tracking
SET(TESTS_PASSED 0)
SET(TESTS_FAILED 0)
SET(TESTS_TOTAL 0)

# Test assertion macros
MACRO(ASSERT_EQUAL expected actual test_name)
    MATH(EXPR TESTS_TOTAL "${TESTS_TOTAL} + 1")
    IF("${expected}" STREQUAL "${actual}")
        MESSAGE(STATUS "PASS: ${test_name}")
        MATH(EXPR TESTS_PASSED "${TESTS_PASSED} + 1")
    ELSE()
        MESSAGE(STATUS "FAIL: ${test_name}")
        MESSAGE(STATUS "  Expected: ${expected}")
        MESSAGE(STATUS "  Actual: ${actual}")
        MATH(EXPR TESTS_FAILED "${TESTS_FAILED} + 1")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_TRUE condition test_name)
    MATH(EXPR TESTS_TOTAL "${TESTS_TOTAL} + 1")
    IF(${condition})
        MESSAGE(STATUS "PASS: ${test_name}")
        MATH(EXPR TESTS_PASSED "${TESTS_PASSED} + 1")
    ELSE()
        MESSAGE(STATUS "FAIL: ${test_name}")
        MATH(EXPR TESTS_FAILED "${TESTS_FAILED} + 1")
    ENDIF()
ENDMACRO()

# Mock dependencies for testing
FUNCTION(MOCK_DEPENDENCIES)
    # Mock CMLIB_PARSE_ARGUMENTS
    MACRO(CMLIB_PARSE_ARGUMENTS)
        CMAKE_PARSE_ARGUMENTS(PARSED_ARGS
            ""
            ""
            "MULTI_VALUE;REQUIRED;P_ARGN"
            ${ARGN}
        )
        SET(__COMPONENTS ${PARSED_ARGS_P_ARGN})
    ENDMACRO()
    
    MACRO(CMLIB_PARSE_ARGUMENTS_CLEANUP)
        # Mock cleanup
    ENDMACRO()
    
    FUNCTION(_CMLIB_LIBRARY_MANAGER)
        # Mock manager
    ENDFUNCTION()
    
    FUNCTION(_CMLIB_LIBRARY_DEBUG_MESSAGE message)
        MESSAGE(STATUS "DEBUG: ${message}")
    ENDFUNCTION()
    
    FUNCTION(CMLIB_DEPENDENCY)
        CMAKE_PARSE_ARGUMENTS(CMLIB_DEP
            ""
            "OUTPUT_PATH_VAR"
            "KEYWORDS;TYPE;URI;URI_TYPE;REVISION"
            ${ARGN}
        )
        
        # Mock successful dependency resolution
        SET(${CMLIB_DEP_OUTPUT_PATH_VAR} "/mock/path/to/component" PARENT_SCOPE)
    ENDFUNCTION()
    
    FUNCTION(FIND_PACKAGE package_name)
        # Mock successful package finding
        SET(${package_name}_FOUND TRUE PARENT_SCOPE)
    ENDFUNCTION()
    
    # Mock environment variables
    SET(CMLIB_REQUIRED_ENV_REMOTE_URL "https://mock.example.com/repo")
    SET(CMLIB_FIND_COMPONENTS "")
ENDFUNCTION()

# Setup mocks
MOCK_DEPENDENCIES()

# Include the module under test
SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
INCLUDE(CMLIB_COMPONENT)

MESSAGE(STATUS "=== Starting CMLIB_COMPONENT Integration Tests ===")

# Integration Test 1: Test _CMLIB_COMPONENT with single component
FUNCTION(TEST_COMPONENT_LOADING_SINGLE)
    MESSAGE(STATUS "Testing single component loading...")
    
    SET(test_components "cmdef")
    SET(CMAKE_MODULE_PATH_BEFORE ${CMAKE_MODULE_PATH})
    
    # Call the internal function
    _CMLIB_COMPONENT(COMPONENTS ${test_components})
    
    # Check that CMAKE_MODULE_PATH was modified
    LIST(LENGTH CMAKE_MODULE_PATH new_path_length)
    LIST(LENGTH CMAKE_MODULE_PATH_BEFORE old_path_length)
    
    ASSERT_TRUE("${new_path_length}" GREATER "${old_path_length}" "Single component: CMAKE_MODULE_PATH extended")
    
    # Reset
    SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH_BEFORE})
ENDFUNCTION()

# Integration Test 2: Test _CMLIB_COMPONENT with multiple components
FUNCTION(TEST_COMPONENT_LOADING_MULTIPLE)
    MESSAGE(STATUS "Testing multiple component loading...")
    
    SET(test_components "cmdef" "storage" "cmutil")
    SET(CMAKE_MODULE_PATH_BEFORE ${CMAKE_MODULE_PATH})
    
    # Call the internal function
    _CMLIB_COMPONENT(COMPONENTS ${test_components})
    
    # Check that CMAKE_MODULE_PATH contains entries for all components
    LIST(LENGTH CMAKE_MODULE_PATH new_path_length)
    LIST(LENGTH CMAKE_MODULE_PATH_BEFORE old_path_length)
    LIST(LENGTH test_components components_count)
    
    MATH(EXPR expected_length "${old_path_length} + ${components_count}")
    ASSERT_EQUAL("${expected_length}" "${new_path_length}" "Multiple components: Correct path count")
    
    # Reset
    SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH_BEFORE})
ENDFUNCTION()

# Integration Test 3: Test local path behavior
FUNCTION(TEST_LOCAL_PATH_BEHAVIOR)
    MESSAGE(STATUS "Testing local path behavior...")
    
    SET(original_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}")
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "/tmp/local/components")
    
    SET(test_components "cmdef")
    SET(CMAKE_MODULE_PATH_BEFORE ${CMAKE_MODULE_PATH})
    
    # Call the internal function
    _CMLIB_COMPONENT(COMPONENTS ${test_components})
    
    # Check that CMAKE_MODULE_PATH was modified
    LIST(LENGTH CMAKE_MODULE_PATH new_path_length)
    LIST(LENGTH CMAKE_MODULE_PATH_BEFORE old_path_length)
    
    ASSERT_TRUE("${new_path_length}" GREATER "${old_path_length}" "Local path: CMAKE_MODULE_PATH extended")
    
    # Reset
    SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH_BEFORE})
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "${original_path}")
ENDFUNCTION()

# Integration Test 4: Test component path construction
FUNCTION(TEST_COMPONENT_PATH_CONSTRUCTION)
    MESSAGE(STATUS "Testing component path construction...")
    
    # Test with local base path
    SET(original_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}")
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "/test/components")
    
    SET(component_lower "cmdef")
    SET(component_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower}")
    SET(expected_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}/${component_dir_name}")
    
    ASSERT_EQUAL("/test/components/cmakelib-component-cmdef" "${expected_path}" "Path construction: Local path")
    
    # Reset
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "${original_path}")
ENDFUNCTION()

# Integration Test 5: Test case sensitivity handling
FUNCTION(TEST_CASE_SENSITIVITY)
    MESSAGE(STATUS "Testing case sensitivity handling...")
    
    # Test that component names are normalized to lowercase
    SET(test_components "CMDEF" "Storage" "cmutil")
    
    FOREACH(component IN LISTS test_components)
        STRING(TOLOWER "${component}" component_lower)
        SET(component_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower}")
        
        # Verify directory name is always lowercase
        STRING(REGEX MATCH "^cmakelib-component-[a-z]+$" lowercase_match "${component_dir_name}")
        ASSERT_TRUE(lowercase_match "Case sensitivity: ${component} normalized to lowercase")
    ENDFOREACH()
ENDFUNCTION()

# Run integration tests
TEST_COMPONENT_LOADING_SINGLE()
TEST_COMPONENT_LOADING_MULTIPLE()
TEST_LOCAL_PATH_BEHAVIOR()
TEST_COMPONENT_PATH_CONSTRUCTION()
TEST_CASE_SENSITIVITY()

# Test Summary
MESSAGE(STATUS "=== Integration Test Summary ===")
MESSAGE(STATUS "Tests Passed: ${TESTS_PASSED}")
MESSAGE(STATUS "Tests Failed: ${TESTS_FAILED}")
MESSAGE(STATUS "Tests Total: ${TESTS_TOTAL}")

IF(TESTS_FAILED GREATER 0)
    MESSAGE(FATAL_ERROR "Some integration tests failed!")
ELSE()
    MESSAGE(STATUS "All integration tests passed!")
ENDIF()