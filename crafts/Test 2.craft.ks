
export(LIST({
  print "running test 2 now.".
},{
  print "Press any key to continue...".
  wait until TERMINAL:INPUT:HASCHAR().
  TERMINAL:INPUT:GETCHAR().
},{
  print "Press any key to complete all the tests...".
  wait until TERMINAL:INPUT:HASCHAR().
  TERMINAL:INPUT:GETCHAR().
})).
