Contributing
===

When contributing to this repository, please first  discuss the change on Flowdock channel and open issue to star progress.

## Branch Naming

1. All features name should prefix with `issue/` and include the issue id, ex. `issue/123`
2. Before release new stable version, the branch name should be `release/[version]`, ex. `release/1.0.0`
3. If there should add some patch to `master` branch, the name should be `hotfix/[issue id]`, ex. `hotfix/123`
4. After release new version, add tag with version, ex. `1.0.0`

## Pull Request Process

1. Ensure any install or build dependencies are removed before the end of the layer when doing a build.
2. Update the README.md with details of changes to the interface, this includes new environment variables, exposed ports, useful file locations and container parameters.
3. All pull request target isn't `develop` should create another merge back pull request to `develop`

### Policy

* If merged branch is new feature, please set target to `develop`
* When `release/` branch exists and branch is fix to next release, set target to `release/` branch
* All `release/` branch will deploy to staging server, and everything reviews will promote to production.
* `master` is always stable version, and also `production` version.

## Commit

1. Comment should under 50 words and describe the changes
2. If this commits finished an issue, append `Closed #1` or `Resolves #1` comment
