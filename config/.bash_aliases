shopt -s expand_aliases

alias gitls="git ls-files -oc --exclude-standard 2>/dev/null"

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
  gitls | xargs -I {} sed -i "s/$1/$2/g" {}
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

alias gitlsdirs="list_dirs | gitls_for_dir"
alias gack="(gitls || gitlsdirs) | ack -x"

alias dc="docker-compose"
alias gf="git fetch origin master:master"
alias dcl="docker-compose logs --follow"

alias vim="nvim"
