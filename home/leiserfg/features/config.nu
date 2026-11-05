use std/config light-theme

$env.CARAPACE_LENIENT = 1 # https://carapace-sh.github.io/carapace-bin/setup/environment.html#carapace_lenient

let carapace_completer = {|place|
    # When completing a wrapped command, ask carapace about the underlying command.
    let command = if $place.command.0 == "with-aws" {
        $place.command | skip 1
    } else {
        $place.command
    }
    if ($command | is-empty) {
        []
    } else {
        carapace $command.0 nushell ...$command | from json
    }
}

$env.config = {
 color_config: (light-theme)
 show_banner: false,
 buffer_editor : $env.EDITOR
 completions: {
   case_sensitive: false # case-sensitive completions
   quick: true    # set to false to prevent auto-selecting completions
   partial: true    # set to false to prevent partial filling of the prompt
   algorithm: "fuzzy"
   external: {
   # set to false to prevent nushell looking into $env.PATH to find more suggestions
   enable: true
   # set to lower can improve completion performance at the cost of omitting some options
    max_results: 100
    completer: $carapace_completer # check 'carapace_completer'
  }
 }
}

def to_print0 [] {
    $in | str join (char -i 0)
}

def from_print0 [] {
     $in | bytes split (char -i 0) | each { decode }
}

def __parse_cmd [] {
  let text = $in
}


$env.config.keybindings ++= [
  {
    name: fuzzy_path_completion
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: {
      send: executehostcommand
      cmd: "
        let path = (rg --files | lines | input list --fuzzy 'Select path:')
        if $path != null {
          commandline edit --insert $path
        }
      "
    }
  }
]

  # Usage: with-aws terraform plan
  # Nushell commands and pipelines can be passed as a closure:
  # with-aws { aws s3 ls | lines }
  def --wrapped with-aws [command: any, ...args: string] {
     let creds = (aws configure export-credentials --format process | from json)

     with-env {
       AWS_ACCESS_KEY_ID: $creds.AccessKeyId
       AWS_SECRET_ACCESS_KEY: $creds.SecretAccessKey
       AWS_SESSION_TOKEN: $creds.SessionToken
     } {
       if (($command | describe) == "closure") {
         do $command
       } else {
         run-external $command ...$args
       }
     }
   }


# def --env awsenv [] {
#    export-env {
#       let credentials_file = (open ~/.aws/credentials | from ini)
#       let profile = ($credentials_file | columns | input list --fuzzy)
#       let credentials = ($credentials_file | get $profile)
#
#       $env.AWS_PROFILE = $profile
#       $env.AWS_ACCESS_KEY_ID = $credentials.aws_access_key_id
#       $env.AWS_SECRET_ACCESS_KEY = $credentials.aws_secret_access_key
#
#    }
# }

def tf [] {
  terraform plan -json | from json -o | where type == planned_change | get change.resource.addr | input list -m | each {|target| $"-target=($target)"} | str join " " |  commandline edit --replace $"terraform apply ($in)"
}

 def fetch-nix-index [] {
       let arch = if $nu.os-info.arch == "arm64" {
           "aarch64"
       } else {
           $nu.os-info.arch
       }

       let os_name = $nu.os-info.name | str lowercase
       let os = if $os_name == "macos" {
           "darwin"
       } else {
           $os_name
       }

       let filename = $"index-($arch)-($os)"
       let cache_dir = ($nu.home-dir | path join ".cache" "nix-index")
       let files_path = ($cache_dir | path join "files")
       let url = $"https://github.com/nix-community/nix-index-database/releases/latest/download/($filename)"

       mkdir $cache_dir
       http get --raw $url | save --force $files_path
}

