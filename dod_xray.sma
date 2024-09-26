#include <amxmodx>
#include <fakemeta>

stock const CLASSES[][] = {
    "player"
}

new Trie: g_tClasses;

public plugin_init() {
    register_forward(FM_AddToFullPack, "AddToFullPack", ._post = true);

    g_tClasses = TrieCreate();

    for(new i; i < sizeof CLASSES; i++)
        TrieSetCell(g_tClasses, CLASSES[i], 0);

// for tests
    register_clcmd("radio2", "toggle");
}

public plugin_end()
    TrieDestroy(g_tClasses);

new bool: gBool[33];
public toggle(pPlayer) {
    gBool[pPlayer] = !gBool[pPlayer];

    return PLUGIN_HANDLED;
}

public AddToFullPack(es, e, ent, host, hostflags, player, pSet) {
    if(!is_user_alive(host) || !gBool[host]) return;

    static szString[19];
    pev(e, pev_classname, szString, charsmax(szString));

    if(TrieKeyExists(g_tClasses, szString))
    {
        set_es_rendering(
            .es = es,
            .fx = kRenderFxGlowShell,
            .color = {255, 0, 0},
            .render = kRenderTransColor,
            .amount = 100
        );
    }
}

stock set_es_rendering(es = 0, fx = kRenderFxNone, color[3] = {255, 255, 255}, render = kRenderNormal, amount = 16) {
    set_es(es, ES_RenderFx, fx);
    set_es(es, ES_RenderColor, color);
    set_es(es, ES_RenderMode, render);
    set_es(es, ES_RenderAmt, amount);
}