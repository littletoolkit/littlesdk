# --
# We define the basic make configuration flags and shell.
SHELL:=bash
.SHELLFLAGS:=-euo pipefail -c
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules
.ONESHELL:
.FORCE:

# --
# We load the standard library, at which point we'll
# be able to load the modules
KIT_MODULES_PATH:=$(patsubst %.mk,%,$(lastword $(MAKEFILE_LIST)))
KIT_MODULES?=$(KIT_MODULES_AVAILABLE)

include $(KIT_MODULES_PATH)/std/lib.mk
include $(KIT_MODULES_PATH)/std/vars.mk
include $(KIT_MODULES_PATH)/std/rules.mk

# FIXME: That won't work if we have modules found elsewhere than KIT_MODULES_PATH
define def-kit-module-load
$(foreach K,$(filter-out std,$(KIT_MODULES)),$(if $(wildcard $(KIT_MODULES_PATH)/$K/$1),$(EOL)include $(KIT_MODULES_PATH)/$K/$1))
endef
$(eval $(call def-kit-module-load,config.mk))
$(eval $(call def-kit-module-load,lib.mk))
$(eval $(call def-kit-module-load,vars.mk))
$(eval $(call def-kit-module-load,rules.mk))

# EOF
