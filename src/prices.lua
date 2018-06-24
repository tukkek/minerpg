PRICES={}

local COMMON={
    'default:coal_lump','default:sand','default:sandstone','default:clay','dye:grey','dye:grey','dye:white','dye:white',
    'dye:magenta','dye:pink','dye:red','default:desert_sand','default:desert_sandstone','default:snowblock','default:snow',
    'farming:straw','farming:wheat','default:glass','glass_fragments','dye:white','dye:dark_green','dye:green','dye:cyan',
    'dye:blue','default:papyrus','default:paper','default:bronzeblock',
}

for _,name in pairs(COMMON) do
    PRICES[name]=1
end

PRICES['default:gold']=10
PRICES['default:gold_ingot']=10
PRICES['default:diamond']=100
PRICES['default:steel_ingot']=5
PRICES['default:obsidian_shard']=5
PRICES['default:silver_sand']=2
PRICES['default:silver_sandstone']=2
PRICES['default:mese_crystal_fragment']=1
PRICES['default:mese_crystal']=10
PRICES['vessels:drinking_glass']=2
PRICES['default:book']=2
PRICES['default:book_written']=5
PRICES['default:bronze_ingot']=2
PRICES['moreores:silver_ingot']=5
