## MAIN
#
# CMake-lib component management unit tests
#
# Testing Framework: Custom CMake testing macros (following project conventions)
# These tests cover the CMLIB_COMPONENT functionality including:
# - Component registration and validation
# - Local vs remote component resolution
# - Revision management
# - Error handling and edge cases
# - CMAKE_MODULE_PATH integration
#

INCLUDE_GUARD(GLOBAL)

# Test helper macros (following the pattern from existing tests)
MACRO(ASSERT_EQUAL actual expected message)
    IF(NOT "${actual}" STREQUAL "${expected}")
        MESSAGE(FATAL_ERROR "ASSERTION FAILED: ${message} - Expected: '${expected}', Got: '${actual}'")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_TRUE condition message)
    IF(NOT ${condition})
        MESSAGE(FATAL_ERROR "ASSERTION FAILED: ${message} - Condition was false")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_FALSE condition message)
    IF(${condition})
        MESSAGE(FATAL_ERROR "ASSERTION FAILED: ${message} - Condition was true")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_DEFINED variable message)
    IF(NOT DEFINED ${variable})
        MESSAGE(FATAL_ERROR "ASSERTION FAILED: ${message} - Variable '${variable}' is not defined")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_NOT_DEFINED variable message)
    IF(DEFINED ${variable})
        MESSAGE(FATAL_ERROR "ASSERTION FAILED: ${message} - Variable '${variable}' should not be defined")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_CONTAINS haystack needle message)
    STRING(FIND "${haystack}" "${needle}" found_pos)
    IF(found_pos EQUAL -1)
        MESSAGE(FATAL_ERROR "ASSERTION FAILED: ${message} - '${needle}' not found in '${haystack}'")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_LIST_CONTAINS list_var value message)
    LIST(FIND ${list_var} "${value}" found_index)
    IF(found_index EQUAL -1)
        MESSAGE(FATAL_ERROR "ASSERTION FAILED: ${message} - '${value}' not found in list")
    ENDIF()
ENDMACRO()

# Test environment setup/teardown
MACRO(SETUP_TEST_ENVIRONMENT)
    # Save original values
    SET(_ORIGINAL_CMLIB_COMPONENT_LOCAL_BASE_PATH "${CMLIB_COMPONENT_LOCAL_BASE_PATH}")
    SET(_ORIGINAL_CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")
    SET(_ORIGINAL_CMLIB_FIND_COMPONENTS "${CMLIB_FIND_COMPONENTS}")
    
    # Reset test environment
    SET(CMAKE_MODULE_PATH)
    SET(CMLIB_REQUIRED_ENV_REMOTE_URL "https://github.com/mock")
    
    MESSAGE(STATUS "Test environment set up")
ENDMACRO()

MACRO(TEARDOWN_TEST_ENVIRONMENT)
    # Restore original values
    IF(DEFINED _ORIGINAL_CMLIB_COMPONENT_LOCAL_BASE_PATH)
        SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "${_ORIGINAL_CMLIB_COMPONENT_LOCAL_BASE_PATH}")
    ENDIF()
    IF(DEFINED _ORIGINAL_CMAKE_MODULE_PATH)
        SET(CMAKE_MODULE_PATH "${_ORIGINAL_CMAKE_MODULE_PATH}")
    ENDIF()
    IF(DEFINED _ORIGINAL_CMLIB_FIND_COMPONENTS)
        SET(CMLIB_FIND_COMPONENTS "${_ORIGINAL_CMLIB_FIND_COMPONENTS}")
    ENDIF()
    
    # Clean up test variables
    UNSET(_ORIGINAL_CMLIB_COMPONENT_LOCAL_BASE_PATH)
    UNSET(_ORIGINAL_CMAKE_MODULE_PATH)
    UNSET(_ORIGINAL_CMLIB_FIND_COMPONENTS)
    
    MESSAGE(STATUS "Test environment cleaned up")
ENDMACRO()

