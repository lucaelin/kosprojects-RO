SAS on.
lock THROTTLE to 1.

stage.
wait 0.8.
stage.

when ALTITUDE > 1000 then {
  toggle AG1.
}

when ALTITUDE > 10000 then {
  toggle AG1.
}

when ALTITUDE > 50000 then {
  toggle AG1.
}

when ALTITUDE > 150000 then {
  toggle AG1.
}


when ALTITUDE > 1000 then {
  when VERTICALSPEED < 0 then {
    toggle AG2.
  }
}

wait until false.
