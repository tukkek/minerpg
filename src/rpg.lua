-- Spawns an entity by its name.
-- Randomizes location and returns nil if couldn't find a good stop
function spawn(name,position)
    position.x=position.x+randomize(6)
    position.z=position.z+randomize(6)
    local tries=0
    while minetest.get_node(position).name~='air' do
        position.y=position.y+1
        tries=tries+1
        if tries==10 then
            return nil
        end
    end
    position.y=position.y+1 --npcs are 2 blocks tall
    return minetest.add_entity(position,name,ItemStack(name):get_metadata())
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
