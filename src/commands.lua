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

minetest.register_chatcommand("spawnmerchant", {func=function(name,param)
    local player=minetest.get_player_by_name(name)
    spawn('minetest_rpg:merchant',player:get_pos())
    return true,'ok'
end})

-- use to check for any problems with your modlist price estimates (including recipe recursion)
minetest.register_chatcommand("priceall", {func=function(name,param)
    for _,name in pairs(listitemnames()) do
        print('calculating '..name)
        priceunsafe(name,nil)
    end
    return true,'ok'
end})

--from this point onwards, place commands for debugging (do not commit!)
