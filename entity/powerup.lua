module('entity.powerup', package.seeall)

function createPowerup(game, enemy)
  local powerup = game.ecs:newEntity()
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

  powerup:addComponent('render', {
    img = img,
    sx = game:scale(5),
    sy = game:scale(5)
  })

  powerup:addComponent('update', {
    update = function(self, game, dt)
      origin.y = origin.y + (dt * 100)
    end
  })

  return powerup
end
