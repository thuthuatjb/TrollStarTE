//
//  vnode.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/07/29.
//

#include <stdio.h>

#define MNT_RDONLY      0x00000001      /* read only filesystem */
#define VISSHADOW       0x008000        /* vnode is a shadow file */

uint64_t getVnodeAtPath(char* filename);
uint64_t findRootVnode(void);
uint64_t getVnodeVar(void);
uint64_t getVnodeVarMobile(void);
uint64_t getVnodeVarTmp(void);
uint64_t findChildVnodeByVnode(uint64_t vnode, char* childname);

/*
Description:
  Hide and reveal file or directory.
*/
uint64_t funVnodeHide(char* filename);

/*
Description:
  Perform chown to file or directory.
*/
uint64_t funVnodeChown(char* filename, uid_t uid, gid_t gid);

/*
Description:
  Perform chmod to file or directory.
*/
uint64_t funVnodeChmod(char* filename, mode_t mode);

/*
Description:
  Redirect directory to another directory.
  Only work when mount points of directories are same.
  Can be escaped out of sandbox.
*/
uint64_t funVnodeRedirectFolder(char* to, char* from);

/*
Description:
  Perform overwrite file data to file.
  Only work when file size is 'lower or same' than original file size.
  Overwriting executable file also works, but executing will not work anymore. just freeze or crash.
*/
uint64_t funVnodeOverwriteFile(char* to, char* from);

uint64_t funVnodeIterateByPath(char* dirname);

uint64_t funVnodeIterateByVnode(uint64_t vnode);

uint64_t funVnodeRedirectFolderFromVnode(char* to, uint64_t from_vnode);
