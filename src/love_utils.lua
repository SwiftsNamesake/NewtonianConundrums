-- Image processing utils

function processImage(image, shader, shader_data)
    --Process the given image with a shader and return it as a new object
    local canvas = love.graphics.newCanvas(image:getDimensions())
    local love_canvas = love.graphics.getCanvas()

    love.graphics.setCanvas(canvas)
    love.graphics.setShader(shader)

    for name, data in pairs(shader_data) do
        shader:send(name, data)
    end

    love.graphics.draw(image, 0, 0)

    love.graphics.setShader()
    love.graphics.setCanvas(love_canvas)

    return canvas
end

function takeScreenshot(filename, add_date)
    filename = filename or "screenshot"
    add_date = add_date or true

    if add_date then
        filename = filename .. "_" .. os.time()
    end

    screenshot = love.graphics.newScreenshot( true )
    screenshot:encode(filename .. ".png")
    print("Saved " .. filename .. ".png")
end

function canvasFromFile(filename)
    local image = love.graphics.newImage(filename)
    local new_canvas = love.graphics.newCanvas(image:getDimensions())
    
    --Set canvas to the new canvas
    local orig_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(new_canvas)
    
        love.graphics.draw(image)
        
    love.graphics.setCanvas(orig_canvas)
    
    return new_canvas
end

function keypadDirection(up, down, left, right, speed)
    speed = speed or 1
    
    local isDown = love.keyboard.isDown
    local y = isDown(up) and -1 or isDown(down) and 1 or 0
    local x = isDown(up) and -1 or isDown(down) and 1 or 0
    
    return x * speed, y * speed
end