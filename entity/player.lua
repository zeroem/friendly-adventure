module('entity.player', package.seeall)

require 'util'

function createPlayer(game)
  local player = game.ecs:newEntity('player')
  local origin = player:addComponent('origin', { x = 200, y = 710 })
  local velocity = player:addComponent('velocity', { speed = 400 })
  local img = game.resources.playerImg
  local bounds = player:addComponent(
    'bounds',
    { dx = game:scale(img:getWidth()), dy = game:scale(img:getHeight())}
  )
  local state = player:addComponent('state', { level = 1 })

  player:addComponent('player')
  player:addComponent('clear-on-reset')
  player:addComponent('render', util.renderImage(game, origin, {img = img}))
  player:addComponent('hitbox', newBBox(0, game:scale(22), game:scale(img:getWidth()), game:scale(20)))
  player:addComponent('hitbox', newBBox(game:scale(img:getWidth()) / 2 -7, 0, 14, game:scale(img:getHeight() - 5)))

  player:addComponent('update', { 
    maxLevel = 5,
    update = function(self, game, dt)
      for _, p in game.ecs:getComponentsByType('powerup') do
        if util.hitboxCollision(player, p) then
          game.ecs:removeEntity(p)
          game.score = game.score + 25
          if state.level < self.maxLevel then
            state.level = state.level + 1
          end
        end
      end

      for _, e in game.ecs:getComponentsByType('enemy') do
        if util.hitboxCollision(player, e) then
          collisionDamage = util.getSingleComponent(e, 'stats')['collisionDamage']
          state.level = state.level - collisionDamage

          game.ecs:removeEntity(e)

          if state.level <= 0 then
            game:playerDeath()
            return
          end
        end
      end

      if game.keysPressed.left then
        origin.x = origin.x - (velocity.speed * dt)
      end

      if game.keysPressed.right then
        origin.x = origin.x + (velocity.speed * dt)
      end

      if game.keysPressed.up then
        origin.y = origin.y - (velocity.speed * dt)
      end

      if game.keysPressed.down then
        origin.y = origin.y + (velocity.speed * dt)
      end

      -- Keep everyone inside the screen
      if origin.x < 0 then
        origin.x = 0
      elseif origin.x > (love.graphics.getWidth() - bounds.dx) then
        origin.x = love.graphics.getWidth() - bounds.dx
      end

      if origin.y < 0 then
        origin.y = 0
      elseif origin.y > (love.graphics.getHeight() - bounds.dy) then
        origin.y = love.graphics.getHeight() - bounds.dy
      end
    end})

  return player
end
