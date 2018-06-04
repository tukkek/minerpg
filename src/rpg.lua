-- Spawns an entity by its name.
-- Randomizes location and returns nil if couldn't find a good stop

local SPAWNHUBCHANCE=tonumber(minetest.setting_get("minetest_rpg_hubspawn"))

function spawn(name,position)
    local position={x=position.x,y=position.y,z=position.z,}
    position.x=position.x+randomize(100)
    position.y=position.y+randomize(10)
    position.z=position.z+randomize(100)
    local tries=1000
    while minetest.get_node(position).name~='air' do
        position.y=position.y+1
        tries=tries-1
        if tries==0 then
            return nil
        end
    end
    position.y=position.y+1 --npcs are 2 blocks tall
    local metadata=ItemStack(name):get_metadata()
    minetest.after(10,minetest.add_entity,position,name,metadata)
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

function listitemnames()
    local items={}
    for name,val in pairs(minetest.registered_items) do
        if name:gsub("%s+","")~='' then
            table.insert(items,name)
        end
    end
    return items
end

function spawnhub(position)
    local population=5+randomize(4)
    local placed=0
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
    print(SPAWNHUBCHANCE)
    print(chance)
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
