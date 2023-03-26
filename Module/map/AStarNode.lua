local node = { noLogger = true, noNewInstance = true }

function node:init(mapId, adjacentMapIds)
  self.mapId = mapId
  self.adjacentMapIds = adjacentMapIds or {}
  self.parent = nil
  self.g = 0
  self.h = 0
  self.f = 0
end

return node
