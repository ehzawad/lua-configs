# Modular Neovim Configuration

A carefully organized, modular Neovim configuration with intelligent terminal detection, LSP integration, completion, and modern editor features.

## Quick Install

```bash
git clone https://github.com/ehzawad/lua-configs ~/.config/nvim
```
```bash
git clone git@github.com:ehzawad/lua-configs.git ~/.config/nvim
```


## Dependencies

This configuration requires several external dependencies:

### Required

- **Nerd Font** - For icons and special characters
  - Install from [Nerd Fonts](https://www.nerdfonts.com/) or with Homebrew: 
  - `brew tap homebrew/cask-fonts && brew install --cask font-hack-nerd-font`
- **Ripgrep** - For telescope grep functionality
  - `brew install ripgrep`
- **fd** - Better find alternative for telescope
  - `brew install fd`
- **Node.js** - Required for many LSP servers
  - `brew install node` or use nvm
- **Luarocks** - Lua package manager
  - `brew install luarocks`
- **Rust** - For certain plugins and tools
  - `brew install rust`

### Recommended

- **iTerm2** (macOS) - Terminal with better color support and functionality
  - Configure Meta key (M key) in iTerm2 for additional keybindings
  - `brew install --cask iterm2`
- **make** - Required for building some plugins
  - Usually pre-installed on macOS

For Linux systems, equivalent packages will need to be installed using your distribution's package manager.

**Note:** This configuration does not officially support Windows.

## Key Features

- **Terminal Detection** - Automatically adapts UI to terminal capabilities
- **Intelligent LSP Configuration** - Easy language server setup with Mason
- **Modern Completion System** - Combines LSP and Codeium/Copilot capabilities
- **Advanced Git Integration** - Gitsigns for inline git blame and actions
- **File Navigation** - Oil.nvim and Telescope for intuitive file management
- **Code Structure** - Aerial for code outline and symbol navigation
- **Performance Optimizations** - Lazy loading and efficient plugin management

## Customizing

A ton of stuff is going on under the hood. Please read through the configuration files before making changes. The modular structure makes it easy to modify specific parts without breaking everything.

The configuration is organized in a modular fashion - core settings are separated from plugin configurations, making it easy to understand and modify specific components.

## Special Notes

1. Terminal-specific optimizations auto-adjust based on your terminal (basic Terminal.app vs. feature-rich like iTerm2)
2. Meta key (`M` key) bindings require proper iTerm2 configuration
3. The configuration regularly gets improvements - pull the latest version periodically
4. Created and maintained by Emrul Hasan Zawad (ehzawad@gmail.com)

## Troubleshooting

If you encounter issues:

1. Run `:checkhealth` to diagnose common problems
2. Use `:Lazy` to check plugin status and errors
3. See if all dependencies are properly installed
4. For LSP issues, run `:LspInfo` and `:Mason` to verify servers

## License

MIT

## Contact

For questions or suggestions: ehzawad@gmail.com
