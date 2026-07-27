-- Heart (Life) UI screen for player's lives
class("HeartScreen").extends()

local gfx = playdate.graphics

-- player has 5 lives. If they get a medium or low score, they lose a life.
function HeartScreen:init()
    self.maxHearts = 3
    self.currentHearts = self.maxHearts
    self.heartSpacing = 5
    self.heartWidth = 35
    self.heartImages = {
        full = gfx.image.new("images/UI_screens/heart-full.png"),
        empty = gfx.image.new("images/UI_screens/heart-blank.png")
    }
end

-- function to lose a life and update the heart UI accordingly. Returns a boolean indicating whether the player has any lives left (true if they do, false if they don't).
function HeartScreen:loseLife()
    if self.currentHearts > 0 then
        self.currentHearts = self.currentHearts - 1
    end

    print("Num of hearts left: " .. self.currentHearts)
    return self.currentHearts > 0
end

function HeartScreen:drawHearts()
    for i = 1, self.maxHearts do
        local imageToUse = self.heartImages.full
        if i > self.currentHearts then
            imageToUse = self.heartImages.empty
        end

        local x = (self.heartWidth + self.heartSpacing) * (i - 1)
        imageToUse:draw(x, 0)
    end
end

function HeartScreen:resetHearts()
    self.currentHearts = self.maxHearts
end

function HeartScreen:getHearts()
    return self.currentHearts
end
