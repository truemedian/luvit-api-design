
# Luvit Style Guide

*Adapted from the [Zig Language Style Guide](https://ziglang.org/documentation/master/#Style-Guide)*

All code provided in the Luvit 3.0 project should follow these guidelines.

## Whitespace

- 4 space indentation
- If a list has more than two items, put each item on its own line and place an extra comma at the end of the last item.
- Aim for 100-120 characters per line

## Names

Roughly speaking: `camelCaseFunctionName`, `TitleCaseClassName`, `snake_case_variable_name`. More precisely:

- if `x` is a class-like table, then `x` should be `TitleCase`.
- if `x` is callable and `x` returns a class-like table, then `x` should be `TitleCase`.
- if `x` is otherwise callable, then `x` should be `camelCase`.
- otherwise, `x` should be `snake_case`.

A class-like table can be identified by having one or more fields that are intended to hold data. For example,
`std/fs.lua`, a namespace-like table, contains only functions and another namespace (`std/fs/path.lua`).

Acronyms, initialisms, proper nouns, or any other word that has capitalization rules in written English are subject to
naming conventions just like any other word.

File names fall into two categories: classes and namespaces. If the file returns a class-like table, it should be named
like any other class-like using `TitleCase`. Otherwise, it should use `snake_case`. Directory names should be
`snake_case`.

These are general rules of thumb; if it makes sense to do something different, do what makes sense. For example, if
there is an established convention such as `ENOENT`, follow the established convention.

## Documentation Guidance

- Omit any information that is redundant based on the name of the thing being documented.
- Duplicating information onto multiple similar functions is encouraged because it helps code analysis tools provide
  better help text.
- Use the word **assume** to indicate invariants that cause undefined behavior when violated.
- Use the word **assert** to indicate invariants that cause errors when violated.

## Source Encoding

All source files should be UTF-8 encoded with LF line endings.
