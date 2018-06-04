local DEBUG=true;

path=minetest.get_modpath("minetest_rpg")

dofile(path..'/src/rpg.lua')
dofile(path..'/src/wizard.lua')
dofile(path..'/src/fighter.lua')

if DEBUG then
    dofile(path..'/src/commands.lua')
end
