class("ScoreScreen").extends()

local gfx = playdate.graphics

function ScoreScreen:init()
    self.score = 0
end

--takes in a number that corresponds to how well the player did. This number is internally translated here to actual points.
function ScoreScreen:addScore(points)
    if points == 1 then
        self.score = self.score + 1
    end

    if points == 2 then
        self.score = self.score + 3
    end

    self:drawScore()
end

function ScoreScreen:drawScore()
    gfx.drawTextAligned("Score: " .. self.score, 390, 1, kTextAlignment.right)
end

function ScoreScreen:resetScore()
    self.score = 0
end

function HeartScreen:getScore()
    return self.score
end
