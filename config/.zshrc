. /opt/homebrew/opt/asdf/libexec/asdf.sh
autoload -U compinit; compinit
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# pnpm
export PNPM_HOME="/Users/rob/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Created by `pipx` on 2024-10-22 20:34:38
export PATH="$PATH:/Users/rob/.local/bin"
