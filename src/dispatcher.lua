--Fighter quest giver
--Note that this file is largely a copy-paste of wizard.lua, sadly it's not trivial to implement these as hierarchical objects

local DIALOGOFFER="minerpg:dispatcheroffer"
local NAME="minerpg:dispatcher"
local DISTANCEDELIVERY=200

local context={}
local formids=0

mobs:register_mob(NAME,{
  nametag='Dispatcher',
  type="npc",
  passive=false,
  damage=1,
  attack_type="dogfight",
  attacks_monsters=true,
  owner_loyal=true,
  pathfinding=true,
  hp_min=10,
  hp_max=10,
  armor=0,
  collisionbox={-0.35,-1.0,-0.35, 0.35,0.8,0.35},
  visual="mesh",
  mesh="character.b3d",
  drawtype="front",
  textures={{"mobs_trader2.png"},},
  child_texture={{"mobs_npc_baby.png"},},
  makes_footstep_sound=true,
  sounds={},
  walk_velocity=0,
  run_velocity=3,
  jump=true,
  drops={},
  water_damage=5,
  lava_damage=2,
  light_damage=0,
  follow={},
  view_range=15,
  owner="",
  order="follow",
  fear_height=3,
  walk_chance=0,
  group_attack=true,
  fall_damage=false,
  animation={
    speed_normal=30,
    speed_run=30,
    stand_start=0,
    stand_end=79,
    walk_start=168,
    walk_end=187,
    run_start=168,
    run_end=187,
    punch_start=200,
    punch_end=219,
  },
  on_rightclick=function(self,clicker)
    if receivepackage(clicker) then return end
    local today=minetest.get_day_count()
    if self.target==nil and (self.nextpackage==nil or today>=self.nextpackage) then
      self.target=gettarget(self.object:get_pos())
    end
    if self.target~=nil then
      local payment=round(distance(clicker:get_pos(),self.target)/100)
      minetest.show_formspec(clicker:get_player_name(), DIALOGOFFER,
        "size[10,4]"..
        "field[0,0;0,0;formid;formid;"..formids.."]"..
        "label[0,0;Do you want to deliver this package for me?]"..
        "label[0,1;"..pointto(clicker:get_pos(),self.target).."]"..
        "label[0,2;He will pay you "..payment.." coins on delivery.]"..
        "button_exit[0,3;1,1;deliver;Yes]"..
        "button_exit[1,3;1,1;exit;No]")
      context[formids..'']=self
      context[formids..'target']=self.target
      formids=formids+1
      return
    end
    minetest.show_formspec(clicker:get_player_name(), "minerpg:dispatcherempty",
      "size[10,2]"..
      "label[0,0;Sorry, I have no packages for you to deliver right now...]"..
      "button_exit[0,1;2,1;exit;OK]")
  end,
})

function receivepackage(clicker)
  local package=clicker:get_wielded_item()
  if package:get_name()~='minerpg:package' then return false end
  local target=minetest.deserialize(package:get_meta():get('target'))
  print('distance '..distance(target,clicker:get_pos()))
  if distance(target,clicker:get_pos())>DISTANCEDELIVERY then return false end
  local payment=package:get_meta():get_int('payment')
  local inventory=minetest.get_inventory({type="player",name=clicker:get_player_name()})
  inventory:remove_item('main',package)
  minetest.show_formspec(clicker:get_player_name(), "minerpg:dispatcherempty",
    "size[10,2]"..
    "label[0,0;Thanks! Here's you "..payment.." coins!]"..
    "button_exit[0,1;2,1;exit;OK]")
  inventory:add_item('main',ItemStack('minerpg:coin '..payment))
  return true
end

minetest.register_on_player_receive_fields(function(player,formname,fields)
  if formname==DIALOGBUY or fields['deliver']==nil then
    return
  end
  local id=fields['formid']
  local dispatcher=context[id]
  local today=minetest.get_day_count()
  local target=context[id..'target']
  dispatcher.nextpackage=today+roll(1,6)+1
  local inventory=minetest.get_inventory({type="player",name=player:get_player_name()})
  local package=ItemStack('minerpg:package')
  package:get_meta():set_string('target',minetest.serialize(target))
  package:get_meta():set_int('payment',round(distance(player:get_pos(),target)/100))
  inventory:add_item("main",package)
  dispatcher.target=nil
end)

function gettarget(pos)
  local targets={}
  local hubs=RPG_STORAGE:get('hubs')
  if hubs==nil then return nil end
  hubs=minetest.deserialize(RPG_STORAGE:get('hubs'))
  for _,hub in pairs(hubs) do
    if distance(pos,hub)>=DISTANCEDELIVERY then
      table.insert(targets,hub)
    end
  end
  if #targets==0 then return nil end
  return choose(targets)
end

function distance(a,b)
  local x=math.abs(a.x-b.x)
  local z=math.abs(a.z-b.z)
  if x>z then
    return x
  else
    return z
  end
end

minetest.register_craftitem("minerpg:package", {
  description="A delivery package",
  inventory_image="package.png",
  stack_max=1,
  on_use=function(stack,user,pointed_thing)
    local target=minetest.deserialize(stack:get_meta():get('target'))
    minetest.show_formspec(user:get_player_name(), "minerpg:packageinfo",
      "size[10,2]"..
      "label[0,0;"..pointto(user:get_pos(),target).."]"..
      "button_exit[0,1;2,1;exit;OK]")
    return itemstack
  end,
})

function pointto(from,to) --TODO figure out correct cardinals
  local x=from.x-to.x
  local pointer='The receiving dispatcher is about '..(round(math.abs(x)/100)*100)..' steps to the '
  if x>0 then 
    pointer=pointer..'west' 
  else 
    pointer=pointer..'east' 
  end
  local z=from.z-to.z
  pointer=pointer..' and '..(round(math.abs(z)/100)*100)..' steps to the '
  if z>0 then 
    pointer=pointer..'south.' 
  else 
    pointer=pointer..'north.' 
  end
  return pointer
end
