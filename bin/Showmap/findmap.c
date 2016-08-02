#include <stdio.h>

char txt[2048];
FILE *fp;


char txt_section[256];
char txt_addr[256];
char txt_size[256];
char txt_file[1024];
char txt_keywords[1024];

int skip_space(char ** pPtr){
    char * p = *pPtr;
    char c;

    while (1){
        c = p[0];
        if (c != ' ' && c != '\t' && c != '\r' && c != '\n') break;

        while (c == '\r' || c == '\n'){
            fgets(txt, sizeof(txt), fp);
            if (feof(fp)) return 0;
            p = txt;
            c = p[0];
        }

        if (c == 0) return 0;
        p++;
    }
    *pPtr = p;
    return 1;
}


int rx_string(char ** pPtr, char * pdst){

    char * p = *pPtr;
    char c;

    while (1){
        c = p[0];
        if (c==0 || c == ' ' || c == '\t' || c == '\r' || c == '\n') break;
        *pdst++ = *p++;
    }
    *pdst = 0;
    *pPtr = p; //the content
    return p[0] != 0;
}



void main(int argc, const char * argv[]){

    const char * map_filepath;
    const char * section;
    const char ** keywords;
    const char * p;

    int value_size;
    int value_size_sum = 0;
    int i;
    int found;
    long pos;

    char * pdst;
    FILE *flog;

    map_filepath = argv[1];
    section = argv[2];
    keywords = &(argv[3]);


    fp = fopen(map_filepath, "rb");
    if (fp == NULL){
        printf("error, file open failed!\n");
        return 0;
    }
   if( system("mkdir -p ._map_temp") < 0){
        printf("error, can not mkdir .map_temp!");
        return;
   }
    sprintf(txt,"map_%s.csv", section);
    flog = fopen(txt, "wb");
    if (flog == NULL){
        printf("error, log file open failed!");
        return 0;
    }

    txt_keywords[0] = 0;
    for(i = 3; i< argc; i++){
        if(txt_keywords[0] != 0)
            strcat(txt_keywords, ",");
        strcat(txt_keywords, argv[i]);
    }

    fprintf(flog, "Map file:%s\n", map_filepath);
    fprintf(flog, "Section:%s contain keywords: %s\n", section, txt_keywords);
    fprintf(flog, "\n");
    fprintf(flog, "%-40s,%-40s,%-10s,%-10s,%s\n", "txt_section", "txt_addr", "txt_size", "value_size", "txt_file");
#define SKIP_SPACE() if(!skip_space(&p)) continue;



    while (!feof(fp)){
        fgets(txt, sizeof(txt), fp);
        p = txt;

        //section
        SKIP_SPACE();
        if (!rx_string(&p, txt_section)) continue;
        if(strncmp(txt_section, section, strlen(section)) != 0) continue;

        //the address
        SKIP_SPACE();
        if (!rx_string(&p, txt_addr)) continue;

        //the size
        SKIP_SPACE();
        if (!rx_string(&p, txt_size)) continue;
        value_size = strtol(txt_size, NULL, 16);

        //the file
        SKIP_SPACE();
        if (!rx_string(&p, txt_file)) continue;
        int discard_char = (strlen(txt_file))/2-1;
        txt_file[discard_char] = '*';
        txt_file[discard_char+1] = '*';
        txt_file[discard_char+2] = '*';

        do{
            found = 0;

            if(argc > 3){
                for(i = 3; i< argc; i++){
                    if (strstr(txt_file, argv[i])){
                        fprintf(flog, "%-40s,%-40s,%-10s,%-10d,%s\n", txt_section, txt_addr, txt_size, value_size, txt_file+discard_char);
                        value_size_sum += value_size;
                        found = 1;
                        break;
                    }
                }
            }
            else
            {
                fprintf(flog, "%-40s,%-40s,%-10s,%-10d,%s\n", txt_section, txt_addr, txt_size, value_size, txt_file+discard_char);
                value_size_sum += value_size;
                found = 1;
            }
            //if no match, we may need try next line
            pos = ftell(fp);
            fgets(txt, sizeof(txt), fp);
            if(found || strncmp(txt,"        ", 8) != 0) {
                fseek(fp, pos, SEEK_SET);
                break;
            }

            p = txt;
            SKIP_SPACE();
            if (!rx_string(&p, txt_addr)) continue;

            SKIP_SPACE();
            if (!rx_string(&p, txt_file)) continue;
        }while(1);
    }
    fclose(fp);
    fclose(flog);
    system("mv map_* ._map_temp");

    printf("total bytes: %8d keyword %s\t section:%s\n", value_size_sum, txt_keywords, section);

    return 1;
}
