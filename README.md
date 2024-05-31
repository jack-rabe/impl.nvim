# impl.nvim

A Neovim Plugin to streamline implementing interfaces in Go.

## Installation

First, install `impl` to generate a list of available interfaces.

```
go install github.com/jack-rabe/impl@latest
```

Then, use your preferred method or plugin manager to install [impl.nvim](https://github.com/jack-rabe/impl.nvim/).
It looks like this for [lazy.nvim](https://github.com/folke/lazy.nvim).
Note: `luarocks` must be installed for this plugin to function correctly

```
-- init.lua:
{
    'jack-rabe/impl.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    }
}
```

## Demo

https://github.com/jack-rabe/impl.nvim/assets/76982748/b8c0a82a-aa17-4ca8-bbd0-197c3dc42573
