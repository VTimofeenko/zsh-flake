# My zsh config
# Originally crafted as a clone from https://github.com/VTimofeenko/zsh-config
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ 
    fzf
    # My bookmark plugin
    (writeTextFile {
      name = "bookmarks.zsh";
      text = ''${builtins.readFile ./dotfiles/zsh/bookmarks.zsh}'';
      destination = "/share/zsh/site-functions/bookmarks.zsh";
    })
    # My cursor plugin
    (writeTextFile {
      name = "cursor_mode.zsh";
      text = ''${builtins.readFile ./dotfiles/zsh/cursor_mode.zsh}'';
      destination = "/share/zsh/site-functions/cursor_mode.zsh";
    })
  ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting = {
      enable = true;
    };
    # Aliases
    # TODO: help sez 'Set of aliases for zsh shell, which overrides environment.shellAliases'
    # Need to merge them? 
    shellAliases = {
      e = "vim";  # looks like 'vim' is needed here so that proper vimrc is being picked up
      nvim = "vim";
      ls = "${pkgs.exa}/bin/exa -h --group-directories-first --icons";
      l = "ls";
      ll = "ls -l";
      la = "ls -al";
      ka = "killall";
      mkd = "mkdir -pv";
      ga = "${pkgs.git}/bin/git add";
      gau = "ga -u";
      grep = "grep --color=auto";
      mv = "mv -v";
      rm = "rm -id";
      vidir = "${pkgs.moreutils}/bin/vidir --verbose";
      # My default shortcut to copy to clipboard, TODO: make wayland/Xorg/Mac agnostic
      ccopy = "${pkgs.wl-clipboard}/bin/wl-copy";
    };
    setOptions = [
      "INTERACTIVE_COMMENTS"  # allow bash-style comments
      # history
      "BANG_HIST"  # enable logging !!-like commands
      "EXTENDED_HISTORY"          # Write the history file in the ":start:elapsed;command" format.
      "INC_APPEND_HISTORY"        # Write to the history file immediately, not when the shell exits.
      "SHARE_HISTORY"             # Share history between all sessions.
      "HIST_EXPIRE_DUPS_FIRST"    # Expire duplicate entries first when trimming history.
      "HIST_IGNORE_DUPS"          # Don't record an entry that was just recorded again.
      "HIST_IGNORE_ALL_DUPS"      # Delete old recorded entry if new entry is a duplicate.
      "HIST_FIND_NO_DUPS"         # Do not display a line previously found.
      "HIST_IGNORE_SPACE"         # Don't record an entry starting with a space.
      "HIST_SAVE_NO_DUPS"         # Don't write duplicate entries in the history file.
      "HIST_REDUCE_BLANKS"        # Remove superfluous blanks before recording entry.
      "HIST_VERIFY"               # Don't execute immediately upon history expansion.
      "HIST_FCNTL_LOCK" # enable fcntl syscall for saving history
      # cd management
      "AUTO_CD"  # automatically cd into directory
    ];
    interactiveShellInit = ''
      # Enable vim editing of command line
      ${builtins.readFile ./dotfiles/zsh/01-vim-edit.zsh}
      # Enable cd +1..9 to go back in dir stack
      ${builtins.readFile ./dotfiles/zsh/02-cd.zsh}
      # fzf bindings
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh

      # Word Navigation shortcuts
      bindkey "^A" vi-beginning-of-line
      bindkey "^E" vi-end-of-line
      bindkey "^F" end-of-line
      
      # ctrl+arrow for word jupming
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      
      # alt+f forward a word
      bindkey "^[f" forward-word
      
      # alt+b back a word
      bindkey "^[b" backward-word
      # working backspace
      bindkey -v '^?' backward-delete-char
      # TODO: alt+hjkl -> arrows

      # Use vim keys in tab complete menu
      zmodload zsh/complist
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey -M menuselect '^ ' accept-line

      # Add entry by "+" but do not exit menuselect
      bindkey -M menuselect "+" accept-and-menu-complete
      # Color the completions
      autoload -Uz compinit
      zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu select

      # Automatically escape urls when pasting
      autoload -Uz url-quote-magic
      zle -N self-insert url-quote-magic
      autoload -Uz bracketed-paste-magic
      zle -N bracketed-paste bracketed-paste-magic

      # Custom plugins (see call to pkgs.writeTextFile in the zsh.nix)
      # Bookmarks by "@@"
      autoload -Uz bookmarks.zsh && bookmarks.zsh
      # Cursor mode block <> beam
      autoload -Uz cursor_mode.zsh && cursor_mode.zsh

      # To use openpgp cards
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"

    '';
    promptInit = ''
      eval "$(${pkgs.starship} init zsh)"
      eval "$(direnv hook zsh)"
    '';
  };
}
