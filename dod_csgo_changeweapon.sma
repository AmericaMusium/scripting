#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5

// Dod CbaseWeapon offsets
#define m_knifeItem 272			// prt ножа 
#define m_pistolItem 273        //  ptr пистолета в инвентаре
#define m_rifleItem 274        //  ptr основы в инвентаре
#define weaponbox_slot_knife 82
#define weaponbox_slot_pistol 83
#define weaponbox_slot_primary 84

public plugin_init()
{
	register_plugin("Weapon Pickup Use", "0.1", "America")

	RegisterHam(Ham_Use, "weaponbox", "CWeaponBox_Use", .Post = false)
	RegisterHam(Ham_ObjectCaps, "weaponbox", "CWeaponBox_ObjectCaps", .Post = false)
    // RegisterHam(Ham_Touch,"weaponbox","CWeaponBox_Touch", .Post = false)

    /*
    	// Here i use AddToFullPack so we can make furiens visible for furiens
	register_forward(FM_AddToFullPack, "Fw__AddToFullPack", 1)
	
	// Setting player models
	register_forward(FM_SetClientKeyValue, "Fw__SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged, "Fw__ClientUserInfoChanged")
    */
}


public CWeaponBox_ObjectCaps(pWeaponBox, pPlayer)
{
    SetHamReturnInteger(FCAP_IMPULSE_USE)    
    return HAM_OVERRIDE
}

public CWeaponBox_Use(const pWeaponBox, const pPlayer, const pCaller, USE_TYPE:useType, Float:value)
{
    new cbase = 82
    new idx_wpn
    new pslot
	for ( cbase = 82; cbase < 86; cbase++ ) 
	{
		idx_wpn = get_pdata_cbase(pWeaponBox, cbase, linux_diff_weapon); // oofset 4

		if (is_valid_ent(idx_wpn))
		{   
            
            // I think simple methon withour define consts is faster 
            //  cbase weaponbox 82 + 190 = m_knifeitem in player inventory
            /*
            switch (cbase)
            {   
                case weaponbox_slot_knife:
                {
                     pslot = m_knifeItem  
                     break;
                }  
                case weaponbox_slot_pistol:
                {
                    pslot = m_pistolItem 
                    break;
                }  
                case weaponbox_slot_primary:
                [
                    pslot = m_rifleItem 
                    break;
                ]  
                case default:
                {
                    break;
                } 
            }
            */  
            pslot = cbase + 190

            new temp_cur_weapon_ent_id = get_pdata_cbase(pPlayer, pslot) // to frop pistol use m_pistolItem
            if (temp_cur_weapon_ent_id != -1)
            {
                new temp_class_name[17]
                entity_get_string(temp_cur_weapon_ent_id ,EV_SZ_classname,temp_class_name, 16)
                engclient_cmd(pPlayer,"drop",temp_class_name)
            }

            dllfunc(DLLFunc_Touch, pWeaponBox, pPlayer)
                
        }
    }
}

public CWeaponBox_Touch(pWeaponBox, pPlayer)
{
    if(is_user_alive(pPlayer) && !is_user_bot(pPlayer) )
    { 
        set_dhudmessage(20, 20, 20, 0.5 , 0.52 , 0 , 0.0 , 4.4 , 0.2, 0.2 )
        show_dhudmessage(0, "Press [E] to get weapon")
    }

}





/////////////////////////////
public Fw__AddToFullPack(es, e, iEntity, iHost, iHostFlags, iPlayer, pSet)
{   
    /*
	if(iPlayer && get_orig_retval() && is_user_alive(iEntity) && !g_bIsHuman[iEntity] && get_user_weapon(iEntity) == CSW_KNIFE)
	{
		new Float:fVecVelocity[3], Float:fCurSpeed
		entity_get_vector(iEntity, EV_VEC_velocity, fVecVelocity)
		fCurSpeed = vector_length(fVecVelocity)
		
		if(fCurSpeed < 255.0)
		{
			if(g_bIsHuman[iHost])
			{
				set_es(es, ES_RenderMode, kRenderTransAlpha)
				set_es(es, ES_RenderAmt, fCurSpeed)
			}
			
			else
			{
				set_es(es, ES_RenderMode, kRenderTransAlpha) // So Furiens know when someone is invisible
				set_es(es, ES_RenderAmt, floatclamp(fCurSpeed, 75.0, 255.0))
			}
		}
	}
    */
}

