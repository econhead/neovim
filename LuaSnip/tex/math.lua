local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

local line_begin = require("luasnip.extras.expand_conditions").line_begin

local in_mathzone = function()
  -- The `in_mathzone` function requires the VimTeX plugin
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local tex_utils = {}
tex_utils.in_mathzone = function() -- math context detection
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function() -- comment detection
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end
tex_utils.in_env = function(name) -- generic environment detection
  local is_inside = vim.fn["vimtex#env#is_inside"](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function() -- equation environment detection
  return tex_utils.in_env("equation")
end
tex_utils.in_itemize = function() -- itemize environment detection
  return tex_utils.in_env("itemize")
end
tex_utils.in_tikz = function() -- TikZ picture environment detection
  return tex_utils.in_env("tikzpicture")
end

return {

  ---------------------Auto Hat,Bar,Overline and vector notation---------------------------

  s(
    { trig = "hat", snippetType = "autosnippet" },
    fmta("\\hat{<>}<>", {
      i(1),
      i(0),
    }, { condition = in_mathzone })
  ),

  s({
    trig = "([a-zA-Z])hat",
    regTrig = true, -- Enable regex triggering
    wordTrig = false, -- Allow triggering within words
    snippetType = "autosnippet",
  }, {
    f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. "}"
    end),
  }, {
    condition = in_mathzone,
  }),

  s(
    { trig = "bar", snippetType = "autosnippet" },
    fmta("\\bar{<>}<>", {
      i(1),
      i(0),
    }, { condition = in_mathzone })
  ),

  s({
    trig = "([a-zA-Z])bar",
    regTrig = true, -- Enable regex triggering
    wordTrig = false, -- Allow triggering within words
    snippetType = "autosnippet",
  }, {
    f(function(_, snip)
      return "\\bar{" .. snip.captures[1] .. "}"
    end),
  }, {
    condition = in_mathzone,
  }),

  s(
    { trig = "over", snippetType = "autosnippet" },
    fmta("\\overline{<>}<>", {
      i(1),
      i(0),
    }, { condition = in_mathzone })
  ),

  s({
    trig = "([a-zA-Z])over",
    regTrig = true, -- Enable regex triggering
    wordTrig = false, -- Allow triggering within words
    snippetType = "autosnippet",
  }, {
    f(function(_, snip)
      return "\\overline{" .. snip.captures[1] .. "}"
    end),
  }, {
    condition = in_mathzone,
  }),

  s({
    trig = "(\\?%w+)([.,])",
    regTrig = true, -- Enable regex triggering
    wordTrig = false, -- triggering within words
    snippetType = "autosnippet",
  }, {
    f(function(_, snip)
      return "\\vec{" .. snip.captures[1] .. "}"
    end),
  }, {
    condition = in_mathzone,
  }),

  -----------------Autosubscript-----------------------------------------------
  s({
    trig = "([A-Za-z]+)(%d+)", -- Match letters followed by digits
    regTrig = true, -- Enables regex matching
    wordTrig = false, -- Allows it to trigger inside words
    --snippetType = "autosnippet", -- Autoexpansion restricts subscipt to only one digit
  }, {
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end),
  }, {
    condition = in_mathzone,
  }),

  s({
    trig = "([A-Za-z]+)(%a+)", -- Match letters followed by letters
    regTrig = true, -- Enables regex matching
    wordTrig = false, -- Allows it to trigger inside words
  }, {
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end),
  }, {
    condition = in_mathzone,
  }),

  s(
    { trig = "sub", snippetType = "autosnippet", wordTrig = false },
    fmta("_{<>}", { i(1) }),
    { condition = in_mathzone }
  ),

  ----------------Autosuperscript-------------------------------------------------
  s({
    trig = "(%d+)([A-Za-z]+)", -- Match digit(s) followed by letter(s)
    regTrig = true,
    wordTrig = false, -- Auto expansion restricts superscript to only one digit
  }, {
    f(function(_, snip)
      return snip.captures[2] .. "^{" .. snip.captures[1] .. "}"
    end),
  }, {
    condition = in_mathzone,
  }),

  s(
    { trig = "rd", snippetType = "autosnippet", wordTrig = false },
    fmta("^{<>}", { i(1) }),
    { condition = in_mathzone }
  ),

  ----------------------------Wrap into inline and Display math mode--------------------------

  s(
    { trig = "([^%a])mm", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
    fmta("<>\\(<>\\)", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    })
  ),

  s(
    { trig = "([^%a])dd", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
    fmta("<>\\[<>\\]", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    })
  ),

  s(
    { trig = "([^%a])ee", regTrig = true, wordTrig = false },
    fmta("<>e^{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    })
  ),

  ----------------------------------------------------------------------------
  s({ trig = "...", snippetType = "autosnippet" }, { t("\\ldots") }, { condition = in_mathzone }),
  s({ trig = ",.,", snippetType = "autosnippet" }, { t("\\cdot") }, { condition = in_mathzone }),
  s({ trig = "xx", snippetType = "autosnippet", priority = 1000 }, { t("\\times") }, { condition = in_mathzone }),
  s(
    { trig = "text", snippetType = "autosnippet" },
    fmta("\\text{ <> } <>", { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -------------------Logic and set theroy----------------------------------

  s({ trig = "fll", snippetType = "autosnippet" }, { t("\\forall") }, { condition = in_mathzone }),

  s({ trig = "ext", snippetType = "autosnippet" }, { t("\\exists") }, { condition = in_mathzone }),

  s({ trig = "next", snippetType = "autosnippet" }, { t("\\nexists") }, { condition = in_mathzone }),

  s({ trig = "in", snippetType = "autosnippet" }, { t("\\in") }, { condition = in_mathzone }),

  s({ trig = "noin", snippetType = "autosnippet" }, { t("\\notin") }, { condition = in_mathzone }),

  s({ trig = "comp", snippetType = "autosnippet" }, { t("\\complement") }, { condition = in_mathzone }),

  s({ trig = "subs", snippetType = "autosnippet" }, { t("\\subset") }, { condition = in_mathzone }),

  s({ trig = "sups", snippetType = "autosnippet" }, { t("\\supset") }, { condition = in_mathzone }),

  s({ trig = "mid", snippetType = "autosnippet" }, { t("\\mid") }, { condition = in_mathzone }),

  s({ trig = "land", snippetType = "autosnippet" }, { t("\\land") }, { condition = in_mathzone }),

  s({ trig = "lor", snippetType = "autosnippet" }, { t("\\lor") }, { condition = in_mathzone }),

  s({ trig = "ni", snippetType = "autosnippet" }, { t("\\ni") }, { condition = in_mathzone }),

  s({ trig = "the", snippetType = "autosnippet" }, { t("\\therefore") }, { condition = in_mathzone }),

  s({ trig = "bec", snippetType = "autosnippet" }, { t("\\because") }, { condition = in_mathzone }),

  s({ trig = "map", snippetType = "autosnippet" }, { t("\\mapsto") }, { condition = in_mathzone }),

  s({ trig = "to", snippetType = "autosnippet" }, { t("\\to") }, { condition = in_mathzone }),

  s({ trig = "get", snippetType = "autosnippet" }, { t("\\gets") }, { condition = in_mathzone }),

  s({ trig = "<=>" }, { t("\\Leftrightarrow") }, { condition = in_mathzone }),

  s({ trig = "<->" }, { t("\\leftrightarrow") }, { condition = in_mathzone }),

  s({ trig = "emp", snippetType = "autosnippet" }, { t("\\emptyset") }, { condition = in_mathzone }),

  s({ trig = "varn", snippetType = "autosnippet" }, { t("\\varnothing") }, { condition = in_mathzone }),

  s({ trig = "=>" }, { t("\\implies") }, { condition = in_mathzone }),

  s({ trig = "<=" }, { t("\\impliedby") }, { condition = in_mathzone }),

  s({ trig = "iff", snippetType = "autosnippet" }, { t("\\iff") }, { condition = in_mathzone }),

  s({ trig = "notni", snippetType = "autosnippet" }, { t("\\not\\ni") }, { condition = in_mathzone }),

  s({ trig = "neg", snippetType = "autosnippet" }, { t("\\neg") }, { condition = in_mathzone }),

  -----------------------------------common math functions---------------

  s({ trig = "sin", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\sin") }),
  s({ trig = "cos", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\cos") }),
  s({ trig = "tan", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\tan") }),
  s({ trig = "asin", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\arcsin") }),
  s({ trig = "acos", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\arccos") }),
  s({ trig = "atan", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\arctan") }),
  s({ trig = "hsin", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\sinh") }),
  s({ trig = "hcos", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\cosh") }),
  s({ trig = "htan", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\tanh") }),
  s({ trig = "csc", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\csc") }),
  s({ trig = "sec", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\sec") }),
  s({ trig = "cot", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\cot") }),
  s({ trig = "log", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\log") }),
  s({ trig = "ln", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\ln") }),
  s({ trig = "exp", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\exp") }),
  s({ trig = "lim", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\lim") }),
  s({ trig = "max", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\max") }),
  s({ trig = "min", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\min") }),
  s({ trig = "sup", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\sup") }),
  s({ trig = "inf", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\inf") }),
  s({ trig = "arg", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\arg") }),
  s({ trig = "det", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\det") }),
  s({ trig = "dim", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\dim") }),
  s({ trig = "gcd", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\gcd") }),
  s({ trig = "lcm", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\lcm") }),
  s({ trig = "mod", wordTrig = false, snippetType = "autosnippet", condition = in_mathzone }, { t("\\mod") }),

  -------------------------------------fractions---------------------------------

  s({
    trig = "ff",
    snippetType = "autosnippet",
  }, fmta("\\frac{<>}{<>}", { i(1), i(2) }), { condition = in_mathzone }),

  s(
    {
      trig = "(\\?[%w\\]+[%^_%d{}]*)/",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
    },
    {
      t("\\frac{"),
      f(function(_, snip)
        return snip.captures[1] or ""
      end), -- Extracts the numerator
      t("}{"),
      i(1),
      t("}"),
      i(0), -- Cursor at the end
    },
    { condition = in_mathzone } -- Ensures expansion only in math mode
  ),

  s(
    {
      trig = "^.+%)%/", -- Match any expression ending with `)/`
      regTrig = true,
      wordTrig = false,
      --snippetType = "autosnippet",
    },
    {
      f(function(_, snip)
        local stripped = snip.trigger:sub(1, -2) -- Remove trailing `/`
        local depth, idx = 0, #stripped -- Use `idx` instead of `i`

        while idx > 0 do
          local char = stripped:sub(idx, idx)
          if char == ")" then
            depth = depth + 1
          end
          if char == "(" then
            depth = depth - 1
          end
          if depth == 0 then
            break
          end
          idx = idx - 1
        end

        if idx > 0 then
          -- Extract correctly by removing both enclosing parentheses
          local numerator = stripped:sub(idx + 1, -2) -- Remove the last `)`
          local prefix = stripped:sub(1, idx - 1) -- Keep anything before `(`

          return prefix .. "\\frac{" .. numerator .. "}"
        else
          return stripped -- Fallback in case of a pattern error
        end
      end),
      t("{"),
      i(1),
      t("}"), -- Insert empty denominator for manual input
      i(0), -- Final cursor position
    },
    { condition = in_mathzone } -- Ensures it only expands inside math mode
  ),

  s(
    { trig = "fv", snippetType = "autosnippet" },
    fmta("\\frac{<>}{<>}", {
      d(1, get_visual),
      i(2),
    }),
    {
      condition = in_mathzone,
    }
  ),
}
