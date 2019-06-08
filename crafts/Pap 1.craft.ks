local util is import("lib/util").
local event is import("lib/event").
local Orbit is import("lib/orbit", "class").
local Maneuver is import("lib/maneuver", "class").
local logging is import("lib/logging").
local landing is import("lib/landing").

set CONFIG:IPU to 1000. // TODO remove

export(LIST({
  RCS on.
  lock STEERING to SRFRETROGRADE.
  event["emit"]("orbit").
  util["awaitInput"]().
}, {
  lock STEERING to SRFRETROGRADE.
  lock THROTTLE to 1.
  wait until STAGE:READY.
  stage.
  wait until PERIAPSIS < 60000 or SHIP:AVAILABLETHRUST = 0.
  lock THROTTLE to 0.
  util["wait"](10).
  wait until STAGE:READY.
  stage.
}, {
  lock STEERING to SRFRETROGRADE.
  wait until ALTITUDE < 100000.
  event["emit"]("reentry").
  wait until STAGE:READY.
  stage.
})).
