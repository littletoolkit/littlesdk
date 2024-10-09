# --
# Sets up LittleDevKit with the given version based on the current directory.
# This makefile is the front door to sourcing `littledevkit` and ensuring that
# it has the correct version.

LITTLE_DEVKIT_VERSION=main
SHELL:=bash
LDK_PATH:=$(subst //,,$(dir $(lastword $(MAKEFILE_LIST)))/)
LDK_FLAGS?=
ifeq ($(filter no-check-version,$(LDK_FLAGS)),)
$(info $(shell env MAKEFLAGS="--silent" make -f $(LDK_PATH)/setup.mk check-version LDK_FLAGS=no-check-version))
include $(LDK_PATH)/src/mk/littledevkit.mk
endif

# --
# Checks the version for littledevkit
.PHONY: check-version
check-version:
	@
	if [ "$(filter no-check-version,$(LDK_FLAGS))" == "" ]; then
		this_version=$$(git -C $(LDK_PATH) rev-parse HEAD)
		that_version=$$(git -C $(LDK_PATH) rev-parse $(LITTLE_DEVKIT_VERSION))
		if [ "$$this_version" != "$$that_version" ]; then
			echo "--- LDK is at $$that_version [$(LITTLE_DEVKIT_VERSION)] (was $$this_version)"
		else
			echo "--- LDK is at $$that_version [$(LITTLE_DEVKIT_VERSION)]"
		fi
	fi

.ONESHELL:
# EOF
