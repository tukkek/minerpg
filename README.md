# MineRPG mod

*Also check out the [MineRPG game](https://github.com/tukkek/minerpg_game) for a full Minetest RPG experience with several new mods, monsters and game content!*

Mod for the free and open-source sandbox game [Minetest](http://minetest.net/) that provides mulitplayer-friendly RPG quests and advancement. This is mainly done by placing "hubs" during world generation, with NPCs that will act as quest givers, shops and trainers. Each hub may have one or more of these NPCs:

* Fighter: rewards you for killing certain hostile mobs and acquiring their drops.
* Wizard: rewards you for fetching certain types of natural or manufactured items.
* Merchant: buys and sells items (stock changes slightly with each passing day).
* Trainer: raises player's stats for gold.

Once a quest is completed, these NPCs will reward the player with gold, which can then be used to buy items or advance their stats. Each quest is also put on a time limit, expiring in anywhere from a couple of days to a week - giving players a chance to either try to complete them or wait until a new quest is generated instead, while they focus on other sandbox activities (or content from other mods).

The main goal of MineRPG is to nudge Minetest into a more traditional gaming experience, vaguely similar to some famous RPG video-games (minus the plot elements). It doesn't try to force the gameplay though, leaving you free to do your own thing in-between or even while you try to complete quests. The ultimate goal is to give you more reasons to go out and explore the amazing procedurally-generated world around you and use all the tools at your disposal, while also rewarding you for doing that!

## Difficulty

Although not intended to be a "hardcore" mode, MineRPG is definitely more difficult than your typical survival server. When you die you also permanently lose 1 heart, on top of normal death setbacks. This is done to encourage a "permadeath" style of play, where death is a serious matter, not a temporary setback.

## Multiplayer

This mod tries to be multiplayer-friendly, creating a competitive and/or cooperative scenario where players can try to be the first ones to finish a quest, or work together in order to fulfill them. It can also be played normally on singleplayer as well!

It's important to note though that, as of the first release, there isn't any thought put into balance - so players who complete more quests earlier are going to become more powerful and are going to have an easier time completing even more quests compared to weaker players. 

To avoid this, the best you can do at this point is have new groups of players find different hubs to operate on instead of trying to compete with more powerful players in the same hub. Another option, if you want to run a RPG-focused server, is to restart the world (or player's inventories and stats) from scratch every week, couple weeks, month, etc.

## Configuration

You can set these options on your `minetest.conf` file:

* `minerpg_hubspawn` (number): luck-based chance of generating a hub with each world-chunk generation.

## Dependencies

These mods are required for MineRPG to work. They will automatically be loaded in the correct order after you install and enable them:

* mobs_redo https://github.com/tenplus1/mobs_redo
* mobs_monster https://github.com/tenplus1/mobs_monster

Of course, the base Minetest game (or stand-alone server) also needs to be installed, which can be done through your package manager or for free via the official website at http://minetest.net/

Optional dependencies which MineRPG benefits from:

* craftguide https://github.com/minetest-mods/craftguide/

## Compatibility with other mods 

MineRPG should be generally compatible with all mods. Read onwards for specific details.

This mod will lookup global item tables and global mob tables when generating quest and shop items - in an attempt to work with *any* other mod you may have active on your server! This allows the RPG quests to grow with the number and complexity of the mods you have, without me having to support each mod independently.  Just install a new mod and it will instantly be incorporated to MineRPG's shops and quest-givers!

The downside to that is that shop items or quests may end up being weird, especially if a quest-giver asks you to bring him an item that isn't generated or crafted normally during that game. This is minimized as much as possible but in these cases, you'll either have to wait until the quest expires and a new one is introduced, find a new hub with new quests, or just not use MineRPG with mods that may cause this to happen.

Some degree of intelligence is put into evaluating item costs (particularly on shops) but obviously it's impossible to create a formula that is perfect and also supports every other mod (including ones that haven't even been created yet). However, it's easy to set an item price by editing the [prices.lua](https://github.com/tukkek/minerpg/blob/master/src/prices.lua) file, if the default estimate isn't adequate (and it will also help inform future estimates for recipes that include any items listed there).

**IMPORTANT:** MineRPG can only lookup items from mods that have been loaded earlier than itself when the server starts. To make sure other mods are loaded earlier, you have to add new lines in the format `othermodname?` to [depends.txt](https://github.com/tukkek/minerpg/blob/master/depends.txt). If you are a mod developer or user and want me to add your own (or favorite) mods to MineRPG's `depends.txt`, feel free to open up a GitHub issue, a pull request or send me an email and I'll be happy to do it.
