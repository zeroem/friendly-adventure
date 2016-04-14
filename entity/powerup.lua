module('entity.powerup', package.seeall)

function createPowerup(game, enemy)
  local powerup = game.ecs:newEntity('powerup')
  local img = game.resources.powerupImg
  local enemyOrigin = util.getOrigin(enemy)
  local enemyBounds = util.getBounds(enemy)

  powerup:addComponent('powerup')
  powerup:addComponent('clear-on-reset')

  local origin = powerup:addComponent('origin', {
    x = enemyOrigin.x + game:scale((enemyBounds.dx / 2)),
    y = enemyOrigin.y + game:scale((enemyBounds.dy / 2))
  })

  powerup:addComponent('hitbox', {
    ox = 0, oy = 0,
    dx = game:scale(img:getWidth() * 5),
    dy = game:scale(img:getHeight() * 5)
  })

  local bounds = powerup:addComponent('bounds', {
    ox = 0, oy = 0,
    dx = game:scale(img:getWidth() * 5),
    dy = game:scale(img:getHeight() * 5)
  })

  powerup:addComponent('render', {
    render = function()
      love.graphics.setColor(0, 255, 0)
      love.graphics.print("P", origin.x, origin.y, 0, 2)
    end
  })

  powerup:addComponent('update', {
    update = function(self, game, dt)
      origin.y = origin.y + (dt * 100)

      if not util.overlap(origin,
                          bounds,
                          util.getOrigin(game.gameArea),
                          util.getBounds(game.gameArea)) then
        game.ecs:removeEntity(powerup)
      end
    end
  })

  return powerup
end
