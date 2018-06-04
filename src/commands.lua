-- skips a day
minetest.register_chatcommand("day", {func=function(name,param)
    minetest.set_timeofday(1)
    return true,'ok'
end})

minetest.register_chatcommand("spawnwizard", {func=function(name,param)
    local player=minetest.get_player_by_name(name)
    spawn('minetest_rpg:wizard',player:get_pos())
    return true,'ok'
end})

minetest.register_chatcommand("spawnfighter", {func=function(name,param)
    local player=minetest.get_player_by_name(name)
    spawn('minetest_rpg:fighter',player:get_pos())
    return true,'ok'
end})

--from this point below use for debugging purposes
