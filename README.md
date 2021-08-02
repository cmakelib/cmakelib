
# CMLIB Library

Linux: ![buildbadge_github], Windows: ![buildbadge_github], Mac OS: ![buildbadge_github]

Dependency tracking library for CMake - completely written in CMake.

CMLIB Library is dependency tracking library which allows effectively track all
needed dependencies without Worrying about consistency and project regeneration times.

Main features are

- No other dependencies. Only CMake and Git.
- CMake cache regeneration - once the dependency is downloaded
   and cached it's preserved even after build directory deletion
- Dependency cache consistency check – the only dependency
  even if explicit keywords are specified

For examples look at the [example] directory

## Usage

- clone directory by `git clone https://github.com/cmakelib/cmakelib.git <path_to_cmakelib_repo>`
- export CMLIB_DIR=<path_to_cmakelib_repo>

Small example for Ubuntu 20.04

```
FIND_PACKAGE(CMLIB REQUIRED)

CMLIB_DEPENDENCY(
	# We use koudis/boost-prebuilt-binaries
	URI "https://bit.ly/3rQsAXd"
	TYPE ARCHIVE
	OUTPUT_PATH_VAR BOOST_ROOT
)
FIND_PACKAGE(Boost 1.76.0 COMPONENTS log_setup log REQUIRED)
```

Full example can be found at [example/DEPENDENCY/boost_example]

## Installation

### Prerequisites

- CMake >=3.18 installed and registered in PATH env. variable
- Git installed and bin/ directory of git registered in PATH env. variable

### Library install

It is intended that the user has only one global instance of library. However it is possible use `cmakelib`
as submodule but it is not recommanded.

#### Global install

Library is stored on User computer and the global CMake variable `CMLIB_DIR`
must be defined.

- Choose directory where cmakelib will be stored. We will call this directory
<cmlib_root>
- Clone repository to local computer to <cmlib_root>
- Define System ENV var `CMLIB_DIR` as absolute path to already cloned repository
- You may define system ENV var `CMLIB_REQUIRED_ENV_TMP_PATH` to path to existing directory.
  This variable represents Cache directory where the cache will be stored.
  If not set the "${CMAKE_CURRENT_LIST_DIR}/_tmp" is use instead.
- call `FIND_PACKAGE(CMLIB REQUIRED)`
- Everything should works fine now

Examples for `CMLIB_DEPENDENCY` can be found at [example/DEPENDENCY]

## API

The library core is a function

	CMLIB_DEPENDENCY

Which can track/cache various number of dependencies.

[System modules] do not contain anything except what is needed for `CMLIB_DEPENDENCY` implementation.

Library consist from following [system modules]

- **[CMLIB_DEPENDENCY] - track and cache remote dependencies** (under remote dependency we
  assume dependency which is not 'directly' attached to the user CMake project)
- [CMLIB_REQUIRED_ENV] which init base environment for library needs
- [CMLIB_CACHE] - cache files on host filesystem (represent persisten cache)
- [CMLIB_FILE_DOWNLOAD] - download file from remote HTTP URl or GIT repository
- [CMLIB_PARSE_ARGUMENTS] - wrapper around cmake_parse_arguments
- [CMLIB_ARCHIVE] - extract files from archive
- [CMLIB_COMPONENT] - component logic

Detailed documentation can be found in each module.

There are examples for each modules in [example] directory.

### CMake-lib components

As optional feaure CMake-lib provides several components which extends functionality of the core library.

Each component has its own git repository in form `cmakelib-component-<component_name>`.

The `master` branch of the given component is always used.

List of CMake-lib components

- [CMLIB_STORAGE] - effectively track build resources,
- [CMDEF] - well defined built environment,

Components can be used by `FIND_PACKAGE(CMLIB REQUIRED COMPONENTS <component_list>)`

## Cache mechanism

Cache entries are represented by ordered, nonempty set of uppercase strings called `KEYWORDS`.

If no `KEYWORDS` are specified then the set is created by the library as hash of `URI`, `GIT_PATH` etc.

Cache mechanism is persistent across CMake binary dir instances.
If user deletes our CMake binary dir the cache will regenerate
in next CMake run for the same CMakeLists.txt
(we assume that cache is located in dir different from CMake binary dir)

