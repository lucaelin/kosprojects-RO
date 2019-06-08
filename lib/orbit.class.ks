local math is import("lib/math").
local util is import("lib/util").

local cache is false. // TODO make cache work with updates

class:ADD("constructor", {
  parameter this.
  parameter r is -BODY:POSITION.
  parameter v is VELOCITY:ORBIT.
  parameter body is BODY.

  this["update"](r, v, body).

  return this.
}).

class:ADD("update", {
  parameter this.
  parameter r is -BODY:POSITION.
  parameter v is VELOCITY:ORBIT.
  parameter body is BODY.

  set r to util["storeVector"](r).
  set v to util["storeVector"](v).

  set this[">r"] to { return util["loadVector"](r). }.
  set this[">v"] to { return util["loadVector"](v). }.
  set this["body"] to { return body. }.
}).

// specific angular momentum vector
class:ADD(">h", {
  parameter this.

  local scale is (this[">v"]():MAG + this[">r"]():MAG) / 2.

  return VCRS(this[">v"]()/scale, this[">r"]()/scale)*scale*scale.
}).

// normal vector
class:ADD(">n", {
  parameter this.

  return this[">h"]():NORMALIZED.
}).

// eccentricity vector
class:ADD(">e", {
  parameter this.

  local scale is (this[">v"]():MAG + this[">h"]():MAG) / 2.

  return -VCRS(this[">v"]()/scale, this[">h"]()/scale)*scale*scale / this["body"]():MU - this[">r"]():NORMALIZED.
}).

// periapsis vector
class:ADD(">pe", {
  parameter this.

  local evec is this[">e"]().
  local l is this["pe"]() + this["body"]():RADIUS.

  set evec:MAG to l.

  return evec.
}).

// ascending node vector
class:ADD(">an", {
  parameter this.

  return VCRS(this[">h"](), this["body"]():ANGULARVEL).
}).

// semimajoraxis
class:ADD("a", {
  parameter this.

  local a is 1 / (2 / this[">r"]():MAG - this[">v"]():MAG ^ 2 / this["body"]():MU).

  if cache set this["a"] to { return a. }. // cache
  return a.
}).

// mean motion
class:ADD("n", {
  parameter this.
  local n is SQRT(this["body"]():MU / ABS(this["a"]())^3) * RADTODEG.
  if this["a"]() < 0 return -n.
  return n.
}).

// true anomaly
class:ADD("ta", {
  parameter this.

  local ta is ARCCOS( VDOT(this[">e"](), this[">r"]()) / (this["e"]() * this[">r"]():MAG)).

  local rv is VDOT(this[">r"](), this[">v"]()).
  if rv < 0 set ta to 360 - ta.

  if cache set this["ta"] to { return ta. }. // cache
  return ta.
}).

// eccentricity
class:ADD("e", {
  parameter this.

  local e is this[">e"]():MAG.

  if cache set this["e"] to { return e. }. // cache
  return e.
}).

// inclination
class:ADD("i", {
  parameter this.

  local i is VANG(this["body"]():ANGULARVEL, this[">n"]()).

  if cache set this["i"] to { return i. }. // cache
  return i.
}).

// periapsis
class:ADD("pe", {
  parameter this.

  local pe is this["a"]() * (1 - this["e"]()) - this["body"]():RADIUS.

  if cache set this["pe"] to { return pe. }. // cache
  return pe.
}).

// apoapsis
class:ADD("ap", {
  parameter this.

  local ap is this["a"]() * (1 + this["e"]()) - this["body"]():RADIUS.

  if cache set this["ap"] to { return ap. }. // cache
  return ap.
}).

class:ADD("radiusAt", {
  parameter this.
  parameter trueAnomaly.

  local eAnomaly is math["trueToEcc"](trueAnomaly).

  return this["a"]() * (1 - this["e"]() * COS(eAnomaly)).
}).

class:ADD("altitudeAt", {
  parameter this.
  parameter trueAnomaly.

  return this["radiusAt"](trueAnomaly) - this["body"]():RADIUS.
}).

class:ADD("speedAt", {
  parameter this.
  parameter trueAnomaly.

  return SQRT(this["body"]():MU * ((2 / this["radiusAt"](trueAnomaly)) - (1 / this["a"]()))).
}).

class:ADD("positionAt", {
  parameter this.
  parameter trueAnomaly.

  local vec is ANGLEAXIS(-trueAnomaly, this[">n"]()) * this[">e"]().
  set vec:MAG to this["radiusAt"](trueAnomaly).

  return vec.
}).

class:ADD("velocityAt", {
  parameter this.
  parameter trueAnomaly.

  local out is this[">e"]() + this["positionAt"](trueAnomaly):NORMALIZED.
  local pro is VCRS(out, this[">n"]()).
  set pro:MAG to this["speedAt"](trueAnomaly).

  return pro.
}).

class:ADD("trueAnomalyAt", {
  parameter this.
  parameter position.

  return math["planarAngle"](this[">pe"](), position, this[">n"]()).
}).

class:ADD("trueAnomalyAtRadius", {
  parameter this.
  parameter radius.


  local anomaly is ARCCOS((radius / this["a"]() - 1) / -this["e"]()).
  return math["eccToTrue"](anomaly).
}).
