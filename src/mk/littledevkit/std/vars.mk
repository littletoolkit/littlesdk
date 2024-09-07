
# --
# Lists all source files defined in the modules like `std/lib.mk std/vars.mk`
KIT_MODULES_SOURCES:=$(patsubst $(KIT_MODULES_PATH)/%,%,$(wildcard $(KIT_MODULES_PATH)/src/mk/littledevkit/*/*.mk))

# --
# Lists all available modules, like `std prep run`
KIT_MODULES_AVAILABLE:=$(foreach M,$(KIT_MODULES_SOURCES),$(firstword $(subst /,$(SPACE),$M)))
# EOF
