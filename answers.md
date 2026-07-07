# CampusCafé — Practical A Answers

## Checkpoint 1
On hot reload, only `build()` prints again — `initState()` runs exactly once
per State object's lifetime (widget creation), while `build()` reruns on
every hot reload and every `setState()` call because Flutter re-renders the
UI without recreating the State.

## Section 4 — Why setState() is required
Removing `setState()` still mutates the `_qty` map (proven by the debugPrint
showing the new value), but Flutter has no way of knowing the widget tree
needs to be redrawn, since `setState()` is the only signal that tells the
framework to rerun `build()` — without it the data changes invisibly while
the screen stays stale.
