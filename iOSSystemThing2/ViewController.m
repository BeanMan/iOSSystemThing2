//
//  ViewController.m
//  iOSSystemThing2
//
//  Created by bean on 16/5/10.
//  Copyright © 2016年 com.xile. All rights reserved.
//

#import "ViewController.h"

//wifi所需
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>



//内存所需
#import <sys/sysctl.h>
#import <mach/mach.h>

@interface ViewController ()
{
    UILabel * lb;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray * arr = @[@"UUID",@"设备型号",@"wifi",@"可用内存",@"占用内存"];
    
    for (int i = 0; i<arr.count; i++)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(60*i, 40, 55, 50);
        btn.backgroundColor = [UIColor redColor];
        btn.titleLabel.numberOfLines = 0;
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = i + 1;
    }
    
    lb = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, 200, 80)];
    lb.numberOfLines = 0;
    lb.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:lb];

}

-(void)click:(UIButton*)btn
{
    switch (btn.tag) {
        case 1:
        {
            [self UUID];
        }
            break;
        case 2:
        {
            [self platform];
        }
            break;
        case 3:
        {
            [self wifi];
        }
            break;
        case 4:
        {
            [self Memory];
        }
            break;
        case 5:
        {
            [self Memory2];
        }
            break;
            
        default:
            break;
    }
    
    
}

-(void)UUID
{
    CFUUIDRef puuid=CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil,puuid);
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    lb.text = [NSString stringWithFormat:@"UUID:%@",result];
    
    
    
}

-(void)platform
{
    // Gets a string with the device model
    size_t size;
    int	sysctlbyname(const char *, void *, size_t *, void *, size_t);
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    NSDictionary* d = nil;
    if (d == nil)
    {
        d = @{
              @"iPhone1,1": @"iPhone 2G",
              @"iPhone1,2": @"iPhone 3G",
              @"iPhone2,1": @"iPhone 3GS",
              @"iPhone3,1": @"iPhone 4",
              @"iPhone3,2": @"iPhone 4",
              @"iPhone3,3": @"iPhone 4(CDMA)",
              @"iPhone4,1": @"iPhone 4S",
              @"iPhone5,1": @"iPhone 5",
              @"iPhone5,2": @"iPhone 5(GSM+CDMA)",
              
              @"iPod1,1": @"iPod Touch(1Gen)",
              @"iPod2,1": @"iPod Touch(2Gen)",
              @"iPod3,1": @"iPod Touch(3Gen)",
              @"iPod4,1": @"iPod Touch(4Gen)",
              @"iPod5,1": @"iPod Touch(5Gen)",
              
              @"iPad1,1": @"iPad",
              @"iPad1,2": @"iPad 3G",
              @"iPad2,1": @"iPad 2(WiFi)",
              @"iPad2,2": @"iPad 2",
              @"iPad2,3": @"iPad 2(CDMA)",
              @"iPad2,4": @"iPad 2",
              @"iPad2,5": @"iPad Mini(WiFi)",
              @"iPad2,6": @"iPad Mini",
              @"iPad2,7": @"iPad Mini(GSM+CDMA)",
              @"iPad3,1": @"iPad 3(WiFi)",
              @"iPad3,2": @"iPad 3(GSM+CDMA)",
              @"iPad3,3": @"iPad 3",
              @"iPad3,4": @"iPad 4(WiFi)",
              @"iPad3,5": @"iPad 4",
              @"iPad3,6": @"iPad 4(GSM+CDMA)",
              
              @"i386": @"Simulator",
              @"x86_64": @"Simulator"
              };
    }
    NSString* ret = [d objectForKey: platform];
    
    lb.text = [NSString stringWithFormat:@"设备型号%@",ret];
}

-(void)wifi
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    
                    lb.text = [NSString stringWithFormat:@"wifi:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)]];
                    
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
}


-(void)Memory
{
    lb.text = [NSString stringWithFormat:@"设备可用内存%.2fM",[self availableMemory]];
    
    
}


-(void)Memory2
{
    lb.text = [NSString stringWithFormat:@"应用占用内存%.2fM",[self usedMemory]];
}

//获取当前设备可用内存(单位：MB）
- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

//获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}


@end
