# -----------------------------------------------------------------------------
#
# LITTLESDK SETUP
#
# -----------------------------------------------------------------------------

# --
# ## Overview
# Sets up LittleSDK with the given version based on the current directory.
# This makefile is the front door to sourcing `littlesdk` and ensuring that
# it has the correct version.

ifndef MAKE_VERSION
$(error !!! ERR − LittleSDK requires GNU make → try running 'gmake' instead)
endif

# -----------------------------------------------------------------------------
#
# CONFIGURATION
#
# -----------------------------------------------------------------------------

# --
# ## SDK Settings

# Version of LittleSDK to use (branch, tag, or commit)
LITTLESDK_VERSION=main

# Shell for recipe execution
SHELL:=bash

# Path to LittleSDK installation directory
LITTLESDK_PATH:=$(subst //,,$(dir $(lastword $(MAKEFILE_LIST)))/)

# Runtime flags for SDK behavior
LITTLESDK_FLAGS?=

ifeq ($(filter no-check-version,$(LITTLESDK_FLAGS)),)
$(info $(shell env MAKEFLAGS="--silent" make -f $(LITTLESDK_PATH)/setup.mk check-version LITTLESDK_FLAGS=no-check-version))
include $(LITTLESDK_PATH)/src/mk/littlesdk.mk
endif

# -----------------------------------------------------------------------------
#
# RULES
#
# -----------------------------------------------------------------------------

# --
# ## Version Management

.PHONY: check-version
check-version: ## Checks the version of LittleSDK against expected version
	@
	if [ "$(filter no-check-version,$(LITTLESDK_FLAGS))" == "" ]; then
		this_version=$$(git -C $(LITTLESDK_PATH) rev-parse HEAD)
		that_version=$$(git -C $(LITTLESDK_PATH) rev-parse $(LITTLESDK_VERSION))
		if [ "$$this_version" != "$$that_version" ]; then
			echo "--- LittleSDK is at $$that_version [$(LITTLESDK_VERSION)] (was $$this_version)"
		else
			echo "--- LittleSDK is at $$that_version [$(LITTLESDK_VERSION)]"
		fi
	fi

.ONESHELL:
# EOF
