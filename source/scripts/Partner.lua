import "scripts/Bowing"

-- Partner class, inherits from the Bowing class and represents the partner character in the game.
class('Partner').extends(Bowing)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
function Partner:init(character_sprite, x_position, y_position, speed)
    Partner.super.init(self, character_sprite, x_position, y_position, speed)
    self.setUp(self)
    self.in_lowest_bow_frame = false
end

-- Set up the partner sprite and any other necessary properties
function Partner:setUp()
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
end

-- adjusts the bow position of the partner sprite based on the provided PartnerBow object
-- returns whether the bow is complete
function Partner:adjustBowPosition(partnerBow, current_time)
    local current_frame = self.character_sprite.current_image_index
    local deepness = partnerBow:getDeepness()
    local reset_position = partnerBow:getResetPosition()
    local bow_deep_time = partnerBow:getTimeStart() + partnerBow:getDuration()
    -- print("Current Frame: " ..
    --     current_frame ..
    --     ", Deepness: " ..
    --     deepness ..
    --     ", Reset Position: " ..
    --     reset_position .. ", Current Time: " .. current_time .. ", Bow Deep Time: " .. bow_deep_time)

    local function stepTowards(target_frame)
        if current_frame < target_frame then
            self:setCurrentFrame(current_frame + 1)
        elseif current_frame > target_frame then
            self:setCurrentFrame(current_frame - 1)
        end
    end

    if current_time < bow_deep_time then
        self.in_lowest_bow_frame = false
        stepTowards(deepness)
    else
        self.in_lowest_bow_frame = true

        if current_frame == reset_position then
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
    end
end
