-- Spawns an entity by its name.
-- Randomizes location and returns nil if couldn't find a good stop

RPG_STORAGE=minetest.get_mod_storage()

local SPAWNHUBCHANCE=tonumber(minetest.setting_get("minerpg_hubspawn"))

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
  minetest.after(5,minetest.add_entity,position,name)
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
    local trainer=true
    local dispatcher=true
    while placed<population do
        local citizen=roll(1,5)
        if citizen==1 then
            citizen='minerpg:fighter'
        elseif citizen==2 then
            citizen='minerpg:wizard'
        elseif citizen==3 then
            citizen='minerpg:merchant'
        elseif citizen==4 and trainer then
            citizen='minerpg:trainer'
            trainer=false
        elseif citizen==5 and dispatcher then
            citizen='minerpg:dispatcher'
            registerhub(position)
            dispatcher=false
        end
        if type(citizen)=='string' and spawn(citizen,position) then
            placed=placed+1
        elseif attempts<=0 then
            return
        else
            attempts=attempts-1
        end
    end
end

function registerhub(position)
  local hubs=RPG_STORAGE:get('hubs')
  if hubs==nil then 
    hubs={} 
  else
    hubs=minetest.deserialize(hubs)
  end
  table.insert(hubs,position)
  RPG_STORAGE:set_string('hubs',minetest.serialize(hubs))
end

--generates hubs during block generation
--mihgt generate no hubs or multiple per chunk
minetest.register_on_generated(function(minp, maxp, blockseed)
    local chance=25
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
  give('minerpg:treasuremap',1,player)
end

minetest.register_on_respawnplayer(function(player)
    giveitems(player)
    local newhp=player:get_hp()-2
    if newhp<1 then
        newhp=1
    end
    player:set_properties({hp_max=newhp,})
    RPG_STORAGE:set_float(player:get_player_name()..'_health_override',newhp)
    return false --proceeds with normal respawn
end)

minetest.register_on_joinplayer(function(player)
    local hp=RPG_STORAGE:get_float(player:get_player_name()..'_health_override')
    if hp~=0 then
        player:set_properties({hp_max=hp,})
    end
end)

minetest.register_on_newplayer(function(player)
  giveitems(player)
  minetest.show_formspec(player:get_player_name(), "minerpg:intro",
    "size[10,7]"..
    "label[0,0;Welcome to MineRPG! First try to find friendly NPCs. They'll help you fight monsters!]"..
    "label[0,1;If you can't find NPCs until nightfall, build a shelther or hide until daybreak.]"..
    "label[0,2;Right-click NPCs to see which quests they are offering and complete them for gold.]"..
    "label[0,3;To sell or deliver an item, make sure to have it on your hand while talking.]"..
    "label[0,4;Doing enough quests will allow you to acquire better equipment, stats and abilities!.]"..
    "label[0,5;When you die, you lose some permanent health. If you die too much, start a new world.]"..
    "button_exit[0,6;10,1;exit;Got it!]")
end)

-- returns true if item give to player or false if item definition not found
function give(itemname,quantity,player)
    if minetest.registered_items[itemname]==nil then
        return false
    end
    minetest.get_inventory({type="player",name=player:get_player_name()}):add_item('main',ItemStack(itemname..' '..quantity))
    return true
end

minetest.register_craftitem("minerpg:coin",{
    description="Coin",
    inventory_image="coins_g.png",
    stack_max=100
})

function round(num,numDecimalPlaces)
  local mult=10^(numDecimalPlaces or 0)
  return math.floor(num*mult+0.5)/mult
end
