local WORLDSIZE=minetest.settings['mapgen_limit'] or 31000
local DISTANCEMAX=10000
local DISTANCEFIND=100
local HUDS={}
local NAME="minerpg:treasuremap"

minetest.register_craftitem(NAME,{
  description="Treasure map",
  inventory_image="treasuremap.png",
  stack_max=1,
  on_use=function(stack,user,pointed_thing)
    local meta=stack:get_meta()
    local marks=meta:get('marks')
    local position=user:get_pos()
    if marks==nil then
      marks=generatemarks(position)
      meta:set_string('marks',minetest.serialize(marks))
    else
      marks=minetest.deserialize(marks)
    end
    for i,mark in pairs(marks) do
      if distance(position,mark)<=DISTANCEFIND then
        marks=findmark(i,marks,user)
        if marks~=nil then marks=minetest.serialize(marks) end
        meta:set_string('marks',marks)
        return stack
      end
    end
    listmarks(marks,user,position)
    return stack
  end,
})

function generatemarks(position)
  local marks={}
  local nmarks=roll(3,7)
  while #marks<nmarks do
    local mark={}
    mark.x=position.x+roll(-DISTANCEMAX,DISTANCEMAX)
    mark.z=position.z+roll(-DISTANCEMAX,DISTANCEMAX)
    if math.abs(mark.x)<WORLDSIZE and math.abs(mark.z)<WORLDSIZE then
      table.insert(marks,mark)
      position=mark
    end
  end
  return marks
end

function listmarks(marks,user,position)
  local text="size[10,"..(#marks+2).."]"..
    "label[0,0;There are several marks on the map:]"
  for i,mark in ipairs(marks) do
    text=text.."label[0,"..(i)..";Mark "..(i)..": "..pointto(position,mark).."]"
  end
  text=text.."button_exit[0,"..(#marks+1)..";2,1;exit;OK]"
  minetest.show_formspec(user:get_player_name(),'minerpg:treasuremaplist',text)
end

function findmark(marki,marks,user)
  if roll(1,#marks)==1 then
    minetest.show_formspec(user:get_player_name(),'minerpg:treasuremapfound',
      "size[10,3]"..
      "label[0,0;The magic incantation on the map produces a chest full of gold!]"..
      "label[0,1;There's another map on the chest. You pick it up...]"..
      "button_exit[0,2;2,1;exit;OK]")
    local inventory=minetest.get_inventory({type="player",name=user:get_player_name()})
    inventory:add_item("main",ItemStack('minerpg:coin 50'))
    return nil
  end
  minetest.show_formspec(user:get_player_name(),'minerpg:treasuremapfound',
    "size[10,2]"..
    "label[0,0;This is not the spot.. You cross the mark from the list.]"..
    "button_exit[0,1;2,1;exit;OK]")
  table.remove(marks,marki)
  return marks
end

minetest.register_on_joinplayer(function(player)
  local id=player:hud_add({
    hud_elem_type ="text",
    position={x=.5,y=0.02},
    offset={x=0,y=0},
    text="",
    alignment={x=0,y=0},
    scale={x=100,y=100},
    number=0xffd700,
  })
  HUDS[player:get_player_name()]=id;
end)

function updatehuds()
  for _,player in pairs(minetest.get_connected_players()) do
    local name=player:get_player_name()
    local hand=player:get_wielded_item()
    local show=hand~=nil and hand:get_name()==NAME
    local text=''
    if  show then
      local facing=player:get_look_dir()
      local direction=''
      local north=facing.z
      if facing.z>=.4 then text='N' elseif facing.z<=-.4 then text='S' end
      if facing.x>=.4 then text=text..'E' elseif facing.x<=-.4 then text=text..'W' end
    end
    player:hud_change(HUDS[name],"text",text)
  end
  minetest.after(2,updatehuds)
end
minetest.after(2,updatehuds)
