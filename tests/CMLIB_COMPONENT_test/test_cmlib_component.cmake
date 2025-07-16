# Unit tests for CMLIB_COMPONENT module
# Testing framework: CMake CTest with custom test macros (following project patterns)

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

# Include the module under test
SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
INCLUDE(CMLIB_COMPONENT)

# Test result tracking
SET(TESTS_PASSED 0)
SET(TESTS_FAILED 0)
SET(TESTS_TOTAL 0)

# Test assertion macros following project patterns
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
        MESSAGE(STATUS "  Condition was false: ${condition}")
        MATH(EXPR TESTS_FAILED "${TESTS_FAILED} + 1")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_FALSE condition test_name)
    MATH(EXPR TESTS_TOTAL "${TESTS_TOTAL} + 1")
    IF(NOT ${condition})
        MESSAGE(STATUS "PASS: ${test_name}")
        MATH(EXPR TESTS_PASSED "${TESTS_PASSED} + 1")
    ELSE()
        MESSAGE(STATUS "FAIL: ${test_name}")
        MESSAGE(STATUS "  Condition was true: ${condition}")
        MATH(EXPR TESTS_FAILED "${TESTS_FAILED} + 1")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_DEFINED variable test_name)
    MATH(EXPR TESTS_TOTAL "${TESTS_TOTAL} + 1")
    IF(DEFINED ${variable})
        MESSAGE(STATUS "PASS: ${test_name}")
        MATH(EXPR TESTS_PASSED "${TESTS_PASSED} + 1")
    ELSE()
        MESSAGE(STATUS "FAIL: ${test_name}")
        MESSAGE(STATUS "  Variable not defined: ${variable}")
        MATH(EXPR TESTS_FAILED "${TESTS_FAILED} + 1")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_NOT_DEFINED variable test_name)
    MATH(EXPR TESTS_TOTAL "${TESTS_TOTAL} + 1")
    IF(NOT DEFINED ${variable})
        MESSAGE(STATUS "PASS: ${test_name}")
        MATH(EXPR TESTS_PASSED "${TESTS_PASSED} + 1")
    ELSE()
        MESSAGE(STATUS "FAIL: ${test_name}")
        MESSAGE(STATUS "  Variable unexpectedly defined: ${variable}")
        MATH(EXPR TESTS_FAILED "${TESTS_FAILED} + 1")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_LIST_CONTAINS list_var item test_name)
    MATH(EXPR TESTS_TOTAL "${TESTS_TOTAL} + 1")
    LIST(FIND ${list_var} "${item}" found_index)
    IF(found_index GREATER_EQUAL 0)
        MESSAGE(STATUS "PASS: ${test_name}")
        MATH(EXPR TESTS_PASSED "${TESTS_PASSED} + 1")
    ELSE()
        MESSAGE(STATUS "FAIL: ${test_name}")
        MESSAGE(STATUS "  Item '${item}' not found in list")
        MATH(EXPR TESTS_FAILED "${TESTS_FAILED} + 1")
    ENDIF()
ENDMACRO()

MACRO(ASSERT_LIST_NOT_CONTAINS list_var item test_name)
    MATH(EXPR TESTS_TOTAL "${TESTS_TOTAL} + 1")
    LIST(FIND ${list_var} "${item}" found_index)
    IF(found_index EQUAL -1)
        MESSAGE(STATUS "PASS: ${test_name}")
        MATH(EXPR TESTS_PASSED "${TESTS_PASSED} + 1")
    ELSE()
        MESSAGE(STATUS "FAIL: ${test_name}")
        MESSAGE(STATUS "  Item '${item}' unexpectedly found in list")
        MATH(EXPR TESTS_FAILED "${TESTS_FAILED} + 1")
    ENDIF()
ENDMACRO()

MESSAGE(STATUS "=== Starting CMLIB_COMPONENT Unit Tests ===")

# Test 1: Verify initial configuration variables are set correctly
FUNCTION(TEST_INITIAL_CONFIGURATION)
    MESSAGE(STATUS "Testing initial configuration...")
    
    ASSERT_DEFINED(_CMLIB_COMPONENT_REPO_NAME_PREFIX "Config: _CMLIB_COMPONENT_REPO_NAME_PREFIX defined")
    ASSERT_EQUAL("cmakelib-component-" "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}" "Config: Repo name prefix value")
    
    ASSERT_DEFINED(_CMLIB_COMPONENT_AVAILABLE_LIST "Config: _CMLIB_COMPONENT_AVAILABLE_LIST defined")
    LIST(LENGTH _CMLIB_COMPONENT_AVAILABLE_LIST available_count)
    ASSERT_TRUE("${available_count}" GREATER 0 "Config: Available list not empty")
    
    ASSERT_DEFINED(_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX "Config: Revision variable prefix defined")
    ASSERT_EQUAL("CMLIB_COMPONENT_REVISION_" "${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}" "Config: Revision prefix value")
    
    # Test that CMLIB_COMPONENT_LOCAL_BASE_PATH is properly initialized
    ASSERT_DEFINED(CMLIB_COMPONENT_LOCAL_BASE_PATH "Config: Local base path variable defined")
