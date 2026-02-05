---
name: review-mk
description: Review and update Makefile documentation following LittleSDK conventions.
---

## What I do

Review and update Makefile documentation, ensuring clarity, consistency, and compliance with LittleSDK conventions. I check for:

- Proper comment formatting with `#` markers
- Section delimiters with separator lines
- Variable documentation with `##` descriptions
- Function documentation using `define` with parameter descriptions
- Task/rule documentation with `.PHONY` declarations and `##` descriptions
- Consistent naming conventions (UPPER_CASE for globals, kebab-case for tasks)
- Proper EOF marker at file end

## When to use me

- After writing or modifying a Makefile
- When adding new variables, functions, or rules
- When refactoring build logic that changes the API surface
- Before committing Makefile changes
- When you need to ensure consistent documentation style across Makefiles

## Principles

- Be concise and direct
- Assume technical competence (documentation is a reference, not a tutorial)
- Use examples to illustrate usage for complex functions
- Use fenced code blocks for all examples
- Follow LittleSDK conventions from AGENTS.md

## Documentation Format

LittleSDK Makefile conventions with markdown support.

### File Template

```makefile
# -----------------------------------------------------------------------------
#
# SECTION
#
# -----------------------------------------------------------------------------

# --
# ## Description for a subsection or concept

# Description of a variable or simple definition
VARIABLE?=default_value ## Brief description of purpose

# --
# Function: function_name
# Description of what the function does.
# - param1: Description of first parameter
# - param2: Description of second parameter
# Returns: Description of return value

define function_name
	# function body using $(1), $(2), etc.
endef

# -----------------------------------------------------------------------------
#
# RULES
#
# -----------------------------------------------------------------------------

# Target with documentation comment
.PHONY: target-name
target-name: dependencies ## Description of what this rule does
	@$(call rule_pre_cmd)
	# rule commands here
	@$(call rule_post_cmd)

# EOF
```

### Rules

- **Variables**: Global variables use `UPPER_CASE`, environment variables use `VARNAME?=DEFAULT` syntax, document with `##` at end of line
- **Section delimiters**: Use `# -----------------------------------------------------------------------------` separators with `# SECTION` headers
- **Subsections**: Use `# --` prefix followed by `##` for subsection descriptions
- **Functions**: Document with `# --` prefix, include function name, description, parameter list using `- param:`, and return value
- **Rules**: Define with `.PHONY:` for non-file targets, use kebab-case names, document with `##` after target definition
- **Comments**: Use `#` for all comments; inline comments with `##` for documentation
- **Naming**: Tasks/rules use `kebab-case`, functions use `snake_case`, variables use `UPPER_CASE`
- **Function parameters**: Single uppercase letters `$(foreach V,A B C,$V)` when iterating
- **EOF marker**: Files end with explicit `# EOF` comment

### Examples

```makefile
# -----------------------------------------------------------------------------
#
# BUILD
#
# -----------------------------------------------------------------------------

# --
# ## Project Configuration

# The project name, defaults to current directory name
PROJECT?=$(notdir $(CURDIR)) ## Project identifier for distributions

# Where build artifacts are stored
PATH_BUILD?=build ## Build output directory

# -----------------------------------------------------------------------------
#
# FUNCTIONS
#
# -----------------------------------------------------------------------------

# --
# ## File Operations

# --
# Function: file_find
# Finds files matching pattern within path (up to 10 levels deep).
# - PATH: Directory to search
# - PATTERN: File pattern to match (e.g., *.py)
# Returns: Space-separated list of matching files
file_find=$(wildcard $(subst SUF,$(strip $(if $2,$2,.)),$(strip $(subst PRE,$(if $1,$1,.),PRE/SUF PRE/*/SUF ...))))

# --
# Function: ensure_dir
# Creates directory if it doesn't exist, with error handling.
# - DIR: Directory path to create
# - MSG: Optional error message

define ensure_dir
	if [ ! -d "$(1)" ]; then
		if ! mkdir -p "$(1)"; then
			echo "$(call fmt_error,$(if $2,$2,Failed to create $(1)))"
			exit 1
		fi
	fi
endef

# -----------------------------------------------------------------------------
#
# RULES
#
# -----------------------------------------------------------------------------

# --
# ## Build Targets

.PHONY: build
build: $(PREP_ALL) $(BUILD_ALL) ## Builds all outputs in BUILD_ALL
	@$(call rule_post_cmd)

.PHONY: clean
clean: ## Removes build, run, and dist directories
	@$(call rule_pre_cmd)
	rm -rf $(PATH_BUILD) $(PATH_RUN) $(PATH_DIST)

# Rule with parameters (-- syntax for passing arguments)
.PHONY: print-%
print-%: ## Shows the value of any variable
	@$(info $(BOLD)$*=$(RESET)$(strip $($*)))

# EOF
```
