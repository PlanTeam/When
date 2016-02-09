# When

A small, lightweight library that adds something like async/await. When uses Grand Central Dispatch.

## Usage

### `await` operator

Because Swift does not allow us to implement custom keywords, When implements a prefix `!>` operator
that does the same thing:

`let foo: String = !>Bar()`

Here, `Bar` is defined as `func Bar() -> Future<String>`. This blocks the current thread until a value is returned, so be careful.

### `then`

Use `then` to execute a closure after the future has completed.

```
Bar().then { result in
	print(result)
}
```