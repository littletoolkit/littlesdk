---
name: review-ts
description: Review and update module documentation using NaturalDocs-style format with markdown.
---

## What I do

Review and update the documentation of a module, ensuring clarity, consistency, and completeness. I check for:

- Proper NaturalDocs-style formatting with markdown support
- Compliance with AGENTS.md conventions (project headers, section delimiters, EOF marker)
- Clear, concise descriptions that assume technical competence
- Embedded parameters in function/method descriptions using backticks
- Appropriate examples (required for factory functions and complex APIs)
- Proper type/class attribute documentation with bullet points

## When to use me

- After writing or modifying a module's public API
- When adding new functions, types, or classes to a module
- When refactoring code that changes the API surface
- Before committing documentation changes
- When you need to ensure consistent documentation style across the codebase

## Principles

- Be concise and direct
- Assume technical competence (documentation is a reference, not a tutorial)
- Introduce concepts and keywords at module level
- Define specific terms before using them
- Use examples to illustrate usage (required for factory functions and complex APIs, optional for simple functions)
- Use fenced code blocks for all examples
- Follow AGENTS.md conventions: project headers, section delimiters, EOF marker

## Documentation Format

NaturalDocs-style with markdown support.

### File Template

```
// Project: {{project name}}
// Author:  {{author name}}
// License: {{license}}
// Created: YYYY-MM-DD

// Module: {{module name}}
// {{description of the module, concepts, short examples}}

// ----------------------------------------------------------------------------
//
// SECTION
//
// ----------------------------------------------------------------------------
// ============================================================================
// SUBSECTION
// ============================================================================

// Type: {{name}}
// {{description}}
// {{attribute_list}}

// Function: {{name}}
// {{description with embedded parameters}}

export { {{name}} }

// EOF
```

### Rules

- **Project headers**: Include project, author, license, and creation date at file top
- **Section delimiters**: Use `// SECTION` and `// SUBSECTION` headers with separators
- **Imports**: User absolute `@module` when posssible, relative `./` and `../` allowed
- **Module-level docs**: Define concepts, keywords, and provide overview
- **Type/Class docs**: Describe purpose; list attributes as bullet points with types
- **Function/Method docs**: Embed parameters in description using backticks; include examples for factory functions and complex APIs
- **Exports**: Named exports listed at file end with explicit `// EOF` marker
- **Examples**: Always use fenced code blocks with language specifier; comment style for examples matches the surrounding code
- **Visibility**: Don't use private/protected, but group internal operations together with a SUBSECTION

### Examples

```typescript
// Project: LittleMake
// Author:  Sebastien Pierre
// License: MIT
// Created: 2024-01-01

// Module: math
// Provides basic arithmetic operations for numeric values. Operations are
// immutable and do not modify input values.

// Function: mul
// Multiplies `a` with `b` and returns the result.
function mul(a: number, b: number): number {
  return a * b
}

// Type: Point
// Represents a 2D coordinate with `x` and `y` values.
// - x: number - horizontal position
// - y: number - vertical position
type Point = { x: number, y: number }

// Function: createCalculator
// Factory that returns a calculator instance with the given `precision`.
//
// Example:
// ```typescript
// const calc = createCalculator(2);
// calc.add(1.234, 5.678); // returns 6.91
// ```
function createCalculator(precision: number): Calculator {
  return new Calculator(precision)
}

// Class: Calculator
// Provides arithmetic operations with configurable precision.
// - precision: number - decimal places for rounding
class Calculator {
  add(a: number, b: number): number { ... }
}

export { mul, Point, createCalculator, Calculator }

// EOF
```
