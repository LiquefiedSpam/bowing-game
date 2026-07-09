import "scripts/Bowing"

-- Partner class, inherits from the Bowing class and represents the partner character in the game.
class('Partner').extends(Bowing)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
function Partner:init(character_sprite, x_position, y_position, speed)
    Partner.super.init(self, character_sprite, x_position, y_position, speed)
    self.setUp(self)
end

-- Set up the partner sprite and any other necessary properties
function Partner:setUp()
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
end

-- Sets the current frame of the partner sprite based on the provided image index
-- param image_index (number): The index of the image in the sprite sheet to set as the current frame (1-10)
function Partner:setCurrentFrame(image_index)
    if image_index >= 0 and image_index <= 10 then
        self.character_sprite:change_current_image(image_index)
    end
end

-- Moves the partner sprite to the specified frame over a given duration
-- param image_index (number): The index of the image in the sprite sheet to move total
-- param time_seconds (number): The duration in seconds over which to move to the target frame
function Partner:moveToFrame(image_index, time_seconds)
    if not (image_index >= 0 and image_index <= 10) then
        return
    end

    local current_frame = self.character_sprite.current_image
    local target_frame = self.character_sprite.top_sprite_sheet:getImage(image_index)

    if current_frame ~= target_frame then
        local frame_difference = math.abs(image_index - self:getCurrentFrameIndex())
        local step_time = time_seconds / frame_difference

        for i = 1, frame_difference do
            local next_frame_index = (image_index > self:getCurrentFrameIndex()) and (self:getCurrentFrameIndex() + i) or
                (self:getCurrentFrameIndex() - i)
            playdate.timer.performAfterDelay(step_time * 1000 * i, function()
                self:setCurrentFrame(next_frame_index)
            end)
        end
    end
end
