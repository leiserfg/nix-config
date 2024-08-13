{pkgs, ...}: {
  home.packages = [pkgs.git-filter-repo];
  programs.git = {
    enable = true;
    delta.enable = true;
    lfs.enable = true;

    userEmail = "leiserfg@gmail.com";
    userName = "leiserfg";
    signing.key = "/home/leiserfg/.ssh/id_rsa.pub";

    ignores = [
      ".direnv"
      ".envrc"
    ];

    aliases = {
      st = "status -sb";
      ci = "commit";
      co = "checkout";
      br = "branch";
      down = "clone --depth=1";
      delouse = "!f() { curr_sha=`git sha`; git reset HEAD~1;git commit --allow-empty --no-verify -C \"$curr_sha\"; }; f";
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
      flog = "!HASH=`git log --pretty=oneline | head -n 100 | fzf` && echo $HASH | awk '{ print $1 }' | xargs echo -n | xsel --clipboard --input";
      frebase = "!HASH=`git log --pretty=oneline | head -n 100 | fzf` && git rebase -i `echo $HASH | awk '{ print $1 }'`^";

      fed = "!FILES=`git status -s | awk '{ print $2 }' | fzf -x -m` && $EDITOR $FILES";
      fedconflicts = "!FILES=`git status -s | grep '^[UMDA]\\{2\\} ' | awk '{ print $2 }' | fzf -x -m` && nvim $FILES";
      fgrep = "!sh -c 'FILES=`git grep -l -A 0 -B 0 $1 $2 | fzf -x -m` &&  $EDITOR `echo $FILES | cut -d':' -f1 | xargs`' -";
      fedlog = "!HASH=`git log --pretty=oneline | head -n 50 | fzf` && HASHZ=`echo $HASH | awk '{ print $1 }'` && FILES=`git show --pretty='format:' --name-only $HASHZ | grep -v -e '^$' | fzf -x -m` && nvim $FILES";
      freset = "!HASH=`git log --pretty=oneline | head -n 50 | fzf` && git reset --soft `echo $HASH | awk '{ print $1 }'`^";
      pr = "!gh pr";
    };

    extraConfig = {
      protocol = {version = 2;};
      init = {defaultBranch = "master";};
      rerere = {enabled = true;};
      status = {short = true;};
      diff = {
        algorithm = "histogram";
        indentheuristic = true;
      };
      push = {default = "current";};
      pull = {rebase = true;};
      rebase = {autoStash = true;};
      gpg = {format = "ssh";};
      commit = {gpgsign = true;};
      tag = {gpgsign = true;};
      feature = {manyFiles = true;};
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
    };
  };

  programs.gh = {enable = true;};
}
