#if defined _kill_assist_included
    #endinput
#endif
#define _kill_assist_included

/**
 * Called before setting the assistant in the killing
 *
 * @param assistant        - Assistant index
 * @param killer           - Killer index
 * @param victim           - Victim index
 * @return                 - PLUGIN_CONTINUE to ignore, PLUGIN_HANDLED or higher to block
 */
forward aka_on_assist(assistant, killer, victim);

/**
 * Get the number of player's assists. The counter resets after the player respawns
 *
 * @param id              - Player index
 * @return                - Player's assists count
 */
native aka_get_player_assists_count(id);
