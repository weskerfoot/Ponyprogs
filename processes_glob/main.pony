use "files"
use "glob"

class ProcessHandler
  let env : Env

  new ref create(env' : Env) =>
    env = env'

  fun apply(path : FilePath,
            entries' : Array[String] ref) =>
    this.env.out.write(path.path + "\n")
    match OpenFile(path)
    | let file: File =>
      while file.errno() is FileOK do
        this.env.out.write(file.read(1024))
      end
    else
      None
    end

class ProcessStatus
  fun getProcesses(cap : AmbientAuth, env : Env) =>
    let glob = Glob.create()

    try
      let proc_dir = FilePath(cap, "/proc")?

      glob.iglob(proc_dir, "[0-9]*/stat", ProcessHandler.create(env))
    else
      None
    end
    None

actor Main
  new create(env : Env) =>
    let procstat = ProcessStatus.create()
    try
      procstat.getProcesses(env.root as AmbientAuth, env)
    else
      None
    end
