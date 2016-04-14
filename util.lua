module('util', package.seeall)

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
  return getSingleComponent(entity, 'origin')
end

function getBounds(entity)
  return getSingleComponent(entity, 'bounds')
end

function getSingleComponent(entity, t, default)
  for c in entity:getComponentsByType(t) do
    return c
  end

  return default
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

function renderImage(game, origin, data)
  return {
    render = function()
      love.graphics.draw(
        data.img,
        origin.x or 0,
        origin.y or 0,
        data.r or 0,
        data.sx or game:scale(),
        data.sy or data.sx or game:scale(),
        data.ox or 0,
        data.oy or 0,
        data.kx or 0,
        data.ky or 0
      )
    end
  }
end
