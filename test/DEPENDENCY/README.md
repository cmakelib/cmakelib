
# CMLIB_DEPENDENCY Unit Tests

DEPENDENCY tests do not test every possible argument combination.

It relies on a defined and documented design of each respective CMLIB macro.

## Test Structure

- `argument_missing/` - verify that DEPENDENCY correctly handles missing arguments
- `cache_control/`    - verify that DEPENDENCY correctly manages the cache
- `type_check/`       - verify that DEPENDENCY can handle different TYPE parameters (FILE, MODULE, ARCHIVE, DIRECTORY)
- `download_check/`   - verify that DEPENDENCY can download files from different URI schemes (file://, http://, https://, git://, git@github.com:user/repo.git)
- `git_revision_validation/` - validates that GIT_REVISION parameter actually works by downloading branch-specific files
