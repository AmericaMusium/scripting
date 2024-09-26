#include <amxmodx>
#include <fakemeta>
#include <fakemeta_stocks>
#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <hamsandwich>


new const REPLACEMENTFILE[] = "addons/amxmodx/configs/sr.cfg";
new const WORKAROUNDKEYWORD[] = "-SUPPORT"; // Should not be confusable for a sound replacement line
const MAXENTRIES = 96;
const MAXPATHLENGTH = 191;


new const VERSION[]=  "1.2";


new i;
new precacheF;
new column1[MAXENTRIES][MAXPATHLENGTH+1];
new column2[MAXENTRIES][MAXPATHLENGTH+1];
new bool:plist[MAXENTRIES];
new bool:ncSEF = true;
new ds;
new replaced;
new bool:ignore;


public plugin_precache() {
	register_plugin("Sound replacements", VERSION, "Silencer")
	if(file_exists(REPLACEMENTFILE)) {
		new len = file_size(REPLACEMENTFILE, 1); // Amount of lines in file
		const arrays=4*MAXPATHLENGTH+4; // Much space for spaces and tabs between sound paths
		new line[arrays];
		new skipline;
		new workaround = MAXPATHLENGTH; // Workaround a false tag mismatch positive by the Pawn compiler
		ds = is_dedicated_server();
		if(!ds) {
			log_amx("[SR] Attention: Running a listenserver -> *.gcf-files are being used -> Cannot verify existence of sound files -> Invalid paths may cause the server to crash.");
		}
		new clipboard1[MAXPATHLENGTH+1];
		new clipboard2[MAXPATHLENGTH+1];
		new failures;
		new overmax;
		new file = fopen(REPLACEMENTFILE, "r");
		if(!file) {
			log_amx("[SR] Error: Cannot open Sound replacement file ^"%s^".", REPLACEMENTFILE);
			set_fail_state("Cannot open file");
		}
		for(i = 0; i < len-skipline; i++) {
			fgets(file, line, arrays-1);
			trim(line);
			if(contain(line, "//") == 0) { // skip comments
				i--; skipline++;
			} else if(equali(line, WORKAROUNDKEYWORD)) {
					ncSEF = false;
					i--; skipline++;
			} else if(strlen(line)) {
				new bool:multi
				new bool:fail
				parse(line, clipboard1, MAXPATHLENGTH+1, clipboard2, MAXPATHLENGTH+1);
				if(clipboard1[workaround] != 0) {
					log_amx("[SR] Warning: Origin sound file path in line %i of sound replacement file is longer than %i chars! Not using.", i+skipline+1, MAXPATHLENGTH);
					i--; skipline++; failures++; fail = true;
					clipboard1[MAXPATHLENGTH] = 0;
				} else if(clipboard2[workaround] != 0) {
					log_amx("[SR] Warning: Target sound file path in line %i of sound replacement file is longer than %i chars! Not using.", i+skipline+1, MAXPATHLENGTH);
					i--; skipline++; failures++; fail = true;
					clipboard2[MAXPATHLENGTH] = 0;
				} else if(equali(clipboard1, clipboard2)) {
					log_amx("[SR] Warning: Target and Origin sound file path in line %i of sound replacement file are the same! Not using.", i+skipline+1);
					i--; skipline++; failures++; fail = true;
				} else if(i > 0) {
					for(new m = 0; m < i; m++) {
						if(equali(clipboard1, column1[m])) {
							log_amx("[SR] Warning: Replacement for Target sound file path in line %i of sound replacement file already set! Not using.", i+skipline+1);
							i--; skipline++; failures++;
							multi = true; // fail = true; // Not needed, since multi is already true
							break;
						}
					}
				}
				if(!multi) {
					if(ds) { // HLDS does not use *.gcf-files, so do safety-checks
						if(!file_exists(clipboard1)) {
							log_amx("[SR] Warning: Origin sound file path in line %i of sound replacement file does not exist! Not using.", i+skipline+1);
							i--; skipline++; failures++; fail = true;
						} else if(!file_exists(clipboard2)) {
							log_amx("[SR] Warning: Target sound file path in line %i of sound replacement file does not exist! Not using.", i+skipline+1);
							i--; skipline++; failures++; fail = true;
						}
					}
					if(!fail) {
						if(i >= MAXENTRIES) {
							i--; skipline++; overmax++;
						} else {
							
							copy(column1[i], MAXPATHLENGTH, clipboard1);
							copy(column2[i], MAXPATHLENGTH, clipboard2);
						}
					}
				}
			} else {
				i--; skipline++;
			}
		}
		fclose(file);
		if(i > 0) {
			if(ncSEF) {
				log_amx("[SR] %i sound(s) will be replaced when used by the map...", i);
				precacheF = register_forward(FM_PrecacheSound, "sr_ps", 0);
			} else {
				log_amx("[SR] Attention: Using support for custom sound engines. The game may cost more resources and be closer to the sound precache limit.");
				for(new l = 0; l < i; l++) {
					EF_PrecacheSound(column2[l]);
					//plist[l] = true; // In this case, plist is not being used
					replaced++;
				}
				log_amx("[SR] %i sound(s) will be hooked up to be replaced when played.", i);
			}
			if(failures)
				log_amx("[SR] %i sound(s) will not be replaced because of errors in the configurations file.", failures)
			if(overmax)
				log_amx("[SR] %i sound(s) will not be replaced because the sound replacements limit of %i has been reached.", overmax, MAXENTRIES)
			if(!failures && !overmax)
				log_amx("[SR] Parsed sound replacement file flawlessly.")
			register_forward(FM_EmitSound, "sr_es", 0);
			register_forward(FM_EmitAmbientSound, "sr_eas", 0);
			register_forward(FM_BuildSoundMsg, "sr_bsm", 0);
		} else {
			log_amx("[SR] Error: Zero sounds replaced.");
			set_fail_state("Nothing to replace");
		}
	} else {
		log_amx("[SR] Error: Sound replacement file ^"%s^" not found.", REPLACEMENTFILE);
		set_fail_state("File not found");
	}
}

