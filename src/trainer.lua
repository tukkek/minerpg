-- trainer will improve player stats for gold

local DIALOG='minerpg:trainerdialog'
local MAXARMOR=.75

mobs:register_mob("minerpg:trainer", {
    nametag='Trainer',
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
    textures={{"mobs_igor8.png"},},
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
        local armor=getarmorprice(clicker)
        if armor==0 then
            armor='button_exit[0,0;5,1;exit;Damage resistance already at maximum.]'
        else
            armor="button_exit[0,0;5,1;armor;Damage resistance for "..armor.." coins]"
        end
        local health=gethealthprice(clicker)
        if health==0 then
            health='button_exit[0,1;5,1;exit;Health already at maximum.]'
        else
            health="button_exit[0,1;5,1;health;Health upgrade for "..health.." coins]"
        end
        minetest.show_formspec(clicker:get_player_name(), DIALOG,
            "size[5,5]"..
            armor..
            health..
            "button_exit[0,2;5,1;jump;Jump upgrade for "..getjumpprice(clicker).." coins]"..
            "button_exit[0,3;5,1;speed;Speed upgrade for "..getspeedprice(clicker).." coins]"..
            "button_exit[0,4;5,1;exit;Bye!]")
    end,
})

function raisearmor(player)
    local armor=RPG_STORAGE:get_float(player:get_player_name()..'_armor')
    RPG_STORAGE:set_float(player:get_player_name()..'_armor',armor+.25)
end

function getarmorprice(player)
    local armor=RPG_STORAGE:get_float(player:get_player_name()..'_armor')
    armor=armor+0.25
    if armor>MAXARMOR then
        return 0
    else
        return round(armor*100)
    end
end

function raisespeed(player)
    local p=player:get_physics_override()
    p.speed=p.speed+0.2
    player:set_physics_override(p)
    RPG_STORAGE:set_float(player:get_player_name()..'_speed_override',p.speed)
end

function getspeedprice(player)
    return round(player:get_physics_override().speed*10)
end

function raisejump(player)
    local p=player:get_physics_override()
    p.jump=p.jump+0.25
    player:set_physics_override(p)
    RPG_STORAGE:set_float(player:get_player_name()..'_jump_override',p.jump)
end

function getjumpprice(player)
    local jump=player:get_physics_override().jump
    return round(jump*10)
end

function gethealthprice(player)
    local hp=tonumber(player:get_properties()['hp_max'])
    if hp>=20 then
        return 0
    else
        return hp/2
    end
end

function raisehealth(player)
    local newhp=tonumber(player:get_properties()['hp_max'])+2
    if newhp>20 then
        newhp=20
    end
    player:set_properties({hp_max=newhp,})
    RPG_STORAGE:set_float(player:get_player_name()..'_health_override',newhp)
end

minetest.register_on_player_receive_fields(function(player,formname,fields)
    if formname~=DIALOG then
        return false
    end
    local inventory=minetest.get_inventory({type="player",name=player:get_player_name()})
    if fields['health'] and pay(gethealthprice(player),inventory)  then
        raisehealth(player)
    elseif fields['speed'] and pay(getspeedprice(player),inventory) then
        raisespeed(player)
    elseif fields['jump'] and pay(getjumpprice(player),inventory) then
        raisejump(player)
    elseif fields['armor'] and pay(getarmorprice(player),inventory) then
        raisearmor(player)
    end
    return true
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change>=0 then
        return hp_change
    end
    if reason.type=='fall' then
        local resistance=round(player:get_physics_override().jump-1)*5
        hp_change=hp_change+resistance
        if hp_change>-1 then
            hp_change=0
        end
        print(hp_change)
    elseif reason.type=='punch' then
        local armor=RPG_STORAGE:get_float(player:get_player_name()..'_armor')
        hp_change=hp_change-hp_change*armor
    end
    return hp_change
end, true)

minetest.register_on_joinplayer(function(player)
    local physics=player:get_physics_override()
    local jump=RPG_STORAGE:get_float(player:get_player_name()..'_jump_override')
    if jump~=0 then
        physics.jump=jump
    end
    local speed=RPG_STORAGE:get_float(player:get_player_name()..'_speed_override')
    if speed~=0 then
        physics.speed=speed
    end
    player:set_physics_override(physics)
end)
