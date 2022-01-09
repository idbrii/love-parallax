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
