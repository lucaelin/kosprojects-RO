runpath("0:/basics/lib/telemetry.ks").
startTelemetryLogging(3).

lock THROTTLE to 1.
wait 3.
stage.

wait until false.
