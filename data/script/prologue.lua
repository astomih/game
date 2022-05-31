local text_window = require "text_window"
local text_window_object = text_window()
function setup()
    text_window_object:setup()

    text_window_object.texts = {
        "俺には唯一の親友が居た", "aaaa",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }
end

function update()
    if keyboard:key_state(keySPACE) == buttonPRESSED and
        text_window_object.is_draw_all_texts then change_scene("stage1_trap") end
    text_window_object:update()
    text_window_object:draw()
end
