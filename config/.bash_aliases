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

alias gitlsdirs="list_dirs | gitls_for_dir"
alias gack="(gitls || gitlsdirs) | ack -x"
