-- ~/.config/nvim/lua/plugins/aerial.lua
-- Aerial code outline plugin configuration
-- Author: ehzawad@gmail.com

local basic_terminal = require('utils.terminal').basic_terminal

require('aerial').setup({
  -- Enable icons for various kinds, adapted for terminal type
  icons = basic_terminal and {
    Array = "Array", Boolean = "Bool", Class = "Class", Constant = "Const",
    Constructor = "Constr", Enum = "Enum", EnumMember = "EnumMem",
    Event = "Event", Field = "Field", File = "File", Function = "Func",
    Interface = "Iface", Key = "Key", Method = "Method", Module = "Module",
    Namespace = "NS", Null = "NULL", Number = "Num", Object = "Obj",
    Operator = "Op", Package = "Pkg", Property = "Prop", String = "Str",
    Struct = "Struct", TypeParameter = "TypeParam", Variable = "Var",
  } or {
    Array = "󰅪",
    Boolean = "⊨",
    Class = "󰌗",
    Constant = "󰏿",
    Constructor = "",
    Enum = "",
    EnumMember = "",
    Event = "",
    Field = "󰜢",
    File = "󰈙",
    Function = "󰊕",
    Interface = "",
    Key = "󰌋",
    Method = "󰆧",
    Module = "",
    Namespace = "󰌗",
    Null = "NULL",
    Number = "#",
    Object = "󰅩",
    Operator = "󰆕",
    Package = "󰏗",
    Property = "󰜢",
    String = "󰀬",
    Struct = "󰙅",
    TypeParameter = "󰊄",
    Variable = "󰀫",
  },
  show_guides = true,
})

return {}
