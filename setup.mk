# -----------------------------------------------------------------------------
#
# SDK SETUP
#
# -----------------------------------------------------------------------------

# --
# ## Overview
# Sets up SDK with the given version based on the current directory.
# This makefile is the front door to sourcing `sdk` and ensuring that
# it has the correct version.

ifndef MAKE_VERSION
$(error !!! ERR − SDK requires GNU make → try running 'gmake' instead)
endif

# -----------------------------------------------------------------------------
#
# CONFIGURATION
#
# -----------------------------------------------------------------------------

# --
# ## SDK Settings

# Version of SDK to use (branch, tag, or commit)
SDK_VERSION=main

# Shell for recipe execution
SHELL:=bash

# Path to SDK installation directory
SDK_PATH:=$(subst //,,$(dir $(lastword $(MAKEFILE_LIST)))/)

# Runtime flags for SDK behavior
SDK_FLAGS?=

ifeq ($(filter no-check-version,$(SDK_FLAGS)),)
SDK_VERSION_CHECK:=$(strip $(shell env MAKEFLAGS="--silent" make -f $(SDK_PATH)/setup.mk check-version SDK_FLAGS=no-check-version))
$(if $(SDK_VERSION_CHECK),$(info $(SDK_VERSION_CHECK)))
include $(SDK_PATH)/src/mk/sdk.mk
endif

# -----------------------------------------------------------------------------
#
# RULES
#
# -----------------------------------------------------------------------------

# --
# ## Version Management

.PHONY: check-version
check-version: ## Checks the version of SDK against expected version
	@
	if [ "$(filter no-check-version,$(SDK_FLAGS))" == "" ]; then
		this_version=$$(git -C $(SDK_PATH) rev-parse HEAD 2>/dev/null || true)
		that_version=$$(git -C $(SDK_PATH) rev-parse $(SDK_VERSION) 2>/dev/null || true)
		if [ -z "$$this_version" ] || [ -z "$$that_version" ]; then
			exit 0
		fi
		if [ "$$this_version" != "$$that_version" ]; then
			echo "--- SDK is at $$that_version [$(SDK_VERSION)] (was $$this_version)"
		else
			echo "--- SDK is at $$that_version [$(SDK_VERSION)]"
		fi
	fi

.ONESHELL:
# EOF
