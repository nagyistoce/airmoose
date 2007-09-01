

#import "ASOutput.h"
#import "ASCore.h"
#include <stdio.h>


@implementation ASOutput
static id asopt = nil;

+(ASOutput *)sharedOutput {
    if (asopt != nil) return asopt;
    asopt = [[ASOutput alloc] init];
    return asopt;
}

-(ASOutput *)init {
    self = [super init];
    return self;
}

-(void)dealloc {
    [super dealloc];
}

-(NSString *)connStats {
    id ref = [ASCore sharedCore];
    if (ref != nil) {
        
        BOOL ostore = [ref shouldNotify];
        
        [ref shouldNotify:NO];
        [ref refreshCurrConn];
        [ref shouldNotify:ostore];
        
        id ssid = [ref curConnAP];
        id mac = [ref curConnMAC];
        id type = [ref curConnType];
        id signal = [ref curConnSignal];
        id link = [ref curConnLink];
        id comm = [ref curConnComm];
        id nois = [ref curConnNoise];
        
        NSMutableString *ret = [NSMutableString string];
        [ret appendString:@"\n\nCurrent Connection Stats:\n---------------------------\n"];
        
        if (ssid != nil) {
            [ret appendString:[NSString stringWithFormat:@"SSID:\t\t%@\n", ssid]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"SSID:\t\tUnkwnown!\n"]];
        }
        
        if (mac != nil) {
            [ret appendString:[NSString stringWithFormat:@"MAC:\t\t%@\n", mac]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"MAC:\t\tUnkwnown!\n"]];
        }
        
        if (type != nil) {
            [ret appendString:[NSString stringWithFormat:@"Type:\t\t%@\n", type]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"Type:\t\tUnkwnown!\n"]];
        }
        
        if (signal != nil) {
            [ret appendString:[NSString stringWithFormat:@"Signal:\t\t%@\n", signal]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"Signal:\t\tUnkwnown!\n"]];
        }
        
        if (nois != nil) {
            [ret appendString:[NSString stringWithFormat:@"Noise:\t\t%@\n", nois]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"Noise:\t\tUnkwnown!\n"]];
        }
        
        if (link != nil) {
            [ret appendString:[NSString stringWithFormat:@"Link:\t\t%@\n", link]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"Link:\t\tUnkwnown!\n"]];
        }
        
        if (comm != nil) {
            [ret appendString:[NSString stringWithFormat:@"Comm:\t\t%@\n", comm]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"Comm:\t\tUnkwnown!\n"]];
        }
        
        [ret appendString:@"\n\n"];
        return [NSString stringWithString:ret];
        
    }
    return nil;
}

-(NSString *)stumEntriesText {
    id ref = [ASCore sharedCore];
    if (ref != nil) {
        
        BOOL ostore = [ref shouldNotify];
        
        [ref shouldNotify:NO];
        [ref refreshStumEntries];
        [ref shouldNotify:ostore];
        
        id ent = [ref stumEntries];
        int ent_cnt = [(NSMutableArray *)ent count];
        int i;
        
        NSMutableString *ret = [NSMutableString string];
        [ret appendString:@"\n\nSSID\t\tMAC\t\t\tWEP\tChan\tSign\n"];
        [ret appendString:@"------------------------------------------------------------\n"];
        
        for (i = 0; i < ent_cnt; i++) {
            id obj = [ent objectAtIndex:i];
            id obj_ssid = [obj objectForKey:@"ssid"];
            id obj_idnt = [obj objectForKey:@"idnt"];
            id obj_wep  = [obj objectForKey:@"wep"];
            id obj_chan = [obj objectForKey:@"chan"];
            id obj_sign = [obj objectForKey:@"sign"];
            
            NSString *fmt = [NSString stringWithFormat:@"%@\t\t%@\t%@\t%@\t%@\n", obj_ssid,
                obj_idnt,
                obj_wep,
                obj_chan,
                obj_sign];
            [ret appendString:fmt];
        }
        [ret appendString:@"\n\n"];
        return [NSString stringWithString:ret];
    }
    return nil;
}

-(NSString *)stumEntriesLogText {
    return nil;
}

-(NSMutableArray *)stumEntriesPlist {
    id ref = [[ASCore sharedCore] stumEntries];
    if (ref != nil) return ref;
    return nil;
}

-(NSMutableArray *)stumEntriesLogPlist {
    id ref = [[ASCore sharedCore] stumEntriesLog];
    if (ref != nil) return ref;
    return nil;
}


-(void)stdoutConnStats {
    id ref = [self connStats];
    if (ref != nil) {
        printf([ref cString]);
    }
}

-(void)stdoutStumEntries {
    id ref = [self stumEntriesText];
    if (ref != nil) {
        printf([ref cString]);
    }
}

-(void)stdoutStumEntryLog {
    
}

-(void)saveStumEntryLogAsPlist {
    NSSavePanel *savepan;
    int res;
    
    savepan = [NSSavePanel savePanel];
    [savepan setRequiredFileType:@"aml"];
    [savepan setTitle:@"Save AirMoose Log"];   
    
    res = [savepan runModalForDirectory:@"" file:@""];
    
    if (res == NSOKButton) {
        [self saveLogPlistAtPath:[savepan filename]];
    }
}

-(void)saveStumEntryLogAsText {
    NSSavePanel *savepan;
    int res;
    
    savepan = [NSSavePanel savePanel];
    [savepan setRequiredFileType:@"txt"];
    [savepan setTitle:@"Save AirMoose Log"];   
    
    res = [savepan runModalForDirectory:@"" file:@""];
    
    if (res == NSOKButton) {
        [self saveLogTextAtPath:[savepan filename]];
    }
}

-(void)saveLogPlistAtPath:(NSString *)path {
    if (path != nil) {
        id ref = [self stumEntriesLogPlist];
        if (ref != nil) [ref writeToFile:path atomically:YES];
    }
}

-(void)saveLogTextAtPath:(NSString *)path {
    if (path != nil) {
        id ref = [self stumEntriesLogText];
        if (ref != nil) [ref writeToFile:path atomically:YES];
    }
}

-(void)openLogPlist {
    NSOpenPanel *openpan;
    int res;
    openpan = [NSOpenPanel openPanel];
    [openpan setRequiredFileType:@"aml"];
    [openpan setTitle:@"Open AirMoose Log"]; 
    res = [openpan runModalForDirectory:@"" file:@""];
    if (res == NSOKButton) {
        if([[openpan filename] hasSuffix:@".aml"]) [self openLogPlistAtPath:[openpan filename]];
    }
}

-(void)openLogPlistAtPath:(NSString *)path {
    id ref = [self stumEntriesLogPlist];
    id fle = [NSMutableArray arrayWithContentsOfFile:path];
    [ref setArray:fle];
    [[ASCore sharedCore] notify];
}


@end
