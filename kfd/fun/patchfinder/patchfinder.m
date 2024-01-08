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
    const char* kernelPath = get_kernel_path();
    printf("kernelpath: %s, %d\n", kernelPath, access(kernelPath, F_OK));
    
    return 0;
}
