#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <hamsandwich>

#define m_iNumTKs 478
#define m_iHideHUD 265
#define m_iClientHideHUD 268
#define m_iClientFOV 269
#define m_pActiveItem 278 		// возвращает Entity id оружия в руках (не константу)



new g_msg_statusicon
public plugin_init()
{
	register_plugin("DOD TEST GPT","0.0","America")
   
    /// All hud becomes red here
	//g_msg_statusicon = get_user_msgid("StatusIcon")
	/*
	RegisterHam(Ham_Item_PostFrame, "weapon_spring", "fw_Item_PostFrame");
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)    


	register_forward(FM_AddToFullPack, "addToFullPack", 1)
	*/
	register_clcmd("say 00", "parse_data")
	register_clcmd("say 1", "wr_riffle_states")
	register_clcmd("say 2", "parse_riffle_states")
	register_forward(FM_AddToFullPack, "addToFullPack", 0)

}   


public parse_data(id)
{	
	new Float:Punchangle[3]
	Punchangle[0] = 20.0 // Нос вниз
	// Punchangle[1] = 20.0 // ПРОТИВ ЧАСОВОЙ левое ухо назад, правое вперёд
	//Punchangle[2] = 20.0 // ПРОТИВ ЧАСОВОЙ левое ухо вних, правое вверх
	//entity_set_vector(1, EV_VEC_punchangle, Punchangle);
	//
	
	
	//set_pdata_int(1,365, 85, 5) // zoom

	


	engfunc(EngFunc_CrosshairAngle, 1, random_float(-50.0,50.0), random_float(-50.0,50.0), 50.0)

	/*
	message_begin(MSG_ONE, get_user_msgid("CurWeapon"), {0, 0, 0}, 1)
	write_byte(1)
	write_byte(10)
	write_byte(10)
	message_end()
	*/
	//entity_set_string(1, EV_SZ_viewmodel , "models/v_mp40.mdl")

	/*
	set_pev(1, pev_viewmodel2, "models/v_mp40.mdl")
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, 1)
  	write_byte(85) //Zooming AUG/SIG style
 	message_end()
	*/

	new abc1 =  get_pdata_int(id , m_iClientHideHUD, 5)
	new abc = get_pdata_int(id , m_iClientFOV, 5)
	new abc2 = get_pdata_int(id, m_iHideHUD, 5)
	new abc3 = get_pdata_int(id, m_iNumTKs, 5)


	client_print(0, print_chat, "mFOV %d, m_iClientHideHUD %d , m_iHideHUD %d, TK= %d", abc , abc1, abc2, abc3)
	set_task(2.0, "parse_data", id)
	set_pdata_int(id,m_iNumTKs, 0, 5) // RESET TEAMKILL


}


public fw_Item_PostFrame(weapon_ent)
{

	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, 1)
  	write_byte(20) //Zooming AUG/SIG style
 	message_end()

	client_print(0, print_chat, " ITEM POST REGISTRED")
	// fm_set_rendering(weapon_ent, kRenderFxGlowShell, 254, 254, 254, kRenderNormal, 16);
}
/*
public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
    
	//set_cd( cd_handle, CD_ViewOfs, fNewView );
	

	/* //ADD 
	set map as v_model O_o  WORKS !!
	set_cd( cd_handle, CD_ViewModel, 1 ); 

	// change only Z-point of view //
	new Float:fNewView[3];
	fNewView[2] = 96.0
	set_cd( cd_handle, CD_ViewOfs, fNewView );

	// set fov only 
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, 1)
  	write_byte(85) //Zooming AUG/SIG style
 	message_end()
	
	// set_cd( cd_handle, CD_FOV, 44.0 ); no FX
    */


public addToFullPack(es, e, ent, host, hostflags, player, pSet)
{
		new idx_wpn = get_pdata_cbase(1, m_pActiveItem, 5);
		if( ent == idx_wpn)
		{	

			new float: f_ori[3]
			// make objects not soild like not transarent glass ! 
			//set_es(ent, ES_Origin, SOLID_SLIDEBOX)
			new flagint
			get_es(es, ES_eFlags, flagint)
			set_es(es, ES_RenderAmt, 13)


			//get_es(ent, ES_Origin, f_ori)
			/*
			f_ori[2] += 50.0
			get_es(ent, ES_Origin, f_ori)
			*/


			set_pdata_int(1, 521, 7, 5) // SET m_flYawModifier 
			new intsome = get_pdata_int(1, 526)

			client_print(0, print_center, "addfl %d" ,intsome)

			return FMRES_SUPERCEDE
		}
		
}


public wr_riffle_states(id)
{

	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
  	write_byte(85) //Zooming AUG/SIG style
 	message_end()

	new idx_wpn = get_pdata_cbase(id, m_pActiveItem, 5);



}



public parse_riffle_states(id)
{

	new idx_wpn = get_pdata_cbase(id, m_pActiveItem, 5);




	client_print(0,print_chat, "statessssss ")
	// sfm_set_entity_visibility(idx_wpn, 1) не рработало
	// EV_INT_fixangle

	set_pdata_int(id, 521, 7, 5) // SET m_flYawModifier 

	// m_flYawModifier 521

}

/* 
при прицеливании CD_fUser2,			// float == 20,0   а просто 0,0
CD_fUser4 == всегда 100,0  х.з. чё




[Ent 1][Offset 230] Int: 42 Float: 0.000000 -> Int: 600 Float 0.00000  === MAX s[eed думаю]
[Ent 1][Offset 231] Int: 68085 Float: 0.000000 -> Int: 68544 Float 0.000000
[Ent 1][Offset 234] Int: -14773 Float: 0.000000 -> Int: -16150 Float 0.000000
Logged [ent 1] pdata 100 to 300
522 = номер анимации моделти игрока



[Ent 1][Offset 521] Int: 7 Float: 0.000000 -> Int: 1 Float 0.000000
*/