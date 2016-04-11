module('entity.gun', package.seeall)

function createGun(game)
  local gun = game.ecs:newEntity()
  gun:addComponent('update', {
    delay = 0.2,
    lastShotTime = nil,
    canShoot = function(self)
      if not self.lastShotTime then
        return true
      else
        local currentTime = love.timer.getTime()
        if (currentTime - self.lastShotTime) > self.delay then
          return true
        end
      end

      return false
    end,
    update = function(self, game, dt)
      if self:canShoot() and game.isAlive then
        self.lastShotTime = love.timer.getTime()
        -- Generate a new bullet...
        local playerOrigin = util.getOrigin(game.player)
        local playerBounds = util.getBounds(game.player)
        local playerState = util.getSingleComponent(game.player, 'state')
        local shotLevel = playerState.level

        local shots = {}

        for i=1,shotLevel do
          table.insert(shots, playerBounds.dx / (shotLevel +1) * i)
        end

        for _, shotOffset in ipairs(shots) do

          local bullet = game.ecs:newEntity()
          local img = game.resources.bulletImg

          local bulletOrigin = bullet:addComponent('origin', {
            x = playerOrigin.x + shotOffset,
            y = playerOrigin.y
          })

          local bulletHitbox = bullet:addComponent('hitbox', {
            dx = game:scale(img:getWidth()),
            dy = game:scale(img:getHeight())
          })

          bullet:addComponent('bullet')
          bullet:addComponent('clear-on-reset')
          bullet:addComponent('render', { img = img })
          bullet:addComponent('update', {
            update = function(self, game, dt)
              if not util.overlap(
                bulletOrigin, bulletHitbox,
                util.getOrigin(game.gameArea), util.getBounds(game.gameArea)
              ) then
                game.ecs:removeEntity(bullet)
              else
                bulletOrigin.y = bulletOrigin.y - (dt * 500)
              end
            end
          })
        end
      end
    end
  })
end