If the `CMLIB_REQUIRED_ENV_TMP_PATH` is set then the cache will be stored
in the directory specified by `CMLIB_REQUIRED_ENV_TMP_PATH`.

If the cache reset is needed, just delete directory path stored
in `CMLIB_REQUIRED_ENV_TMP_PATH`.

### Dependency cache control

Dependency cache control is optional feature (enabled by default) which ensure that
there are only one dependency cached at a time.

If ON we cannot track one dependency under two different `KEYWORDS` sets.

Mechanism can be disabled by setting `CMLIB_DEPENDENCY_CONTROL` to OFF.

### Cache environment settings

All temporary files and outputs are stored in temporary directory

Path to temporary directory is controlled by `CMLIB_REQUIRED_ENV_TMP_PATH`

`CMLIB_REQUIRED_ENV_TMP_PATH` can be overridden be system ENV var named
`CMLIB_REQUIRED_ENV_TMP_PATH`

User can define global ENV var to specify one, central cache storage which will be
shared across CMake project instances.

## Best practices

- Each cache entry is represented by ordered set of keywords.
It's common idiom the the first keyword is name of the project in which
the CMLIB_DEPENDENCY/CMLIB_CACHE is written.
- Use CMLIB_DEPENDENCY instead of other CMLIB functions. (use other only if you known what
you are doing)

## Config variables

- `CMLIB_REQUIRED_ENV_TMP_PATH` - where to store tmp path where the cache will be stored.
  Can be set as Environment variable (which must be accessible by $ENV{CMLIB_REQUIRED_ENV_TMP_PATH}).
  Default value is "${CMAKE_CURRENT_LIST_DIR}/_tmp". More info at [CMLIB_REQUIRED_ENV]
- `CMLIB_DEPENDENCY_CONTROL` - Boolean variable which controls if the Dependency cache control is enabled.
  [CMLIB_DEPENDENCY]
- `CMLIB_FILE_DOWNLOAD_SHOW_PROGRESS` - if ON show HTTP download progress.
  If OFF do not show http download progress
- `CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE` - if ON no `git archive` is used for downloading
  resources from the remoe git repository.
- `CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY` - If ON the `git archive` functionality is required for downloading resouces
  from remote git repository. OFF value has no effect to standard workflow

## Tests

For test go to the test/ directory and run

Linux/Mac Os:

```
	GIT_TERMINAL_PROMPT=0 cmake .
	GIT_TERMINAL_PROMPT=0 cmake -P ./CMakeLists.txt
```

Windows PowerShell:

```
	$env:GIT_TERMINAL_PROMPT=0
	cmake .
	cmake -P ./CMakeLists.txt
```

then just clean up all intermediate files by

    git clean -xfd

## Coding style

In library we use Uppercase for all CMake keywords.

Local variables can be named as lowercase.

## Update

Just call "git pull" on repository root.

In case of cmake-generation problem reset cache.

## License

Project is licensed under [BSD-3-Clause License](LICENSE)



[CMLIB_REQUIRED_ENV]:    ./system_modules/CMLIB_REQUIRED_ENV.cmake
[CMLIB_CACHE]:           ./system_modules/CMLIB_CACHE.cmake
[CMLIB_FILE_DOWNLOAD]:   ./system_modules/CMLIB_FILE_DOWNLOAD.cmake
[CMLIB_PARSE_ARGUMENTS]: ./system_modules/CMLIB_PARSE_ARGUMENTS.cmake
[CMLIB_ARCHIVE]:         ./system_modules/CMLIB_ARCHIVE.cmake
[CMLIB_DEPENDENCY]:      ./system_modules/CMLIB_DEPENDENCY.cmake
[CMLIB_COMPONENT]:       ./system_modules/CMLIB_COMPONENT.cmake
[CMLIB_STORAGE]:         https://github.com/cmakelib/cmakelib-component-storage
[CMDEF]:                 https://github.com/cmakelib/cmakelib-component-basedef
[System modules]:        ./system_modules/
[system modules]:        ./system_modules/
[example]:               ./example/
[example/DEPENDENCY]:    ./example/DEPENDENCY
[buildbadge_github]:     https://github.com/cmakelib/cmakelib/workflows/Tests/badge.svg
[example/DEPENDENCY/boost_example]: ./example/DEPENDENCY/boost_example/
