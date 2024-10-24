player = {}

function player:new()
    obj = {}

        

    setmetatable(obj, self)
    self.__index = self
    return obj
end