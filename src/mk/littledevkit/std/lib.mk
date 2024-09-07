# Core variables
NULL:=
SPACE:=$(NULL) $(NULL)

# --
#  `rwildcard PATH PATTERN`, eg `$(call rwildcard,src/py,*.py)` will match all
#  files in `PATH` (recursively) and also matching patterns.
rwildcard=$(wildcard $(subst SUF,$2,$(subst PRE,$(if $1,$1,.),PRE/SUF PRE/*/SUF PRE/*/*/SUF PRE/*/*/*/SUF PRE/*/*/*/*/SUF PRE/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/*/SUF)))

# EOF
