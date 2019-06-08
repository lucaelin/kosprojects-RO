class:ADD("constructor", {
  parameter this.
  parameter g is GUI(400,400).
  parameter name is "Unnamed context".

  set this["g"] to g.
  set this["name"] to name.

  set this["removed"] to false.

  set this["parent"] to g:ADDVLAYOUT().
  set this["title"] to this["parent"]:ADDLABEL(name).

  set this["valuelist"] to this["parent"]:ADDVBOX().

  set this["entries"] to LEX().

  return this.
}).

class:ADD("log", {
  parameter this.
  parameter name.
  parameter value.

  set this["entries"][name] to value.
}).

class:ADD("update", {
  parameter this.

  this["valuelist"]:CLEAR().
  for key in this["entries"]:KEYS {
    local layout is this["valuelist"]:ADDHLAYOUT().
    layout:ADDLABEL(key).
    layout:ADDSPACING(-1).
    local value is this["entries"][key].
    if value:ISTYPE("UserDelegate") {
      set value to value().
    }
    layout:ADDLABEL(value + "").
  }
}).

class:ADD("remove", {
  parameter this.

  this["parent"]:DISPOSE().
  set this["removed"] to true.
}).
