local M = {}

function M.setup()
  -- add blade snippets
  local ok, ls = pcall(require, "luasnip")
  if not ok then
    return
  end

  local s = ls.snippet
  local i = ls.insert_node
  local t = ls.text_node
  local d = ls.dynamic_node
  -- local f = ls.function_node
  local fmt = require("luasnip.extras.fmt").fmt
  local snippet_from_nodes = ls.sn

  ls.add_snippets("blade", {
    --- if
    s(
      { trig = "@if", desc = "if conditional" },
      fmt(
        [[@if({})
    {}
@endif]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- else
    s(
      { trig = "@else", desc = "else branch" },
      fmt(
        [[@else({})
    {}]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- elseif
    s(
      { trig = "@elseif", desc = "elseif branch" },
      fmt(
        [[@elseif({})
    {}]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- unless
    s(
      { trig = "@unless", desc = "unless conditional" },
      fmt(
        [[@unless({})
    {}
@endunless]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- isset
    s(
      { trig = "@isset", desc = "isset conditional" },
      fmt(
        [[@isset({})
    {}
@endisset]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- empty
    s(
      { trig = "@empty", desc = "empty conditional" },
      fmt(
        [[@empty({})
    {}
@endempty]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- auth
    s(
      { trig = "@auth", desc = "auth conditional" },
      fmt(
        [[@auth
    {}
@endauth]],
        { i(0, "") }
      )
    ),

    --- guest
    s(
      { trig = "@guest", desc = "guest conditional" },
      fmt(
        [[@guest
    {}
@endguest]],
        { i(0, "") }
      )
    ),

    --- production
    s(
      { trig = "@production", desc = "production conditional" },
      fmt(
        [[@production
    {}
@endproduction]],
        { i(0, "") }
      )
    ),

    --- env
    s(
      { trig = "@env", desc = "env conditional" },
      fmt(
        [[@env({})
    {}
@endenv]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- hasSection
    s(
      { trig = "@hasSection", desc = "hasSection conditional" },
      fmt(
        [[@hasSection({})
    {}
@endif]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- section missing
    s(
      { trig = "@sectionMissing", desc = "sectionMissing conditional" },
      fmt(
        [[@sectionMissing({})
    {}
@endif]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- session
    s(
      { trig = "@session", desc = "session conditional" },
      fmt(
        [[@session({})
    {}
@endsession]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- switch
    s(
      { trig = "@switch", desc = "switch statement" },
      fmt(
        [[@switch({})
    @case({})
      {}
      @break
    @endcase
    {}
@endswitch]],
        { i(1, ""), i(2, ""), i(3, ""), i(0, "") }
      )
    ),

    s(
      { trig = "@case", desc = "case for switch" },
      fmt(
        [[@case({})
    {}
    @break
@endcase]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- for
    s(
      { trig = "@for", desc = "for loop" },
      fmt(
        [[@for(${} = {}; ${} {} {}; ${}{})
    {}
@endforeach]],
        {
          i(1, "i"),
          i(2, "0"),
          d(3, function(args)
            return snippet_from_nodes(nil, {
              i(1, args[1][1] or ""),
            })
          end, { 1 }),
          i(4, "<"),
          i(5, "0"),
          d(6, function(args)
            return snippet_from_nodes(nil, {
              i(1, args[1][1] or ""),
            })
          end, { 1 }),
          i(7, "++"),
          i(0, ""),
        }
      )
    ),

    --- foreach
    s(
      { trig = "@foreach", desc = "foreach loop" },
      fmt(
        [[@foreach(${} as ${})
    {}
@endforeach]],
        { i(1, ""), i(2, ""), i(0, "") }
      )
    ),

    --- forelse
    s(
      { trig = "@forelse", desc = "forelse loop" },
      fmt(
        [[@forelse(${} as ${})
    {}
    @empty
    {}
@endforelse]],
        { i(1, ""), i(2, ""), i(3, ""), i(0, "") }
      )
    ),

    --- while
    s(
      { trig = "@while", desc = "forelse loop" },
      fmt(
        [[@while({})
    {}
@endwhile]],
        { i(1, ""), i(0, "") }
      )
    ),

    s({ trig = "@continue", des = "continue a loop" }, { t "@continue" }),
    s({ trig = "@break", des = "break a loop" }, { t "@break" }),

    --- can
    s(
      { trig = "@can", desc = "can" },
      fmt(
        [[@can({})
    {}
@endcan]],
        { i(1, ""), i(0, "") }
      )
    ),

    --- php
    s(
      { trig = "@php", desc = "php" },
      fmt(
        [[@php
    {}
@endphp]],
        { i(0, "") }
      )
    ),
  })
end

return M
