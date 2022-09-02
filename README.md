TTT VR
====================

A Garry's Mod addon bringing VR support to TTT using VRMod.

## Features ##

- Default TTT GUI ports (weapon select, buy menu, scoreboard, etc.)
- VR versions of TTT HUD elements (radar, traitor traps, etc.)
- Indicator for player's role at the start of the round
- Gun muzzle position and melee weapon fixes
- Ability to suicide with headshot like in Pavlov VR (toggleable with tttvr_suicide cvar)
- Can physically pickup weapons with hands while holstered

## To-Do ##

- Client UI for health, haste timer, role, and radar timer during round (use [j2b2's VRMod HUD addon](https://steamcommunity.com/sharedfiles/filedetails/?id=1937891124) for now)
- Fix CSS weapon viewmodels so weapons have backsides (looking for expert help regarding source engine quirks)
- Other obscure weapons (DNA Scanner, some traitor weapons, etc.)
- Game status messages
- Sync TTT Hitboxes with the VRMod player's model (might be impossible, will try to ask Catse eventually)

## Bugs ##

- Can get kicked out of vr at the end of the round
- Player's camera is frequently in the wrong world position during setup time
- Target ID menus can linger after targetted player dies
- Right hand inverted in spectator mode if player dies while holstered
- HUD elements z-order incorrectly
- C4 drops sideways from hand
- Traitor trap hands sometimes appear massive (has not been replicated)
- Magneto stick props occasionally gain huge velocity
- Have to double click the buy menu tabs to switch between them
- Muzzle flashes come from world model position rather than view model position (need to check if this is only for the player in VR or for everyone)

## FAQ ##

### Will you accept merge requests? ###
Yes, absolutely! (As long as it isn't completely spaghetti)

### How should I contact you? ###
Feel free to add me on [Steam](https://steamcommunity.com/profiles/76561198079528240), open a bug report on GitHub, or start a discussion on [the workshop](https://steamcommunity.com/sharedfiles/filedetails/discussions/2129490712)!

### Can you add this feature/fix this bug? ###
As long as it sticks to the vanilla TTT experience, of course!
