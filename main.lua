function love.load()                                                        --LOAD

    math.randomseed(os.time())

    sprites={}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')
    sprites.heart = love.graphics.newImage('sprites/heart.png')
    sprites.heart2 = love.graphics.newImage('sprites/heart2.png')

    player={}
        player.x = love.graphics.getWidth() / 2
        player.y = love.graphics.getHeight() / 2
        player.speed = 180

    myFont = love.graphics.newFont(30)
    zombies = {}
    bullets = {}

    gameState = 1
    maxTime = 2
    timer = maxTime
    t = 0
end
-- *****************************************************************************************************
function love.update(dt)                                                --UPDATE

    if gameState == 2 then
        if love.keyboard.isDown("d") then
            if player.x < love.graphics.getWidth()- sprites.player:getWidth() then
                player.x = player.x + player.speed*dt
            end
        end
        if love.keyboard.isDown("a") then
            if player.x > sprites.player:getWidth() then
                player.x = player.x - player.speed*dt
            end
        end
        if love.keyboard.isDown("s") then
            if player.y < love.graphics.getHeight()- sprites.player:getHeight() then
                player.y = player.y + player.speed*dt
            end
        end
        if love.keyboard.isDown("w") then
            if player.y > sprites.player:getHeight() then
                player.y = player.y - player.speed*dt
            end
        end
    end
    
    for i,z in ipairs(zombies) do
        z.x = z.x + math.cos(playerZombieAngle(z)) * z.speed *dt
        z.y = z.y + math.sin(playerZombieAngle(z)) * z.speed *dt

        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
                gameState = 1
                t = 0
                player.x = love.graphics.getWidth() / 2
                player.y = love.graphics.getHeight() / 2
            end
        end
    end

    for i,b in ipairs(bullets) do
        b.x = b.x + math.cos( b.direction ) * b.speed * dt
        b.y = b.y + math.sin( b.direction ) * b.speed * dt
    end

    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.x > love.graphics.getWidth() or b.y < 0 or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end

    for i, z in ipairs(zombies) do
        for j, b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 10 then
                z.dead = true
                b.dead = true
            end
        end
    end

    for i = #zombies, 1, -1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies, i)
        end
    end
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets, i)
        end
    end

    t = t + dt

    if gameState == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
    end
end
--******************************************************************************************************
function love.draw()                                                    --DRAW
    love.graphics.draw(sprites.background, 0, 0)

    if gameState == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click Anywhere To Begin!", 0, 50, love.graphics.getWidth(), "center")
        love.graphics.draw(sprites.player, love.graphics.getWidth()/4, 200, initialPlayerAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
        love.graphics.draw(sprites.zombie, love.graphics.getWidth()*3/4, 200, math.rad(150) + initialZombieAngle(), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    if gameState == 2 then
        love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

        love.graphics.draw(sprites.heart, 0, 0)                               --, nil, 0.03125, 0.03125)
        love.graphics.draw(sprites.heart2, 30, 0)
        for i,z in ipairs(zombies) do
            love.graphics.draw(sprites.zombie, z.x, z.y, playerZombieAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
        end

        for i,b in ipairs(bullets) do
            love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
        end
    end

end
--******************************************************************************************************
function love.keypressed(key)                                           --PRESSED
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == 2 then
        spawnBullet()
    elseif button == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
    end
end
--******************************************************************************************************
function playerMouseAngle()                                             --ANGLE
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
end

function playerZombieAngle(enemy)
    return math.atan2(player.y - enemy.y, player.x - enemy.x )
end

function initialPlayerAngle()
    return math.sin( 2.5 * t)
end
function initialZombieAngle()
    return -math.sin( 2.5 * t)
end
--******************************************************************************************************
function spawnZombie()                                                  --SPAWN
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 100
    zombie.dead = false

    local side = math.random(1,4)
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end
--******************************************************************************************************
function distanceBetween(x1, y1, x2, y2)                                --DISTANCE BETWEEN
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

