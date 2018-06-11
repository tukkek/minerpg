--Fighter quest giver
--Note that this file is largely a copy-paste of wizard.lua, sadly it's not trivial to implement these as hierarchical objects

mobs:register_mob("minetest_rpg:fighter", {
    nametag='Fighter',
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
    textures={{"mobs_trader.png"},},
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
        if self.quest~=nil and today>self.deadline then
            self.quest=nil
        end
        if self.quest==nil then
            self.questname=choose(rpg_monster_drops[choose(rpg_monsters_with_drops)])
            self.quest=minetest.registered_items[self.questname]
            local deadline=1+roll(1,6)
            self.deadline=today+deadline
            self.reward=7-deadline+randomize(4)+math.floor(price(self.questname))
            if self.reward<1 then
                self.reward=1
            end
        end
        local inventory=minetest.get_inventory({type="player",name=clicker:get_player_name()})
        if checkcompleted(inventory,self.questname,clicker) then
            self.quest=nil
            inventory:add_item("main", ItemStack('minetest_rpg:coin '..self.reward))
            minetest.show_formspec(clicker:get_player_name(), "minetest_rpg:fighterquestdone",
                    "size[10,2]"..
                    "label[0,0;Thanks! Here's your "..self.reward.." coins!]"..
                    "button_exit[0,1;2,1;exit;OK]")
            return
        end
        local timeleft=self.deadline-today
        minetest.show_formspec(clicker:get_player_name(), "minetest_rpg:fighterquest",
                "size[10,4]"..
                "label[0,0;Can you bring me one "..self.quest.description.."?]"..
                "label[0,1;I'll pay you "..self.reward.." coins.]"..
                "label[0,2;You have "..timeleft.." days remaining.]"..
                "button_exit[0,3;2,1;exit;OK]")
    end,
})
