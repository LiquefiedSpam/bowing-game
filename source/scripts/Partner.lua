import "scripts/Bowing"

-- Partner class, inherits from the Bowing class and represents the partner character in the game.
class('Partner').extends(Bowing)

-- SHARED CONSTANTS for every bow
local bow_move_time = 0.2 --seconds the partner takes to go from upright to the deepest frame (and back)

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

-- Work out which sprite frame the partner is on at the given time (seconds) and show it.
-- Everything is calculated from the time, so nothing accumulates and nothing depends on frame rate.
-- A bow runs on this schedule, relative to partnerBow's start time:
--   0 -> bow_move_time              go from the reset frame down to the deepest frame
--   bow_move_time -> duration       hold the deepest frame
--   duration -> duration + move     come back up to the reset frame
-- returns whether the bow is complete
function Partner:adjustBowPosition(partnerBow, current_time)
    --lots of coupling, but it can be fine
    local bow_start_time = partnerBow:getTimeStart()         --the time (from now?) at which the bow should start
    local deepness = partnerBow:getDeepness()                --the deepness which this bow should reach
    local reset_position = partnerBow:getResetPosition()     --the position to which this partner should reset? shouldn't that be frame 0?
    local bow_deep_time = partnerBow:getDuration()           --seconds from the bow's start until it begins coming back up

    local move_time = math.min(bow_move_time, bow_deep_time) --a very short bow can't move for longer than it lasts
    local bow_end_time = bow_start_time + bow_deep_time + move_time
    local elapsed = current_time - bow_start_time

    --how far down the bow is: 0 = reset frame, 1 = deepest frame
    local depth
    if elapsed < move_time then
        depth = math.max(0, elapsed) / move_time
    elseif elapsed < bow_deep_time then
        depth = 1
    else
        depth = 1 - math.min(1, (elapsed - bow_deep_time) / move_time)
    end

    self:setCurrentFrame(math.floor(reset_position + (deepness - reset_position) * depth + 0.5))

    --this should probably be handled elsewhere by a parent class
    self.in_lowest_bow_frame = current_time >= bow_start_time + bow_deep_time and current_time < bow_end_time

    return current_time >= bow_end_time
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