ENDFUNCTION()
TEST_INITIAL_CONFIGURATION()

# Test 2: Verify default revision variables are set
FUNCTION(TEST_DEFAULT_REVISIONS)
    MESSAGE(STATUS "Testing default revision variables...")
    
    ASSERT_DEFINED(CMLIB_COMPONENT_REVISION_CMDEF "Revisions: CMDEF revision defined")
    ASSERT_EQUAL("v1.0.0" "${CMLIB_COMPONENT_REVISION_CMDEF}" "Revisions: CMDEF revision value")
    
    ASSERT_DEFINED(CMLIB_COMPONENT_REVISION_STORAGE "Revisions: STORAGE revision defined")
    ASSERT_EQUAL("v1.0.0" "${CMLIB_COMPONENT_REVISION_STORAGE}" "Revisions: STORAGE revision value")
    
    ASSERT_DEFINED(CMLIB_COMPONENT_REVISION_CMUTIL "Revisions: CMUTIL revision defined")
    ASSERT_EQUAL("v1.1.0" "${CMLIB_COMPONENT_REVISION_CMUTIL}" "Revisions: CMUTIL revision value")
ENDFUNCTION()
TEST_DEFAULT_REVISIONS()

# Test 3: Test _CMLIB_COMPONENT_GET_REVISION function - Happy path
FUNCTION(TEST_GET_REVISION_HAPPY_PATH)
    MESSAGE(STATUS "Testing _CMLIB_COMPONENT_GET_REVISION happy path...")
    
    _CMLIB_COMPONENT_GET_REVISION(output_revision "CMDEF")
    ASSERT_EQUAL("v1.0.0" "${output_revision}" "GET_REVISION: CMDEF returns correct revision")
    
    _CMLIB_COMPONENT_GET_REVISION(output_revision "STORAGE")
    ASSERT_EQUAL("v1.0.0" "${output_revision}" "GET_REVISION: STORAGE returns correct revision")
    
    _CMLIB_COMPONENT_GET_REVISION(output_revision "CMUTIL")
    ASSERT_EQUAL("v1.1.0" "${output_revision}" "GET_REVISION: CMUTIL returns correct revision")
ENDFUNCTION()
TEST_GET_REVISION_HAPPY_PATH()

# Test 4: Test component availability checking logic
FUNCTION(TEST_COMPONENT_AVAILABILITY)
    MESSAGE(STATUS "Testing component availability...")
    
    # Test that all predefined components are in the available list
    ASSERT_LIST_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "cmdef" "Availability: cmdef found in available list")
    ASSERT_LIST_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "storage" "Availability: storage found in available list")
    ASSERT_LIST_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "cmutil" "Availability: cmutil found in available list")
    
    # Test that non-existent components are not in the list
    ASSERT_LIST_NOT_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "nonexistent" "Availability: nonexistent not in list")
    ASSERT_LIST_NOT_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "invalid-component" "Availability: invalid-component not in list")
ENDFUNCTION()
TEST_COMPONENT_AVAILABILITY()

# Test 5: Test component directory name generation
FUNCTION(TEST_COMPONENT_DIR_NAME_GENERATION)
    MESSAGE(STATUS "Testing component directory name generation...")
    
    # Test lowercase conversion and prefix addition
    SET(test_component "CMDEF")
    STRING(TOLOWER "${test_component}" component_lower)
    SET(expected_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower}")
    ASSERT_EQUAL("cmakelib-component-cmdef" "${expected_dir_name}" "Dir name: CMDEF to lowercase")
    
    SET(test_component "Storage")
    STRING(TOLOWER "${test_component}" component_lower)
    SET(expected_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower}")
    ASSERT_EQUAL("cmakelib-component-storage" "${expected_dir_name}" "Dir name: Storage mixed case")
    
    SET(test_component "cmutil")
    STRING(TOLOWER "${test_component}" component_lower)
    SET(expected_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower}")
    ASSERT_EQUAL("cmakelib-component-cmutil" "${expected_dir_name}" "Dir name: cmutil already lowercase")
