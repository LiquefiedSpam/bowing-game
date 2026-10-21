import "CoreLibs/graphics"
import "scripts/Clock"

-- ResumeCountdown class: the screen shown for a few seconds after the player closes the system menu,
-- so they can get their hands back on the crank before the game continues. It shows the frozen game
-- grayed out, with a wheel that fills clockwise and a number that counts down in the middle.
-- Everything drawn is calculated from its own clock.
class("ResumeCountdown").extends()

local gfx = playdate.graphics

-- SHARED CONSTANTS
ResumeCountdown.duration = 3      --seconds the countdown lasts
ResumeCountdown.start_angle = 90  --where the wheel starts filling. 0 is straight up, so 90 is the right middle
ResumeCountdown.wheel_radius = 46 --pixels from the center to the middle of the wheel's ring
ResumeCountdown.wheel_width = 8   --pixels thick the filled part of the ring is
ResumeCountdown.number_scale = 4  --how much bigger than the normal font the number is drawn
ResumeCountdown.gray_amount = 0.5 --how much of the frozen game is covered up (0 = none, 1 = all)

function ResumeCountdown:init()
    self.clock = Clock()
    self.active = false
    self.snapshot = nil     --picture of the game from when it was paused
    self.number_images = {} --the drawn number for each value, made the first time it is needed
end

-- Takes a picture of the game as it is now. Call this when the game is paused, so there is something
-- to draw the countdown over.
function ResumeCountdown:capture()
    self.snapshot = gfx.getDisplayImage()
end

-- Starts the countdown from the beginning.
function ResumeCountdown:start()
    self.clock:reset()
    self.active = true
end

function ResumeCountdown:is_active()
    return self.active
end

-- Advances the countdown by dt seconds and draws it. Returns true on the frame it finishes.
function ResumeCountdown:update(dt)
    self.clock:advance(dt)
    if self.clock:now() >= ResumeCountdown.duration then
        self.active = false
        self.snapshot = nil
        return true
    end

    self:draw()
    return false
end

-- The number to show at the given time (seconds): it counts down each time a full second is used up.
function ResumeCountdown:number_at(time)
    return ResumeCountdown.duration - math.floor(time)
end

-- Finds the box that the drawn (non-transparent) pixels of an image fit in.
-- Returns the left, top, right and bottom pixel positions, or nil if nothing is drawn.
local function ink_bounds(image)
    local width, height = image:getSize()
    local left, top, right, bottom = width, height, -1, -1
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            if image:sample(x, y) ~= gfx.kColorClear then
                left = math.min(left, x)
                right = math.max(right, x)
                top = math.min(top, y)
                bottom = math.max(bottom, y)
            end
        end
    end
    if right < left then
        return nil
    end
    return left, top, right, bottom
end

-- The image of the given number, drawn big, and where its middle is (as a fraction of the image's
-- width and height, ready for drawAnchored). The middle is the middle of the digits themselves, not of the
-- text box the font puts around them, which has extra space for letters that hang below the line.
function ResumeCountdown:number_image(number)
    if self.number_images[number] == nil then
        local text = gfx.imageWithText(tostring(number), 40, 20)
        local width, height = text:getSize()
        local anchor_x, anchor_y = 0.5, 0.5
        local left, top, right, bottom = ink_bounds(text)
        if left ~= nil then
            anchor_x = (left + right + 1) / 2 / width
            anchor_y = (top + bottom + 1) / 2 / height
        end
        self.number_images[number] = {
            image = text:scaledImage(ResumeCountdown.number_scale),
            anchor_x = anchor_x,
            anchor_y = anchor_y,
        }
    end
    return self.number_images[number]
end

-- Draws the frozen game, grayed out, with the wheel and number on top.
function ResumeCountdown:draw()
    local time = self.clock:now()
    local center_x = playdate.display.getWidth() / 2
    local center_y = playdate.display.getHeight() / 2
    local radius = ResumeCountdown.wheel_radius

    gfx.pushContext() --so none of this drawing setup leaks into the rest of the game

    if self.snapshot ~= nil then
        self.snapshot:draw(0, 0)
    end

    --gray everything out
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(1 - ResumeCountdown.gray_amount, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRect(0, 0, playdate.display.getWidth(), playdate.display.getHeight())

    --plain background for the wheel so it reads clearly
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(center_x, center_y, radius + ResumeCountdown.wheel_width)

    --thin outline of the whole wheel, then the part that has elapsed on top of it
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawCircleAtPoint(center_x, center_y, radius)

    gfx.setLineWidth(ResumeCountdown.wheel_width)
    local elapsed_angle = 360 * time / ResumeCountdown.duration
    gfx.drawArc(
        center_x,
        center_y,
        radius,
        ResumeCountdown.start_angle,
        ResumeCountdown.start_angle + elapsed_angle)

    local number = self:number_image(self:number_at(time))
    number.image:drawAnchored(center_x, center_y, number.anchor_x, number.anchor_y)

    gfx.popContext()
end
