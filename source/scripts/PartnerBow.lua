-- PartnerBow class, holding data needed to command partner when to bow
class('PartnerBow').extends()

-- constructor for PartnerBow class, initializes the properties of the bow including timeStart, duration, deepness, and resetPosition.
-- param timeStart (number): The time at which the bow should start.
-- param duration (number): The duration of the bow.
-- param deepness (number): The depth of the bow
-- param resetPosition (number): The position to which the partner should return after the bow is
function PartnerBow:init(timeStart, duration, deepness, resetPosition)
    self.timeStart = timeStart
    self.duration = duration
    self.deepness = deepness
    self.resetPosition = resetPosition
    self.timeBetweenBowIntervals = 5 / 30
end

function PartnerBow:getTimeStart()
    return self.timeStart
end

function PartnerBow:getDuration()
    return self.duration
end

function PartnerBow:getDeepness()
    return self.deepness
end

function PartnerBow:getResetPosition()
    return self.resetPosition
end

function PartnerBow:printBowDetails()
    print("Partner Bow Details:")
    print("Time Start: " .. self.timeStart)
    print("Duration: " .. self.duration)
    print("Deepness: " .. self.deepness)
    print("Reset Position: " .. self.resetPosition)
end
