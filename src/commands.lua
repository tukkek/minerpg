minetest.register_chatcommand("createhub", {func=function(name,param)
    local player=minetest.get_player_by_name(name)
    createhub(player:get_pos(),player)
    return true,'yes'
end})
