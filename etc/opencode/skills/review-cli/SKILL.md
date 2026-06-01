---
name: review-cli
description: Review and update CLI user experience
---

## What I do

Review and update the command line argument names, description and behaviour so
that:

- Expected arguments are here (-h|--help, -v|--version)
- Default (no arguments) text is helpful
- Shorthands and longnames respect existing conventions

## When to use me

Where writing shell scripts, or cli modules in code.

## Rules

- **No arguments show how to use**: show basics (cli, args, description) and list of commands
- **Error show context**: If failing before logging anything, should show the CLI name, arguments and one line description.
- **Errors should have a tip**: should be followed by a helpful tip to recover/resolve.
- **Show configuration variables**: any env variable used should be listed in info
- **Show general flags**: any general/common flag should be listed by default


## Example

```
Usage: jj-deps <subcommand> [options]

jj-deps is an alternative to submodules that keeps dependencies in
sync.

Available subcommands:
  add REPO_PATH REPO_URL [BRANCH] [COMMIT]    Adds a new dependency
  status [PATH...]           Shows the status of each dependency, or specific ones
  checkout [PATH]            Checks out the dependency
  pull [PATH]                Pulls (and update) dependencies
  push [PATH]                Push  (and update) dependencies
  sync [PATH]                Push and then pull dependencies
  state                      Shows the current state
  save                       Saves the current state to .gitdeps
  import [PATH]              Imports dependencies from PATH=deps/
```

Good:
- Shows usage and options
- Shows descriptions
- Shows commands

Bad:
- Does not show general flags
- Does not show env variables to be configured
