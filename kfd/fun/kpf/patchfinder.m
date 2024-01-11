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
#import "libdimentio.h"
#import "krw.h"

bool did_patchfinder = false;
uint64_t off_cdevsw = 0;
uint64_t off_gPhysBase = 0;
uint64_t off_gPhysSize = 0;
uint64_t off_gVirtBase = 0;
uint64_t off_perfmon_dev_open = 0;
uint64_t off_perfmon_devices = 0;
uint64_t off_ptov_table = 0;
uint64_t off_vn_kqfilter = 0;
uint64_t off_proc_object_size = 0;

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
    if(did_patchfinder)
        return 0;
    
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
    
    off_cdevsw = find_cdevsw();
    printf("cdevsw: 0x%llx\n", off_cdevsw);
    off_gPhysBase = find_gPhysBase();
    printf("gPhysBase: 0x%llx\n", off_gPhysBase);
    off_gPhysSize = find_gPhysSize();
    printf("gPhysSize: 0x%llx\n", off_gPhysSize);
    off_gVirtBase = find_gVirtBase();
    printf("gVirtBase: 0x%llx\n", off_gVirtBase);
    off_perfmon_dev_open = find_perfmon_dev_open();
    printf("perfmon_dev_open: 0x%llx\n", off_perfmon_dev_open);
    off_perfmon_devices = find_perfmon_devices();
    printf("perfmon_devices: 0x%llx\n", off_perfmon_devices);
    off_ptov_table = find_ptov_table();
    printf("ptov_table: 0x%llx\n", off_ptov_table);
    off_vn_kqfilter = find_vn_kqfilter();
    printf("vn_kqfilter: 0x%llx\n", off_vn_kqfilter);
    off_proc_object_size = find_proc_object_size();
    printf("proc_object_size: 0x%llx\n", off_proc_object_size);
    
    term_kernel();
    
    did_patchfinder = true;
    
    return 0;
}

int do_dynamic_patchfinder(void) {
//    if(did_patchfinder)
//        return 0;
    
    set_kbase(0xFFFFFFF007004000 + get_kslide());
    pfinder_t pfinder;
    if(pfinder_init(&pfinder) == KERN_SUCCESS) {
        printf("pfinder_init: success\n");
        uint64_t kernproc = pfinder_kernproc(pfinder);
        printf("kernproc: 0x%llx\n", kernproc);
        
        uint64_t cdevsw = pfinder_cdevsw(pfinder);
        printf("cdevsw: 0x%llx\n", (cdevsw != 0) ? cdevsw - get_kslide() : 0);
        uint64_t gPhysBase = pfinder_gPhysBase(pfinder);
        printf("gPhysBase: 0x%llx\n", (gPhysBase != 0) ? gPhysBase - get_kslide() : 0);
        uint64_t gPhysSize = pfinder_gPhysSize(pfinder);
        printf("gPhysSize: 0x%llx\n", (gPhysSize != 0) ? gPhysSize - get_kslide() : 0);
        uint64_t gVirtBase = pfinder_gVirtBase(pfinder);
        printf("gVirtBase: 0x%llx\n", (gVirtBase != 0) ? gVirtBase - get_kslide() : 0);
        
        uint64_t perfmon_dev_open_2 = pfinder_perfmon_dev_open_2(pfinder);
        printf("perfmon_dev_open_2: 0x%llx\n", (perfmon_dev_open_2 != 0) ? perfmon_dev_open_2 - get_kslide() : 0);
        uint64_t perfmon_dev_open = pfinder_perfmon_dev_open(pfinder);
        printf("perfmon_dev_open: 0x%llx\n", (perfmon_dev_open != 0) ? perfmon_dev_open - get_kslide() : 0);
        
        uint64_t perfmon_devices = pfinder_perfmon_devices(pfinder);
        printf("perfmon_devices: 0x%llx\n", (perfmon_devices != 0) ? perfmon_devices - get_kslide() : 0);
        
        uint64_t ptov_table = pfinder_ptov_table(pfinder);
        printf("ptov_table: 0x%llx\n", (ptov_table != 0) ? ptov_table - get_kslide() : 0);
        
        uint64_t vn_kqfilter = pfinder_vn_kqfilter(pfinder);
        printf("vn_kqfilter: 0x%llx\n", (vn_kqfilter != 0) ? vn_kqfilter - get_kslide() : 0);
        
        uint64_t vn_kqfilter_2 = pfinder_vn_kqfilter_2(pfinder);
        printf("vn_kqfilter_2: 0x%llx\n", (vn_kqfilter_2 != 0) ? vn_kqfilter_2 - get_kslide() : 0);
        
        uint64_t proc_object_size = pfinder_proc_object_size(pfinder);
        printf("proc_object_size: 0x%llx\n", proc_object_size);
        
    }
    pfinder_term(&pfinder);
    
//    did_patchfinder = true;
    
    return 0;
}
