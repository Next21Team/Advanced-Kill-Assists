# Advanced Kill Assists

_**English** | [Русский](README.ru.md)_

![Advanced Kill Assists](images/advanced_kill_assists.png)

AMX Mod X plugin for Counter-Strike.

Displays assists for kills in the kill list, without changing the client settings.
There is a setting for the monetary reward that the player can get for helping in the kill; switch for issuing frags for an assist; selection of an algorithm for counting assistants.

To integrate with AES, you need to compile the plugin with the *aes_v.inc* present in the include folder. You do not need to edit anything in the plugin.

## Cvars
- ```aka_algorithm "1"``` Algorithm for determining assistants in the assassination. The default is ADVANCED (1).
```c
//		CSSTATSX — Equivalent to CSstatsX.
//		ADVANCED is an improved and fairer formula that chooses from a number of other assistants who has dealt the most damage victim and whose percentage of damage from the total damage from all is at least DAMAGE_FOR_ASSIST percent.
```
- ```aka_frag "1"``` If the value is positive, the player who assisted in the kill will be credited with a frag.
- ```aka_money "100"``` How much money to pay to the assisted player. Payment will be made only if the specified value is greater than zero.
- ```aka_damage "30.0"``` Universal damage value. Its value is determined by the ```aka_algorithm```.
- ```aka_exp "0"``` How much AES experience to give to a player who assisted in a kill. The output will only occur if a value greater than zero is specified.
- ```aka_noffreward "1"``` If the value is not zero, the player who assisted in the kill a teammate (friendly fire) will not be credited with a frag, money and AES experience.
- ```aka_chatmessage "1"``` Display a chat message to the player who assisted in the kill. The message template is contained in **data/lang/next21_kill_assist.txt**. Special inserts supported:
```c
//		[award]  — Money kill reward equal to aka_money. Output without the '$' character.
//		[exp]    — Experience kill reward equal to aka_exp. Only works with AES.
//		[killer] — Killer player nickname.
//		[victim] — Victim player nickname.
//    The [exp] value only works with aka_exp > 0 and AES activated, and the [award] value only works with aka_money > 0.
//    Otherwise, an empty value will be displayed.
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
- **ReHLDS Team** for [Invisible Spectator](https://dev-cs.ru/threads/1055/) plugin
