AddCSLuaFile()

local SpellList = {
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
	ply.TableSpells = ply.TablePhaseSpeTableSpells or {}
end )

net.Receive("UpdatePlayerSpell", function()
    local nettable = net.ReadTable()

    local ply = LocalPlayer()

    local owner = nettable.owner
    local spell = nettable.spell
    local type = nettable.type

    hook.Call("UpdatePlayerSpell", nil, ply, owner, type, spell)
end)

hook.Add( "UpdatePlayerSpell", "UpdatePlayerSpell", function( ply, owner, type, spell )
	if IsValid( ply ) then
        if type == "init" then
            -- добавить обилку в массив игрока
            -- в том числе и создать объект spell на стороне клиента
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