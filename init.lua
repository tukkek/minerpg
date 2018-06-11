local DEBUG=true;

path=minetest.get_modpath("minetest_rpg")

dofile(path..'/src/items.lua')
dofile(path..'/src/rpg.lua')
dofile(path..'/src/prices.lua')
dofile(path..'/src/merchant.lua')
dofile(path..'/src/wizard.lua')
dofile(path..'/src/fighter.lua')
dofile(path..'/src/trainer.lua')

if DEBUG then
    dofile(path..'/src/commands.lua')
end
