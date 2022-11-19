AddCSLuaFile()

local SpelList = {
    ["Blink"] = {
        delay = 5,
        cooldown = 0,
        timestart = 0,
        prefunction = function( ply )

        end,
        postfunction = function( ply )

        end,
    },

}

hook.Add( "InitPostEntity", "Ready", function()
    local ply = LocalPlayer()
	ply.TableSpels = ply.TablePhaseSpeTableSpelsls or {}
end )

net.Receive("UpdatePlayerSpel", function()
    local nettable = net.ReadTable()

    local ply = LocalPlayer()

    local owner = nettable.owner
    local spel = nettable.spel
    local type = nettable.type

    hook.Call("UpdatePlayerSpel", nil, ply, owner, type, spel)
end)

hook.Add( "UpdatePlayerSpel", "UpdatePlayerSpel", function( ply, owner, type, spel )
	if IsValid( ply ) then
        if type == "init" then
            -- добавить обилку в массив игрока
            -- в том числе и создать объект spel на стороне клиента
        end

        if type == "cooldown" then
            -- включить отсчёт кд ( ну и худ соответственно тоже )
        end

        if type == "pre" then
            -- включить пре функцию ( например отрисовка траектории )
            -- выключение пре функции должно быть либо при начале пост функции либо при отмене
        end

        if type == "cancel" then
            -- отмена пре функции если она была активирована
        end

        if type == "post" then
            -- включить отсчёт кд ( ну и худ соответственно тоже )
            -- включить пост функцию ( само действие )
        end

        if type == "remove" then
            -- удаляет обилку из массива игрока
        end
    end
end )