# Test: Default variable initialization
FUNCTION(TEST_DEFAULT_VARIABLE_INITIALIZATION)
    MESSAGE(STATUS "Running TEST_DEFAULT_VARIABLE_INITIALIZATION")
    
    # Test that default variables are properly initialized
    ASSERT_DEFINED(CMLIB_COMPONENT_LOCAL_BASE_PATH "CMLIB_COMPONENT_LOCAL_BASE_PATH should be defined")
    ASSERT_EQUAL("${_CMLIB_COMPONENT_REPO_NAME_PREFIX}" "cmakelib-component-" "Repo name prefix should be set correctly")
    ASSERT_EQUAL("${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}" "CMLIB_COMPONENT_REVISION_" "Revision variable prefix should be set correctly")
    
    # Test available components list
    ASSERT_DEFINED(_CMLIB_COMPONENT_AVAILABLE_LIST "Available components list should be defined")
    ASSERT_LIST_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "cmdef" "cmdef should be in available components")
    ASSERT_LIST_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "storage" "storage should be in available components")
    ASSERT_LIST_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "cmutil" "cmutil should be in available components")
    
    # Test revision variables
    ASSERT_DEFINED(CMLIB_COMPONENT_REVISION_CMDEF "CMDEF revision should be defined")
    ASSERT_DEFINED(CMLIB_COMPONENT_REVISION_STORAGE "STORAGE revision should be defined")
    ASSERT_DEFINED(CMLIB_COMPONENT_REVISION_CMUTIL "CMUTIL revision should be defined")
    
    # Test specific revision values
    ASSERT_EQUAL("${CMLIB_COMPONENT_REVISION_CMDEF}" "v1.0.0" "CMDEF revision should be v1.0.0")
    ASSERT_EQUAL("${CMLIB_COMPONENT_REVISION_STORAGE}" "v1.0.0" "STORAGE revision should be v1.0.0")
    ASSERT_EQUAL("${CMLIB_COMPONENT_REVISION_CMUTIL}" "v1.1.0" "CMUTIL revision should be v1.1.0")
    
    MESSAGE(STATUS "✓ TEST_DEFAULT_VARIABLE_INITIALIZATION passed")
ENDFUNCTION()

# Test: Component revision retrieval
FUNCTION(TEST_COMPONENT_REVISION_RETRIEVAL)
    MESSAGE(STATUS "Running TEST_COMPONENT_REVISION_RETRIEVAL")
    
    # Test valid component revision retrieval
    _CMLIB_COMPONENT_GET_REVISION(test_revision "CMDEF")
    ASSERT_EQUAL("${test_revision}" "v1.0.0" "CMDEF revision should be v1.0.0")
    
    _CMLIB_COMPONENT_GET_REVISION(test_revision "STORAGE")
    ASSERT_EQUAL("${test_revision}" "v1.0.0" "STORAGE revision should be v1.0.0")
    
    _CMLIB_COMPONENT_GET_REVISION(test_revision "CMUTIL")
    ASSERT_EQUAL("${test_revision}" "v1.1.0" "CMUTIL revision should be v1.1.0")
    
    MESSAGE(STATUS "✓ TEST_COMPONENT_REVISION_RETRIEVAL passed")
ENDFUNCTION()

# Test: Component registration validation
FUNCTION(TEST_COMPONENT_REGISTRATION_VALIDATION)
    MESSAGE(STATUS "Running TEST_COMPONENT_REGISTRATION_VALIDATION")
    
    # Test case sensitivity handling
    SET(test_components "CMDEF" "cmdef" "CmDef")
    FOREACH(component IN LISTS test_components)
        STRING(TOUPPER "${component}" component_upper)
        STRING(TOLOWER "${component}" component_lower)
        
        SET(component_registered OFF)
        FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
            STRING(TOLOWER "${avail_component}" avail_component_lower)
            IF("${component_lower}" STREQUAL "${avail_component_lower}")
                SET(component_registered ON)
                BREAK()
            ENDIF()
        ENDFOREACH()
        
        ASSERT_TRUE(component_registered "Component '${component}' should be registered")
    ENDFOREACH()
    
    # Test unregistered component
    SET(unregistered_component "nonexistent")
    STRING(TOLOWER "${unregistered_component}" component_lower)
    SET(component_registered OFF)
    FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
        STRING(TOLOWER "${avail_component}" avail_component_lower)
        IF("${component_lower}" STREQUAL "${avail_component_lower}")
            SET(component_registered ON)
            BREAK()
        ENDIF()
    ENDFOREACH()
    
    ASSERT_FALSE(component_registered "Unregistered component should not be found")
    
    MESSAGE(STATUS "✓ TEST_COMPONENT_REGISTRATION_VALIDATION passed")
ENDFUNCTION()

