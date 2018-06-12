-- skips a day
minetest.register_chatcommand("day", {func=function(name,param)
    minetest.set_timeofday(1)
    return true,'ok'
end})

minetest.register_chatcommand("spawnwizard", {func=function(name,param)
    spawn('minerpg:wizard',minetest.get_player_by_name(name):get_pos())
    return true,'ok'
end})

minetest.register_chatcommand("spawnfighter", {func=function(name,param)
    spawn('minerpg:fighter',minetest.get_player_by_name(name):get_pos())
    return true,'ok'
end})

minetest.register_chatcommand("spawnmerchant", {func=function(name,param)
    spawn('minerpgg:merchant',minetest.get_player_by_name(name):get_pos())
    return true,'ok'
end})

minetest.register_chatcommand("spawnhub", {func=function(name,param)
    spawnhub(minetest.get_player_by_name(name):get_pos())
    return true,'ok'
end})

--from this point onwards, place commands for debugging (do not commit!)
