//
//  patchfinder.m
//  kfd
//
//  Created by Seo Hyun-gyu on 1/8/24.
//

#import <Foundation/Foundation.h>
#import <sys/sysctl.h>
#import <sys/mount.h>
#import "patchfinder.h"
#import "img4helper/img4.h"
#import "patchfinder64.h"
#import "libgrabkernel/libgrabkernel.h"

const char* getBootManifestHash(void) {
    struct statfs fs;
    if (statfs("/usr/standalone/firmware", &fs) == 0) {
        NSString *mountedPath = [NSString stringWithUTF8String:fs.f_mntfromname];
        NSArray<NSString *> *components = [mountedPath componentsSeparatedByString:@"/"];
        if ([components count] > 3) {
            NSString *substring = components[3];
            return substring.UTF8String;
        }
    }
    return NULL;
}

const char* get_kernel_path(void) {
    NSString *kernelPath = [NSString stringWithFormat:@"/private/preboot/%s%@", getBootManifestHash(), @"/System/Library/Caches/com.apple.kernelcaches/kernelcache"];
    
    return kernelPath.UTF8String;
}

void removeIfExist(const char* path) {
    if(access(path, F_OK) == 0) remove(path);
}

int do_patchfinder(void) {
    //Stage 1. Download kernelcache
    const char *kernelPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/kernelcache"].UTF8String;
    removeIfExist(kernelPath);
    grabkernel(kernelPath, 0);
    
    //Stage 2. Extract kernel raw from kernelcache
    if(access(kernelPath, R_OK) == -1) return -1;
    NSString *kernelcacheRawPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/kernelcache_raw"];
    removeIfExist(kernelcacheRawPath.UTF8String);
    img4_extract_im4p(kernelPath, kernelcacheRawPath.UTF8String, NULL, 0);
    
    //Stage 3. Run Patchfinder
    if(init_kernel(NULL, 0, kernelcacheRawPath.UTF8String) != 0) {
        return -1;
    }
    
    uint64_t cdevsw = find_cdevsw();
    printf("cdevsw: 0x%llx\n", cdevsw);
    uint64_t gPhysBase = find_gPhysBase();
    printf("gPhysBase: 0x%llx\n", gPhysBase);
    uint64_t gPhysSize = find_gPhysSize();
    printf("gPhysSize: 0x%llx\n", gPhysSize);
    uint64_t gVirtBase = find_gVirtBase();
    printf("gVirtBase: 0x%llx\n", gVirtBase);
    uint64_t perfmon_dev_open = find_perfmon_dev_open();
    printf("perfmon_dev_open: 0x%llx\n", perfmon_dev_open);
    uint64_t perfmon_devices = find_perfmon_devices();
    printf("perfmon_devices: 0x%llx\n", perfmon_devices);
    uint64_t ptov_table = find_ptov_table();
    printf("ptov_table: 0x%llx\n", ptov_table);
    uint64_t vn_kqfilter = find_vn_kqfilter();
    printf("vn_kqfilter: 0x%llx\n", vn_kqfilter);
    
    term_kernel();
    
    return 0;
}