ENDFUNCTION()
TEST_COMPONENT_DIR_NAME_GENERATION()

# Test 6: Test CMLIB_COMPONENT_LOCAL_BASE_PATH behavior
FUNCTION(TEST_LOCAL_BASE_PATH)
    MESSAGE(STATUS "Testing local base path behavior...")
    
    # Save original value
    SET(original_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}")
    
    # Test with empty/unset local base path
    UNSET(CMLIB_COMPONENT_LOCAL_BASE_PATH)
    ASSERT_FALSE(CMLIB_COMPONENT_LOCAL_BASE_PATH "Local path: Unset path evaluates to false")
    
    # Test with set local base path
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "/tmp/test/components")
    ASSERT_TRUE(CMLIB_COMPONENT_LOCAL_BASE_PATH "Local path: Set path evaluates to true")
    ASSERT_EQUAL("/tmp/test/components" "${CMLIB_COMPONENT_LOCAL_BASE_PATH}" "Local path: Correct value")
    
    # Test path construction with local base path
    SET(component_lower "cmdef")
    SET(component_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower}")
    SET(expected_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}/${component_dir_name}")
    ASSERT_EQUAL("/tmp/test/components/cmakelib-component-cmdef" "${expected_path}" "Local path: Path construction")
    
    # Restore original value
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "${original_path}")
ENDFUNCTION()
TEST_LOCAL_BASE_PATH()

# Test 7: Test string manipulation functions
FUNCTION(TEST_STRING_MANIPULATION)
    MESSAGE(STATUS "Testing string manipulation functions...")
    
    # Test TOUPPER
    SET(test_string "cmdef")
    STRING(TOUPPER "${test_string}" upper_string)
    ASSERT_EQUAL("CMDEF" "${upper_string}" "String: TOUPPER conversion")
    
    # Test TOLOWER
    SET(test_string "STORAGE")
    STRING(TOLOWER "${test_string}" lower_string)
    ASSERT_EQUAL("storage" "${lower_string}" "String: TOLOWER conversion")
    
    # Test mixed case
    SET(test_string "CmUtil")
    STRING(TOUPPER "${test_string}" upper_string)
    STRING(TOLOWER "${test_string}" lower_string)
    ASSERT_EQUAL("CMUTIL" "${upper_string}" "String: Mixed case TOUPPER")
    ASSERT_EQUAL("cmutil" "${lower_string}" "String: Mixed case TOLOWER")
ENDFUNCTION()
TEST_STRING_MANIPULATION()

# Test 8: Test revision variable name construction
FUNCTION(TEST_REVISION_VARIABLE_NAME_CONSTRUCTION)
    MESSAGE(STATUS "Testing revision variable name construction...")
    
    SET(component_upper "CMDEF")
    SET(expected_varname "${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}${component_upper}")
    ASSERT_EQUAL("CMLIB_COMPONENT_REVISION_CMDEF" "${expected_varname}" "Revision varname: CMDEF construction")
    
    SET(component_upper "STORAGE")
    SET(expected_varname "${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}${component_upper}")
    ASSERT_EQUAL("CMLIB_COMPONENT_REVISION_STORAGE" "${expected_varname}" "Revision varname: STORAGE construction")
    
    SET(component_upper "CMUTIL")
    SET(expected_varname "${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}${component_upper}")
    ASSERT_EQUAL("CMLIB_COMPONENT_REVISION_CMUTIL" "${expected_varname}" "Revision varname: CMUTIL construction")
ENDFUNCTION()
TEST_REVISION_VARIABLE_NAME_CONSTRUCTION()

# Test 9: Test component registration checking logic
FUNCTION(TEST_COMPONENT_REGISTRATION_LOGIC)
    MESSAGE(STATUS "Testing component registration logic...")
    
    # Test valid components
    SET(test_component "cmdef")
    SET(component_registered OFF)
    FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
        STRING(TOLOWER "${avail_component}" avail_component_lower)
        IF("${test_component}" STREQUAL "${avail_component_lower}")
            SET(component_registered ON)
            BREAK()
        ENDIF()
    ENDFOREACH()
    ASSERT_TRUE(component_registered "Registration: cmdef is registered")
    
    # Test case insensitive matching
    SET(test_component "STORAGE")
    STRING(TOLOWER "${test_component}" component_lower)
    SET(component_registered OFF)
    FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
        STRING(TOLOWER "${avail_component}" avail_component_lower)
        IF("${component_lower}" STREQUAL "${avail_component_lower}")
            SET(component_registered ON)
            BREAK()
        ENDIF()
    ENDFOREACH()
    ASSERT_TRUE(component_registered "Registration: STORAGE case insensitive")
    
    # Test invalid component
    SET(test_component "invalidcomponent")
    SET(component_registered OFF)
    FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
        STRING(TOLOWER "${avail_component}" avail_component_lower)
        IF("${test_component}" STREQUAL "${avail_component_lower}")
            SET(component_registered ON)
            BREAK()
        ENDIF()
    ENDFOREACH()
    ASSERT_FALSE(component_registered "Registration: invalid component not registered")
