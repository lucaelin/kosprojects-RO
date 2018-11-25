@lazyglobal off.
parameter export.
local class is LEX().
{
@content
}
export({
  parameter this is LEX().

  for membername in class:KEYS {
    local member is class[membername].
    if member:ISTYPE("delegate") {
      set this[membername] to member:BIND(this).
    } else {
      set this[membername] to member.
    }
  }
  return this["constructor"]().
}).
