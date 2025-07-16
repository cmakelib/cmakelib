# CMLIB_COMPONENT Test Suite

This directory contains comprehensive unit and integration tests for the CMLIB_COMPONENT system, following the project's existing testing patterns and conventions.

## Testing Framework

The tests use **custom CMake testing macros** that are consistent with the project's existing test infrastructure. The assertion functions provide clear, descriptive error messages:

- `ASSERT_EQUAL(actual, expected, message)` - Assert two values are equal
- `ASSERT_TRUE(condition, message)` - Assert condition is true
- `ASSERT_FALSE(condition, message)` - Assert condition is false
- `ASSERT_DEFINED(variable, message)` - Assert variable is defined
- `ASSERT_NOT_DEFINED(variable, message)` - Assert variable is not defined
- `ASSERT_CONTAINS(haystack, needle, message)` - Assert string contains substring
- `ASSERT_LIST_CONTAINS(list_var, value, message)` - Assert list contains value

## Test Files

### test_CMLIB_COMPONENT.cmake
**Unit tests** covering all core functionality:
- Default variable initialization and validation
- Component revision retrieval and validation
- Component registration and case-insensitive matching
- Directory name generation for different components
- Local path resolution with CMLIB_COMPONENT_LOCAL_BASE_PATH
- Remote URI construction with CMLIB_REQUIRED_ENV_REMOTE_URL
- Component list processing and validation
- Case sensitivity handling across all functions
- Edge cases and boundary conditions
- Variable scoping and isolation
- Configuration validation for cache variables
- CMAKE_MODULE_PATH integration
- String manipulation functions
- List operations and management
- Conditional logic validation
- Revision variable name construction

### test_CMLIB_COMPONENT_integration.cmake
**Integration tests** covering system-level behavior:
- Full component loading workflow simulation
- Component dependency resolution in different orders
- Error handling workflow for invalid components
- Environment variable handling (local vs remote)
- Multiple component processing simultaneously
- Module path management and preservation

## Running Tests

### Method 1: Complete test suite
```bash
cd tests/CMLIB_COMPONENT_test
cmake -P run_tests.cmake
```

### Method 2: Individual test files
```bash
# Unit tests only
cmake -P test_CMLIB_COMPONENT.cmake

# Integration tests only
cmake -P test_CMLIB_COMPONENT_integration.cmake
```

### Method 3: Using CTest (if available)
```bash
cd tests/CMLIB_COMPONENT_test
cmake .
ctest -V
```

### Method 4: Using Make target
```bash
cd tests/CMLIB_COMPONENT_test
cmake .
make run_all_tests
```

## Test Coverage

The test suite provides comprehensive coverage of:

### 1. **Happy Path Scenarios**
- Normal component loading and initialization
- Successful revision retrieval for all components
- Proper path resolution in both local and remote modes
- CMAKE_MODULE_PATH integration

### 2. **Edge Cases**
- Empty component lists
- Single component processing
- Very long component names
- Special characters in component names
- Case sensitivity across all operations
- Mixed case component names

### 3. **Error Conditions**
- Unregistered component handling
- Invalid component names
- Missing revision variables
- Malformed configuration

### 4. **Integration Scenarios**
- Multi-component processing
- Order-independent component resolution
- Environment variable state management
- Module path preservation and cleanup

### 5. **System Validation**
- Variable scoping and isolation
- Configuration consistency
- Cache variable properties
- String manipulation correctness
- List operation accuracy

## Test Environment

Tests use **isolated environments** with:
- Saved and restored original variable states
- Mock component directories and files
- Temporary file structures for integration tests
- Controlled environment variables
- Proper cleanup after each test run

## Design Principles

The tests follow these principles:
- **Isolation**: Each test is independent and doesn't affect others
- **Clarity**: Descriptive test names and comprehensive error messages
- **Coverage**: Both positive and negative test cases
- **Maintainability**: Clear structure and documentation
- **Consistency**: Following project conventions and patterns

## Extending Tests

To add new tests:

1. **Create test function** following the naming pattern `TEST_*`
2. **Use assertion macros** for validation
3. **Include proper setup/teardown** if needed
4. **Add to the runner function** (RUN_ALL_TESTS or RUN_INTEGRATION_TESTS)
5. **Update documentation** with test description
6. **Follow existing patterns** for consistency

## Dependencies

The tests require:
- CMake 3.10 or higher
- The CMLIB_COMPONENT.cmake file being tested
- Standard CMake modules (no external dependencies)

## Troubleshooting

Common issues and solutions:
- **Path not found**: Ensure CMAKE_CURRENT_SOURCE_DIR is set correctly
- **Assertion failures**: Check test output for detailed error messages
- **File not found**: Verify the component file path is correct
- **Variable not defined**: Check if required variables are initialized