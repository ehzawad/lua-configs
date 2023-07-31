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

You might have xclip installed on the system
