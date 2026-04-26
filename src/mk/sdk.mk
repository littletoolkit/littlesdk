# --
# We define the basic make configuration flags and shell.
SHELL:=bash
.SHELLFLAGS:=-euo pipefail -c
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules


# --
# We load the standard library, at which point we'll
# be able to load the modules
_SDK_PATH:=$(subst $(realpath .)/,,$(realpath $(dir $(lastword $(MAKEFILE_LIST)))../..))
SDK_PATH:=$(if $(_SDK_PATH),$(_SDK_PATH),./)
SDK_MAKE:=$(MAKE) -f $(firstword $(MAKEFILE_LIST))

SDK_MODULES_PATH:=$(patsubst %.mk,%,$(lastword $(MAKEFILE_LIST)))
SDK_MODULES?=$(SDK_MODULES_AVAILABLE)
SDK_TITLE?=
SDK_HLO?=🧰 $(BOLD)SDK$(if $(SDK_TITLE), ― $(SDK_TITLE))$(RESET)
SDK_LOGGING?=all
# The prefix used in logging output
FMT_PREFIX?=[sdk]

include $(SDK_MODULES_PATH)/std/lib.mk

$(info ┉┅━┅┉ $(SDK_HLO)$(RESET))

def-include=$(EOL)$(if $(value DEBUG),$(info $(call fmt_action,$(call fmt_module,$1))))$(EOL)include $1
# FIXME: That won't work if we have modules found elsewhere than SDK_MODULES_PATH
define def-module-load
$(if $(wildcard src/mk/$(subst .mk,.pre.mk,$1)),$(call def-include,src/mk/$(subst .mk,.pre.mk,$1)))
$(if $(filter config.mk,$1),$(if $(wildcard src/mk/$1),$(call def-include,src/mk/$1)))

# We source an additional override.
$(if $(wildcard Makefile.local),$(call def-include,Makefile.local))

# We ensure that variables are exported to the rules environment
$(eval $(call make_export_vars))

# NOTE: We skip the std module here, as it's already loaded
$(foreach K,$(filter-out std,$(SDK_MODULES)),$(if $(wildcard $(SDK_MODULES_PATH)/$K/$1),$(call def-include,$(SDK_MODULES_PATH)/$K/$1)))
$(if $(filter rules.mk,$1),$(if $(wildcard src/mk/$1),$(call def-include,src/mk/$1)))
$(if $(wildcard src/mk/$(subst .mk,.post.mk,$1)),$(call def-include,src/mk/$(subst .mk,.post.mk,$1)))
endef

# We load the standard library first
$(eval $(call def-include,$(SDK_MODULES_PATH)/std/config.mk))
$(eval $(call def-module-load,config.mk))
# Standard rules are loaded first
$(eval $(call def-include,$(SDK_MODULES_PATH)/std/rules.mk))
$(eval $(call def-module-load,rules.mk))

#
# EOF
