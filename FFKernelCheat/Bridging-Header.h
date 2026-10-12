//
//  Bridging-Header.h
//  FFKernelCheat
//
//  Developer: Dinh Duc Nam
//  Contact: 0395109314 - 0332011756
//

#ifndef Bridging_Header_h
#define Bridging_Header_h

// ═══════════════════════════════════════════════════════════
//  KERNEL EXPLOIT — import từ folder kexploit/
// ═══════════════════════════════════════════════════════════

// Core exploit
#import "kexploit/kexploit_opa334.h"

// Kernel read/write primitives
#import "kexploit/krw.h"

// Kernel utilities (proc_find, task_self, get_task_port_for_pid...)
#import "kexploit/kutils.h"

// Kernel offsets (iOS 17.0 - 26.0)
#import "kexploit/offsets.h"

// PAC strip helper
#import "kexploit/xpaci.h"

// Machine info (CPU family, device type)
#import "kexploit/machine_info.h"

// Vnode manipulation
#import "kexploit/vnode.h"

// Sandbox escape
#import "kexploit/sandbox_escape.h"

// ═══════════════════════════════════════════════════════════
//  EXPLOIT HELPERS — import từ folder exploit/
// ═══════════════════════════════════════════════════════════

// Bad query (sandbox token)
#import "exploit/bad_query.h"

// MCM bridge (container access)
#import "exploit/mcm_bridge.h"

// Wallpaper zip (zip extraction)
#import "exploit/wallpaper_zip.h"

// ═══════════════════════════════════════════════════════════
//  TASK PORT — file rỗng, không import
//  (Hàm get_task_port_for_pid() đã có trong kutils.h)
// ═══════════════════════════════════════════════════════════
// #import "kexploit/include/task_port.h"

#endif /* Bridging_Header_h */
