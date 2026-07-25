-- Cutscene class, represents a cutscene in the game, which displays a sequence of images with sound effects.
class("Cutscene").extends()

local gfx = playdate.graphics
local pd = playdate
local boxes_sprite = gfx.image.new("background/box-sprites.png")
local box_sfx = playdate.sound.fileplayer.new("sounds/box_add_sfx.mp3")
local timer = 0

-- Cutscene class constructor, taking in three image file paths corresponding to the images to be displayed in the cutscene.
function Cutscene:init(image_one_path, image_two_path, image_three_path)
    self.image_one_path = gfx.image.new(image_one_path)
    self.image_two_path = gfx.imagetable.new(image_two_path)
    self.image_three_path = gfx.image.new(image_three_path)
    self.animation_complete = false
    self.mid_animation_frame_num = 1
    timer = 0
end

-- Draws the cutscene by displaying the sequence of images and playing sound effects.
function Cutscene:draw(dt)
    self:animation_sequence(dt)

    if self.animation_complete then
        return true
    end

    return false
end

function Cutscene:animation_sequence(dt)
    timer = timer + dt

    if timer >= .75 then
        self.image_one_path:draw(17, 64)
    end
    box_sfx:play()

    if timer >= 1.3 and timer < 1.4 then
        self.image_two_path:getImage(1):draw(145, 64)
    end

    if timer >= 1.4 and timer < 1.5 then
        self.image_two_path:getImage(2):draw(145, 64)
    end

    if timer >= 1.5 and timer < 1.6 then
        self.image_two_path:getImage(3):draw(145, 64)
    end

    if timer >= 1.6 then
        self.image_two_path:getImage(4):draw(145, 64)
    end

    if timer >= 2.35 then
        self.image_three_path:draw(273, 64)
    end

    if timer >= 3.1 then
        self.animation_complete = true
    end
end