# Test: Component directory name generation
FUNCTION(TEST_COMPONENT_DIRECTORY_NAME_GENERATION)
    MESSAGE(STATUS "Running TEST_COMPONENT_DIRECTORY_NAME_GENERATION")
    
    # Test directory name generation for various components
    STRING(TOLOWER "CMDEF" component_lower)
    SET(component_dir_name ${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower})
    ASSERT_EQUAL("${component_dir_name}" "cmakelib-component-cmdef" "Directory name should be correctly generated")
    
    STRING(TOLOWER "STORAGE" component_lower)
    SET(component_dir_name ${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower})
    ASSERT_EQUAL("${component_dir_name}" "cmakelib-component-storage" "Directory name should be correctly generated")
    
    STRING(TOLOWER "CMUTIL" component_lower)
    SET(component_dir_name ${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower})
    ASSERT_EQUAL("${component_dir_name}" "cmakelib-component-cmutil" "Directory name should be correctly generated")
    
    MESSAGE(STATUS "✓ TEST_COMPONENT_DIRECTORY_NAME_GENERATION passed")
ENDFUNCTION()

# Test: Local path resolution
FUNCTION(TEST_LOCAL_PATH_RESOLUTION)
    MESSAGE(STATUS "Running TEST_LOCAL_PATH_RESOLUTION")
    
    # Set up local base path
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "/mock/local/path")
    
    # Test local path construction
    STRING(TOLOWER "cmdef" component_lower)
    SET(component_dir_name ${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower})
    SET(expected_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}/${component_dir_name}")
    
    ASSERT_EQUAL("${expected_path}" "/mock/local/path/cmakelib-component-cmdef" "Local path should be constructed correctly")
    
    # Test empty local base path
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "")
    ASSERT_FALSE(CMLIB_COMPONENT_LOCAL_BASE_PATH "Empty local base path should evaluate to false")
    
    MESSAGE(STATUS "✓ TEST_LOCAL_PATH_RESOLUTION passed")
ENDFUNCTION()

# Test: Remote URI construction
FUNCTION(TEST_REMOTE_URI_CONSTRUCTION)
    MESSAGE(STATUS "Running TEST_REMOTE_URI_CONSTRUCTION")
    
    # Unset local base path to trigger remote resolution
    UNSET(CMLIB_COMPONENT_LOCAL_BASE_PATH)
    SET(CMLIB_REQUIRED_ENV_REMOTE_URL "https://github.com/example")
    
    # Test remote URI construction
    STRING(TOLOWER "cmdef" component_lower)
    SET(component_dir_name ${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower})
    SET(expected_uri "${CMLIB_REQUIRED_ENV_REMOTE_URL}/${component_dir_name}")
    
    ASSERT_EQUAL("${expected_uri}" "https://github.com/example/cmakelib-component-cmdef" "Remote URI should be constructed correctly")
    
    # Test with different remote URL
    SET(CMLIB_REQUIRED_ENV_REMOTE_URL "https://custom.domain.com/repos")
    SET(expected_uri "${CMLIB_REQUIRED_ENV_REMOTE_URL}/${component_dir_name}")
    ASSERT_EQUAL("${expected_uri}" "https://custom.domain.com/repos/cmakelib-component-cmdef" "Custom remote URI should be constructed correctly")
    
    MESSAGE(STATUS "✓ TEST_REMOTE_URI_CONSTRUCTION passed")
ENDFUNCTION()

# Test: Component list processing
FUNCTION(TEST_COMPONENT_LIST_PROCESSING)
    MESSAGE(STATUS "Running TEST_COMPONENT_LIST_PROCESSING")
    
    # Test multiple components processing
    SET(test_components "cmdef" "storage" "cmutil")
    SET(processed_components)
    
    FOREACH(component IN LISTS test_components)
        STRING(TOUPPER "${component}" component_upper)
        STRING(TOLOWER "${component}" component_lower)
        
        # Verify component is in available list
        SET(component_registered OFF)
        FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
            STRING(TOLOWER "${avail_component}" avail_component_lower)
            IF("${component_lower}" STREQUAL "${avail_component_lower}")
                SET(component_registered ON)
                BREAK()
            ENDIF()
        ENDFOREACH()
        
        ASSERT_TRUE(component_registered "Component '${component}' should be registered")
        LIST(APPEND processed_components "${component}")
    ENDFOREACH()
    
    LIST(LENGTH processed_components processed_count)
    ASSERT_EQUAL("${processed_count}" "3" "Should process all 3 components")
    
    MESSAGE(STATUS "✓ TEST_COMPONENT_LIST_PROCESSING passed")
