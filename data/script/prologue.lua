local text_window = require "text_window"
local text_window_object = text_window()
local menu = require("menu")
local menu_object = menu()
local casino = texture()
local drawer = draw2d(casino)
casino:load("casino.png")
drawer.scale = casino:size()
function setup()
    menu_object:setup()
    text_window_object:setup()

    text_window_object.texts = {
        "ディーラー「21、ブラックジャックだ。」",
        "ぐわあああああああああああああ！！！！",
        "また負けてしまった...",
        "謎の男「おい、お前ジョンズ博士の息子だろ？」",
        "なんだお前！",
        "謎の男「今は関係無い。とにかく、この遺跡に行って言う通りに動け。",
        "ぐわああああああああああああああ！！！！"

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
    drawer:draw()
    menu_object:draw()
end
