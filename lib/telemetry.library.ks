export({
  parameter prerun is 0.

  local t0 is TIME:SECONDS + prerun.
  if KUNIVERSE:HASSUFFIX("REALTIME") set t0 to KUNIVERSE:REALTIME.
  local indexfile is "0:/logs/mission.csv".
  local logfilename is "log_" + t0 + ".csv".
  local logfile is "0:/logs/" + logfilename.
  log logfilename + "," + SHIP:NAME + "," + t0 to indexfile.
  local starttime is TIME:SECONDS + prerun.
  local timeprecision is 100.

  local loggers is LEX().

  local lock UPFACING to -SHIP:UP * SHIP:FACING.
  local lock UPSRFPROGRADE to -SHIP:UP * SRFPROGRADE.
  local lock UPPROGRADE to -SHIP:UP * PROGRADE.
  local lock UPNORMAL to -SHIP:UP * NORMAL.

  loggers:ADD("MET", { return ROUND((TIME:SECONDS - starttime) * timeprecision) / timeprecision. }).
  loggers:ADD("THRUST", { return SHIP:AVAILABLETHRUST. }).
  loggers:ADD("MAXTHRUST", { return SHIP:MAXTHRUST. }).
  loggers:ADD("ALTITUDE", { return ALTITUDE. }).
  loggers:ADD("SPEED", { return SHIP:VELOCITY:SURFACE:MAG. }).
  loggers:ADD("GROUNDSPEED", { return GROUNDSPEED. }).
  loggers:ADD("ACCELERATION", { return SHIP:AVAILABLETHRUST / SHIP:MASS. }).
  loggers:ADD("AoA", { return VANG(SHIP:FACING:FOREVECTOR, SHIP:VELOCITY:SURFACE). }).
  loggers:ADD("Q", { return SHIP:Q. }).
  loggers:ADD("MASS", { return SHIP:MASS. }).
  loggers:ADD("ETA:APOAPSIS", { return ETA:APOAPSIS. }).
  loggers:ADD("APOAPSIS", { return APOAPSIS. }).
  loggers:ADD("PERIAPSIS", { return PERIAPSIS. }).
  loggers:ADD("__PITCH", { return UPFACING:PITCH. }).
  loggers:ADD("__YAW", { return UPFACING:YAW. }).
  loggers:ADD("__ROLL", { return UPFACING:ROLL. }).
  loggers:ADD("__SRFPROGRADE_X", { return UPSRFPROGRADE:VECTOR:X. }).
  loggers:ADD("__SRFPROGRADE_Y", { return UPSRFPROGRADE:VECTOR:Y. }).
  loggers:ADD("__SRFPROGRADE_Z", { return UPSRFPROGRADE:VECTOR:Z. }).
  loggers:ADD("__PROGRADE_X", { return UPPROGRADE:VECTOR:X. }).
  loggers:ADD("__PROGRADE_Y", { return UPPROGRADE:VECTOR:Y. }).
  loggers:ADD("__PROGRADE_Z", { return UPPROGRADE:VECTOR:Z. }).
  loggers:ADD("__NORMAL_X", { return UPNORMAL:VECTOR:X. }).
  loggers:ADD("__NORMAL_Y", { return UPNORMAL:VECTOR:Y. }).
  loggers:ADD("__NORMAL_Z", { return UPNORMAL:VECTOR:Z. }).
  loggers:ADD("THROTTLE", { return THROTTLE. }).

  log loggers:KEYS:JOIN(",") to logfile.

  on floor(time:seconds * 10) {
    local data is LIST().

    for key in loggers:KEYS {
      data:ADD(loggers[key]:CALL()).
    }

    log data:JOIN(",") to logfile.
    PRESERVE.
  }
}).