public sr_ps(const szSample[]) {
	if(!ignore) {
		for(new j = 0; j < i; j++) {
			if(equali(szSample, column1[j])) {
				if(!plist[j]) { // Prevent double precaches
					ignore = true;
					EF_PrecacheSound(column2[j]);
					ignore = false;
					plist[j] = true;
					replaced++;
				}
				return FMRES_SUPERCEDE;
			}
		}
	}
	return FMRES_IGNORED;
}

public sr_es(ent, iChannel, const szSample[], Float:fVolume, Float:fAttenuation, iFlags, iPitch) {
	for(new j = 0; j < i; j++) {
		if(equali(szSample, column1[j])) {
			EF_EmitSound(ent, iChannel, column2[j], fVolume, fAttenuation, iFlags, iPitch);
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public sr_eas(ent, Float:fOrigin[3], const szSample[], Float:fVolume, Float:fAttenuation, iFlags, iPitch) {
	for(new j = 0; j < i; j++) {
		if(equali(szSample, column1[j])) {
			EF_EmitAmbientSound(ent, fOrigin, column2[j], fVolume, fAttenuation, iFlags, iPitch);
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public sr_bsm(ent, iChannel, const szSample[], Float:fVolume, Float:fAttenuation, iFlags, iPitch, iMsg_Dest, iMsg_Type, const Float:fOrigin[3], ent2) {
	for(new j = 0; j < i; j++) {
		if(equali(szSample, column1[j])) {
			EF_BuildSoundMSG(ent, iChannel, column2[j], fVolume, fAttenuation, iFlags, iPitch, iMsg_Dest, iMsg_Type, fOrigin, ent2);
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public plugin_init() {
	if(ncSEF) {
		unregister_forward(FM_PrecacheSound, precacheF, 0);
		log_amx("[SR] Out of %i sound files max., the necessary %i have been hooked up to be replaced when played.", i, replaced);
	}
}
