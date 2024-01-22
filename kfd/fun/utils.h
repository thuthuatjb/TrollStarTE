//
//  utils.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/07/30.
//

#include <stdio.h>
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

uint64_t createFolderAndRedirectR(NSString *path, NSString *mntPath);
int VarMobileWriteTest(void);
int VarMobileRemoveTest(void);
int VarMobileWriteFolderTest(void);
int VarMobileRemoveFolderTest(void);
void HexDump(uint64_t addr, size_t size);
bool sandbox_escape_can_i_access_file(char* path, int mode);
