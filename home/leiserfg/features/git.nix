{
  pkgs,
  lib,
  config,
  ...
}:
let
  userEmail = "leiserfg@gmail.com";
  userName = "leiserfg";
  ssh_key = "/home/leiserfg/.ssh/id_rsa.pub";
in
{
  home.packages = builtins.attrValues {
    inherit (pkgs)
      # git-filter-repo
      glab
      # git-branchless
      jjui
      mergiraf
      ;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;

    ignores = [
      ".direnv"
      # ".envrc"
    ];

    settings = {
      user = {
        email = userEmail;
        name = userName;
      };

      signing.key = ssh_key;
      signing.signByDefault = true;

      aliases = {
        st = "status -sb";
        ci = "commit";
        co = "checkout";
        br = "branch";
        down = "clone --depth=1";
        delouse = "!f() { curr_sha=`git rev-parse HEAD`; git reset HEAD~1;git commit --allow-empty --no-verify -C \"$curr_sha\"; }; f";
        cp = "cherry-pick";
        cps = "cherry-pick -s";
        today = "diff @{yesterday}.. --stat";
        meh = "commit --amend";
        wdiff = "diff --word-diff=color";
        wshow = "show --word-diff=color";
        lasttag = "!git tag --sort=-creatordate|head -n 1";
        branches = "branch -vv";
        comerge = "!x() { target=`git symbolic-ref HEAD`; git co $1; git merge $target; }; x";
        ours = "!f() { git checkout --ours -- $@ && git add -- $@; }; f";
        theirs = "!f() { git checkout --theirs -- $@ && git add -- $@; }; f";
        ignore = "!gi() { curl -L -s https://www.gitignore.io/api/$@ ;}; gi";
        yolo = "!git add -A && git commit -m \"$(curl --silent --fail https://raw.githubusercontent.com/ngerakines/commitment/master/commit_messages.txt| shuf -n 1 -)\"";
        origin = "config --get remote.origin.url";
        current = "rev-parse --abbrev-ref HEAD";
        out = "!git log origin/$(git current)..";
        fixup = "!git commit --amend --no-edit --no-verify --allow-empty\n";
        fixit = "!f() { git commit --fixup=$1; GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash $1~1; }; f";
        wip = "!git add --all . && git commit -m 'WIP'";
        root = "!pwd";
        upstream = "!git branch --set-upstream-to=origin/$(git current) $(git current)";
        repo = "!git remote -v | grep '@.*fetch' | sed 's/.*:\\(.*\\).git.*/\\1/g'";
        # Welcome to fzf heaven. xargs hell
        fbr = "!BRANCH=`git recent | fzf` && git checkout $BRANCH";
        ffix = "!HASH=`git log --pretty=oneline | head -n 100 | fzf` && git fixit `echo $HASH | awk '{ print $1 }'`";
        flog = "!HASH=`git log --pretty=oneline | head -n 100 | fzf` && echo $HASH | awk '{ print $1 }' | xargs echo -n | wl-copy";
        frebase = "!HASH=`git log --pretty=oneline | head -n 100 | fzf` && git rebase -i `echo $HASH | awk '{ print $1 }'`^";

        fed = "!FILES=`git status -s | awk '{ print $2 }' | fzf -x -m` && $EDITOR $FILES";
        fedconflicts = "!FILES=`git status -s | grep '^[UMDA]\\{2\\} ' | awk '{ print $2 }' | fzf -x -m` && nvim $FILES";
        fgrep = "!sh -c 'FILES=`git grep -l -A 0 -B 0 $1 $2 | fzf -x -m` &&  $EDITOR `echo $FILES | cut -d':' -f1 | xargs`' -";
        fedlog = "!HASH=`git log --pretty=oneline | head -n 50 | fzf` && HASHZ=`echo $HASH | awk '{ print $1 }'` && FILES=`git show --pretty='format:' --name-only $HASHZ | grep -v -e '^$' | fzf -x -m` && nvim $FILES";
        freset = "!HASH=`git log --pretty=oneline | head -n 50 | fzf` && git reset --soft `echo $HASH | awk '{ print $1 }'`^";
        pr = "!gh pr";
      };

      protocol = {
        version = 2;
      };
      init = {
        defaultBranch = "master";
      };
      branch = {
        sort = "-committerdate";
      };
      tag = {
        sort = "version:refname";
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      status = {
        short = true;
      };
      diff = {
        algorithm = "histogram";
        indentheuristic = true;
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      merge = {
        conflictstyle = "zdiff3";
      };
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      pull = {
        rebase = true;
      };
      rebase = {
        autoStash = true;
        autoSquash = true;
        updateRefs = true;
      };
      help = {
        autocorrect = "prompt";
      };
      commit = {
        verbose = true;
      };
      gpg = {
        format = "ssh";
      };
      feature = {
        manyFiles = true;
      };
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
    };
  };

  programs.gh = {
    enable = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {

      user = config.programs.git.settings.user;

      signing = {
        behavior = "own";
        backend = "ssh";
        key = ssh_key;
      };

      # git = {
      #   sign-on-push = true;
      # };

      git.fetch = [
        "origin"
        "upstream"
      ];

      # fsmonitor.backend = "watcher";

      ui.diff-formatter = [
        "env"
        "DFT_BACKGROUND=light"
        (lib.getExe pkgs.difftastic)
        "--color=always"
        "$left"
        "$right"
      ];

      experimental-advance-branches = {
        enabled-branches = [ "glob:*" ];
        disabled-branches = [
          "main"
          "master"
        ];
      };

      aliases =
        let
          sh = cmd: [
            "util"
            "exec"
            "--"
            "bash"
            "-c"
            # bash
            (''
              set -euo pipefail
              ${cmd}
            '')
            "" # This will be replaced by bash with $@
          ];
        in
        {
          ll = [
            "log"
            "-T"
            "log_with_files"
          ];
          tug = [
            "bookmark"
            "move"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
          ];
          rebase-all = [
            "rebase"
            "-s"
            "all:roots(trunk()..mutable())"
            "-d"
            "trunk()"
          ];
          z = sh ''
            jj bookmark list -a -T 'separate("@", name, remote) ++ "\n"' 2> /dev/null | sort | uniq | fzf | xargs jj new
          '';
          pre-commit = sh (
            # bash
            ''
              [ ! -f "$(jj root)/.pre-commit-config.yaml" ] || ${lib.getExe' pkgs.prek "prek"} run -a
            '');
          push = sh (
            # bash
            ''
              jj pre-commit && jj git push "$@"
            '');
          prc = sh ''
            gh pr create --head $(jj log -T "bookmarks" --no-graph -r @) "$@"
          '';
          prw = sh ''
            gh pr view  $(jj log -T "bookmarks" --no-graph -r @) -w "$@"
          '';

          prm = sh ''
            gh pr merge  $(jj log -T "bookmarks" --no-graph -r @) "$@"
          '';
        };
      templates = {
        log_node = ''
          if(self && !current_working_copy && !immutable && !conflict && in_branch(self),
            "◇",
            builtin_log_node
          )
        '';
      };
      template-aliases = {
        "in_branch(commit)" = ''commit.contained_in("immutable_heads()..bookmarks()")'';

        log_with_files = ''
          if(root,
            format_root_commit(self),
            label(if(current_working_copy, "working_copy"),
              concat(
                format_short_commit_header(self) ++ "\n",
                separate(" ",
                  if(empty, label("empty", "(empty)")),
                  if(description,
                    description.first_line(),
                    label(if(empty, "empty"), description_placeholder),
                  ),
                ) ++ "\n",
                if(self.contained_in("recent_work"), diff.summary()),
              ),
            )
          )
        '';

      };
      revset-aliases = {
        recent_work = "ancestors(visible_heads(), 3) & mutable()";
      };
      revsets = {
        # log = "(trunk()..@):: | (trunk()..@)-";
      };

    };
  };
}
