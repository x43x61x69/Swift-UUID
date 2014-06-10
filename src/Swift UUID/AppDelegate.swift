//
//  AppDelegate.swift
//  Swift UUID
//
//  Copyright (c) 2014 Cai, Zhi-Wei. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Xcode 6 beta does not implement #pragma yet. :(
    // #pragma mark - UI
                            
    @IBOutlet var window: NSWindow
    @IBOutlet var result: NSTextField
    @IBOutlet var popUp:  NSPopUpButton

    // #pragma mark - Basic
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        println("Hello World!");
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(theApplication: NSApplication?) -> Bool {
        return true
    }
    
    // #pragma mark - IBActions
    
    @IBAction func generateUUID(sender: AnyObject) {
        
        var uuid = ""
        if uuidGen(popUp.selectedItem.tag, uuid: &uuid) == true {
            result.stringValue = uuid
        }
    }
    
    func uuidGen(type: Int, inout uuid: String) -> Bool {
        // Random UUID.
        func getUUID(inout uuid: String) -> Bool {
            
            var uuidRef:        CFUUIDRef?
            var uuidStringRef:  CFStringRef?
            
            uuidRef         = CFUUIDCreate(kCFAllocatorDefault)
            uuidStringRef   = CFUUIDCreateString(kCFAllocatorDefault, uuidRef)
            
            if uuidRef {
                uuidRef = nil
            }
            
            if uuidStringRef {
                uuid = CFBridgingRelease(uuidStringRef!) as String
                return true
            }
            
            return false
        }
        
        // Hardare UUID shows in the system profiler.
        func getHwUUID(inout uuid: String) -> Bool {
            
            var uuidRef:        CFUUIDRef?
            var uuidStringRef:  CFStringRef?
            var uuidBytes:      CUnsignedChar[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            
            var ts = timespec(tv_sec: 0,tv_nsec: 0)
            
            gethostuuid(&uuidBytes, &ts)
            
            uuidRef = CFUUIDCreateWithBytes(
                kCFAllocatorDefault,
                uuidBytes[0],
                uuidBytes[1],
                uuidBytes[2],
                uuidBytes[3],
                uuidBytes[4],
                uuidBytes[5],
                uuidBytes[6],
                uuidBytes[7],
                uuidBytes[8],
                uuidBytes[9],
                uuidBytes[10],
                uuidBytes[11],
                uuidBytes[12],
                uuidBytes[13],
                uuidBytes[14],
                uuidBytes[15]
            )
            
            if uuidBytes != nil {
                uuidBytes = []
            }
            
            uuidStringRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef)
            
            if uuidRef {
                uuidRef = nil
            }
            
            if uuidStringRef {
                uuid = CFBridgingRelease(uuidStringRef!) as String
                return true
            }
            
            return false
        }
        
        // Hardware serial number shows in "About this Mac" window.
        func getSystemSerialNumber(inout uuid: String) -> Bool {
            
            var ioPlatformExpertDevice:             io_service_t?
            var serialNumber:                       CFTypeRef?
            let ioPlatformExpertDeviceKey:          CString?        = "IOPlatformExpertDevice".UTF8String
            
            ioPlatformExpertDevice = IOServiceGetMatchingService(
                kIOMasterPortDefault,
                IOServiceMatching(ioPlatformExpertDeviceKey!).takeUnretainedValue()
            )
            
            if ioPlatformExpertDevice {
                serialNumber = IORegistryEntryCreateCFProperty(
                    ioPlatformExpertDevice!,
                    CFStringCreateWithCString(kCFAllocatorDefault, kIOPlatformSerialNumberKey, kCFStringEncodingASCII),
                    kCFAllocatorDefault,
                    0
                )
                
                ioPlatformExpertDevice = nil
                
                if serialNumber {
                    uuid = CFBridgingRelease(serialNumber!) as String
                    return true
                }
            }
            
            return false
        }
        
        var success = false
        
        switch type {
        case 1:
            success = getHwUUID(&uuid)
        case 2:
            success = getSystemSerialNumber(&uuid)
        default:
            success = getUUID(&uuid)
        }
        
        return success
        
    }
    
}

