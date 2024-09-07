# --
# We define the basic make configuration flags and shell.
SHELL:=bash
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules
.ONESHELL:
.FORCE:

# --
# We load the standard library, at which point we'll
# be able to load the modules
KIT_MODULES_PATH:=$(patsubst %.mk,%,$(lastword $(MAKEFILE_LIST)))
include $(KIT_MODULES_PATH)/std/lib.mk
include $(KIT_MODULES_PATH)/std/vars.mk
include $(KIT_MODULES_PATH)/std/rules.mk

KIT_MODULES?=$(KIT_MODULES_AVAILABLE)
# EOF
