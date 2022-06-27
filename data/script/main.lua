local hello_texture = {}
local press_texture = {}
local hello_font = {}
local press_font = {}
local hello_drawer = {}
local press_drawer = {}
local menu = require("menu")
local menu_object = menu()

function setup()
    menu_object:setup()
    hello_texture = texture()
    hello_drawer = draw2d(hello_texture)
    hello_font = font()
    hello_font:load(DEFAULT_FONT, 64)
    hello_font:render_text(hello_texture, "HIDDEN REMAINS", color(1, 1, 1, 1))
    hello_drawer.scale = hello_texture:size()

    press_texture = texture()
    press_drawer = draw2d(press_texture)
    press_font = font()
    press_font:load("SoukouMincho-Font/SoukouMincho.ttf", 32)
    press_font:render_text(press_texture,
                           "スペースキー、もしくはクリックで開始",
                           color(1, 1, 1, 1))
    press_drawer.scale = press_texture:size()
    press_drawer.position = vector2(0, -hello_drawer.scale.y)
end

function update()
    hello_drawer:draw()
    press_drawer:draw()
    menu_object:update()
    menu_object:draw()
    if menu_object.hide then
        if keyboard:key_state(keySPACE) == buttonPRESSED or
            mouse:button_state(mouseLEFT) == buttonPRESSED then
            change_scene("stage1")
        end
    end
end

