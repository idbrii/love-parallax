[![Tested on love2d 11.3+
](https://img.shields.io/badge/L%F6ve-11.3%2B-pink.svg)](https://love2d.org/) [![Lint status
](https://github.com/idbrii/love-parallax/actions/workflows/luacheck.yml/badge.svg?branch=main)
](https://github.com/idbrii/love-parallax/actions?query=branch%3Amain)

# parallax

parallax is a camera utility library for [LÖVE](https://love2d.org) that
adds parallax scrolling when used with a camera library.

parallax is not itself a camera system!

parallax was developed using LÖVE 11.3, but may work on earlier versions.

## Quick Start

This is a very minimal example of using parallax, but [there's a more involved
demo](#demo).

![parallax-quick-start](https://user-images.githubusercontent.com/43559/111591121-3f28bf80-8784-11eb-9ffa-f8fb74d2f838.gif)

```lua
local gamera = require('gamera') -- https://github.com/kikito/gamera
local parallax = require('parallax')

local layers = {}
local player = {}
local camera

function love.load()
    camera = gamera.new(0,0,2000,700)
    layers.near = parallax.new(camera, 1.5)
    layers.far = parallax.new(camera, 0.25)
    player.x = camera.ww / 2
    player.base_y = camera.wh * 2 / 3
    player.jump = 100
    player.y = 0
    player.width = 10
    player.half = player.width / 2
    player.speed = 500
end

function love.update(dt)
    -- move the player around so we can see the layers move
    player.x = player.x + player.speed * dt
    if player.x <= 0 or camera.ww < player.x then
        player.speed = player.speed * -1
    end
    player.y = player.base_y + math.cos(player.x / 100) * player.jump
    camera:setPosition(player.x, player.y)
end

local function draw_all(l,t,w,h)
    local rect_w = 50
    local offset = camera.ww * 2

    layers.far:draw(function()
        -- Draw something distant from the camera here.
        love.graphics.setColor(0,0.2,0.7,0.3)
        for x=-offset,offset,rect_w do
            local rh = love.math.noise(x/w) * 1200
            love.graphics.rectangle('fill', x, -900, rect_w, rh)
        end
    end)

    -- Draw the game here
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle('fill', player.x - player.half, player.y - player.half, player.width, player.width)
    love.graphics.setColor(0,0.7,0.7,0.3)
    love.graphics.rectangle('fill', -camera.ww, player.base_y + player.jump, camera.ww * 2, camera.wh)

    layers.near:draw(function()
        -- Draw something near the camera here.
        for x=-offset,offset,rect_w do
            local rh = love.math.noise(x/w) * 150
            love.graphics.rectangle('fill', x, camera.wh - 50, rect_w, -rh)
        end
    end)
end

function love.draw()
    love.graphics.clear()
    camera:draw(draw_all)
end
```

## Demo

There's a [demo branch](https://github.com/idbrii/love-parallax/tree/demo) that
demonstrates a more complex program using parallax. It uses
[gamera](https://github.com/kikito/gamera) for its camera and demonstrates
multiple ways the camera can be transformed while maintaining correct parallax
orientation.


## Functions

### parallax.new(camera, scale, speed)

Creates a new parallax object.

- `camera`: _table_. A camera object containing x,y (camera position), w2,h2 (half camera width and height), angle (camera rotation), and scale (camera scaling factor). gamera provides all of these.
- `scale`: _number_. The scale for this layer. Larger numbers look closer and smaller look more distant.
- `speed`: _number_. Optional. A speed scale for this layer's movement. A number closer to zero makes it move slower (and look more distant) without changing its size.

### layer:draw(f)

Draw input function on the parallax layer. Should be called inside love.draw.

- `f`: _function_ A function that does drawing operations.

### layer:setOffset(x,y)

Give the parallax layer an offset from the camera's position. If you have a
background layer, you may want to move it down to see more of the ceiling area.

- `x, y`: _numbers_. This offset adjusts the position of the layer relative to the camera.

### layer:translateOffset(dx,dy)

Set incremental changes to the parallax layer's offset. Allows you to fine tune
how the layer is displayed.

- `dx, dy`: _numbers_. Increment the offset by these values.


### layer:draw_tiled_xy(x, y, image)

Draw an image (or Canvas or Video) tiled using a minimal number of draws. Uses
inverseTransformPoint so transformations from your camera should ensure only
visible tiles are drawn.

- `x, y`: _numbers_. Tune the positioning of the image.
- `image`: _Drawable_. A drawable (Image, Canvas) that provides getDimensions to draw tiled.

- returns: _number_. The number of times the image was drawn.


### layer:draw_tiled_single_axis(x, y, image, axis)

Draw an image (or Canvas or Video) tiled using a minimal number of draws and
only along a single axis. See also draw_tiled_xy.

- `x, y`: _numbers_. Tune the positioning of the image.
- `image`: _Drawable_. A drawable (Image, Canvas) that provides getDimensions to draw tiled.
- `axis`: _string_. Either `x` to tile horizontally or `y` to tile vertically.

- returns: _number_. The number of times the image was drawn.


## Credits

* kikito for [gamera](https://github.com/kikito/gamera) which I built this library to work with.
* davisdude for [Brady](https://github.com/davisdude/brady) which was instrumental to figuring out how to make parallax work.


## License

MIT