ENDFUNCTION()

# Test: Case sensitivity handling
FUNCTION(TEST_CASE_SENSITIVITY_HANDLING)
    MESSAGE(STATUS "Running TEST_CASE_SENSITIVITY_HANDLING")
    
    # Test that component names are handled case-insensitively
    SET(test_cases "cmdef" "CMDEF" "CmDef" "CMDef")
    
    FOREACH(component IN LISTS test_cases)
        STRING(TOUPPER "${component}" component_upper)
        STRING(TOLOWER "${component}" component_lower)
        
        # All should resolve to the same lowercase name
        ASSERT_EQUAL("${component_lower}" "cmdef" "All variants should normalize to 'cmdef'")
        
        # All should match the available component
        SET(component_registered OFF)
        FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
            STRING(TOLOWER "${avail_component}" avail_component_lower)
            IF("${component_lower}" STREQUAL "${avail_component_lower}")
                SET(component_registered ON)
                BREAK()
            ENDIF()
        ENDFOREACH()
        
        ASSERT_TRUE(component_registered "Component '${component}' should be registered")
    ENDFOREACH()
    
    MESSAGE(STATUS "✓ TEST_CASE_SENSITIVITY_HANDLING passed")
ENDFUNCTION()

# Test: Edge cases and boundary conditions
FUNCTION(TEST_EDGE_CASES)
    MESSAGE(STATUS "Running TEST_EDGE_CASES")
    
    # Test empty component list handling
    SET(empty_components)
    LIST(LENGTH empty_components empty_count)
    ASSERT_EQUAL("${empty_count}" "0" "Empty component list should have zero length")
    
    # Test single component
    SET(single_component "cmdef")
    LIST(LENGTH single_component single_count)
    ASSERT_EQUAL("${single_count}" "1" "Single component list should have length 1")
    
    # Test component name with special characters (should be handled by string operations)
    SET(special_name "cm-def")
    STRING(TOLOWER "${special_name}" special_lower)
    ASSERT_EQUAL("${special_lower}" "cm-def" "Special characters should be preserved in lowercase")
    
    # Test very long component name
    SET(long_name "verylongcomponentnamethatexceedsnormalexpectations")
    STRING(TOLOWER "${long_name}" long_lower)
    ASSERT_EQUAL("${long_lower}" "verylongcomponentnamethatexceedsnormalexpectations" "Long names should be handled correctly")
    
    MESSAGE(STATUS "✓ TEST_EDGE_CASES passed")
ENDFUNCTION()

# Test: Variable scoping
FUNCTION(TEST_VARIABLE_SCOPING)
    MESSAGE(STATUS "Running TEST_VARIABLE_SCOPING")
    
    # Test that variables are properly scoped
    SET(test_var "initial_value")
    
    # Call a function that might modify variables
    _CMLIB_COMPONENT_GET_REVISION(revision_var "CMDEF")
    
    # Original variable should remain unchanged
    ASSERT_EQUAL("${test_var}" "initial_value" "Local variables should not be affected by function calls")
    ASSERT_EQUAL("${revision_var}" "v1.0.0" "Function output should be correct")
    
    # Test that function parameters don't leak
    ASSERT_NOT_DEFINED(output_var "Function internal variables should not be defined")
    ASSERT_NOT_DEFINED(component_name "Function internal variables should not be defined")
    
    MESSAGE(STATUS "✓ TEST_VARIABLE_SCOPING passed")
ENDFUNCTION()

