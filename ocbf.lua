local unicode = require("unicode")

local ocbf = {}
local charpattern = utf8 and utf8.charpattern or "[\0-\x7F\xC2-\xF4][\x80-\xBF]*"

local function readstr(f)
  local count, reason = f:read(1)
  if not count then return nil, reason or "unexpected EOF" end

  count = string.unpack(">B", count)
  local data, reason = f:read(count)
  if not data or #data ~= count then return nil, reason or "unexpected EOF" end
  
  return data
end

function readchr(f)
  local c1, reason = f:read(1)
  if not c1 then return nil, reason or "unexpected EOF" end

  local ctr, c = -1, math.max(c1:byte(), 128)

  repeat
    ctr = ctr + 1
    c = (c - 128) * 2
  until c < 128

  local crest, reason = f:read(ctr)
  if not crest or #crest ~= ctr then return nil, reason or "unexpected EOF" end

  return c1 .. crest
end

function ocbf.load(path)
  local font = {sizes = {}}

  local f, reason = io.open(path, "rb")
  if not f then return nil, reason end

  if f:read(4) ~= "ocbf" then return nil, "bad signature" end

  font.family, reason = readstr(f) 
  if not font.family then return nil, reason end

  font.style, reason = readstr(f) 
  if not font.style then return nil, reason end

  while true do
    local char = readchr(f)
    if not char then break end

    local sizewidth, reason = f:read(2)
    if not sizewidth or #sizewidth ~= 2 then
      return nil, reason or "unexpected EOF"
    end

    local size, width = string.unpack(">BB", sizewidth)
    local len = math.ceil(size * width / 8)

    local data = f:read(len)
    if not data or #data ~= len then return nil, reason or "unexpected EOF" end
  
    if not font.sizes[size] then font.sizes[size] = {} end
    font.sizes[size][char] = {}
    font.sizes[size][char] = {width = width, data = data}
  end

  f:close()
  return font
end

function ocbf.drawchar(set, font, size, char, x, y)
  local char = font.sizes[size][char]
  local i = 0

  for by = 0, size - 1 do
    for bx = 0, char.width - 1 do
      local bytei = math.floor((by * char.width + bx) / 8)
      local biti = 7 - (by * char.width + bx) % 8
      local byte = string.byte(char.data:sub(bytei + 1, bytei + 1))

      if byte >> biti & 1 == 1 then
        set(bx + x, by + y, 1)
      else
        set(bx + x, by + y, 0)
      end
      i = i + 1
    end
  end
end

function ocbf.draw(set, font, size, str, x, y)
  local ix = x
  for i = 1, unicode.len(str) do
    local char = unicode.sub(str, i, i)
    if char == "\n" then
      x = ix
      y = y + size
    else
      ocbf.drawchar(set, font, size, char, x, y)
      x = x + font.sizes[size][char].width
    end
  end
end

function ocbf.width(font, size, str)
  local width = 0

  for i = 1, unicode.len(str) do
    local char = unicode.sub(str, i, i)
    width = width + font.sizes[size][char].width
  end

  return width
end

return braille

