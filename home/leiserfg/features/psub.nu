def tmp_pipe [] {
  let pipe = mktemp -d | path join (random uuid)
  mkfifo $pipe
  $pipe
}

def cleanup_job [pipe:path, timeout] {
  job spawn -d psub_cleanup {
    let $id = job recv
    try {
      if $timeout != null { job recv --timeout $timeout } else { job recv }
    } catch {
      job kill $id
      print -e $"psub task id ($id) timed out"
    }
    rm -rf ($pipe | path dirname)
  }
}

def main_job [pipe:path, write:bool, task, cleanup:int] {
  use std/assert
  assert ((not $write) or ($task | is-not-empty)) "Needs a task to write to"
  
  job spawn -d psub {
    job id | job send $cleanup
    if $write {
      open -r $pipe | do $task
    } else {
      try {
        job recv | do ($task | default {{||}}) | save --append $pipe
      } catch {|err|
        let code = $err.json | from json | get code
        if ($code != "nu::shell::io::broken_pipe") {
          error make $err
        }
      }
    }
    job send $cleanup
  }
}

# Emulation for bash's process substitution syntax `<( ... )` and `>( ... )`
#
# Executes a task in a background thread, returning a path
# to a fifo pipe being written to by said task. The pipe can
# then be read from to get the output of the task.
#
# If `--write` is passed, then instead of the task writing to
# the pipe, it will instead read from it. If the flag seems
# backwards, it's because the flag is meant to represent
# what the *caller* will do with the returned pipe,
# rather than what the given task will do.
#
# In read mode, the incoming pipeline is directed to the task
# without collecting it.
export def main [
  task?: closure # The task to run
  --write(-w) # Have the task read from the produced pipe instead of write to it so that a caller can write to it
  --timeout(-t): duration # Abort the spawned task after a given amount of time
]: [
  any -> path
] {
  do {|pipe|
    job send (main_job $pipe $write $task (cleanup_job $pipe $timeout))
    $pipe
  } (tmp_pipe)
}
