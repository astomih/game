local text_window = require "text_window"
local text_window_object = text_window()
local menu = require("menu")
local menu_object = menu()
function setup()
    menu_object:setup()
    text_window_object:setup()

    text_window_object.texts = {
        "aaa", "aaaa", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }
end

function update()
    menu_object:update()
    if menu_object.hide then
        if (keyboard:key_state(keySPACE) == buttonPRESSED or
            mouse:button_state(mouseLEFT) == buttonPRESSED) and
            text_window_object.is_draw_all_texts then
            change_scene("stage1_trap")
        end
        text_window_object:update()
    end
    text_window_object:draw()
    menu_object:draw()
end