ENDFUNCTION()
TEST_COMPONENT_REGISTRATION_LOGIC()

# Test 10: Test edge cases for empty and malformed inputs
FUNCTION(TEST_EDGE_CASES)
    MESSAGE(STATUS "Testing edge cases...")
    
    # Test empty string handling
    SET(empty_string "")
    STRING(TOLOWER "${empty_string}" empty_lower)
    ASSERT_EQUAL("" "${empty_lower}" "Edge case: Empty string TOLOWER")
    
    # Test whitespace handling
    SET(whitespace_string "  cmdef  ")
    STRING(STRIP "${whitespace_string}" stripped_string)
    ASSERT_EQUAL("cmdef" "${stripped_string}" "Edge case: Whitespace stripping")
    
    # Test special characters in component names (should not be valid)
    SET(special_chars "cm-def")
    ASSERT_LIST_NOT_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "${special_chars}" "Edge case: Special chars not in available list")
    
    # Test numbers in component names
    SET(numeric_component "cmdef123")
    ASSERT_LIST_NOT_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "${numeric_component}" "Edge case: Numeric suffix not in available list")
ENDFUNCTION()
TEST_EDGE_CASES()

# Test 11: Test list operations
FUNCTION(TEST_LIST_OPERATIONS)
    MESSAGE(STATUS "Testing list operations...")
    
    # Test list length
    LIST(LENGTH _CMLIB_COMPONENT_AVAILABLE_LIST list_length)
    ASSERT_EQUAL("3" "${list_length}" "List ops: Available list length")
    
    # Test list contains all expected components
    SET(expected_components "cmdef" "storage" "cmutil")
    FOREACH(expected_comp IN LISTS expected_components)
        ASSERT_LIST_CONTAINS(_CMLIB_COMPONENT_AVAILABLE_LIST "${expected_comp}" "List ops: Expected component ${expected_comp} found")
    ENDFOREACH()
    
    # Test list append behavior
    SET(test_list "item1" "item2")
    LIST(APPEND test_list "item3")
    LIST(LENGTH test_list new_length)
    ASSERT_EQUAL("3" "${new_length}" "List ops: Append increases length")
    
    # Test list find behavior
    LIST(FIND test_list "item2" found_index)
    ASSERT_EQUAL("1" "${found_index}" "List ops: Find returns correct index")
    
    LIST(FIND test_list "nonexistent" not_found_index)
    ASSERT_EQUAL("-1" "${not_found_index}" "List ops: Find returns -1 for missing item")
ENDFUNCTION()
TEST_LIST_OPERATIONS()

# Test 12: Test cache variable behavior
FUNCTION(TEST_CACHE_VARIABLES)
    MESSAGE(STATUS "Testing cache variables...")
    
    # Test that cache variables are properly set with correct types
    GET_PROPERTY(local_base_path_type CACHE CMLIB_COMPONENT_LOCAL_BASE_PATH PROPERTY TYPE)
    ASSERT_EQUAL("PATH" "${local_base_path_type}" "Cache: Local base path type")
    
    GET_PROPERTY(prefix_type CACHE _CMLIB_COMPONENT_REPO_NAME_PREFIX PROPERTY TYPE)
    ASSERT_EQUAL("INTERNAL" "${prefix_type}" "Cache: Repo name prefix type")
    
    GET_PROPERTY(available_list_type CACHE _CMLIB_COMPONENT_AVAILABLE_LIST PROPERTY TYPE)
    ASSERT_EQUAL("INTERNAL" "${available_list_type}" "Cache: Available list type")
    
    GET_PROPERTY(revision_prefix_type CACHE _CMLIB_COMPONENT_REVISION_VARANAME_PREFIX PROPERTY TYPE)
    ASSERT_EQUAL("INTERNAL" "${revision_prefix_type}" "Cache: Revision prefix type")
    
    # Test revision variables have correct type
    GET_PROPERTY(cmdef_revision_type CACHE CMLIB_COMPONENT_REVISION_CMDEF PROPERTY TYPE)
    ASSERT_EQUAL("STRING" "${cmdef_revision_type}" "Cache: CMDEF revision type")
