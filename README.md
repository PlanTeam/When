# When

A small, lightweight library that adds something like async/await to Swift. When uses Grand Central Dispatch.

## Usage

Complete reference documentation is available [here](http://planteam.github.io/When/).

### await operator: `!>`

Because Swift does not allow us to implement custom keywords, When implements a prefix `!>` operator
that does the same thing:

`let foo: String = !>Bar()`

Here, `Bar` is defined as `func Bar() -> Future<String>`. This blocks the current thread until a value is returned, so be careful.

When `Bar` returns a `ThrowingFuture`, the `!>` operator can throw. You would then use it like this: `let foo = try !>throwingTestFunc()`. 

### `then`

Use `then` to execute a closure after the future has completed.

```swift
Bar().then { result in
	print(result)
}
```

### Error handling with `ThrowingFuture`

Functions that would normally throw can return a `ThrowingFuture`. Throwing futures provide error handling mechanics.

```swift
ThrowingFunction().then { result in
	// do something, the code hasn't crashed
}.onError { error in
	switch error {
	// ...
	}
}
```

### Writing an asynchronous function

```swift
func fetchLotsOfData() -> Future<[UInt8]> {
	// optionally, do some processing here
	// note that the caller is still waiting
	return Future {
		// do your expensive processing here
		// ...
		// return when done:
		return data
	}
}
```

### Writing an asynchronous function that throws

```swift
func fetchLotsOfData() -> ThrowingFuture<[UInt8]> {
	return Future {
		guard someCondition else {
			// throw inside your Future-closure like you are used to!
			throw YayError.Oops
		}
		
		return data
	}
}
```

### `Completer`

When you need to hand out work to another function that uses a callback, you can use a `Completer`.

```swift
func doSomething() -> Future<Void> {
	let completer = Completer<Void>()
	handOutWork(completer)
	return completer.future
}
```

The error-supporting counterpart of `Completer` is `ThrowingCompleter`. 

### Debugging

Provide the WHEN_DEBUG_MODE compile time 

## Installing

Use the Swift Package Manager, Carthage or git submodules.