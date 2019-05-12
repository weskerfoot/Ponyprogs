use "itertools"
use "files"

class ProcessHandler
  let env : Env

  new ref create(env' : Env) =>
    env = env'

  fun isNumeric(st : String) : Bool =>
    try
      if st.at_offset(0)? == 48 then
        return false
      end
    end
    Iter[U8](st.values()).all({ (c) => (c >= 48) and (c <= 57) })

  fun apply(path : FilePath, entries : Array[String] ref) =>
    let new_entries : Array[String] ref = entries.clone()
    let i : USize = 0
    for f in new_entries.values() do
      if not isNumeric(f) then
        try
          entries.delete(i)?
        else
          None
        end
      end
      i.add(1)
    end

    if path.path == "/proc" then
      return None
    end

    try
      let status = path.join("stat")?
      this.env.out.write(path.path + "\n")
      match OpenFile(status)
      | let file: File =>
        while file.errno() is FileOK do
          this.env.out.write(file.read(1024))
        end
      else
        None
      end
    end

class ProcessStatus
  let proc_path : FilePath
  let env : Env

  new create(proc_path' : FilePath,
             env' : Env) =>
    proc_path = proc_path'
    env = env'

  fun getProcesses() => proc_path.walk(ProcessHandler.create(env))

actor Main
  new create(env : Env) =>
    try
      let proc_dir = FilePath(env.root as AmbientAuth, "/proc")?
      let procstat = ProcessStatus.create(proc_dir, env)
      procstat.getProcesses()
    else
      None
    end
