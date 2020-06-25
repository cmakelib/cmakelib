
# BIMCM Library

Soft and "tiny" CMake library for C/C++.

BIMCM Library is dependency tracking library which allows
user-programmer effectively track all needed dependencies.

## Common

![Scheme]

Library consist from three main parts

- **cmake-lib - dependency tracking (this repository)**
- cmake-lib-storage - storage where the shared data (like URLs) are stored (configured by cmake-lib)
- cmake-lib-basedef - base definitions and wrappers for standard Cmake functionality
Contains component called "DEFAULTS" which reset CMake build env setting...

Each component has own git repository.

### API

The library core is function

	BIMCM_DEPENDENCY

Which can track/cache various number of dependencies.

Modules does not contain anything except what we need for `BIMCM_DEPENDENCY` implementation.

Library consist from several modules

- **[BIMCM_DEPENDENCY] - track and cache remote dependencies** (under remote dependency we assume dependency
which is not 'directly' attached to the user CMake project)
- [BIMCM_REQUIRED_ENV] which init base environment for library needs
- [BIMCM_CACHE] - cache files on host filesystem (represent persisten cache)
- [BIMCM_FILE_DOWNLOAD] - download file from remote HTTP URl or GIT repository
- [BIMCM_PARSE_ARGUMENTS] - wrapper around cmake_parse_arguments
- [BIMCM_ARCHIVE] - extract files from archive
- [BIMCM_STORAGE] - initialize [BIMCM_STORAGE], controlled by  STORAGE component (specified as component in FIND_PACKAGE).
Can be overriden by BIMCM_USE_STORAGE env variable.

Detailed documentation can be found in each module.

There are examples for each modules in [example] directory.

## Installation

### Prerequisites

- CMake >=3.16 installed and registered in PATH env. variable
- 7Zip installed and bin/ directory of 7zip registered in PATH env. variable
- Git installed and bin/ directory of git registered in PATH env. variable

### Library install

It's intended that the user has only one instance of library.

Library is stored on User computer and the global CMake variable `BIMCM_DIR`
must be defined.

- Choose directory where cmakelib will be stored. We will call this directory
<bimcm_root>
- Clone repository to local computer to <bimcm_root>
- Define System ENV var `BIMCM_DIR` as absolute path to already cloned repository
- Define System ENV var `BIMCM_REQUIRED_ENV_TMP_PATH` to path to existing directory. This variable represents
Cache directory where the cache will be stored
- Restart computer (due to System ENV vars) and in given CMakeLists.txt
call `FIND_PACKAGE(BIMCM [COMPONENTS STORAGE])`
- Everything should works fine now

Examples for `BIMCM_DEPENDENCY` can be found at [example/DEPENDENCY]


## Update

Just call "git pull" on repository root.

In case of cmake-generation problem reset cache.

## Reset cache

If the `BIMCM_REQUIRED_ENV_TMP_PATH` is set then the cache will be stored
in the directory specified by `BIMCM_REQUIRED_ENV_TMP_PATH`.

If the cache reset is needed, just delete directory which path is stored
in `BIMCM_REQUIRED_ENV_TMP_PATH` env variable.

### CMake environment settings

All temporary files and outputs are stored in temporary directory

Path to temporary directory is controlled by `BIMCM_REQUIRED_ENV_TMP_PATH`

`BIMCM_REQUIRED_ENV_TMP_PATH` can be overridden be system ENV var named
`BIMCM_REQUIRED_ENV_TMP_PATH`

User define global ENV var to specify one, central cache storage which will be
shared across CMake project instances.

### Best practices

- Each cache entry is represented by ordered set of keywords.
It's common idiom the the first keyword is name of the project in which
the BIMCM_DEPENDENCY/BIMCM_CACHE is written.
- Use BIMCM_DEPENDENCY instead of other BIMCM functions. (use other only if you known what
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




[BIMCM_REQUIRED_ENV]:    ./system_modules/BIMCM_REQUIRED_ENV.cmake
[BIMCM_CACHE]:           ./system_modules/BIMCM_CACHE.cmake
[BIMCM_FILE_DOWNLOAD]:   ./system_modules/BIMCM_FILE_DOWNLOAD.cmake
[BIMCM_PARSE_ARGUMENTS]: ./system_modules/BIMCM_PARSE_ARGUMENTS.cmake
[BIMCM_ARCHIVE]:         ./system_modules/BIMCM_ARCHIVE.cmake
[BIMCM_DEPENDENCY]:      ./system_modules/BIMCM_DEPENDENCY.cmake
[BIMCM_STORAGE]:         ./system_modules/BIMCM_STORAGE.cmake
[example]:               ./example/
[example/DEPENDENCY]:    ./example/DEPENDENCY
[Scheme]:                ./doc/cmake-lib-img.png


