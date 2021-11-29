# Advanced Kill Assists

_**English** | [Русский](README.ru.md)_

![Advanced Kill Assists](images/advanced_kill_assists.png)

AMX Mod X plugin for Counter-Strike.

Displays assists for kills in the kill list, without changing the client settings.
There is a setting for the monetary reward that the player can get for helping in the kill; switch for issuing frags for an assist; selection of an algorithm for counting assistants.

## Configuration
### Cvars
- ```aka_frag "1"``` If the value is positive, the player who assisted in the kill will be credited with a frag.
- ```aka_money "100"``` How much money to pay to the assisted player. Payment will be made only if the specified value is greater than zero.
- ```aka_damage "30.0"```

### Definitions
The configuration is done in the source file:
```c
#define ASSIST_ALGORITHM ADVANCED /* Algorithm for determining assistants in the assassination. The default is ADVANCED.

	CSSTATSX — Equivalent to CSstatsX.
	ADVANCED is an improved and fairer formula that chooses from a number of other assistants who has dealt the most damage victim and whose percentage of damage from the total damage from all is at least DAMAGE_FOR_ASSIST percent. */
```

## Requirements
- [Reapi](https://github.com/s1lentq/reapi)

## Authors
- [Xelson](https://github.com/Xelson)

## Thanks
- **Nestle_** for the stock to change the nicknames of the players
- **PRoSToC0der** for potential bugs found
- **8dp** for help in developing an algorithm for reducing nicknames with floating sizes
- **Garey** for investigating and identifying the cause of the crash POV demo
- **ReHLDS Team** for Invisible Spectator plugin
