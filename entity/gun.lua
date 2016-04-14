module('entity.gun', package.seeall)

function delayElapsed(lastShotTime, delay)
  if not lastShotTime then
    return true
  else
    if (love.timer.getTime() - lastShotTime) > delay then
      return true
    end
  end

  return false
end

function createGun(game)
  local gun = game.ecs:newEntity('gun')

  gun:addComponent('update', {
    update = bulletGenerator(comboUpdater(straightShotUpdaterFactory()))
    -- update = bulletGenerator(comboUpdater(straightShotUpdaterFactory(),waveShotUpdaterFactory(),rocketShotUpdaterFactory()))
  })
end

function bulletGenerator(f)
  return function(self, game, dt)
    if game.isAlive then
      f(self, game, dt)
    end
  end
end

function comboUpdater(...)
  local args = { n = select("#", ...), ...}

  return function(self, game, dt)
    for i=1,args.n do
      args[i](self, game, dt)
    end
  end
end

function straightShotUpdaterFactory()
  local delay = 0.2
  local lastShotTime = nil
  return function(self, game, dt)
    if delayElapsed(lastShotTime, delay) then
      lastShotTime = love.timer.getTime()

      -- Generate a new bullet...
      local playerOrigin = util.getOrigin(game.player)
      local playerBounds = util.getBounds(game.player)
      local numShots = 2
      local img = game.resources.bulletImg

      local offsets = {playerOrigin.x + 10, playerOrigin.x + playerBounds.dx - 30}

      for _, shotOffset in ipairs(offsets) do

        local bullet = game.ecs:newEntity('straightBullet')

        local bulletOrigin = bullet:addComponent('origin', {
          x = shotOffset,
          y = playerOrigin.y
        })

        local bulletHitbox = bullet:addComponent('hitbox', {
          dx = 2 * img:getWidth(),
          dy = 2 * img:getHeight()
        })

        bullet:addComponent('bullet')
        bullet:addComponent('clear-on-reset')
        bullet:addComponent('damage', { amount = 3 })
        bullet:addComponent('render-0', util.renderImage(game, bulletOrigin, { img = img, sx = 2, sy = 2}))
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
end

function waveShotUpdaterFactory(self, game, dt)
  local delay = 0.3
  local lastShotTime = nil

  return function(self, game, dt)
    if delayElapsed(lastShotTime, delay) then
      lastShotTime = love.timer.getTime()
      -- Generate a new bullet...
      local playerOrigin = util.getOrigin(game.player)
      local playerBounds = util.getBounds(game.player)
      local img = game.resources.waveImg

      local shots = {
        10,
        20,
        playerBounds.dx - 20,
        playerBounds.dx - 10
      }

      for i, shotOffset in ipairs(shots) do
        local bullet = game.ecs:newEntity('waveBullet')

        local bulletOrigin = bullet:addComponent('origin', {
          x = playerOrigin.x + shotOffset,
          y = playerOrigin.y
        })

        local bulletHitbox = bullet:addComponent('hitbox', {
          dx = 2 * img:getWidth(),
          dy = 2 * img:getHeight()
        })

        local startTime = love.timer.getTime()
        local originalX = bulletOrigin.x

        bullet:addComponent('bullet')
        bullet:addComponent('clear-on-reset')
        bullet:addComponent('render-0', util.renderImage(game, bulletOrigin, { img = img, sx = 2, sy = 2}))
        bullet:addComponent('damage', { amount = 4 })
        bullet:addComponent('update', {
          update = function(self, game, dt)
            if not util.overlap(
              bulletOrigin, bulletHitbox,
              util.getOrigin(game.gameArea), util.getBounds(game.gameArea)
            ) then
              game.ecs:removeEntity(bullet)
            else
              local direction = nil
              if i <= 2 then
                direction = 1
              else
                direction = -1
              end
              bulletOrigin.y = bulletOrigin.y - (dt * 400)
              bulletOrigin.x = originalX + direction * 40 * math.sin(10 * (love.timer.getTime() - startTime))
            end
          end
        })
      end
    end
  end
end

function rocketShotUpdaterFactory()
  local delay = 0.3
  local lastShotTime = nil
  local shootLeft = true

  return function(self, game, dt)
    if delayElapsed(lastShotTime, delay) then
      lastShotTime = love.timer.getTime()
      local playerOrigin = util.getOrigin(game.player)
      local playerBounds = util.getBounds(game.player)
      local xOffset = nil

      if shootLeft then
        xOffset = 5
      else
        xOffset = playerBounds.dx - 5
      end

      shootLeft = not shootLeft

      local bullet = game.ecs:newEntity('rocketBullet')
      local img = game.resources.rocketImg

      local bulletOrigin = bullet:addComponent('origin', {
        x = playerOrigin.x + xOffset,
        y = playerOrigin.y + game:scale(15)
      })

      local bulletHitbox = bullet:addComponent('hitbox', {
        dx = 2 * img:getWidth(),
        dy = 2 * img:getHeight()
      })

      local startTime = love.timer.getTime()
      local fullSpeedAt = 0.5

      bullet:addComponent('bullet')
      bullet:addComponent('clear-on-reset')
      bullet:addComponent('render-0', util.renderImage(game, bulletOrigin, { img = img, sx = 2, sy = 2}))
      bullet:addComponent('damage', { amount = 5 })
      bullet:addComponent('update', {
        update = function(self, game, dt)
          local speedMultiplier = nil
          local currentTime = love.timer.getTime()

          if currentTime - startTime >= fullSpeedAt then
            speedMultiplier = 1
          else
            speedMultiplier = (currentTime - startTime) / fullSpeedAt
          end

          if not util.overlap(
            bulletOrigin, bulletHitbox,
            util.getOrigin(game.gameArea), util.getBounds(game.gameArea)
            ) then
            game.ecs:removeEntity(bullet)
          else
            bulletOrigin.y = bulletOrigin.y - (dt * (-200 + (speedMultiplier * 700)))
          end
        end
      })
    end
  end
end
