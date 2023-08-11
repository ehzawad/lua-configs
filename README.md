# lua-configs for neovim

```bash
git clone https://github.com/ehzawad/lua-configs ~/.config/nvim
```

### A tons of stuff are going on under the hood. So please make sure you're judiciously reading init.lua and then adapt it for you (yeah, I'm telling it myself too; I might forget it after a while. Software stuffs change faster than anything imo


## Make sure to have the system installed fd ripgrep and node


##### Linux users for the clipboard copy support
Add this to your zshrc or bashrc or whatevs
```
alias pbcopy="xclip -sel clip"
alias cpkey="pbcopy < ~/.ssh/id_rsa.pub"
```


```bash
sudo apt install ripgrep fd-find
```

You might have xclip installed on the system


```zshrc

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/ehz/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/ehz/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/ehz/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/ehz/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/usr/local/sbin:$PATH"

source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

function nocuda() {
    gcloud compute ssh --zone "asia-southeast1-b" "ehzawad@fastvm" --project "cudazz"
}

# Define the colors
USERNAME_COLOR="%F{magenta}"
FOLDER_COLOR="%F{cyan}" # Setting to light blue

# Customize the prompt
PROMPT="$USERNAME_COLOR%n $FOLDER_COLOR%~ %# %f"


# Function to colorize ls output
random_ls() {
  # Save the output of the real ls command
  local LS_OUTPUT=$(command ls "$@")

  # Iterate over each line (file/folder) in the output
  while IFS= read -r line; do
    # Fixed color for folders (e.g., light blue)
    local FOLDER_COLOR=94

    # If it's a directory, use the fixed color
    if [ -d "$line" ]; then
      echo -e "\e[38;5;${FOLDER_COLOR}m$line"
    else
      # Generate a unique color based on the file name
      local FILE_COLOR=$(printf '%s' "$line" | cksum | cut -f1 -d" " | awk '{print $1 % 256}')

      # Use the unique color for the file
      echo -e "\e[38;5;${FILE_COLOR}m$line"
    fi
  done <<< "$LS_OUTPUT"

  # Reset the text color
  echo -e "\e[0m"
}

# Alias the ls command to the random_ls function
alias ls='random_ls'
```