ENDFUNCTION()
TEST_CACHE_VARIABLES()

# Test 13: Test version string validation
FUNCTION(TEST_VERSION_STRING_VALIDATION)
    MESSAGE(STATUS "Testing version string validation...")
    
    # Test valid version strings
    SET(valid_versions "v1.0.0" "v1.1.0" "v2.0.0-alpha" "v1.0.0-beta.1")
    FOREACH(version IN LISTS valid_versions)
        STRING(REGEX MATCH "^v[0-9]+\\.[0-9]+\\.[0-9]+" valid_match "${version}")
        ASSERT_TRUE(valid_match "Version: ${version} matches pattern")
    ENDFOREACH()
    
    # Test that existing revision variables follow version pattern
    STRING(REGEX MATCH "^v[0-9]+\\.[0-9]+\\.[0-9]+" cmdef_match "${CMLIB_COMPONENT_REVISION_CMDEF}")
    ASSERT_TRUE(cmdef_match "Version: CMDEF revision follows pattern")
    
    STRING(REGEX MATCH "^v[0-9]+\\.[0-9]+\\.[0-9]+" storage_match "${CMLIB_COMPONENT_REVISION_STORAGE}")
    ASSERT_TRUE(storage_match "Version: STORAGE revision follows pattern")
    
    STRING(REGEX MATCH "^v[0-9]+\\.[0-9]+\\.[0-9]+" cmutil_match "${CMLIB_COMPONENT_REVISION_CMUTIL}")
    ASSERT_TRUE(cmutil_match "Version: CMUTIL revision follows pattern")
ENDFUNCTION()
TEST_VERSION_STRING_VALIDATION()

# Test 14: Test URI construction logic
FUNCTION(TEST_URI_CONSTRUCTION)
    MESSAGE(STATUS "Testing URI construction logic...")
    
    # Mock CMLIB_REQUIRED_ENV_REMOTE_URL for testing
    SET(CMLIB_REQUIRED_ENV_REMOTE_URL "https://example.com/repo")
    
    # Test URI construction for different components
    SET(components "cmdef" "storage" "cmutil")
    FOREACH(component IN LISTS components)
        SET(component_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component}")
        SET(expected_uri "${CMLIB_REQUIRED_ENV_REMOTE_URL}/${component_dir_name}")
        
        # Expected URIs
        IF("${component}" STREQUAL "cmdef")
            ASSERT_EQUAL("https://example.com/repo/cmakelib-component-cmdef" "${expected_uri}" "URI: CMDEF construction")
        ELSEIF("${component}" STREQUAL "storage")
            ASSERT_EQUAL("https://example.com/repo/cmakelib-component-storage" "${expected_uri}" "URI: STORAGE construction")
        ELSEIF("${component}" STREQUAL "cmutil")
            ASSERT_EQUAL("https://example.com/repo/cmakelib-component-cmutil" "${expected_uri}" "URI: CMUTIL construction")
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()
TEST_URI_CONSTRUCTION()

# Test 15: Test path manipulation edge cases
FUNCTION(TEST_PATH_MANIPULATION)
    MESSAGE(STATUS "Testing path manipulation...")
    
    # Test path separator handling
    SET(test_base_path "/tmp/test/components")
    SET(component_dir "cmakelib-component-cmdef")
    SET(expected_path "${test_base_path}/${component_dir}")
    ASSERT_EQUAL("/tmp/test/components/cmakelib-component-cmdef" "${expected_path}" "Path: Forward slash separator")
    
    # Test trailing slash handling
    SET(test_base_path_with_slash "/tmp/test/components/")
    SET(path_with_slash "${test_base_path_with_slash}${component_dir}")
    ASSERT_EQUAL("/tmp/test/components/cmakelib-component-cmdef" "${path_with_slash}" "Path: Trailing slash handling")
    
    # Test relative paths
    SET(relative_base "components")
    SET(relative_path "${relative_base}/${component_dir}")
    ASSERT_EQUAL("components/cmakelib-component-cmdef" "${relative_path}" "Path: Relative path construction")
ENDFUNCTION()
TEST_PATH_MANIPULATION()

# Test Summary
MESSAGE(STATUS "=== Test Summary ===")
MESSAGE(STATUS "Tests Passed: ${TESTS_PASSED}")
MESSAGE(STATUS "Tests Failed: ${TESTS_FAILED}")
MESSAGE(STATUS "Tests Total: ${TESTS_TOTAL}")

IF(TESTS_FAILED GREATER 0)
    MESSAGE(FATAL_ERROR "Some tests failed!")
ELSE()
    MESSAGE(STATUS "All tests passed!")
ENDIF()