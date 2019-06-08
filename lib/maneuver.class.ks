local Orbit is import("lib/orbit", "class").
local math is import("lib/math").
local util is import("lib/util").

class:ADD("constructor", {
  parameter this.
  parameter src is Orbit()().

  set this["src"] to src.
  set this["trueAnomaly"] to 0.
  set this["progradeDv"] to 0.
  set this["normalDv"] to 0.
  set this["outDv"] to 0.

  this["update"]().

  return this.
}).

class:ADD("adjustPeriapsis", {
  parameter this.
  parameter newAlt.

  local newSMA is this["src"]["a"]() + (newAlt - this["src"]["pe"]()) / 2.
  local newSpeed is SQRT(BODY:MU*((2 / this["src"]["radiusAt"](180)) - (1 / newSMA))).

  set this["trueAnomaly"] to 180.
  set this["progradeDv"] to newSpeed - this["src"]["speedAt"](180).
  set this["normalDv"] to 0.
  set this["outDv"] to 0.

  this["update"]().
}).

class:ADD("adjustApoapsis", {
  parameter this.
  parameter newAlt.

  local newSMA is this["src"]["a"]() + (newAlt - this["src"]["ap"]()) / 2.
  print newSMA.
  local newSpeed is SQRT(BODY:MU*((2 / this["src"]["radiusAt"](0)) - (1 / newSMA))).

  set this["trueAnomaly"] to 0.
  set this["progradeDv"] to newSpeed - this["src"]["speedAt"](0).
  set this["normalDv"] to 0.
  set this["outDv"] to 0.

  this["update"]().
}).

class:ADD("update", {
  parameter this.

  if SHIP:ORBIT:TRUEANOMALY > this["trueAnomaly"] set this["trueAnomaly"] to this["trueAnomaly"] + 360.
  local trueAnomaly is this["trueAnomaly"].
  local body is this["src"]["body"]().
  local burnPos is this["src"]["positionAt"](trueAnomaly).
  set this["mnvPos"] to util["storeVector"](burnPos).
  local origVel is this["src"]["velocityAt"](trueAnomaly).
  print "burn start rad: " + burnPos:MAG.
  print "burn start vel: " + origVel:MAG.

  local nrml is this["src"][">n"]().

  local mnvVel is V(0,0,0)
    + origVel:NORMALIZED * this["progradeDv"]
    + nrml:NORMALIZED * this["normalDv"]
    + VCRS(nrml:NORMALIZED, origVel:NORMALIZED):NORMALIZED * this["outDv"].

  set this["mnvVel"] to util["storeVector"](mnvVel).
  local endVel is origVel + mnvVel.
  set this["endVel"] to util["storeVector"](endVel).

  set this["dst"] to Orbit()(burnPos, endVel, body).
}).

class:ADD("exec", {
  parameter this.
  parameter leadTime is 60.
  parameter ullage is 0.

  this["update"]().

  local burn is util["loadVector"](this["mnvVel"]).

  local currentMean is math["trueToMean"](Orbit()()["ta"]()).
  local burnMean is math["trueToMean"](this["trueAnomaly"]).

  local diffMean is burnMean - currentMean.
  local await is diffMean / this["src"]["n"]().
  print "await: " + (await / 60 / 60).
  local nodeTime is TIME:SECONDS + await.
  local burnTime is nodeTime - util["burnDuration"](burn:MAG / 2).
  print util["burnDuration"](burn:MAG).

  local maneuvernode is "".
  if CAREER():CANMAKENODES {
    set maneuvernode to NODE(TIME:SECONDS + await, this["outDv"], this["normalDv"], this["progradeDv"]).
    ADD maneuvernode.
  }

  local mnvExec is this["mnvVel"].
  lock STEERING to util["loadVector"](mnvExec).
  VECDRAW(V(0,0,0), { return util["loadVector"](mnvExec). }, red, "burn", 1, true).

  KUNIVERSE:TIMEWARP:WARPTO(burnTime - leadTime).
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  wait until TIME:SECONDS > burnTime - ullage.
  set SHIP:CONTROL:FORE to 1.
  wait until TIME:SECONDS > burnTime.
  set SHIP:CONTROL:FORE to 0.

  local t is TIME:SECONDS.
  lock THROTTLE to 1.
  local done is false.
  local chase is 0.
  local myOrbit is Orbit()().
  local burnMag is SHIP:FACING:FOREVECTOR.
  wait 0.
  until done {
    local dt is TIME:SECONDS - t.
    set t to TIME:SECONDS.
    local burn to util["loadVector"](mnvExec).
    local acc is SHIP:FACING:FOREVECTOR * util["thrust"]() / SHIP:MASS.
    set burn to burn - acc * dt.
    if (
      (
        burn:MAG > SHIP:AVAILABLETHRUST / SHIP:MASS
        and VANG(burnMag - acc, SHIP:FACING:FOREVECTOR) < 90
      )
      or burnMag = SHIP:FACING:FOREVECTOR
    ) {
      myOrbit["update"]().
      local nodePos to util["loadVector"](this["mnvPos"]).
      local currentNodeTa is myOrbit["trueAnomalyAt"](nodePos).
      local currentNodeVel is myOrbit["velocityAt"](currentNodeTa).
      set burnMag to (util["loadVector"](this["endVel"]) - currentNodeVel).
      set burn:MAG to burnMag:MAG.
    }
    set burnMag to burnMag - acc * dt.
    set mnvExec to util["storeVector"](burn).

    if VANG(burn, burn - acc * dt) > 90 {
      print "burn complete".
      set done to true.
    }
    if VANG(burnMag, SHIP:FACING:FOREVECTOR) > 90 {
      print "burn kinda complete".
      set done to true.
    }
    if VANG(burn, SHIP:FACING:FOREVECTOR) > 10 {
      set chase to chase + dt.
    } else {
      set chase to chase - dt.
    }
    if chase > 5 {
      print "burn aborted, cause: chase".
      set done to true.
    }
    if SHIP:AVAILABLETHRUST = 0 {
      print "burn aborted, cause: out of fuel".
      set done to true.
    }

    print burn:MAG + "      " at (0,0).
    print dt + "      " at (0,2).
    print (1/dt) + "      " at (0,3).
    wait 0.
  }
  lock THROTTLE to 0.
  lock STEERING to "kill".
  if CAREER():CANMAKENODES {
    print "maneuver done". util["awaitInput"]().
    REMOVE maneuvernode.
  }
  CLEARVECDRAWS().
}).
