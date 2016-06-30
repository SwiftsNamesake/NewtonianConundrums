-- Configurations ahead


function import()


end


function love.conf(t)
    t.version = '0.10.1'
    t.window.msaa = 8
    t.console = true

    t.window.title = 'Newtonian Conundrums'
    -- t.window.setIcon 'icon.png' --love.graphics.newImage('icon.png')

    t.window.width      = 1024
    t.window.height     = 768
    t.window.borderless = false
    t.window.resizable  = true

    t.window.vsync = false
end
