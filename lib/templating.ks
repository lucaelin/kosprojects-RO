@lazyglobal off.
{
  local registries is LEX().

  function prepareTemplate {
    parameter fileName. // ie: myscript.library.ks

    local fileTypes is filename:SPLIT("."). // ie: [myscript, library, ks]
    local cleanName is fileTypes:SUBLIST(0, fileTypes:LENGTH - 2):JOIN("."). // ie: myscript
    local templateType is fileTypes[fileTypes:LENGTH - 2]. // ie: library

    local templatename is "0:/templates/"+templateType+".template.ks". // ie: library.template.ks
    local infilename is "0:/"+cleanName+"."+templateType+".ks".
    local outfilename is "1:/"+cleanName+".bundle.ks". // myscript.bundle.ks

    if HOMECONNECTION:ISCONNECTED {
      local template is OPEN(templatename):READALL:STRING.

      if not EXISTS(infilename) {
        print "ERROR: Unable to prepare template [input "+infilename+" does not exist].".
        wait until false.
      }

      local input is OPEN(infilename).
      DELETEPATH(outfilename).
      CREATE(outfilename).
      local output is OPEN(outfilename).

      if not output:WRITE(template
        :REPLACE("@filename", fileName)
        :REPLACE("@outfilename", outfilename)
        :REPLACE("@infilename", infilename)
        :REPLACE("@content", input:READALL:STRING)
      ) {
        print "ERROR: Unable to write bundle [Insufficient space in space]".
        SHUTDOWN.
      }
    } else {
      if not EXISTS(outfilename) {
        print "ERROR: Unable to prepare template [output "+outfilename+" does not exist].".
        SHUTDOWN.
      }
    }
    return outfilename.
  }

  global function import {
    parameter name.
    parameter importType is "library".

    local fullName is name+"."+importType+".ks".

    local registry is LEX().
    if registries:HASKEY(importType)
      set registry to registries[importType].
    set registries[importType] to registry.

    if not registry:HASKEY(fullName) {
      RUNPATH(prepareTemplate(fullName), {
        parameter export.

        registry:ADD(fullName, export).
      }).
    }

    return registry[fullName].
  }
}
