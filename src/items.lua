local PRINTALL=false

rpg_drops={} --i:name
rpg_monsters_with_drops={} --i:name
rpg_monster_drops={} --mob:{name,name,...}
rpg_tools={} --i:name

function add(name,index)
    if name:gsub("%s+","")=='' then
        return false
    end
    table.insert(index,name)
    return true
end

function makeunique(oldtable)
    newtable={}
    names={}
    for _,name in pairs(oldtable) do
        if names[name]==nil then
            names[name]=true
            table.insert(newtable,name)
        end
    end
    return newtable
end

for name,node in pairs(minetest.registered_nodes) do
    if type(node.drop)=='string' then
        add(node.drop,rpg_drops)
    elseif type(node.drop)=='table' then
        for _,drop in pairs(node.drop.items) do
            for _,item in pairs(drop.items) do
                add(item,rpg_drops)
            end
        end
    end
end
rpg_drops=makeunique(rpg_drops)

for name,value in pairs(mobs.spawning_mobs) do
    local mob=minetest.registered_entities[name]
    if mob.type=='monster' and #mob.drops>0 then
        table.insert(rpg_monsters_with_drops,name)
        rpg_monster_drops[name]={}
        for _,drop in pairs(mob.drops) do
            add(drop.name,rpg_monster_drops[name])
        end
    end
end

for name,val in pairs(minetest.registered_tools) do
    add(name,rpg_tools)
end

if PRINTALL then
    for _,name in pairs(rpg_drops) do
        print('drop '..name)
    end
    for _,mob in pairs(rpg_monsters_with_drops) do
        for _,drop in pairs(rpg_monster_drops[mob]) do
            print(mob..' drops '..drop)
        end
    end
    for _,name in pairs(rpg_tools) do
        print('tool '..name)
    end
end
