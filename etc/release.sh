#!/usr/bin/env bash

MAIN_BRANCH="main"

### 
## Release Flow
# 
# 1. Normal releases are performed from master
# 2. When releasing a new major or minor this can _ONLY_ be done from master
# 3. A patch release can only be done from master for or a release branch.
#    e.g. if the latest release is 1.2.0, patch releases can be done from master or release_v1.2.1 only
#
# As part of a release, regardless of type:
# - Bump versions
# - Create release notes
# - Create a release commit and tag
# - Push the branch and tag
# 
# After the build/deploy is done, if the release was a patch release from a release branch then it will be merged back into master
# to allow it to contain the new version number and release notes.




# Check if a branch exists in local repo.
function is_in_local() {
	local branch
	local existed_in_local
	branch=${1}
	existed_in_local=$(git branch --list "${branch}")

	if [[ -z ${existed_in_local} ]]; then
		echo 0
	else
		echo 1
	fi
}

# Remote:
# Ref: https://stackoverflow.com/questions/8223906/how-to-check-if-remote-branch-exists-on-a-given-remote-repository
# test if the branch is in the remote repository.
# return 1 if its remote branch exists, or 0 if not.
function is_in_remote() {
	local branch
	local existed_in_local
	branch=${1}
	existed_in_remote=$(git ls-remote --heads origin "${branch}")

	if [[ -z ${existed_in_remote} ]]; then
		echo 0
	else
		echo 1
	fi
}

# Get short version from full version
# e.g. 1.2.3 -> 1.2
function short_version() {
  local version
  version=${1}
  sed -E "s/([0-9]+\.[0-9]+).*/\1/g" <<<"$version"
}

# Perform branch checks based on bump type
# e.g. major/minor releases must be done from main, patch releases from release branches or main
function branch_checks() {
  local bump_type=$1
  local current_branch=$2

  # Ensure we are on an appropriate branch for the bump type
	if [[ ($bump_type == "major" || $bump_type == "minor") && $current_branch != "$MAIN_BRANCH" ]]; then
		echo "You must be on the '$MAIN_BRANCH' branch to create a $bump_type release."
		exit 1
	fi

	if [[ $bump_type == "patch" && ($current_branch != release_v* && $current_branch != "$MAIN_BRANCH") ]]; then
		echo "You must be on a 'release_v*' branch to create a $bump_type release."
		exit 1
	fi

  # If it's a patch release, check the release branch number matches the version we're about to release.
  if [[ $bump_type == "patch" && $current_branch == release/* ]]; then
    release_branch_version=$(sed -E "s/release_v([0-9]+\.[0-9]+).*/\1/g" <<<"$current_branch")
    package_version=$(node -p "require('./package.json').version")
    package_version_short=$(short_version "$package_version")

    if [[ $release_branch_version != "$package_version_short" ]]; then
      echo "The release branch version ($release_branch_version) does not match the package.json version ($package_version_short)."
      echo "When you are creating a patch release from a release branch the branch version must match the package.json minor version."
      exit 1
    fi
  fi

}

# TODO: Remove - this is for testing while developing
function BREAK() {
  echo "Resetting changes to package.json"
  git checkout package.json package-lock.json
  echo "==== $1 ===="
  exit 0;
}

function main() {
  bump_type=${1:-minor}
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  branch_checks "$bump_type" "$current_branch"

  # Ensure working directory is clean
	if [[ -n $(git status -s) ]]; then
		echo "There are pending changes in your working directory:"
    git status -s
    # TODO: Uncomment when ready
		# exit 1
	fi


  # TODO: Use bump-my-version when ready, for now use npm version to simulate it.
	# bump-my-version bump "$bump_type"
  npm version "$bump_type" --no-git-tag-version

	local new_version
	# local short_version
	# version=$(grep -Po "\"version\": \"\K(\d*\.\d*\.\d*)" <package.json)
	new_version=$(node -p "require('./package.json').version")

	echo "## Releasing version ${new_version} ##"

	echo "Creating release notes"

  # TODO: Uncomment when ready
	# towncrier --yes

	echo "Creating release commit and tag"

  # Create commit and tag
	git add .
	git commit -m "Release v${new_version}"
	git tag -a "v${new_version}" -m "Release v${new_version}"

  # For 
	echo "Pushing branch and tag back to repo"
	git push origin "$current_branch"
	git push --tags
}

main "$@"
