fbneo-combo-trials is a framework for fighting game combo trials on the [FBNeo](https://github.com/finalburnneo/FBNeo) emulator used in [Fightcade](https://www.fightcade.com/).
Inspiration and large pieces of code taken from peon2's [fbneo-training-mode](https://github.com/peon2/fbneo-training-mode).

**Features include:**

- A basic GUI for combo trials based on Street Fighter 4. No input display or demos and no plans to implement such as of now.
- Graphical menu interface for selecting different trials and settings. Separate menu supports buttons for selecting any specific trial within screen dimensions.
- Modular structure which allows for easy incorporation of combo trials and character state data. Everything is in separate files that are free to edit as you see fit.
- Ability to make your own combo trials in unlimited amounts.
- Ability to add support for other fighting games. This will take more effort and a basic knowledge of Lua programming. Usually Fightcade's training scripts can be used as a base for memory addresses and basic functions and the like. I'd also suggest looking through the cheat files over at [Pugsy's Cheats](https://www.mamecheat.co.uk/) and [fbneo-cheats](https://github.com/finalburnneo/FBNeo-cheats) for memory addresses.
- Extremely flexible. Conditions for success & failure in a trial can be basically anything as long as you're creative enough and have a decent knowledge of the codebase. Currently implemented basic conditions for hitting, whiffing, and multiple consecutive hits of a single attack.

## Usage

1. Open a supported game in Fightcade or the standalone FinalBurn Neo emulator. The rom must be in the list of supported roms. Generally, everything is made to work with the version that has the highest player count in the Fightcade lobbies.
2. Start a 2 player match.
3. Select `Game - Lua Scripting - New Lua Script Window` and press `Browse`.
4. Select the file `fbneo-combo-trials.lua` and press `Run`.

For any specific information not covered in this readme, refer to the enclosed documentation in the `docs` folder.

## Contribution

Suggestions of features are welcome. If you can code in Lua, improvements to the codebase would be appreciated.
Aside from that, you can contribute by mapping out character states.
You can do so as follows:

1. Backup Fightcade's training mode folder in case anything goes wrong. It is located here:
`<Fightcade install folder>\emulator\fbneo\fbneo-training-mode`
2. Copy the contents of the `statetest` folder to Fightcade's training mode folder. This modifies Fightcade's training mode to display certain relevant information depending on the game.
3. Run Fightcade's training mode with a supported game.
4. Use the provided txt templates to fill out state data for other characters. Don't touch the files in the `char_data` folders unless you're certain of what you're doing - these are used to map out character actions and serve as a foundation for the trials.

## Supported Games

- Street Fighter Alpha 1 **[sfa]** - 100% complete

## Special Thanks

- clymax
- crystal_cube99
- JAM
- Pau Oliva & the other Fightcade developers
- peon2
- Maximilian Dood
- silentscope88
- VesperArcade

And a very special thanks to you, for using this script!
