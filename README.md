
# CMLIB Library

[buildbadge_github]

[buildbadge_travisci]

Dependency trackikg library for CMake - completly written in CMake.

CMLIB Library is dependency tracking library which allows
user-programmer effectively track all needed dependencies.

## Common

Library consist from two main parts

- **cmake-lib - dependency tracking (this repository)**
Contains component called "DEFAULTS" which reset CMake build env setting...
- cmakelib components - Components represents optional functionality which can be
managed by `cmakelib`. Each component has own git repository in form `cmakelib-component-<component_name>`

## Usage

- `git clone https://github.com/cmakelib/cmakelib.git`

```
	LIST(APPEND CMAKE_MODULE_PATH <path_to_cmakelib_repo>)
	FIND_PACKAGE(CMLIB REQUIRED)
	CMLIB_DEPENDENCY(
		URI "https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.bz2"
		TYPE ARCHIVE
		OUTPUT_PATH_VAR boost_source_path
	)
	IF(NOT DEFINED boost_source_path)
		MESSAGE(FATAL_ERROR "Cannot download Boost!")
	ENDIF()
	MESSAGE(STATUS "Boost downloaded to '${boost_source_path}'")
```

### API

The library core is function

	CMLIB_DEPENDENCY

Which can track/cache various number of dependencies.

Modules does not contain anything except what we need for `CMLIB_DEPENDENCY` implementation.

Library consist from several modules

- **[CMLIB_DEPENDENCY] - track and cache remote dependencies** (under remote dependency we assume dependency
which is not 'directly' attached to the user CMake project)
- [CMLIB_REQUIRED_ENV] which init base environment for library needs
- [CMLIB_CACHE] - cache files on host filesystem (represent persisten cache)
- [CMLIB_FILE_DOWNLOAD] - download file from remote HTTP URl or GIT repository
- [CMLIB_PARSE_ARGUMENTS] - wrapper around cmake_parse_arguments
- [CMLIB_ARCHIVE] - extract files from archive
- [CMLIB_COMPONENT] - component logic

Detailed documentation can be found in each module.

There are examples for each modules in [example] directory.

## Installation

### Prerequisites

- CMake >=3.16 installed and registered in PATH env. variable
- 7Zip installed and bin/ directory of 7zip registered in PATH env. variable
    - Without 7Zip cmakelib `ARCHIVE` functionality will not work - no arcives can be tracked
	by cmakelib
- Git installed and bin/ directory of git registered in PATH env. variable

### Library install

It's intended that the user has only one instance of library but it's possible use `cmakelib`
as submodule.

#### Global install

Library is stored on User computer and the global CMake variable `CMLIB_DIR`
must be defined.

- Choose directory where cmakelib will be stored. We will call this directory
<bimcm_root>
- Clone repository to local computer to <bimcm_root>
- Define System ENV var `CMLIB_DIR` as absolute path to already cloned repository
- Define System ENV var `CMLIB_REQUIRED_ENV_TMP_PATH` to path to existing directory. This variable represents
Cache directory where the cache will be stored
- Restart computer (due to System ENV vars) and in given CMakeLists.txt
call `FIND_PACKAGE(CMLIB [COMPONENTS STORAGE])`
- Everything should works fine now

Examples for `CMLIB_DEPENDENCY` can be found at [example/DEPENDENCY]



## Update

Just call "git pull" on repository root.

In case of cmake-generation problem reset cache.

## Reset cache

If the `CMLIB_REQUIRED_ENV_TMP_PATH` is set then the cache will be stored
in the directory specified by `CMLIB_REQUIRED_ENV_TMP_PATH`.

If the cache reset is needed, just delete directory which path is stored
in `CMLIB_REQUIRED_ENV_TMP_PATH` env variable.

### CMake environment settings

All temporary files and outputs are stored in temporary directory

Path to temporary directory is controlled by `CMLIB_REQUIRED_ENV_TMP_PATH`

`CMLIB_REQUIRED_ENV_TMP_PATH` can be overridden be system ENV var named
`CMLIB_REQUIRED_ENV_TMP_PATH`

User define global ENV var to specify one, central cache storage which will be
shared across CMake project instances.

### Best practices

- Each cache entry is represented by ordered set of keywords.
It's common idiom the the first keyword is name of the project in which
the CMLIB_DEPENDENCY/CMLIB_CACHE is written.
- Use CMLIB_DEPENDENCY instead of other CMLIB functions. (use other only if you known what
you are doing)


### Cache mechanism

Cache mechanism is persistent across CMake instances.
If user delete our CMake binary dir the cache will be regenerate
in next CMake run for the same CMakeLists.txt
(we assume that cache is located in dir different from CMake binary dir)

## Coding style

In library we use Uppercase for all CMake keywords.

Local variables can be named as lowercase.

## Tests

For test go to the test/ directory and run

	cmake .

then just clean up all intermediate files by

    git clean -xfd




[CMLIB_REQUIRED_ENV]:    ./system_modules/CMLIB_REQUIRED_ENV.cmake
[CMLIB_CACHE]:           ./system_modules/CMLIB_CACHE.cmake
[CMLIB_FILE_DOWNLOAD]:   ./system_modules/CMLIB_FILE_DOWNLOAD.cmake
[CMLIB_PARSE_ARGUMENTS]: ./system_modules/CMLIB_PARSE_ARGUMENTS.cmake
[CMLIB_ARCHIVE]:         ./system_modules/CMLIB_ARCHIVE.cmake
[CMLIB_DEPENDENCY]:      ./system_modules/CMLIB_DEPENDENCY.cmake
[CMLIB_COMPONENT]:       ./system_modules/CMLIB_COMPONENT.cmake
[example]:               ./example/
[example/DEPENDENCY]:    ./example/DEPENDENCY
[buildbadge_github]:     https://github.com/cmakelib/cmakelib/workflows/Tests/badge.svg

