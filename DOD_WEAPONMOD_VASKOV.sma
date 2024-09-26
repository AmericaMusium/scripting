/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define PLUGIN "WEAPONMOD VASKOV"
#define VERSION "1.0"
#define AUTHOR "[America][TheVaskov]"

#define OFFSET_WPN_ID			91
#define OFFSET_WPN_CLIP 		108
#define OFFSET_PISTOL_BPAMMO_LINUX	52
#define OFFSET_PISTOL_BPAMMO_WIN32	53
#define OFFSET_LINUX 			4


new DODW_CUST1name[] = "talnah"
new DODW_CUST1log[] = "talnah" // weapon_talnah
new DODW_CUST1id
new g_v_weaponmdl[] = "models/red/v_98kIO2.mdl"  // 98k model
new g_p_weaponmdl[] = "models/red/p_weaponmod1.mdl"
new g_w_weaponmdl[] = "models/red/w_weaponmod1.mdl"

new wpmod_weaponid[45]


new g_msgHideWeapon
new g_leftSptire
new g_scopetest
new const Hudleftsp[] = "sprites/glow03.spr" // SPTIRE


public plugin_precache()
{
	precache_model(g_v_weaponmdl) //�������� � ������ ������
	precache_model(g_p_weaponmdl) //�������� � ������ ������
	precache_model(Hudleftsp) //�������� � ������ ������
} 


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say addon", "wpm_create") // ������� � ��������� ������
	g_leftSptire = get_user_msgid("Object")	// Add your code here.
	// Add your code here...
	
	
}


public wpm_create(id){
	
	
	// 61 = 1 weapon new
	strip_user_weapons(id)
	// client_cmd(id,"drop")
	
	
	
	new logName[32],gunNam[32]
	DODW_CUST1id = custom_weapon_add(DODW_CUST1name, 1, DODW_CUST1log)
	xmod_get_wpnlogname( DODW_CUST1id, logName, 32) 
	xmod_get_wpnname ( DODW_CUST1id, gunNam, 32 ) 
	client_print(id,print_chat,"CUST1 ID %d created, l %s nam %s", DODW_CUST1id , logName, gunNam)
	// give_item(id,"talnah")
	
	// give_item(id,"weapon_bren")
	new clipg, ammog
	new wpnid = dod_get_user_weapon(id, clipg, ammog)
	new wpnent = dod_get_weapon_ent(id, wpnid)
	wpmod_weaponid[id] = wpnent
	
	// dod_weapon_type(id, 3)  scroll weapon inventory
	
	// dod_set_weaponlist(id, wpnent, 3, 2, 0) // ���������� ������ � ���� 1
	
	
		
	set_pev(id, pev_viewmodel2, g_v_weaponmdl) /// v_weapon 
	entity_set_string(id, EV_SZ_weaponmodel,  g_p_weaponmdl) // p_weapon
	
	
	
	// set_clip_stock(id,"weapon_bren",12)
	
	
	
	message_begin(MSG_ONE,g_leftSptire,{0,0,0},id)
	write_string("sprites/glow03.spr")
	message_end()

	

}





//////////////////////////// STOCKS 
public  set_clip_stock(id,const weapon[],clip) 
{
	new currentent = -1, gunid = 0
	// get origin
	new Float:origin[3];
	entity_get_vector(id,EV_VEC_origin,origin);
	
	while((currentent = find_ent_in_sphere(currentent,origin,Float:1.0)) != 0)
	{
		new classname[32];
		entity_get_string(currentent,EV_SZ_classname,classname,31);
		
		if(equal(classname,weapon))
			gunid = currentent
	}
	
	
	set_pdata_int(gunid,108,clip,4); // set their ammo (4 is linux update setting)
	return PLUGIN_CONTINUE
} 
stock dod_get_weapon_ent(id,wpnid)
{
	new ent = -1,entid

	new Float:origin[3]
	entity_get_vector(id,EV_VEC_origin,origin)
	
	while((ent = find_ent_in_sphere(ent,origin,0.4)) != 0)
			
		{
		if(is_valid_ent(ent))
			{
			entid = get_pdata_int(ent,OFFSET_WPN_ID,OFFSET_LINUX)
			
			if(wpnid == entid)
				return ent
			}
		}
		
	return 0
}
	
	
	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/