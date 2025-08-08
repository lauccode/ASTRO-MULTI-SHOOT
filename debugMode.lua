function debugMode(objects, fontNerd11)
    love.graphics.setFont(fontNerd11)

    if (objects[1] ~= nil) then
        if (objects[1].nameInstance == "VAISSEAU") then
            objects[1].print_infos(objects[1].nameInstance, 0, 0)
            objects[1].graphic_infos()
        end
    end

    if (objects[1].nameInstance == "ASTEROID") then
        love.graphics.print("" .. tostring(1), objects[1].X_pos,
            objects[1].Y_pos)
        local offsetPrint = 10
        love.graphics.print("#asteroids :" .. tostring(#objects), 300, 270 - offsetPrint)
        for objects_it = 1, #objects do
            love.graphics.print(".", (3 * objects_it) + 300, 280 - offsetPrint)
            if (objects[objects_it] == nil) then
                love.graphics.print(".", (3 * objects_it) + 300, 285 - offsetPrint)
            end
            objects[objects_it].graphic_infos()
        end
        objects[1].print_infos(objects[1].nameInstance, 300, 300)
    end

    if (objects[1].nameInstance == "MISSILE") then
        local offsetPrint = 10
        love.graphics.print("#missiles :" .. tostring(#objects), 0, 270 - offsetPrint)
        for objects_it = 1, #objects do
            love.graphics.print(".", 3 * objects_it, 280 - offsetPrint)
            if (objects[objects_it] == nil) then
                love.graphics.print(".", 3 * objects_it, 285 - offsetPrint)
            end
            objects[objects_it].graphic_infos()
        end
        objects[1].print_infos(objects[1].nameInstance, 0, 300)
    end
    love.graphics.print("getFPS :" .. tostring(string.format("%5.3f", love.timer.getFPS())), 380, 10)
    love.graphics.print("getDelta :" .. tostring(string.format("%5.3f", love.timer.getDelta())), 380, 20)
    love.graphics.print("getAverageDelta :" .. tostring(string.format("%5.3f", love.timer.getAverageDelta())), 380, 30)
end
