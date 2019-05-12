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
  fun getProcesses(cap : AmbientAuth, env : Env) =>
    try
      let proc_dir = FilePath(cap, "/proc")?
      proc_dir.walk(ProcessHandler.create(env))
    else
      None
    end
    None

actor Main
  new create(env : Env) =>
    let test = ProcessStatus.create()
    try
      test.getProcesses(env.root as AmbientAuth, env)
    else
      None
    end
