

#import <Foundation/Foundation.h>
#import "Apple80211.h"


@interface ASCore : NSObject {
    NSTimer *coreTimer;
    NSDictionary *venDict;
    NSMutableDictionary *curConnStore;
    NSMutableArray *stumEntries;
    NSMutableArray *stumEntriesLog;
    WirelessContextPtr wiContext;
    NSNumber *updInterval;
    BOOL contextConn;
    BOOL isScanning;
    BOOL canStumble;
    BOOL canCurConn;
    BOOL canPlaySound;
    BOOL canAutoConnect;
    BOOL shouldNotify;
}

+(ASCore *)sharedCore;
-(ASCore *)init;

-(void)checkForWirelessSupport;
-(void)powerOn;
-(void)powerOff;
-(void)joinNetworkWithSSID:(NSString *)ssid;
-(void)joinNetworkWithSSID:(NSString *)ssid usingPass:(NSString *)pass;
-(void)dropNetwork;

-(void)setUpdateFrequency:(NSNumber *)freq;
-(void)start;
-(void)stop;
-(void)toggle;
-(BOOL)isScanning;

-(void)contextLoad;
-(void)contextKill;
-(void)notify;

-(void)update;
-(void)updateTimer:(NSTimer *)timer;
-(void)startTimer;
-(void)killTimer;

-(void)refreshCurrConn;
-(void)refreshStumEntries;

-(void)clearStumEntries;
-(void)clearStumEntriesLog;

-(BOOL)curConnAvail;
-(NSString *)curConnAP;
-(NSString *)curConnMAC;
-(NSString *)curConnType;
-(NSString *)curConnSignal;
-(NSString *)curConnLink;
-(NSString *)curConnComm;
-(NSString *)curConnNoise;

-(id)stumEntries;
-(id)stumEntriesLog;
-(id)curConnStore;

-(id)makeStumEntry:(WirelessNetworkInfo *)info withType:(NSString *)type;
-(void)addStumEntry:(id)entry;

-(void)canStumble:(BOOL)yn;
-(void)canCurConn:(BOOL)yn;
-(BOOL)canStumble;
-(BOOL)canCurConn;

-(void)canAutoConnect:(BOOL)yn;
-(BOOL)canAutoConnect;

-(void)canPlaySound:(BOOL)yn;
-(BOOL)canPlaySound;
-(void)playWEPSound;
-(void)playNoWEPSound;

-(void)shouldNotify:(BOOL)yn;
-(BOOL)shouldNotify;

-(void)loadVendors;
-(NSString *)vendorForMAC:(NSString *)mac;
-(NSString *)parseMAC:(NSString *)mac;

@end
