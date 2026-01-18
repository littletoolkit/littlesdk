# TypeScript Convention

Follow this template:

```
// File: {name}
// {description}

// NOTE: Imports use "@module" whenever possible, no ../../.. (3+ depth)
import {symbol} from "@module"

# -----------------------------------------------------------------------------
#
# DEFINITIONS
#
# -----------------------------------------------------------------------------

// NOTE: Types first
type SomeData = {
  field: String
}

// NOTE: Then constants, singletons
const CONST_VALUE = 10
const SomeSingleton = {items:[]}

// -----------------------------------------------------------------------------
//
// OPERATIONS
//
// -----------------------------------------------------------------------------

// NOTE: Group your operations based on logic/semantics
// =============================================================================
// {GROUP}
// =============================================================================

// Function: dosomething
// Multiplies `a` by `b`
function dosomething(a:int, b:int):int {
  return a * b
}

// -----------------------------------------------------------------------------
//
// API
//
// -----------------------------------------------------------------------------

// NOTE: This is your high-leve API/operations
function …

// NOTE: Exports at the end
export type {…}
export {CONST_VALUE, dosomething}
export defaults

# EOF
```
Naming:
- Most functions as `lowercase`, compact Unix/Go-like syntax when one or two words, otherwise `camelCase`
- Parameters `camelCase`
- Local variables `snake_case`, use short variables names (`i`,`j`,`k`,`l`, etc) for a short scope
- When writing a module, make sure classes and types share one or two common prefix (eg. `storage` module, `Storage`, `Stored` prefixes)


Structure:
- Imports at the beginning
- Type declarations first
- Utilities first
- Functions grouped logically
- High level APIs functions last
- Export explicit at the end of the file

Documentation:
- Natural docs, in `//` comments
- Comment when using tricks or using hardcoded values
- Compact, not verbose

Style:
- Functional, data-driven, declarative
- Composable, Unix-style
- Compact (minimize lines) while being readable
- Elegant and balanced
