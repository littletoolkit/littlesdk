# -----------------------------------------------------------------------------
#
# RELEASE CONFIG
#
# -----------------------------------------------------------------------------

# --
# ## Version

## Project version as MAJOR.MINOR.PATCH, declared by the project in
## `$(PROJECT_VERSION_FILE)`. Defining it enables the `update-version`,
## `release` and `release-deploy` rules. Distinct from `REVISION`, which is the
## git revision used by build and distribution paths.
PROJECT_VERSION?=

## File that declares `PROJECT_VERSION` and is rewritten by `release` when the
## version is bumped.
PROJECT_VERSION_FILE?=src/mk/config.mk

## Files that carry a copy of the version and are rewritten when it is synced.
## Only `package.json` is rewritten automatically; use `RELEASE_VERSION_EXTRA`
## for other files.
RELEASE_VERSION_FILES?=$(if $(wildcard package.json),package.json)

## Files committed by `release` when it bumps the version. Any other pending
## change is left in the working copy and excluded from the tagged revision.
RELEASE_COMMIT_FILES?=$(PROJECT_VERSION_FILE) $(RELEASE_VERSION_FILES)

## Extra shell command run with `VERSION` in the environment when the version
## is synced, for source/README rewrites that cannot be inferred.
RELEASE_VERSION_EXTRA?=

# --
# ## Deployment

## Remote destination for `release-deploy`, may reference `$(PROJECT)` and
## `$(PROJECT_VERSION)`, for instance
## `agent@host:/srv/www/$(PROJECT)/$(PROJECT_VERSION)`. Must end with `/` for
## rsync to treat it as a directory.
RELEASE_DEPLOY_URI?=

## Artifacts published by `release-deploy`.
RELEASE_DEPLOY_FILES?=$(DIST_ALL)

## Git remote the release tag is pushed to.
RELEASE_REMOTE?=origin

# --
# ## Registration

## Task that propagates `PROJECT_VERSION` to derived files; only registered
## when the project declares a version.
RELEASE_VERSION_TASK=$(if $(strip $(PROJECT_VERSION)),$(PATH_RUN_TASK)/project-version-$(PROJECT_VERSION).task)
ifneq ($(strip $(PROJECT_VERSION)),)
PREP_ALL+=$(RELEASE_VERSION_TASK)
endif

# EOF
