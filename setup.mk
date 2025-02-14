# --
# Sets up LittleDevKit with the given version based on the current directory.
# This makefile is the front door to sourcing `littlebuild` and ensuring that
# it has the correct version.

LITTLEBUILD_VERSION=main
SHELL:=bash
LDK_PATH:=$(subst //,,$(dir $(lastword $(MAKEFILE_LIST)))/)
LDK_FLAGS?=
ifeq ($(filter no-check-version,$(LDK_FLAGS)),)
$(info $(shell env MAKEFLAGS="--silent" make -f $(LDK_PATH)/setup.mk check-version LDK_FLAGS=no-check-version))
include $(LDK_PATH)/src/mk/littlebuild.mk
endif

# --
# Checks the version for littlebuild
.PHONY: check-version
check-version:
	@
	if [ "$(filter no-check-version,$(LDK_FLAGS))" == "" ]; then
		this_version=$$(git -C $(LDK_PATH) rev-parse HEAD)
		that_version=$$(git -C $(LDK_PATH) rev-parse $(LITTLEBUILD_VERSION))
		if [ "$$this_version" != "$$that_version" ]; then
			echo "--- LDK is at $$that_version [$(LITTLEBUILD_VERSION)] (was $$this_version)"
		else
			echo "--- LDK is at $$that_version [$(LITTLEBUILD_VERSION)]"
		fi
	fi

.ONESHELL:
# EOF
