-- love uses luajit with some extras (unpack) from 5.2
std = "love+luajit+lua52"

-- These are acceptable to me, but not currently necessary.
--~ max_line_length    = false -- Do not limit line length.
--~ unused_secondaries = false -- Filter out warnings related to unused variables set together with used ones.

self = false -- ignore "unused implicit self"

exclude_files = {
    -- leafo/gh-actions-lua & luarocks put lua files here
    '.install',
    '.lua',
    '.luarocks',
}

-- vim:set et sw=4 ts=4 ft=lua:
