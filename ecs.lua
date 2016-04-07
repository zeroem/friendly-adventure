module("ecs", package.seeall)

local next = next
local function componentIterator(comps)
  local index = nil
  return function()
    local val
    index, val = next(comps, index)
    if val ~= nil then
      return val, val._owner, val._type
    end
  end
end

function ecs.new()
    return {
      components = {},

      newEntity = function(self)
        local system = self
        return {
          components = {},

          addComponent = function(self, componentType, data)
            local data = data or {}
            data._owner = self
            data._type = componentType

            if self.components[componentType] == nil then
              self.components[componentType] = {}
            end

            table.insert(self.components[componentType], data)

            system:_addComponent(data)

            return data
          end,

          getComponentsByType = function(self, t)
            if self.components[t] ~= nil then
              return componentIterator(self.components[t])
            else
              return componentIterator({})
            end
          end,

          hasComponentType = function(self, t)
            for c in self:getComponentsByType(t) do
              return true
            end

            return false
          end
        }
      end,

      _addComponent = function(self, data)
        if self.components[data._type] == nil then
          self.components[data._type] = {}
        end

        table.insert(self.components[data._type], data)
      end,

      getComponentsByType = function(self, t)
        if self.components[t] ~= nil then
          return componentIterator(self.components[t])
        else
          return componentIterator({})
        end
      end,

      removeComponent = function(self, c)
        for i, comp in ipairs(self.components[c._type]) do
          if comp == c then
            table.remove(self.components[c._type], i)
            return
          end
        end
      end,

      removeEntity = function(self, ent)
        for k, _ in pairs(ent.components) do
          local result = {}
          for i, c in ipairs(self.components[k]) do
            if c._owner ~= ent then
              table.insert(result, c)
            end
          end

          self.components[k] = result
        end
      end,
    }
  end
