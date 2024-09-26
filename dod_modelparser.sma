
#include <amxmodx>


#define PLUGIN "mdl data parser"
#define VERSION "0"
#define AUTHOR ""


new model_file[128] = "models\player\axis-inf\axis-inf.mdl"
// new model_file[128] = "models\player\allie-sniper\allie-sniper.mdl"


new const parts[] = {0,3,4,2,0,0};
new const sizes[] = {6,8,7,7,0,0};
new count = 4;


public plugin_init()
{   
    getSequenceData(model_file) // works 
    getBodyGroupData(model_file) // works 


    server_print("the pev_body index: %d",CalculateModelBodyArr(parts,sizes,count));
     server_print("    ")
}


getSequenceData(modelPath[])
{
    new filePointer = fopen(modelPath, "rb")
    if(!filePointer)
    {
        return 0
    }
    
    const numseqPosition      = 164 //10 x int, 5 x vec3_t(float[3]), 64 x char
    const numframesPosition   = 20  //5 x int
    const labelSize           = 32
    const headerSize          = 176
    
    fseek(filePointer, numseqPosition, SEEK_SET)

    new numseq
    fread(filePointer, numseq, BLOCK_INT)
    
    if(!numseq)
    {
        return 0
    }

    new seqindex
    fread(filePointer, seqindex, BLOCK_INT)
    fseek(filePointer, seqindex, SEEK_SET)

    new label[labelSize], Float:fps, numframes
    for(new i = 0; i < numseq; i++)
    {
        fread_blocks(filePointer, label     , labelSize, BLOCK_CHAR)
        fread(filePointer, _:fps            , BLOCK_INT)
        fseek(filePointer, numframesPosition, SEEK_CUR)
        fread(filePointer, numframes        , BLOCK_INT)

        fseek(filePointer, headerSize - labelSize - numframesPosition - 8, SEEK_CUR)
        
        server_print("%s %f %d", label, fps, numframes)
    }
    
    fclose(filePointer)
    return 1
    
} 


public getBodyGroupData(modelPath[])
{
    new filePointer = fopen(modelPath, "rb");
    if (!filePointer)
    {
        return 0;
    }

    
    const bodygroup_nums_position = 204; // aka numbodyparts
    new bodygroup_nums, bodypartindex_position, submodels_nums
    new bodygroup_name[64] 

    fseek(filePointer, bodygroup_nums_position, SEEK_SET); // set search cursor to position 
    fread(filePointer, bodygroup_nums, BLOCK_INT); // read data from position 
    fread(filePointer, bodypartindex_position, BLOCK_INT); // == 3791044 in this file

    server_print("Total number of bodygroups in models: %d", bodygroup_nums);
    // server_print("Body part index position: %d", bodypartindex_position); // == 3791044 in this file

    fseek(filePointer, bodypartindex_position, SEEK_SET)


    for (new group = 0; group < bodygroup_nums; group++){
        for (new i = 0; i < sizeof(bodygroup_name); i++){
            // get every char in name[64]
            fread(filePointer, bodygroup_name[i], BLOCK_CHAR)
        }
        server_print("%d:%s", group+1, bodygroup_name)

        fseek(filePointer, bodypartindex_position += 64, SEEK_SET)  
        fread(filePointer, submodels_nums, BLOCK_CHAR)
      
        server_print("      submodels: %d",  submodels_nums)
        fseek(filePointer, bodypartindex_position += 12, SEEK_SET)
    }
    

    fclose(filePointer);
    return 1;
}







public CalculateModelBodyArr(const parts[], const sizes[],const count){//Если есть массив который нужно выбрать
    static bodyInt32 = 0, temp=0, it=0, tempCount;bodyInt32=0;tempCount = count;
    while (tempCount--){
        if (sizes[tempCount] == 1)continue;
        temp = parts[tempCount]; for (it=0;it<tempCount;it++)temp *= sizes[it];
        bodyInt32 += temp;
    }
    return bodyInt32;
}



/*
https://github.com/dreamstalker/rehlds/blob/65c6ce593b5eabf13e92b03352e4b429d0d797b0/rehlds/public/rehlds/studio.h#L148
watch this file 

typedef struct
{   
    // data data data
	int					numbodyparts;  == 204 aka bodygroup_nums_position
	int					bodypartindex;  == 208 
    // data data data
} studiohdr_t;
    

this info we can find with  "bodypartindex" 
64 + 4 + 4 + 4 = 76 == searchstep
typedef struct
{
	char				name[64];   // 
	int					nummodels;  
	int					base;
	int					modelindex; // index into models array
} mstudiobodyparts_t; 
*/