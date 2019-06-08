local Context is import("lib/context", "class").

local contexts is LIST().
local g is GUI(400, 100).
g:SHOW().

g:ADDLABEL("kOS LOGGING").

on FLOOR(TIME:SECONDS * 10) {
  for context in contexts:COPY {
    if context["removed"] {
      contexts:REMOVE(contexts:INDEXOF(context)).
    } else {
      context["update"]().
    }
  }

  PRESERVE.
}

export(LEX(
  "createContext", {
    parameter name.

    local context is context()(g, name).

    contexts:ADD(context).

    return context.
  },
  "removeContext", {
    parameter context.

    contexts:REMOVE(contexts:INDEXOF(Context)).
    context["remove"]().
  }
)).
