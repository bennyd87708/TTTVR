TTT VR
====================

A Garry's Mod addon bringing VR support to TTT using VRMod.

## Features ##

- Weapon selection UI ported from TTT
- Buy menu for detectives and traitors
- Round end UI (show winning team and highlights)
- Indicator for player's role at the start of the round
- Gun muzzle position and melee weapon fixes
- In-world HUD with proper depth perception
- Can suicide via headshot like in Pavlov VR
- Can pickup weapons with hands while holstered
- Searchable dead bodies
- Triggerable traitor traps

## To-Do ##

- Client UI for health, haste timer, role, and radar timer during round (use [j2b2's VRMod HUD addon](https://steamcommunity.com/sharedfiles/filedetails/?id=1937891124) for now)
- Replace CSS weapon viewmodels
- Planted bomb and DNA scanner UIs
- Editable controls
- Scoreboard UI
- Spectator Mode
- Game status messages
- Support for TTT2

## Bugs ##

- Traitor hands sometimes scale incorrectly
- Target ID menus sometimes linger after target dies
- HUD menus sometimes z-order incorrectly causing trippy overlap
- Need to double click tabs in buy menu to switch them
- Weapon muzzle flashes come from world model position rather than view model position
- Mac-10 shoots significantly sideways
- Held magneto stick props launch randomly
- Player's camera is sometimes in the wrong world position during setup time
- TTT Hitboxes don't move with visible VRMod player
- Suicide launches player's camera in direction of gun
- throwing grenade can cause server crash - seems like an addon conflict, hard to recreate
- crowbar swing can sometimes force weapon switch - seems like an addon conflict, hard to recreate

## FAQ ##

### Will you accept merge requests? ###
Yes, absolutely! (As long as it isn't completely spaghetti)

### How should I contact you? ###
Feel free to add me on [Steam](https://steamcommunity.com/profiles/76561198079528240), open a bug report on GitHub, or start a discussion on [the workshop](https://steamcommunity.com/sharedfiles/filedetails/discussions/2129490712)!

### Can you add this feature/fix this bug? ###
As long as it sticks to the vanilla TTT experience, of course!