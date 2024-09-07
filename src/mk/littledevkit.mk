# --
# We define the basic make configuration flags and shell.
SHELL:=elvish
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules
.ONESHELL:
.FORCE:
# We define the path where we can find the modules
KIT_MODULES_PATH:=$(patsubst %.mk,%,$(lastword $(MAKEFILE_LIST)))
$(info XXX $(KIT_MODULES_PATH)/std/lib.mk)
include $(KIT_MODULES_PATH)/std/lib.mk
include $(KIT_MODULES_PATH)/std/vars.mk
# include $(KIT_MODULES_PATH)/std/rules.mk

KIT_MODULES?=$(KIT_MODULES_AVAILABLE)
$(info $(KIT_MODULES_AVAILABLE))
# EOF
