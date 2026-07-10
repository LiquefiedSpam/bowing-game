class("Scenario").extends()

function Scenario:init(
    name,
    cutscene,
    humility_low_range_score,
    humility_high_range_score,
    humility_forgiveness,
    many_bows_humility,
    deep_bows_humility)
    self.name = name
    -- cutscene for later
    self.cutscene = cutscene
    self.event_table = {}


    self.player_humility_score = 0
    self.humility_low_range_score = humility_low_range_score
    self.humility_high_range_score = humility_high_range_score
    self.humility_forgiveness = humility_forgiveness
    self.many_bows_humility = many_bows_humility
    self.deep_bows_humility = deep_bows_humility
end
