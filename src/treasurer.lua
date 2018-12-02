local TRIESPERCHUNK=10000
local CHESTSPERCHUNK=1

local function registertreasure(name,rarity)
  local preciousness=price(name)
  if preciousness<=1 then return end
  --print('register '..name..' $'..preciousness)
  if preciousness>10 then preciousness=10 end
  if not treasurer.register_treasure(name,rarity,preciousness) then
    print('[MineRPG] Error registering treasure: '..name)
  end
end

local function registertreasures() --TODO decide which rarities to use (0=very rare, 1=most common)
  for _,drop in pairs(rpg_drops) do
    registertreasure(drop,1)
  end
  for _,tool in pairs(rpg_tools) do
    registertreasure(tool,1)
  end
  for _,drops in pairs(rpg_monster_drops) do
    for _,drop in pairs(drops) do
      registertreasure(drop,1)
    end
  end
end

function placetreasure(minp,maxp)
  local position={
    x=roll(minp.x,maxp.x),
    y=roll(minp.y,maxp.y),
    z=roll(minp.z,maxp.z),
  }
  if position.y>-10 then return false end
  if minetest.get_node(position).name~='air' then return false end
  while minetest.get_node(position).name=='air' do
    position.y=position.y-1
    if position.y<minp.y then return false end
  end
  position.y=position.y+1
  --if minetest.registered_nodes[name].liquidtype~='none' then return false end
  if minetest.get_node(position).name~='air' then return false end
  local treasure=treasurer.select_random_treasures(roll(1,4)+roll(1,4))
  if #treasure==0 then return false end
  minetest.set_node(position,{name="default:chest"})
  local inventory=minetest.get_meta(position):get_inventory()
  for _,item in pairs(treasure) do inventory:add_item("main", item) end
  --print('generated treasure: ',position)
  return true
end

function generatetreasure(minp, maxp, blockseed) --creates underground chests
  local chests=CHESTSPERCHUNK
  for i=0,TRIESPERCHUNK do
    if placetreasure(minp,maxp) then 
      chests=chests-1
      if chests==0 then return end
    end
  end
end

if minetest.get_modpath("treasurer")~=nil then
  registertreasures()
  minetest.register_on_generated(function(minp,maxp,blockseed)
    minetest.after(3,generatetreasure,minp,maxp)
  end)
end
