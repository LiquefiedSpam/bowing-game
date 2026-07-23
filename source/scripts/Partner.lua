import "scripts/Bowing"

-- Partner class, inherits from the Bowing class and represents the partner character in the game.
class('Partner').extends(Bowing)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
function Partner:init(character_sprite, x_position, y_position, speed)
    Partner.super.init(self, character_sprite, x_position, y_position, speed)
    self.setUp(self)
    self.in_lowest_bow_frame = false
    self.current_frame = 0
end

-- Set up the partner sprite and any other necessary properties
function Partner:setUp()
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
end

-- adjusts the bow position of the partner sprite based on the provided PartnerBow object
-- returns whether the bow is complete
function Partner:adjustBowPosition(partnerBow, current_time)
    self.current_frame = self.character_sprite.current_image_index
    local bow_start_time = partnerBow:getTimeStart()
    local deepness = partnerBow:getDeepness()
    local reset_position = partnerBow:getResetPosition()
    local bow_deep_time = partnerBow:getDuration()
    -- print("Current Frame: " ..
    --     current_frame ..
    --     ", Deepness: " ..
    --     deepness ..
    --     ", Reset Position: " ..
    --     reset_position .. ", Current Time: " .. current_time .. ", Bow Deep Time: " .. bow_deep_time)

    local function stepTowards(target_frame)
        if self.current_frame < target_frame then
            self:setCurrentFrame(self.current_frame + 1)
        elseif self.current_frame > target_frame then
            self:setCurrentFrame(self.current_frame - 1)
        end
    end

    if current_time < bow_start_time then
        self.in_lowest_bow_frame = false
        stepTowards(reset_position)
    elseif current_time < bow_start_time + bow_deep_time then
        self.in_lowest_bow_frame = false
        stepTowards(deepness)
    else
        self.in_lowest_bow_frame = true

        if self.current_frame == reset_position then
            self.in_lowest_bow_frame = false
            return true
        end

        stepTowards(reset_position)
    end

    return false

    -- if current_time < bow_deep_time then
    --     if current_frame < deepness then
    --         self:setCurrentFrame(current_frame + 1)
    --     elseif current_frame > deepness then
    --         self:setCurrentFrame(current_frame - 1)
    --     else
    --         self.in_lowest_bow_frame = true
    --     end
    -- else
    --     self.in_lowest_bow_frame = false

    --     if current_frame < reset_position then
    --         self:setCurrentFrame(current_frame + 1)
    --     elseif current_frame > reset_position then
    --         self:setCurrentFrame(current_frame - 1)
    --     end
    -- end
end

-- Sets the current frame of the partner sprite based on the provided image index
-- param image_index (number): The index of the image in the sprite sheet to set as the current frame (1-18)
function Partner:setCurrentFrame(image_index)
    if image_index >= 1 and image_index <= 18 then
        self.character_sprite:change_current_image(image_index)
        self.current_frame = image_index
    end
end

function Partner:getCurrentBowFrame()
    return self.current_frame
end
