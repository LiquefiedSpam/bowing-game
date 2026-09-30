import "scripts/Bowing"

-- Partner class, inherits from the Bowing class and represents the partner character in the game.
class('Partner').extends(Bowing)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
--what does speed do?
function Partner:init(character_sprite, x_position, y_position, speed)
    Partner.super.init(self, character_sprite, x_position, y_position, speed)
    self.setUp(self)
    self.in_lowest_bow_frame = false
    self.current_frame = 0 -- 0 is upright
end

-- Set up the partner sprite and any other necessary properties
-- 'setting up' here means putting the partner into its spot for a scenario
function Partner:setUp()
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
end

-- adjusts the bow position of the partner sprite based on the provided PartnerBow object
-- returns whether the bow is complete
function Partner:adjustBowPosition(partnerBow, current_time)
    self.current_frame = self.character_sprite.current_image_index
    --lots of coupling, but it can be fine
    local bow_start_time = partnerBow:getTimeStart()     --the time (from now?) at which the bow should start
    local deepness = partnerBow:getDeepness()            --the deepness which this bow should reach
    local reset_position = partnerBow:getResetPosition() --the position to which this partner should reset? shouldn't that be frame 0?
    local bow_deep_time = partnerBow:getDuration()
    -- print("Current Frame: " ..
    --     current_frame ..
    --     ", Deepness: " ..
    --     deepness ..
    --     ", Reset Position: " ..
    --     reset_position .. ", Current Time: " .. current_time .. ", Bow Deep Time: " .. bow_deep_time)

    --seems like this 'steps toward' the next frame
    local function stepTowards(target_frame)
        if self.current_frame < target_frame then
            self:setCurrentFrame(self.current_frame + 1)
        elseif self.current_frame > target_frame then
            self:setCurrentFrame(self.current_frame - 1)
        end
    end

    if current_time < bow_start_time then
        self.in_lowest_bow_frame = false --this should probably be handled elsewhere by a parent class
        stepTowards(reset_position)
    elseif current_time < bow_start_time + bow_deep_time then
        self.in_lowest_bow_frame = false
        stepTowards(deepness) --so this is just popping once a frame it seems
    else
        --at this point, we have ended the bow duration
        self.in_lowest_bow_frame = true

        if self.current_frame == reset_position then
            self.in_lowest_bow_frame = false
            return true
        end

        stepTowards(reset_position)
    end

    return false
end

-- Sets the current frame of the partner sprite based on the provided image index
-- param image_index (number): The index of the image in the sprite sheet to set as the current frame (1-18)
function Partner:setCurrentFrame(image_index)
    if image_index >= 1 and image_index <= self.max_bow_frames then
        self.character_sprite:change_current_image(image_index)
        self.current_frame = image_index
    end
end

function Partner:getCurrentBowFrame()
    return self.current_frame
end