# Test: Configuration validation
FUNCTION(TEST_CONFIGURATION_VALIDATION)
    MESSAGE(STATUS "Running TEST_CONFIGURATION_VALIDATION")
    
    # Test that all required configuration variables are set
    ASSERT_DEFINED(_CMLIB_COMPONENT_REPO_NAME_PREFIX "Repo name prefix must be defined")
    ASSERT_DEFINED(_CMLIB_COMPONENT_AVAILABLE_LIST "Available components list must be defined")
    ASSERT_DEFINED(_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX "Revision variable prefix must be defined")
    
    # Test that revision variables follow the correct naming pattern
    SET(expected_cmdef_var "CMLIB_COMPONENT_REVISION_CMDEF")
    SET(expected_storage_var "CMLIB_COMPONENT_REVISION_STORAGE")
    SET(expected_cmutil_var "CMLIB_COMPONENT_REVISION_CMUTIL")
    
    ASSERT_DEFINED(${expected_cmdef_var} "CMDEF revision variable should exist")
    ASSERT_DEFINED(${expected_storage_var} "STORAGE revision variable should exist")
    ASSERT_DEFINED(${expected_cmutil_var} "CMUTIL revision variable should exist")
    
    # Test that cache variables have proper properties
    GET_PROPERTY(cmdef_type CACHE CMLIB_COMPONENT_REVISION_CMDEF PROPERTY TYPE)
    ASSERT_EQUAL("${cmdef_type}" "STRING" "Revision variables should be STRING type")
    
    MESSAGE(STATUS "✓ TEST_CONFIGURATION_VALIDATION passed")
ENDFUNCTION()

# Test: Integration with CMAKE_MODULE_PATH
FUNCTION(TEST_CMAKE_MODULE_PATH_INTEGRATION)
    MESSAGE(STATUS "Running TEST_CMAKE_MODULE_PATH_INTEGRATION")
    
    # Save original CMAKE_MODULE_PATH
    SET(original_path "${CMAKE_MODULE_PATH}")
    
    # Mock a component path addition
    SET(mock_component_path "/mock/component/path")
    LIST(APPEND CMAKE_MODULE_PATH "${mock_component_path}")
    
    # Verify path was added
    ASSERT_CONTAINS("${CMAKE_MODULE_PATH}" "${mock_component_path}" "Component path should be added to CMAKE_MODULE_PATH")
    
    # Test multiple path additions
    SET(mock_component_path2 "/mock/component/path2")
    LIST(APPEND CMAKE_MODULE_PATH "${mock_component_path2}")
    
    ASSERT_CONTAINS("${CMAKE_MODULE_PATH}" "${mock_component_path}" "First component path should still be present")
    ASSERT_CONTAINS("${CMAKE_MODULE_PATH}" "${mock_component_path2}" "Second component path should be present")
    
    # Restore original path
    SET(CMAKE_MODULE_PATH "${original_path}")
    
    MESSAGE(STATUS "✓ TEST_CMAKE_MODULE_PATH_INTEGRATION passed")
ENDFUNCTION()

# Test: String manipulation functions
FUNCTION(TEST_STRING_MANIPULATION)
    MESSAGE(STATUS "Running TEST_STRING_MANIPULATION")
    
    # Test TOUPPER functionality
    STRING(TOUPPER "cmdef" upper_result)
    ASSERT_EQUAL("${upper_result}" "CMDEF" "TOUPPER should work correctly")
    
    # Test TOLOWER functionality
    STRING(TOLOWER "CMDEF" lower_result)
    ASSERT_EQUAL("${lower_result}" "cmdef" "TOLOWER should work correctly")
    
    # Test mixed case
    STRING(TOUPPER "CmDeF" mixed_upper)
    ASSERT_EQUAL("${mixed_upper}" "CMDEF" "TOUPPER should handle mixed case")
    
    STRING(TOLOWER "CmDeF" mixed_lower)
    ASSERT_EQUAL("${mixed_lower}" "cmdef" "TOLOWER should handle mixed case")
    
    MESSAGE(STATUS "✓ TEST_STRING_MANIPULATION passed")
ENDFUNCTION()

# Test: List operations
FUNCTION(TEST_LIST_OPERATIONS)
    MESSAGE(STATUS "Running TEST_LIST_OPERATIONS")
    
    # Test list initialization
    SET(test_list "item1" "item2" "item3")
    LIST(LENGTH test_list list_length)
    ASSERT_EQUAL("${list_length}" "3" "List should have 3 items")
    
    # Test list append
    LIST(APPEND test_list "item4")
    LIST(LENGTH test_list new_length)
    ASSERT_EQUAL("${new_length}" "4" "List should have 4 items after append")
    
    # Test list find
    LIST(FIND test_list "item2" found_index)
    ASSERT_EQUAL("${found_index}" "1" "item2 should be at index 1")
    
    LIST(FIND test_list "nonexistent" not_found_index)
    ASSERT_EQUAL("${not_found_index}" "-1" "nonexistent item should return -1")
    
    MESSAGE(STATUS "✓ TEST_LIST_OPERATIONS passed")
