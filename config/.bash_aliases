# shopt -s expand_aliases

alias gitls="git ls-files -oc --exclude-standard -- ':!:**/pspdfkit/**' 2>/dev/null"

list_dirs() {
  for dir in */; do
    echo "$dir"
  done
}

prepend() {
  while read line; do
    echo "$1$line"
  done
}

gitls_for_dir() {
  while read dir; do
    cd $dir
    gitls | prepend $dir
    cd - >/dev/null
  done
}

greplace() {
  gitls | xargs -I@ sed -i "" "s/$1/$2/g" @
}

freplace() {
  find . -depth -name "*$1*" -execdir rename 's/$1/$2/' '{}' +
}


search_tmux_pane() {
  REQUIRED_PID=$1
  while read PID PANE; do
    if [ `pstree -p $PID | grep $REQUIRED_PID` ] ; then
      echo $PANE
    fi
  done
}

tmux_pid() {
  REQUIRED_PID=${1:-666}
  tmux list-panes -a -F "#{pane_pid} #{session_name}:#{window_index}:#{pane_index}" | search_tmux_pane $REQUIRED_PID
}

ggg() {
  local message
  if git diff --cached --quiet; then
    # No staged changes to commit, so commit all changes
    message=$(git diff | sgpt 'Come up with a suitable 1 line git commit message for these changes')
    git commit -am $message
  else
    # Staged changes exist, so commit only those
    message=$(git diff --cached | sgpt 'Come up with a suitable 1 line git commit message for these changes')
    git commit -m $message
  fi
}

alias gitlsdirs="list_dirs | gitls_for_dir"
alias gack="(gitls || gitlsdirs) | ack -x"

alias dc="docker-compose"
alias gf="git fetch origin main:main"
alias dcl="docker-compose logs --follow"

alias showdir="nautilus ."

alias vim=nvim
