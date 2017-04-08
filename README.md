
This package provides bindings to the
[hat-trie](https://github.com/dcjones/hat-trie) C library.

It exports one type called `HATTrie` that acts as an `Associative{String,
UInt}`.

Generally you should use Dicts for string maps, but this library can be faster
and significantly more compact on certain types of keys. Particularly it does
well on large numbers of short keys, and especially keys that tends to share
prefixes, like URLs or various types of IDs (e.g. this library was written to
index DNA sequencer read IDs and is pretty great at it).

