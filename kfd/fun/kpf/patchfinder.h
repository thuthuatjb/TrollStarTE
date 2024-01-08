//
//  patchfinder.h
//  kfd
//
//  Created by Seo Hyun-gyu on 1/8/24.
//

#ifndef patchfinder_h
#define patchfinder_h

#import <Foundation/Foundation.h>

typedef UInt32        IOOptionBits;
#define IO_OBJECT_NULL ((io_object_t)0)
typedef mach_port_t io_object_t;
typedef io_object_t io_registry_entry_t;
extern const mach_port_t kIOMainPortDefault;
typedef char io_string_t[512];

kern_return_t
IOObjectRelease(io_object_t object );

io_registry_entry_t
IORegistryEntryFromPath(mach_port_t, const io_string_t);

CFTypeRef
IORegistryEntryCreateCFProperty(io_registry_entry_t entry, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);


int do_patchfinder(void);

#endif /* patchfinder_h */
