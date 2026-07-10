-- class to handle bowing conditions and logic in a given scene
class('BowingConditions').extends()

function BowingConditions:init(table_of_conditions)
    self.conditions = table_of_conditions
end
