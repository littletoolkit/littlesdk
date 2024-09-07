# --
# Sets up LittleDevKit with the given version based on the current directory
LITTLE_DEVKIT_VERSION=main
LDK_PATH:=$(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: setup
setup:

.PHONY: check-version
check-version:
	@echo $(LDK_PATH)
	THIS_VERSION=$$(git -C $(LDK_PATH) rev-parse HEAD)
	EXPECT_VERSION=$$(git -C $(LDK_PATH) rev-parse $(LITTLE_DEVKIT_VERSION))
	if [ "$$THIS_VERSION" != "$$EXPECT_VERSION" ]; then
		echo "--- Checking out version: $(LITTLE_DEVKIT_VERSION) $$EXPECT_VERSION (has $$THIS_VERSION)"
	fi

.ONESHELL:
# EOF
