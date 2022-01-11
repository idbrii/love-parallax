-- https://github.com/idbrii/love-parallax
--[[
Copyright (c) 2021 David Briscoe
Released under the MIT License
]]
local parallax = {}
local parallaxMt = {__index = parallax}

function parallax.new(target, scale, speed)
    local p = setmetatable({
            target = target,
            scale = scale,
            speed = speed or 1,
            mode = 'transform',
            offsetX = 0, offsetY = 0,
        }, parallaxMt)
    return p
end

function parallax:draw(f)
    love.graphics.push(self.mode)
    love.graphics.origin()
    love.graphics.translate(self.target.w2 + self.offsetX, self.target.h2 + self.offsetY)
    love.graphics.rotate(-self.target.angle)
    love.graphics.scale(self.target.scale * self.scale)
    love.graphics.translate(-self.target.x * self.speed, -self.target.y * self.speed)

    f()

    love.graphics.pop()
end

-- Call from within your function passed to parallax:draw to infinitely tile a
-- background image. If you've implemented rotation or resolution independence,
-- you may want to copy this into your own project to modify as needed.
function parallax:draw_tiled_xy(x, y, image)
    local art_pixels_x,art_pixels_y = image:getDimensions()
    local min_x,min_y = love.graphics.inverseTransformPoint(0,0)
    local max_x,max_y = love.graphics.inverseTransformPoint(love.window.getMode())

    -- Offset in steps of image width to first visible.
    local num_before_pos = math.floor((min_x - x) / art_pixels_x)
    x = x + (art_pixels_x * num_before_pos)
    num_before_pos = math.floor((min_y - y) / art_pixels_y)
    y = y + (art_pixels_y * num_before_pos)

    local count = 0
    local start_x = x
    repeat
        x = start_x
        repeat
            love.graphics.draw(image, x, y)
            count = count + 1
            -- DEBUG: Indicate where image starts to help debug gaps/mismatch.
            --~ love.graphics.rectangle('fill', x, y, 50, max_y)
            --~ love.graphics.rectangle('fill', x, y, max_x, 50)
            x = x + art_pixels_x
        until x > max_x
        y = y + art_pixels_y
    until y > max_y

    --~ -- DEBUG: Show screen left/right to show we can draw without moving.
    --~ local w,h = 100,2000
    --~ love.graphics.setColor(0.3,0,1,1) -- dark purple
    --~ love.graphics.rectangle('fill', min_x,   min_y, w, h)
    --~ love.graphics.setColor(0.7,0,1,1) -- light purple
    --~ love.graphics.rectangle('fill', max_x-w, min_y, w, h)
    --~ love.graphics.setColor(1,1,1,1)

    return count
end

-- Call from within your function passed to parallax:draw to infinitely tile a
-- background image on a single axis. If you've implemented rotation or
-- resolution independence, you may want to copy this into your own project to
-- modify as needed.
local cache = { -- cache to avoid per-frame table creation
    pos = {}, min = {}, max = {}, size = {}
}
function parallax:draw_tiled_single_axis(x, y, image, axis)
    local pos, min, max, art_pixels = cache.pos, cache.min, cache.max, cache.size
    pos.x,pos.y = x,y
    art_pixels.x,art_pixels.y = image:getDimensions()
    min.x,min.y = love.graphics.inverseTransformPoint(0,0)
    max.x,max.y = love.graphics.inverseTransformPoint(love.window.getMode())

    assert(pos[axis], "axis must be x or y")

    -- Offset in steps of image width to first visible.
    local num_before_pos = math.floor((min[axis] - pos[axis]) / art_pixels[axis])
    pos[axis] = pos[axis] + (art_pixels[axis] * num_before_pos)

    local count = 0
    repeat
        love.graphics.draw(image, pos.x, pos.y)
        count = count + 1
        -- DEBUG: Indicate where image starts to help debug gaps/mismatch.
        --~ love.graphics.rectangle('fill', pos.x, pos.y, 50, max.y)
        --~ love.graphics.rectangle('fill', pos.x, pos.y, max.x, 50)
        pos[axis] = pos[axis] + art_pixels[axis]
    until pos[axis] > max[axis]

    --~ -- DEBUG: Show screen left/right to show we can draw without moving.
    --~ local w,h = 100,2000
    --~ love.graphics.setColor(0.3,0,1,1) -- dark purple
    --~ love.graphics.rectangle('fill', min.x,   min.y, w, h)
    --~ love.graphics.setColor(0.7,0,1,1) -- light purple
    --~ love.graphics.rectangle('fill', max.x-w, min.y, w, h)
    --~ love.graphics.setColor(1,1,1,1)

    return count
end

-- To adjust a layer's position relative to the target.
function parallax:setOffset(x,y)
    self.offsetX = x or 0
    self.offsetY = y or 0
end

-- To adjust a layer's position relative to the target. Useful to interactively
-- move the layer to match your other art.
function parallax:translateOffset(dx,dy)
    assert(type(dx) == "number")
    assert(type(dy) == "number")
    self.offsetX = self.offsetX + dx
    self.offsetY = self.offsetY + dy
end

return parallax
