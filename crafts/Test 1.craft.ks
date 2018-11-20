local testlib is import("lib/Testlib 1").

export(LIST({
  print "running test 1 now.".
  print "imported " + testlib.
},{
  print "Press any key to continue...".
  wait until TERMINAL:INPUT:HASCHAR().
  TERMINAL:INPUT:GETCHAR().
},{
  print "Press any key to complete the mission...".
  wait until TERMINAL:INPUT:HASCHAR().
  TERMINAL:INPUT:GETCHAR().
})).
