
PREP_ALL?=## Dependencies that will be met by `make prep`
RUN_ALL?=## Dependencies that will be met by `make run`
SOURCES_ALL?=## All the source files known by the kit
PACKAGE_ALL?=## All the files that will be packaged in distributions
DIST_ALL?=## All the distribution files

# --
# Lists all source files defined in the modules like `std/lib.mk std/vars.mk`
KIT_MODULES_SOURCES:=$(patsubst $(KIT_MODULES_PATH)/%,%,$(wildcard $(KIT_MODULES_PATH)/*/*.mk))

# --
# Lists all available modules, like `std prep run`
KIT_MODULES_AVAILABLE:=$(foreach M,$(wildcard $(KIT_MODULES_PATH)/*),$(if $(wildcard $M/*.mk),$(notdir $M)))
# EOF
