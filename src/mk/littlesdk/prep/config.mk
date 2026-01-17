## Alias to Git
GIT?=git

## Forces non-interactive mode
NO_INTERACTIVE?=

## Removes color output
NO_COLOR?=

PREP_ALL+=$(SOURCES_ETC:src/etc/%=%)
PREP_ALL+=$(SOURCES_DOTFILES:$(SDK_PATH)/etc/dotfiles/%=.%)

# EOF
