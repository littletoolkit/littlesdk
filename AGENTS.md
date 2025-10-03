# LittleSDK Agent Guidelines

## Build Commands
- `make` - Default build (runs BUILD_ALL)
- `make build` - Builds all outputs in BUILD_ALL
- `make prep` - Installs dependencies & prepares environment
- `make run` - Runs the project and dependencies
- `make dist` - Creates distributions
- `make clean` - Removes build, run, and dist directories
- `make help` - Shows available rules and phases
- `make help-vars` - Shows configuration variables

## Test Commands
- `make test` - Runs tests (implementation pending)
- Test framework not yet implemented - follow build phase pattern: `test(-*)`

## Code Style
### Makefile Conventions
- Global variables: `UPPER_CASE`
- Environment variables: `VARNAME?=DEFAULT`
- Functions: `snake_case` (callable via `$(call function_name,…)`)
- Parameters: Single uppercase letters `$(foreach V,A B C,$V)`
- Tasks: `kebab-case`, suffix with `--` for params (`deploy--account=123`) or `@` for env (`deploy@staging`)

### Coding Principles
- Be concise, write compact code
- Comments only to clarify intent
- Prefer functional over imperative
- Write short docstrings for all elements
- Favor standard library, minimize third-party dependencies
- Define interfaces for third-party libraries

### Project Structure
- `src/$LANG/*` - Sources by language
- `build/$COMPONENT/$REVISION/*` - Build artifacts
- `dist/$REVISION/*` - Distribution artifacts
- `run/bin` - CLI binaries
- `run/{share,man,lib}` - Supporting files

## Development Commands
- `make shell` - Opens environment shell
- `make live-<target>` - Auto-rebuild on file changes
- `make print-VARNAME` - Shows variable value
- `make def-VARNAME` - Shows variable definition