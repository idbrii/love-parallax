-- Demonstration of parallax with gamera.
-- Creates a world with a player who can walk around the world.

local gamera = require('gamera')
local parallax = require('parallax')

local camera
local world_dimensions = {1600,1200}
local has_gravity = false
local making_waves = true
local layers = {}

local player = {
    x = world_dimensions[1] * 0.5,
    y = world_dimensions[2] * 0.5,
    velocity = {
        y = 0,
    },
    jump_height = -300,
    gravity = -500,
    width = 10,
}

local chaser = {
    x = 0,
    y = 0,
}

local function clamp(x, min, max)
    return math.min(math.max(x, min), max)
end
local function lerp(a,b,t)
    return a * (1-t) + b * t
end
local function loop(i, n)
    local z = i - 1
    return (z % n) + 1
end

local function translate(x,y)
    local half_width = player.width / 2
    player.x = clamp(player.x + x, half_width, world_dimensions[1] - half_width)
    player.y = clamp(player.y + y, half_width, world_dimensions[2] - half_width)
end

local rects = {}
local function new_rect(x, y, w, h)
    return {
        x = x - w / 2, y = y - h / 2,
        w = w, h = h,
        draw = function(self)
            love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
        end,
    }
end
local function draw_rects()
    for _, rect in ipairs(rects) do
        rect:draw()
    end
end

function love.load()
    camera = gamera.new(0,0,unpack(world_dimensions))
    layers.near = parallax.new(camera, 1.5)
    layers.far = parallax.new(camera, 0.5)
    layers.bg = parallax.new(camera, 0.25)
    layers.bg_data = {
        enabled = true,
        img = love.graphics.newImage("assets/bg-seamless-icecream.jpg"),
    }
end

function love.keyreleased(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'z' then
        making_waves = not making_waves
    elseif key == 'p' then
        has_gravity = not has_gravity
        if has_gravity then
            player.velocity.y = 1
        else
            player.velocity.y = 0
        end
    elseif key == 'n' then
        camera:setScale(loop(camera.scale + 1, 4))
    elseif key == 'm' then
        camera:setScale(camera.scale * 0.5)
    elseif key == 'b' then
        layers.bg_data.enabled = not layers.bg_data.enabled
    end
end

function love.update(dt)
    local moveSpeed = 300
    local tau = math.pi * 2
    local rotateSpeed = tau * 0.05
    local offsetMoveSpeed = 100

    if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
        -- Kill movement while moving layer
        moveSpeed = 0
        local target_layer = layers.far
        if love.keyboard.isDown('w') then target_layer:translateOffset(0, -offsetMoveSpeed * dt) end
        if love.keyboard.isDown('s') then target_layer:translateOffset(0, offsetMoveSpeed * dt) end
        if love.keyboard.isDown('a') then target_layer:translateOffset(-offsetMoveSpeed * dt, 0) end
        if love.keyboard.isDown('d') then target_layer:translateOffset(offsetMoveSpeed * dt, 0) end
    end

    if love.keyboard.isDown('a') then translate(-moveSpeed * dt, 0) end
    if love.keyboard.isDown('d') then translate(moveSpeed * dt, 0) end

    if love.keyboard.isDown('x') then camera:setAngle(camera.angle - rotateSpeed * dt) end
    if love.keyboard.isDown('c') then camera:setAngle(camera.angle + rotateSpeed * dt) end

    if has_gravity then
        -- See https://love2d.org/wiki/Tutorial:Baseline_2D_Platformer
        if love.keyboard.isDown('w') or love.keyboard.isDown('space') then
            -- infinite jumps
            player.velocity.y = player.jump_height
        end
        if player.velocity.y ~= 0 then
            player.y = player.y + player.velocity.y * dt
            player.velocity.y = player.velocity.y - player.gravity * dt
        end

        local half_width = player.width * 0.5
        local bottom = world_dimensions[2] - half_width
        if player.y > bottom then
            player.velocity.y = 0
            player.y = bottom
        end
    else
        if love.keyboard.isDown('w') then translate(0, -moveSpeed * dt) end
        if love.keyboard.isDown('s') then translate(0, moveSpeed * dt) end
    end

    if making_waves then
        local size = 16
        table.insert(rects, new_rect(player.x,player.y, size / camera.scale * 2, size / camera.scale))
    end

    -- Chase the mouse to demonstrate converting mouse to world
    -- coordinates.
    local x,y = camera:toWorld(love.mouse.getPosition())
    chaser.x = lerp(chaser.x, x, 0.025)
    chaser.y = lerp(chaser.y, y, 0.025)

    -- ## Update the camera and the target position. ##
    camera:setPosition(player.x, player.y)
end

local function draw_game(l,t,w,h)
    -- ## Draw the game here ##
    -- Draw world bounds.
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('line', 0, 0, world_dimensions[1], world_dimensions[2])

    love.graphics.setColor(1, 0, 1, 1)
    draw_rects()

    -- Draw the player (position is their centre)
    love.graphics.setColor(0, 1, 1, 1)
    local half_width = player.width * 0.5
    love.graphics.rectangle('fill', player.x - half_width, player.y - half_width, player.width, player.width)
    -- Populate the world with something.
    love.graphics.setColor(1, 0, 1, 1)
    for y=0,world_dimensions[2]-1,10 do
        for x=0,world_dimensions[1]-1,10 do
            if love.math.noise(x,y) > 0.98 then
                love.graphics.rectangle('fill', x, y, 10, 10)
            end
        end
    end
    -- Draw mouse position
    love.graphics.setColor(1, 1, 0, 1)
    local x,y = camera:toWorld(love.mouse.getPosition())
    love.graphics.circle('fill', x,y, 7,7)
    love.graphics.setColor(0.5, 1, 0, 1)
    love.graphics.circle('fill', chaser.x,chaser.y, 7,7)
end

local function draw_bg_img()
    if not layers.bg_data.enabled then
        layers.bg_data.count = 0
        return
    end
    -- To fine tune your background image positioning, adjust x,y.
    -- Here, we offset image to align with edge of world.
    local x,y = 90,380
    layers.bg_data.count = layers.bg:draw_tiled(x,y, layers.bg_data.img)
end

local function draw_all(l,t,w,h)
    love.graphics.setColor(1,1,1,0.3)
    layers.bg:draw(draw_bg_img)
    love.graphics.setColor(0,1,1,0.1)
    layers.far:draw(draw_rects)
    draw_game(l,t,w,h)
    love.graphics.setColor(1,1,0,0.5)
    layers.near:draw(draw_rects)
end

function love.draw()
    love.graphics.clear()
    camera:draw(draw_all)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Physics: " .. (has_gravity and "Platformer" or "TopDown"), 0,0, 1000)

    local w,h = love.window.getMode()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Tiled image draws: " .. layers.bg_data.count, w - 1000,0, 1000, "right")

    local x,y = camera:toScreen(world_dimensions[1]/2,world_dimensions[2]/2)
    love.graphics.circle("fill", x,y, 5,5)
    love.graphics.printf("World Center", x,y, 100, 'center')

    --~ love.graphics.printf("Draw Calls: ".. love.graphics.getStats().drawcalls, w - 1000, h - 20, 1000, "right")
end
