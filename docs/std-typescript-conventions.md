Naming:
- Most functions as `lowercase`, compact Unix/Go-like syntax when one or two words, otherwise `camelCase`
- Parameters `camelCase`
- Local variables `snake_case`, use short variables names (`i`,`j`,`k`,`l`, etc) for a short scope

Structure:
- Imports at the beginning
- Type declarations first
- Utilities first
- Functions grouped logically
- High level APIs functions last
- Export explicit at the end of the file

Documentation:
- Natural docs, in `//` comments
- Compact, not verbose

Style:
- Functional, data-driven, declarative
- Composable, Unix-style
- Compact (minimize lines) while being readable
- Elegant and balanced

Example

```
import {symbol} from "@module"

type SomeData = {
  field: String
}

const CONST_VALUE = 10
const SomeSingleton = {items:[]}

// Function: dosomething
// Multiplies `a` by `b`
function dosomething(a:int, b:int):int {
  return a * b
}


export {CONST_VALUE, dosomething}
```

