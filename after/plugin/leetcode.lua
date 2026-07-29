-- leetcode.nvim: open with `:Leet`
-- First run: `:Leet cookie` to sign in (paste LEETCODE_SESSION cookie from browser).
-- Solutions are stored in the directory below.

require("leetcode").setup({
  lang = "python3",
  cn = { enabled = false },
  storage = {
    home = vim.fn.stdpath("data") .. "/leetcode",
    cache = vim.fn.stdpath("cache") .. "/leetcode",
  },
  injector = {
    golang = {
      before = { "package main" },
    },
    cpp = {
      before = { "#include <bits/stdc++.h>", "using namespace std;" },
    },
    python3 = {
      before = "from typing import List, Optional",
    },
  },
})
