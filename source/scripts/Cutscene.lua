class("Cutscene").extends()

local gfx = playdate.graphics
local pd = playdate
local boxes_sprite = gfx.image.new("images/background/box-sprites.png")
local box_sfx = playdate.sound.fileplayer.new("sounds/box_add_sfx.mp3")

function Cutscene:init(image_one_path, image_two_path, image_three_path)
    self.image_one_path = gfx.image.new(image_one_path)
    self.image_two_path = gfx.image.new(image_two_path)
    self.image_three_path = gfx.image.new(image_three_path)
    self.animation_complete = false
end

function Cutscene:draw()
    if not self.animation_complete then
        self:animation_sequence()
        self.animation_complete = true
    end
    boxes_sprite:draw(0, 0)
    self.image_one_path:draw(17, 64)
    self.image_two_path:draw(145, 64)
    self.image_three_path:draw(273, 64)
end

function Cutscene:animation_sequence()
    boxes_sprite:draw(0, 0)
    pd.wait(1000)
    self.image_one_path:draw(17, 64)
    box_sfx:play()
    pd.wait(1000)
    self.image_two_path:draw(145, 64)
    box_sfx:play()
    pd.wait(1000)
    self.image_three_path:draw(273, 64)
    box_sfx:play()
    pd.wait(1000)
end