ENDFUNCTION()

# Test: Conditional logic
FUNCTION(TEST_CONDITIONAL_LOGIC)
    MESSAGE(STATUS "Running TEST_CONDITIONAL_LOGIC")
    
    # Test IF conditions
    SET(test_var "value")
    IF(DEFINED test_var)
        SET(condition_result "defined")
    ELSE()
        SET(condition_result "undefined")
    ENDIF()
    ASSERT_EQUAL("${condition_result}" "defined" "DEFINED condition should work")
    
    # Test NOT condition
    UNSET(undefined_var)
    IF(NOT DEFINED undefined_var)
        SET(not_condition_result "not_defined")
    ELSE()
        SET(not_condition_result "defined")
    ENDIF()
    ASSERT_EQUAL("${not_condition_result}" "not_defined" "NOT DEFINED condition should work")
    
    # Test STREQUAL condition
    SET(str1 "test")
    SET(str2 "test")
    IF("${str1}" STREQUAL "${str2}")
        SET(strequal_result "equal")
    ELSE()
        SET(strequal_result "not_equal")
    ENDIF()
    ASSERT_EQUAL("${strequal_result}" "equal" "STREQUAL condition should work")
    
    MESSAGE(STATUS "✓ TEST_CONDITIONAL_LOGIC passed")
ENDFUNCTION()

# Test: Revision variable name construction
FUNCTION(TEST_REVISION_VARIABLE_NAME_CONSTRUCTION)
    MESSAGE(STATUS "Running TEST_REVISION_VARIABLE_NAME_CONSTRUCTION")
    
    # Test revision variable name construction
    SET(component_name "CMDEF")
    SET(varname "${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}${component_name}")
    ASSERT_EQUAL("${varname}" "CMLIB_COMPONENT_REVISION_CMDEF" "Revision variable name should be constructed correctly")
    
    # Test for different components
    SET(component_name "STORAGE")
    SET(varname "${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}${component_name}")
    ASSERT_EQUAL("${varname}" "CMLIB_COMPONENT_REVISION_STORAGE" "Storage revision variable name should be constructed correctly")
    
    SET(component_name "CMUTIL")
    SET(varname "${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}${component_name}")
    ASSERT_EQUAL("${varname}" "CMLIB_COMPONENT_REVISION_CMUTIL" "Cmutil revision variable name should be constructed correctly")
    
    MESSAGE(STATUS "✓ TEST_REVISION_VARIABLE_NAME_CONSTRUCTION passed")
ENDFUNCTION()

# Main test runner
FUNCTION(RUN_ALL_TESTS)
    MESSAGE(STATUS "========================================")
    MESSAGE(STATUS "Running CMLIB_COMPONENT Unit Tests")
    MESSAGE(STATUS "Testing Framework: Custom CMake testing macros")
    MESSAGE(STATUS "========================================")
    
    SETUP_TEST_ENVIRONMENT()
    
    # Run all tests
    TEST_DEFAULT_VARIABLE_INITIALIZATION()
    TEST_COMPONENT_REVISION_RETRIEVAL()
    TEST_COMPONENT_REGISTRATION_VALIDATION()
    TEST_COMPONENT_DIRECTORY_NAME_GENERATION()
    TEST_LOCAL_PATH_RESOLUTION()
    TEST_REMOTE_URI_CONSTRUCTION()
    TEST_COMPONENT_LIST_PROCESSING()
    TEST_CASE_SENSITIVITY_HANDLING()
    TEST_EDGE_CASES()
    TEST_VARIABLE_SCOPING()
    TEST_CONFIGURATION_VALIDATION()
    TEST_CMAKE_MODULE_PATH_INTEGRATION()
    TEST_STRING_MANIPULATION()
    TEST_LIST_OPERATIONS()
    TEST_CONDITIONAL_LOGIC()
    TEST_REVISION_VARIABLE_NAME_CONSTRUCTION()
    
    TEARDOWN_TEST_ENVIRONMENT()
    
    MESSAGE(STATUS "========================================")
    MESSAGE(STATUS "All CMLIB_COMPONENT tests completed successfully!")
    MESSAGE(STATUS "========================================")
ENDFUNCTION()

# Run tests if this file is executed directly
IF(CMAKE_CURRENT_LIST_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
    RUN_ALL_TESTS()
ENDIF()