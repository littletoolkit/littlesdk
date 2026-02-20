---
name: data-modeling
description: model data schema, taxonomies and ontologies
---

# About the skill

- To be used when modeling data structured, database schema, taxonomies, ontologies
- Used during design, analysis and elaboration to communicate specification for development
- Introduces a compact data modeling notation

# Data Modeling Notation

We want to create a data modeling notation that is expressive and compact,
can help represent JSON-like data, relational data, and puts the emphasis
on structure and semantics. It is intended to be used as shorthand for
describing data, in particular as directions to LLM.

## Concepts

- Type: namespace for attributes and relations
- Category: collections of types the type belongs to, helps build taxonomies
- Attribute: binds a shape to a name in a type
- Relation: binds a relation between two types by way of their attributes
- Composition: a tight-coupled relation, where A composes B implies B is part of A
- Aggregation: a loose-coupled relation, where A aggregates B implied B is not part of A
- Reference: a one-to-one mapping between A.a and B.b, where B.b is the source of truth
- Inclusion: denotation of inclusion of all attributes from type A into type B
- Derivation: denotes an attribute is derived from others
- View: denotes a relation that is derived from a query over fields
- Shape: represents the encoding/serializable structure of a value

## Notation

Basic notation:
- Descriptions are optional
- Descriptions can span more than one line
- Relations field is optional, defaults to key


```
# Comments
Type.
Type, description.
Type(Category), description.

Type(Category, Category), description:
- Field:Shape, description
- Composition=Type.Field, description
- Aggregation:Type.Field, description
- Reference~Type.Field, description
- Derivation{Field, Field}, description
- View<Field{Condition}, description
+ IncludedType, description

Shape=shape, description
```

Types can:
- Be defined with no attributes, in which case the definition ends with `.`
- Have one or more categories to disambiguate `Instrument(Finance)`, `Instrument(Sampling)`

Fields can be suffixed (after the name, like `id!:string`):
- `?` optional
- `!` key
- `@` indexed

Relations and views can be suffixed (after the name, like `tasks*:Task.id`):
- `?` optional
- `*` multiple optional
- `+` multiple required

Shapes are described using a compact shape notation, similar to TypeScript's
type notation:
- Literals: `"string"`, `1` (int), `1.0` (float)
- Primitive types: `bool`, `int`, `float`, `string`, `bytes`, `date`, `time`, `datetime`
- Composite: `shape[]` for array, `{[name:shape]:shape}` for mapping
- Conditional: `shape & shape` for union, `shape | shape` for option
- Grouping: `(shape)`
- Aliasing: `name=(shape)`

Views conditions are predicates that refer to attributes, where A and B are both
attributes, and `E` and `F` conditions.
- `A=B`, `A!=B`, equality (or non equality)
- `A>B`, `A>=B`, `A<B`, `A<=B`, comparisons
- `E & F`, intersection
- `E | F`, union
- `!E`, negation

Conventions:
- Type in `PascalCase`
- Field and Relation in `camelCase`

## Examples


### Data Modeling

```
# We define a shape

OrganisationStatus="active" | "inactive"

Creation: attribute set to track creation
- createdAt:datetime, datetime of creation, UTC
- updatedAt:datetime, datetime of update, UTC, same as creation by default
- deletedAt:datetime?, datetime of deletion, UTC

Organisation:
- id!:string, organisation identifier
- name@:string, organisation name
- slug{id,name}:string, combination of id and name that is URL-safe
- status:OrganisationStatus, organisation status
- members*->User.id, users that are member of this organisation
+ Creation

```

### Domain Modeling

```
Currency="NZD" | "USD"

Amount:
- amount:number
- currency:Currency

Account:
- id: number
- inflows*<Transaction.id(Transaction.to=id), transactions to this account
- outflows*<Transaction.id(Transaction.from=id), transactions from this account

Transaction:
- id:number
- from=Account.id
- to~Account.id
- date:datetime
+ Amount

```

## Process

- Start by building a glossary of terms
- Refer and align to the glossary when naming types, attributes, relations and shapes


