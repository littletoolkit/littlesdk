# Conventions

Makefile conventions:
- Global variables are `UPPER_CASE`
- Environment variables should be defined with defaults using `VARNAME?=DEFAULT`
- Functions (callable using `$(call function_name,…)` are `snake_case`
- Parameters are single letters uppercase like `$(foreach V,A B C,$V)`
- Tasks (phony rules) are `kebab-case`, sometimes suffixed by `--`
  for extra parameters (for instance `deploy--account=123+role=Admin`) or
  by `@` for environment (for instance `deploy@staging`)


Coding style:
- Be concise and write compact code, only write comments to clarify your intent.
- Write short docstrings for all elements.
- Prefer functional over imperative

Implementation Style:
- Favor the use of the standard library .
- Minimise the use of third party libraries.

- Define interfaces when using third party libraries so that they can be swapper later.

