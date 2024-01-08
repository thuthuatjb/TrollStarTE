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

int do_patchfinder(void) {
    
    //Stage 1. Extract kernel raw from kernelcache
    const char* kernelPath = get_kernel_path();
    printf("kernelpath: %s, %d\n", kernelPath, access(kernelPath, R_OK));
    if(access(kernelPath, R_OK) == -1) {
        return -1;
    }
    NSString *kernelcacheRawPath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"/Documents/kernel.raw"];
    if(access(kernelcacheRawPath.UTF8String, F_OK) == 0) remove(kernelcacheRawPath.UTF8String);
    img4_extract_im4p(kernelPath, kernelcacheRawPath.UTF8String, NULL, 0);
    
    return 0;
}
