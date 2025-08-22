#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "gen_instr.h"


int main() {
    FILE *fp = fopen("hex_riscv.txt", "w");
    if (fp == NULL) {
        perror("Unable to open file!");
        return 1;
    }

    srand(time(NULL));  // Seed random generator
     unsigned int rd_triggerStall = 0;

    // Generate 1024 random RISC-V instructions
    for (int i = 0; i < 1024; i++) {
        int opcode_type = rand() % 6;
        int isLoad = 0;
       
        unsigned int instr = 0;
        unsigned int rd = rand() % 32;
        unsigned int rs1 = rand() % 32;
        unsigned int rs2 = rand() % 32;
        unsigned int funct3, funct7, imm; 

        switch (opcode_type) {
            case 0: //R_Type
                funct3 = (rand() % 8);
                if (funct3 == 0 || funct3 == 5)
                    funct7 = (rand() % 2) ? F7_ADD : F7_SUB;
                else
                    funct7 = 0;
                // Help trigger stall
                if (isLoad == 1)
                    rd = rd_triggerStall;
                
                instr = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) |
                        (funct3 << 12) | (rd << 7) | R_TYPE;
                break;

            case 1: // I-IMM: addi
                funct3 = rand() % 8;
                if (funct3 == 5) {
                    funct7 = (rand() % 2) ? F7_SRL : F7_SRA;
                    imm = ((funct7 << 5) | (rand() % 8)*4) & 0xFFF;  
                } else 
                    imm = (rand() % 1024)*4 & 0xFFF; 

                if (isLoad == 1)
                    rd = rd_triggerStall;  

                instr = (imm << 20) | (rs1 << 15) | (funct3 << 12) |
                        (rd << 7) | I_IMM;
                break;
            // immediate value must be divisible by 4 to make sure it is word aligned
            case 2: // I-LOAD: lw
                funct3 = F3_LW;
                isLoad = 1;
                rd_triggerStall = rd;
                imm = (rand() % 8)*4 & 0xFFF;
                instr = (imm << 20) | (rs1 << 15) | (funct3 << 12) |
                        (rd << 7) | I_LOAD;
                break;

            case 3: // S-TYPE: sw
                funct3 = F3_SW;
                imm = (rand() % 1024)*4 & 0xFFF;
                instr = ((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) |
                        (funct3 << 12) | ((imm & 0x1F) << 7) | S_TYPE;
                break;

            case 4: // B_Type
                funct3 = rand() % 8;
                if (funct3 == 2 || funct3 == 3)
                    funct3 = (rand() % 2) ? F3_BEQ : F3_BNE;

                imm = (rand() % 1024)*4 & 0xFFF;  
                instr = ((imm >> 12) << 31) |
                        (((imm >> 5) & 0x3F) << 25) |
                        (rs2 << 20) | (rs1 << 15) |
                        (funct3 << 12) |
                        ((imm & 0xF) << 8) |
                        (((imm >> 11) & 0x1) << 7) |
                        B_TYPE;
                break;

            case 5: // J-TYPE: jal
                imm = (rand() % (1 << 20)) & 0xFFFFF;
                instr = ((imm >> 19) & 0x1) << 31 |
                        ((imm >> 9) & 0x3FF) << 21 |
                        ((imm >> 8) & 0x1) << 20 |
                        ((imm >> 0) & 0xFF) << 12 |
                        (rd << 7) |
                        J_JAL;
                break;
        }

        fprintf(fp, "rom[%d] = 32'h%08X;\n", i, instr);
    }

    fclose(fp);
    printf("Instructions written to hex_riscv.txt\n");

    return 0;
}
