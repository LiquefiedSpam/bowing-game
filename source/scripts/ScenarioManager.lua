class("ScenarioManager").extends()

local Location = {
    KONBINI = 1,
    --TAXI = 2
}

local Actions = { --for now we can just make sure in the code to not select an action
    --that doesn't work with the current location I guess
    CHECKOUT = 1,
}

local ScenarioState = {
    INTERVAL = 1,
    INTRO = 2,
    WALKIN = 3,
    GAMEPLAY = 4,
    OUTRO = 5
}

local Npc = {
    KONBINI_CLERK = 1
}

local currentLocation
local currentAction
local currentNpc
local currentState

local hasScenario

local runningIntro = false

local timer = 0

local dt = 0

local bowTimeStamps = {}

function ScenarioManager:init()
    self.hasScenario = false
    self.currentState = ScenarioState.INTERVAL
end

function ScenarioManager:Update()
    dt = playdate.getElapsedTime()
    playdate.resetElapsedTime()


    if hasScenario == false then
        self.ConstructScenario()
        hasScenario = true
    end

    if currentState == ScenarioState.INTERVAL then
        playdate.wait(1000)
        currentState = ScenarioState.INTRO
    end

    if currentState == ScenarioState.INTRO and runningIntro == false then
        runningIntro = true
    end

    if currentState == ScenarioState.GAMEPLAY then
        timer += dt
    end

    if currentState == ScenarioState.OUTRO then
        --outro state
        timer = 0
    end
end

function ScenarioManager:ConstructScenario()
    local randomIndex = math.random(#Location)
    currentLocation = Location[randomIndex]
    randomIndex = math.random(#Actions)
    currentAction = randomIndex
    randomIndex = math.random(#Npc)
    currentNpc = randomIndex
end

function ScenarioManager:RunIntro()
    --running intro, which means displaying the visuals of location, action and person, having the characters walk in
    --or just pop in based on what the scenario is, etc
end
