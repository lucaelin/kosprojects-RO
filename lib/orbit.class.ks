class:ADD("constructor", {
  parameter this.
  parameter position.
  parameter velocity.
  parameter body.

  set this["x"] to startValue.

  return this.
}).

class:ADD("addOne", {
  parameter this.

  set this["x"] to this["x"] + 1.
}).

class:ADD("toString", {
  parameter this.

  return "" + this["x"].
}).
