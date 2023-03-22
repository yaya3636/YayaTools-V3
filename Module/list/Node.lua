local node = {}

function node:init(value)
    self.value = value
    self.next = nil
end

return node