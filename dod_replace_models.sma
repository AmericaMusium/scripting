#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <okapi>


#define MultiModel "models/w_30cal.mdl"

new const models_list[][] = 
{
    "models/w_30cal.mdl",
    "models/w_30cal_box.mdl",
    "models/w_98k.mdl",
    "models/w_amerk.mdl",
    "models/w_bar.mdl",
    "models/w_bazooka.mdl",
    "models/w_bazooka_rocket.mdl",
    "models/w_bren.mdl",
    "models/w_colt.mdl",
    "models/w_enfield.mdl",
    "models/w_enfield_scoped.mdl",
    "models/w_enfields.mdl",
    "models/w_fcarb.mdl",
    "models/w_fg42.mdl",
    "models/w_fg42s.mdl",
    "models/w_garand.mdl",
    "models/w_greasegun.mdl",
    "models/w_grenade.mdl",
    "models/w_k43.mdl",
    "models/w_luger.mdl",
    "models/w_m1carb.mdl",
    "models/w_mg34.mdl",
    "models/w_mg42.mdl",
    "models/w_mg42_box.mdl",
    "models/w_mills.mdl",
    "models/w_mills2.mdl",
    "models/w_mortar.mdl",
    "models/w_mp40.mdl",
    "models/w_mp44.mdl",
    "models/w_mp44clip.mdl",
    "models/w_paraknife.mdl",
    "models/w_piat.mdl",
    "models/w_piat_rocket.mdl",
    "models/w_piatmodel.mdl",
    "models/w_pschreck.mdl",
    "models/w_pschreck_rocket.mdl",
    "models/w_satchel.mdl",
    "models/w_scoped98k.mdl",
    "models/w_spade.mdl",
    "models/w_spring.mdl",
    "models/w_sten.mdl",
    "models/w_stick.mdl",
    "models/w_tommy.mdl",
    "models/w_webley.mdl"
};

public plugin_init()
{
    register_plugin("DOD OKAPI TEST", "2023", "America");
    for (new i = 0; i < sizeof(models_list); i++)
    {   
        okapi_mod_replace_string(models_list[i], MultiModel, 1);
        okapi_engine_replace_string(models_list[i], MultiModel, 1);
    }
}