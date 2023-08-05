//
//  cs_blobs.c
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/05.
//

#include "cs_blobs.h"
#include "krw.h"
#include "offsets.h"
#include "vnode.h"
#include "utils.h"

uint64_t fun_cs_blobs(char *execPath) {
    
    uint64_t ubc_info = kread64(getVnodeAtPath(execPath) + off_vnode_vu_ubcinfo) | 0xffffff8000000000;
    uint32_t cs_add_gen = kread32(ubc_info + 0x2c);
//    cs_add_gen += 1;
    printf("cs_add_gen, 0x2c: 0x%x\n", cs_add_gen);
    kwrite32(ubc_info + 0x2c, cs_add_gen);
    
    uint64_t csblobs = kread64(ubc_info + 0x50);
    printf("csblobs: 0x%llx\n", csblobs);
    uint32_t csb_flags = kread32(csblobs + 0x20);
    printf("csb_flags: 0x%x\n", csb_flags);
    uint64_t csb_teamid = kread64(csblobs + 0x88);
    printf("csb_teamid: 0x%llx\n", csb_teamid);
    
    printf("csb_cdhash\n");
    HexDump(csblobs + 0x58, 20);    //csblobs + 0x58 = csb_cdhash
    
    return 0;
}
