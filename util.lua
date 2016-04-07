module('util', package.seeall)

-- Somehow this makes things faster?
-- http://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
local next = next

function array_iterator(a)
  local index = nil
  return function()
    local val
    index, val = next(a, index)
    return val
  end
end

function array_empty(a)
  return next(a) == nil
end

function getOrigin(entity)
  for c in entity:getComponentsByType('origin') do
    return c
  end
end

function getBounds(entity)
  for c in entity:getComponentsByType('bounds') do
    return c
  end
end

function hitboxCollision(e1, e2)
  local e1Origin = getOrigin(e1)
  local e2Origin = getOrigin(e2)

  for e1Hitbox in e1:getComponentsByType('hitbox') do
    for e2Hitbox in e2:getComponentsByType('hitbox') do
      if overlap(e1Origin, e1Hitbox, e2Origin, e2Hitbox) then
        return true
      end
    end
  end

  return false
end

function overlap(originA, bboxA, originB, bboxB)
  if (originA.x + (bboxA.ox or 0)) < (originB.x + (bboxB.ox or 0) + bboxB.dx) and
     (originB.x + (bboxB.ox or 0)) < (originA.x + (bboxA.ox or 0)+ bboxA.dx) and
     (originA.y + (bboxA.oy or 0)) < (originB.y + (bboxB.oy or 0)+ bboxB.dy) and
     (originB.y + (bboxB.oy or 0)) < (originA.y + (bboxA.oy or 0)+ bboxA.dy) then
     return true
   end

   return false
end
