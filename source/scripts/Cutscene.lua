-- Cutscene class, represents a cutscene in the game, which displays a sequence of images with sound effects.
class("Cutscene").extends()

local gfx = playdate.graphics
local pd = playdate
local boxes_sprite = gfx.image.new("background/box-sprites.png")
local box_sfx = playdate.sound.fileplayer.new("sounds/box_add_sfx.mp3")

-- Cutscene class constructor, taking in three image file paths corresponding to the images to be displayed in the cutscene.
function Cutscene:init(image_one_path, image_two_path, image_three_path)
    self.image_one_path = gfx.image.new(image_one_path)
    self.image_two_path = gfx.imagetable.new(image_two_path)
    self.image_three_path = gfx.image.new(image_three_path)
    self.animation_complete = false
end

-- Draws the cutscene by displaying the sequence of images and playing sound effects.
function Cutscene:draw()
    if not self.animation_complete then
        self:animation_sequence()
        self.animation_complete = true
    end
    --boxes_sprite:draw(0, 0)
    self.image_one_path:draw(17, 64)
    self.image_three_path:draw(273, 64)
end

function Cutscene:animation_sequence()
    --boxes_sprite:draw(0, 0)
    pd.wait(750)
    self.image_one_path:draw(17, 64)
    box_sfx:play()
    pd.wait(750)
    self.image_two_path:getImage(1):draw(145, 64)
    pd.wait(100)
    self.image_two_path:getImage(2):draw(145, 64)
    pd.wait(100)
    self.image_two_path:getImage(3):draw(145, 64)
    pd.wait(100)
    self.image_two_path:getImage(4):draw(145, 64)
    box_sfx:play()
    pd.wait(750)
    self.image_three_path:draw(273, 64)
    box_sfx:play()
    pd.wait(750)
end
