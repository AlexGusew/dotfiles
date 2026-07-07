set -g fish_greeting


bind \cf forward-char
bind -M insert \cf accept-autosuggestion

# ~/.config/fish/functions/nvm.fish
function nvm
  bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end

# ~/.config/fish/functions/nvm_find_nvmrc.fish
function nvm_find_nvmrc
  bass source ~/.nvm/nvm.sh --no-use ';' nvm_find_nvmrc
end

# ~/.config/fish/functions/load_nvm.fish
# Removed --on-variable="PWD" to prevent running on every directory change
# Call manually with 'load_nvm' when you need to switch node versions
function load_nvm
  set -l default_node_version (nvm version default)
  set -l node_version (nvm version)
  set -l nvmrc_path (nvm_find_nvmrc)
  if test -n "$nvmrc_path"
    set -l nvmrc_node_version (nvm version (cat $nvmrc_path))
    if test "$nvmrc_node_version" = "N/A"
      nvm install (cat $nvmrc_path)
    else if test "$nvmrc_node_version" != "$node_version"
      nvm use $nvmrc_node_version
    end
  else if test "$node_version" != "$default_node_version"
    echo "Reverting to default Node version"
    nvm use default
  end
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx EDITOR nvim

# ~/.config/fish/config.fish
# Commented out to prevent slow startup - call 'load_nvm' manually when needed
# load_nvm > /dev/stderr

alias ls 'eza --icons'

starship init fish | source

zoxide init fish | source

fzf --fish | source

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

if not set -q WAYLAND_DISPLAY; and test "$XDG_VTNR" = "1"
   set -gx XDG_CURRENT_DESKTOP Hyprland
   exec start-hyprland
end

# Add local bin to PATH
fish_add_path -p "$HOME/.local/bin"

# Lazy-load emsdk - only source when emsdk commands are used
set -g EMSDK_LOADED 0
function __emsdk_lazy_load
    if test $EMSDK_LOADED -eq 0
        source "/home/alex/emsdk/emsdk_env.fish"
        set -g EMSDK_LOADED 1
    end
end

# Wrapper functions for common emsdk commands
function emcc
    __emsdk_lazy_load
    command emcc $argv
end

function em++
    __emsdk_lazy_load
    command em++ $argv
end

function emconfigure
    __emsdk_lazy_load
    command emconfigure $argv
end

function emmake
    __emsdk_lazy_load
    command emmake $argv
end

# OpenClaw Completion
test -f "/home/alex/.openclaw/completions/openclaw.fish"; and source "/home/alex/.openclaw/completions/openclaw.fish"
