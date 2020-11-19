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
- Fix CSS weapon viewmodels so weapons have backsides
- DNA Scanner and other obscure weapons
- Game status messages and many other similar UI elements
- Sync TTT Hitboxes with the VRMod player's model

## Bugs ##

- Can get kicked out of vr at the end of the round
- Player's camera is frequently in the wrong world position during setup time
- Target ID menus linger after target dies
- Right hand has weird problems in spectator mode if player dies while holstered
- HUD elements z-order incorrectly causing trippy overlap
- C4 throws sideways from hand
- Traitor trap hands sometimes scale incorrectly
- Held magneto stick props rarely gain huge velocity
- Have to double click the buy menu tabs to switch between them
- Muzzle flashes come from world model position rather than view model position
- Throwing a VR grenade can rarely cause server crash - might be an addon conflict, hard to recreate
- Swinging the VR crowbar can rarely force weapon switch - might be an addon conflict, hard to recreate

## FAQ ##

### Will you accept merge requests? ###
Yes, absolutely! (As long as it isn't completely spaghetti)

### How should I contact you? ###
Feel free to add me on [Steam](https://steamcommunity.com/profiles/76561198079528240), open a bug report on GitHub, or start a discussion on [the workshop](https://steamcommunity.com/sharedfiles/filedetails/discussions/2129490712)!

### Can you add this feature/fix this bug? ###
As long as it sticks to the vanilla TTT experience, of course!