
# CMakeLib Release Process

When new version is abvout to be released, the following steps must be taken

**Open PR to release cmakelib**

- Choose next version number in standard format (example: `1.0.0`)
- Update version version in `version.txt`

**Open PR for each cmlib component**

- Update CI/CD for each respective component (cmakelib is boiund to version in each CI/CD pipeline).
  Update CI/CD yamls to point to a new version of cmaikelib
- Choose next version number in standard format (example: `1.0.0`)
  Increment MINOR part of the component version if the release is doe only because of cmakelib release 
- Update component version version in `version.txt`

**Merge PRs**

- For CMakeLib
  - Merge the PR.
  - Create new release in cmakelib github with a versiontag (`v<version>`).
- For each component
  - Merge the PR.
  - create new release in component github with a versiontag (`v<component_version>`).



