-- The merchant sells any item from any mod in exchange for gold

local DIALOGNAME="minetest_rpg:merchant"

local context={}
local formid=0

mobs:register_mob("minetest_rpg:merchant", {
    nametag='Merchant',
    type="npc",
    passive=false,
    damage=3,
    attack_type="dogfight",
    attacks_monsters=true,
    owner_loyal=true,
    pathfinding=true,
    hp_min=20,
    hp_max=20,
    armor=0,
    collisionbox={-0.35,-1.0,-0.35, 0.35,0.8,0.35},
    visual="mesh",
    mesh="character.b3d",
    drawtype="front",
    textures={{"mobs_trader3.png"},},
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
        local today=minetest.get_day_count()
        if self.stock==nil then
            self.stock={}
            self.lastupdate=today-5
        end
        restock(self.stock,self.lastupdate,today)
        self.lastupdate=today
        context[formid..'']=self
        showdialog(self.stock,clicker:get_player_name(),formid)
        formid=formid+1
    end,
})

function restock(stock,lastupdate,today)
    while lastupdate<today do
        if #stock==9 then
            table.remove(stock,roll(1,#stock))
        else
            table.insert(stock,choose(rpg_tools))
        end
        lastupdate=lastupdate+1
    end
end

function showdialog(stock,playername)
    local actions=''
    local line=0
    for i,itemname in pairs(stock) do
        local item=minetest.registered_items[itemname]
        actions=actions.."button_exit[0,"..line..";2,1;"..itemname..";Buy]"

        actions=actions.."label[2,"..line..";"..item.description.." for "..price(itemname).." gold.]"
        line=line+1
    end
    minetest.show_formspec(playername, DIALOGNAME,
        "size[10,10]"..actions..
        "field[0,0;0,0;formid;formid;"..formid.."]"..
        "button_exit[0,"..line..";2,1;exit;Bye!]")
end

--safe price estimate (prevents recursion) and converted to 1-gold_ingot scale
function price(itemname)
    local cost=priceunsafe(itemname,{})
    cost=math.floor(cost/10)
    if cost<1 then
        return 1
    end
    return cost
end

--recursive function for estimating an item value
--also uses a fixed-cost list of PRICES
--if the second parameter is not nil, will prevent recursion (not optimal, but neeeds to be default for max compatibility)
--use /priceall to run a risky evaluation of all items in your server (requires DEBUG=true on init.lua)
function priceunsafe(itemname,safe)
    if safe~=nil then
        if safe[itemname]~=nil then
            return 1
        end
        safe[itemname]=1
    end
    if PRICES[itemname]~=nil then
        return PRICES[itemname]
    end
    local recipe=minetest.get_craft_recipe(itemname)
    if recipe.items==nil then
        return 1
    end
    local cost=0
    for _,material in pairs(recipe.items) do
        if safe==nil then
            print(material)
        end
        material=ItemStack(material)
        cost=cost+priceunsafe(material:get_name(),safe)*material:get_count()
    end
    return cost
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname~=DIALOGNAME then
        return false
    end
    local purchase=nil
    for name,value in pairs(fields) do
        if name~='formid' and name~='exit' and name~='quit' then
            purchase=name
            break
        end
    end
    local inventory=minetest.get_inventory({type="player",name=player:get_player_name()})
    if purchase~=nil and pay(purchase,inventory) then
        local merchant=context[fields['formid']]
        for i,value in pairs(merchant.stock) do
            if value==purchase then
                table.remove(merchant.stock,i)
                break
            end
        end
        inventory:add_item("main", ItemStack(purchase))
    end
    return true --consumer event and stops propagation
end)

function pay(purchase,inventory)
    local cost=price(purchase)
    local gold=0
    for _,stack in pairs(inventory:get_list("main")) do
        if stack:get_name()=='default:gold_ingot' then
            gold=gold+stack:get_count()
        end
    end
    if gold<cost then
        return false
    end
    inventory:remove_item('main',ItemStack('default:gold_ingot '..cost))
    return true
end
