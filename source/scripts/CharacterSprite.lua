import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/easing"

-- A parent class for all characters' sprites.
class('CharacterSprite').extends(Object)
local pd = playdate
local gfx = pd.graphics
local walking_sfx = playdate.sound.fileplayer.new("sounds/pop-walk.mp3")

-- SHARED CONSTANTS for every walk
CharacterSprite.walk_speed = 90        --pixels per second while walking at full speed
CharacterSprite.slow_radius = 25       --distance in pixels from the target at which the character starts slowing down
CharacterSprite.bounce_amplitude = 4   --pixels the character bounces up and down while walking
CharacterSprite.bounce_frequency = 0.3 --how many 'bounces' per pixel walked
CharacterSprite.walk_base_y = 125      --y position the character walks along

-- Requires: sprite_sheet (string) (spritesheet of character's bowing frames)
function CharacterSprite:init(sprite_sheet)
    self.top_sprite_sheet = gfx.imagetable.new(sprite_sheet)
    --self.current_image = self.top_sprite_sheet:getImage(1) redundant line

    --walking state for the walk-in animation
    -- state for the walk-in animation
    self.walking = false
    self.walkTarget = 0 --target x value where this sprite will fully stop
    --the rest of the walk (start time, start x, direction, cruise and slow-down durations) is worked out
    --by startWalkIn


    -- current image is preset to the first frame of the sprite sheet
    self.current_image = self.top_sprite_sheet:getImage(1)
    self.current_image_index = 1
    self.playerSprite = gfx.sprite.new(self.current_image)

    -- if blow_up then
    --     self.playerSprite:setScale(1.5)
    -- else
    --     self.playerSprite:setScale(1)
    -- end
end

-- Changes the current image of the character sprite to the image at the specified index in the sprite sheet.
-- Requires: image_index (number)
function CharacterSprite:change_current_image(image_index)
    local new_image = self.top_sprite_sheet:getImage(image_index)
    if new_image then
        self.current_image_index = image_index
        self.current_image = new_image
        self.playerSprite:setImage(self.current_image)
    end
end

--update the walk-in 'animation' for the given time (seconds, on the same clock that was used for start_time).
--Everything is calculated from the time, so nothing accumulates and nothing depends on frame rate.
--A walk goes at walk_speed until the character is slow_radius from the target, then slows to a stop there.
function CharacterSprite:updateWalkIn(time)
    if not self.walking then return end
    local elapsed = math.max(0, time - self.walk_start_time)

    if elapsed >= self.walk_cruise_time + self.walk_slow_time then
        self.playerSprite:moveTo(self.walkTarget, self.playerSprite.y)
        self.walking = false
        self.hasWalkedIn = true
        self.startedWalkingIn = false
        return
    end

    --how far along the path the character is, in pixels
    local walked
    if elapsed < self.walk_cruise_time then
        walked = CharacterSprite.walk_speed * elapsed
    else
        --easing(elapsed, start value, change in value, duration)
        walked = CharacterSprite.walk_speed * self.walk_cruise_time + playdate.easingFunctions.outQuad(
            elapsed - self.walk_cruise_time,
            0,
            self.walk_slow_distance,
            self.walk_slow_time)
    end

    local newX = self.walk_start_x + self.walk_direction * walked

    --the y value 'bounce' depends on how far the character has walked
    local bounceOffset = math.sin(walked * CharacterSprite.bounce_frequency) * CharacterSprite.bounce_amplitude

    -- if touching the ground, play a sound effect
    if bounceOffset <= 0.5 then
        walking_sfx:play()
    end

    --actual moving
    self.playerSprite:moveTo(newX, self.baseY + bounceOffset)
end

--start the walk-in 'animation.'
--walkIn: boolean. True means the character is walking right, false means left.
--isPlayer: boolean. True if we are dealing with player sprite, false if partner sprite.
--start_time: the time (seconds) at which the character starts moving, on the clock later passed to updateWalkIn.
function CharacterSprite:startWalkIn(walkIn, isPlayer, start_time)
    self.hasWalkedIn = false
    self.startedWalkingIn = true
    self.walking = true
    self.baseY = CharacterSprite.walk_base_y
    self.walk_start_time = start_time

    if walkIn then
        if isPlayer then
            self.playerSprite:moveTo(80, self.baseY) -- start off-screen, 0 is dummy approximate value
            self.walkTarget = 230
        else
            self.walkTarget = 600 -- dummy approximate value
        end
    else
        if isPlayer then
            self.playerSprite:setImage(self.playerSprite.getImage(self.playerSprite), 1)
            self.playerSprite:moveTo(-100, self.baseY)
            self.walkTarget = -250
        else
            self.playerSprite:moveTo(250, self.baseY) -- start off-screen, 600 is dummy approximate value
            self.walkTarget = 200                     -- dummy approximate value
        end
    end

    --DERIVED: the path from where the character is now to the target (never changes during the walk)
    self.walk_start_x = self.playerSprite.x
    self.walk_direction = self.walkTarget >= self.walk_start_x and 1 or -1
    local distance = math.abs(self.walkTarget - self.walk_start_x)
    self.walk_slow_distance = math.min(distance, CharacterSprite.slow_radius)
    self.walk_cruise_time = (distance - self.walk_slow_distance) / CharacterSprite.walk_speed
    --slowing down from full speed to a stop covers half the distance full speed would, so it takes twice as long
    self.walk_slow_time = 2 * self.walk_slow_distance / CharacterSprite.walk_speed
end

function CharacterSprite:moveTo(x, y)
    self.playerSprite:moveTo(x, y)
end

function CharacterSprite:add()
    self.playerSprite:add()
end

--I dont think this is being used
function CharacterSprite:setImageFlip(flip)
    self.playerSprite:setImageFlip(flip)
    return self
end

function CharacterSprite:removeSprite()
    self.playerSprite:remove()
end
