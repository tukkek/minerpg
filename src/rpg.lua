-- Spawns an entity by its name.
-- Randomizes location and returns nil if couldn't find a good stop

local SPAWNHUBCHANCE=tonumber(minetest.setting_get("minetest_rpg_hubspawn"))

function spawn(name,position)
    local maxheight=200
    local tries=maxheight*2
    local position={x=position.x+randomize(100),y=maxheight,z=position.z+randomize(100),}
    local node=minetest.get_node(position)
    local meta=minetest.registered_nodes[node.name]
    while node.name=='air' or node.name=='ignore' or meta.liquidtype~='none' or meta.drawtype~='normal' do
        tries=tries-1
        if tries==0 then
            return false
        end
        position.y=position.y-1
        node=minetest.get_node(position)
        meta=minetest.registered_nodes[node.name]
    end
    position.y=position.y+1 --npcs are 2 blocks tall
    local metadata=ItemStack(name):get_metadata()
    minetest.after(5,minetest.add_entity,position,name,metadata)
    return true
end

function roll(minp,maxp)
    return math.random(minp,maxp)
end

function randomize(maxp)
    return roll(1,maxp)-roll(1,maxp)
end

function choose(choices)
    return choices[math.random(#choices)]
end

function spawnhub(position)
    local population=5+randomize(4)
    local placed=0
    local attempts=1000
    while placed<population do
        local citizen=roll(1,3)
        if citizen==1 then
            citizen='minetest_rpg:fighter'
        elseif citizen==2 then
            citizen='minetest_rpg:wizard'
        else
            citizen='minetest_rpg:merchant'
        end
        if spawn(citizen,position) then
            placed=placed+1
        elseif attempts<=0 then
            return
        else
            attempts=attempts-1
        end
    end
end

--generates hubs during block generation
--mihgt generate no hubs or multiple per chunk
minetest.register_on_generated(function(minp, maxp, blockseed)
    local chance=50
    if SPAWNHUBCHANCE~=nil then
        chance=SPAWNHUBCHANCE
    end
    chance=chance-roll(1,100)
    while chance>0 do
        chance=chance-roll(1,100)
        local attempts=10
        for i=1,50 do
            if attemptplacement(minp,maxp) then
                break
            end
        end
    end
end)

function attemptplacement(minp,maxp)
    local position={
        x=roll(minp.x,maxp.x),
        y=0,
        z=roll(minp.z,maxp.z),
    }
    local name=minetest.get_node(position).name
    if name=='air' then
        while name=='air' do
            position.y=position.y-1
            name=minetest.get_node(position).name
            if minetest.registered_nodes[name].liquidtype~='none' or position.y<-1000 then
                return false
            end
        end
    else
        while name~='air' do
            position.y=position.y+1
            name=minetest.get_node(position).name
            if minetest.registered_nodes[name].liquidtype~='none' or position.y>1000 then
                return false
            end
        end
    end
    name=minetest.get_node(position).name
    local node=minetest.registered_nodes[name]
    if not node.walkable or node.drawtype~='normal' then
        return false
    end
    minetest.after(1,spawnhub,position)
    return true
end

function giveitems(player)
    give('default:sword_steel',1,player)
    give('default:pick_steel',1,player)
    give('default:apple',10,player)
    give('craftguide:book',1,player)
end

minetest.register_on_respawnplayer(function(player)
    giveitems(player)
    local newhp=player:get_hp()-2
    if newhp<1 then
        newhp=1
    end
    player:set_properties({hp_max=newhp,})
    return false --proceeds with normal respawn
end)

minetest.register_on_newplayer(function(player)
    giveitems(player)
    minetest.show_formspec(player:get_player_name(), "minetest_rpg:intro",
            "size[12,6]"..
            "label[0,0;Welcome to MineRPG! Your first goal is to find some friendly NPCs. They'll help fight against monsters!]"..
            "label[0,1;If you cannot find NPCs before your first nightfall, build a shelther or hide until daybreak.]"..
            "label[0,2;Once you're safe, talk to the NPCs to see which quests they are offering and try to complete them.]"..
            "label[0,3;Doing enough quests will allow you to acquire better equipment, stats and abilities!.]"..
            "label[0,4;Every time you die, you will lose some permanent health. If you die too much, start a new world.]"..
            "button_exit[0,4;2,4;exit;Got it!]")
end)

-- returns true if item give to player or false if item definition not found
function give(itemname,quantity,player)
    if minetest.registered_items[itemname]==nil then
        return false
    end
    minetest.get_inventory({type="player",name=player:get_player_name()}):add_item('main',ItemStack(itemname..' '..quantity))
    return true
end
