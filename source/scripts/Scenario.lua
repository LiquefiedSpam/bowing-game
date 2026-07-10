class("Scenario").extends()

function Scenario:init(name, cutscene, bow_conditions)
    self.name = name
    -- cutscene for later
    self.cutscene = cutscene
    self.bow_conditions = bow_conditions
    self.event_table = {}
end
