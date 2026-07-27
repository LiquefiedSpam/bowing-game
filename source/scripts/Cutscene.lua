-- Cutscene class, represents a cutscene in the game, which displays a sequence of images with sound effects.
class("Cutscene").extends()

local gfx = playdate.graphics
local pd = playdate
local boxes_sprite = gfx.image.new("background/box-sprites.png")
local box_sfx = playdate.sound.fileplayer.new("sounds/box_add_sfx.mp3")
local timer = 0
local timer2_1 = 0
local timer2_2 = 0
local timer2_3 = 0

local starting_y_value = 64
local y_value_1 = starting_y_value
local y_value_2 = starting_y_value
local y_value_3 = starting_y_value

local interval_between_boxes = 1

-- Cutscene class constructor, taking in three image file paths corresponding to the images to be displayed in the cutscene.
function Cutscene:init(image_one_path, image_two_path, image_three_path)
    self.image_one_path = gfx.image.new(image_one_path)
    self.image_two_path = gfx.imagetable.new(image_two_path)
    self.image_three_path = gfx.image.new(image_three_path)

    self.first_part_complete = false
    self.animation_complete = false

    self.cur_anim_frame = 1
    self.sound1Bool = false
    self.sound2Bool = false
    self.sound3Bool = false

    timer2_1 = 0
    timer2_2 = 0
    timer2_3 = 0

    y_value_1 = starting_y_value
    y_value_2 = starting_y_value
    y_value_3 = starting_y_value

    self.interval_between_anim_frame = interval_between_boxes / #self.image_two_path
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

    if timer >= interval_between_boxes then
        if not self.sound1Bool then
            box_sfx:play()
            self.sound1Bool = true
        end
        self.image_one_path:draw(17, y_value_1)
    end


    if timer >= (interval_between_boxes * 2) then
        if not self.sound2Bool then
            box_sfx:play()
            self.sound2Bool = true
        end
        self.image_two_path:getImage(self.cur_anim_frame):draw(145, y_value_2)
    end


    if timer >= (interval_between_boxes * 2) + self.interval_between_anim_frame * self.cur_anim_frame
        and timer < (interval_between_boxes * 3) then
        if #self.image_two_path > self.cur_anim_frame + 1 then
            self.cur_anim_frame = self.cur_anim_frame + 1
        end
    end

    if timer >= interval_between_boxes * 3 then
        if not self.sound3Bool then
            box_sfx:play()
            self.sound3Bool = true
        end
        self.image_three_path:draw(273, y_value_3)
    end

    if timer >= (interval_between_boxes * 4)
    then
        self.first_part_complete = true
    end

    if self.first_part_complete then
        self:slide_off_screen(dt)
    end
end

function Cutscene:slide_off_screen(dt)
    local rate = 3

    timer2_1 = timer2_1 + dt
    local boost1 = 5 * math.exp(-20 * timer2_1)
    y_value_1 = y_value_1
        - boost1
        - math.exp(rate * timer2_1)

    if timer2_1 > .3 then
        timer2_2 = timer2_2 + dt
        local boost2 = 5 * math.exp(-20 * timer2_2)
        y_value_2 = y_value_2
            - boost2
            - math.exp(rate * timer2_2)
    end

    if timer2_1 > .6 then
        timer2_3 = timer2_3 + dt
        local boost3 = 5 * math.exp(-20 * timer2_3)
        y_value_3 = y_value_3
            - boost3
            - math.exp(rate * timer2_3)
    end

    if y_value_3 < -300 then
        self.animation_complete = true
    end
end
