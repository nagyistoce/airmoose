

#import "ASCore.h"
#import "Growl/Growl.h"

#define GROWL_OPEN_NET @"Open Network"
#define GROWL_CLOSED_NET @"Closed Network"

@implementation ASCore
static id ascre = nil;

+(ASCore *)sharedCore {
if (ascre != nil) return ascre;
ascre = [[ASCore alloc] init];
return ascre;
}

-(ASCore *)init {
self = [super init];
[self contextLoad];
[self loadVendors];
curConnStore = [[NSMutableDictionary alloc] init];
stumEntries = [[NSMutableArray alloc] init];
stumEntriesLog = [[NSMutableArray alloc] init];
updInterval = nil;
canCurConn = NO;
canStumble = NO;
shouldNotify = YES;
return self;
}

-(void)checkForWirelessSupport {
int res;
if (!WirelessIsAvailable()) {
res = NSRunInformationalAlertPanel(@"Error Initializing Card", @"It Appears That You Don't Currently Have An Airport Card Installed. Continue Anyway?\n\n(Chances Are, If you Choose To Continue AirMoose Will Crash.)", @"Quit", @"Continue", nil);
if (res == 1) {
[[NSApplication sharedApplication] terminate:self];
}
}
}

-(void)powerOn {
WirelessSetPower(wiContext, 1);
}

-(void)powerOff {
WirelessSetPower(wiContext, 0);
}

-(void)joinNetworkWithSSID:(NSString *)ssid {
[self contextLoad];
int err = WirelessJoin(wiContext, (CFStringRef)ssid);
if ( err != 0) {
NSString *errMsg = [NSString stringWithFormat:@"Error Joining Network '%@'.", ssid];
NSRunInformationalAlertPanel(@"Error.", errMsg , @"OK", nil, nil);
}
[self contextKill];
}

-(void)joinNetworkWithSSID:(NSString *)ssid usingPass:(NSString *)pass {
[self contextLoad];
int err = WirelessJoinWEP(wiContext, (CFStringRef)ssid, (CFStringRef)pass);

if ( err != 0) {
NSString *errMsg = [NSString stringWithFormat:@"Error Joining WEP Network '%@'.", ssid];
NSRunInformationalAlertPanel(@"Error.", errMsg , @"OK", nil, nil);
}
[self contextKill];
}

-(void)dropNetwork {
[self contextLoad];
NSString *blah =[NSString stringWithFormat:@"%s", @""];
WirelessJoin(wiContext,(CFStringRef) blah);
[self contextKill];
}

-(void)setUpdateFrequency:(NSNumber *)freq {
if (freq != nil) {
if (updInterval != nil) updInterval = nil;
updInterval = [[NSNumber alloc] initWithFloat:[freq floatValue]];
}
}

-(void)start {
[self contextLoad];
[self startTimer];
}

-(void)stop {
[self contextKill];
[self killTimer];
}

-(void)toggle {
BOOL a = [self isScanning];
if (a == YES) {
[self stop];
} else {
[self start];
}
}

-(BOOL)isScanning {
return isScanning;
}

-(void)contextLoad {
if (contextConn == NO) {
WirelessAttach(&wiContext, 0);
contextConn = YES;
}
}

-(void)contextKill {
if (contextConn == YES) {
WirelessDetach(wiContext);
contextConn = NO;
}
}

-(void)notify {
if ([self shouldNotify] == YES) {
[[NSNotificationCenter defaultCenter] postNotificationName:@"ASCoreUpdateNotify" object:nil];
}
}

-(void)update {
if (canCurConn == YES) {
[self refreshCurrConn];
}

if (canStumble == YES) {
[self refreshStumEntries];
}

[self notify];
}

-(void)updateTimer:(NSTimer *)timer {
if (([self canStumble] == YES) || ([self canCurConn] == YES)) {
[self update];
} else {
[self killTimer];
}
}

-(void)startTimer {
if (isScanning == NO) {
if (updInterval != nil) {
float ival = [updInterval floatValue];
coreTimer = [NSTimer scheduledTimerWithTimeInterval:ival target:self selector:@selector(updateTimer:) userInfo:Nil repeats:TRUE];
} else {
coreTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTimer:) userInfo:Nil repeats:TRUE];
}
isScanning = YES;
[self notify];
}
}

-(void)killTimer {
if (isScanning == YES) {
[coreTimer invalidate];
coreTimer = nil;
isScanning = NO;
[self notify];
}
}

-(void)refreshCurrConn {

[self contextLoad];

WIErr err = noErr;
WirelessInfo i;

err = WirelessGetInfo(wiContext, &i);

if (curConnStore != nil) curConnStore = nil;
curConnStore = [[NSMutableDictionary alloc] init];


if (err) {
NSLog(@"Can't get current connection info for some reason.");
} else {
id ssid = [NSString stringWithCString: (char *)i.name];
id idnt = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", i.macAddress[0],
																	   i.macAddress[1],
																	   i.macAddress[2],
																	   i.macAddress[3],
																	   i.macAddress[4],
																	   i.macAddress[5]];
																	   
id type;

if (i.client_mode == 1) {
type = [NSString stringWithString:@"Managed"];
} else if (i.client_mode == 4) {
type = [NSString stringWithString:@"Ad-Hoc"];
} else {
type = [NSString stringWithString:@"Unknown"];
}

id sign = [NSString stringWithFormat:@"%d", i.signal];
id link = [NSString stringWithFormat:@"%d", i.link_qual];
id comm = [NSString stringWithFormat:@"%d", i.comms_qual];
id nois = [NSString stringWithFormat:@"%d", i.noise];

if ((ssid != nil) && (idnt != nil) && (type != nil) && (sign != nil) && (link != nil) && (comm != nil) && (nois != nil)) {


[curConnStore setObject:ssid forKey:@"ssid"];
[curConnStore setObject:idnt forKey:@"idnt"];
[curConnStore setObject:type forKey:@"type"];
[curConnStore setObject:sign forKey:@"sign"];
[curConnStore setObject:link forKey:@"link"];
[curConnStore setObject:comm forKey:@"comm"];
[curConnStore setObject:nois forKey:@"nois"];

}

}
}

-(void)refreshStumEntries {

[self contextLoad];

CFArrayRef mang = NULL, adhc = NULL;
int mangstep, adhcstep;
WirelessNetworkInfo *manginfo;
WirelessNetworkInfo *adhcinfo;
WIErr res;

res = WirelessScanSplit(wiContext, &mang, &adhc, 0);

[stumEntries removeAllObjects];


if (mang != NULL) {
int mangcnt = CFArrayGetCount(mang);
for (mangstep = 0; mangstep < mangcnt; mangstep++) {
manginfo = (WirelessNetworkInfo *)CFDataGetBytePtr(CFArrayGetValueAtIndex(mang, mangstep));
[self addStumEntry:[self makeStumEntry:manginfo withType:@"Managed"]];
}
}

if (adhc != NULL) {
int adhccnt = CFArrayGetCount(adhc);
for (adhcstep = 0; adhcstep < adhccnt; adhcstep++) {
adhcinfo = (WirelessNetworkInfo *)CFDataGetBytePtr(CFArrayGetValueAtIndex(adhc, adhcstep));
[self addStumEntry:[self makeStumEntry:manginfo withType:@"Ad-Hoc"]];
}
}

}

-(void)clearStumEntries {
[stumEntries removeAllObjects];
[self notify];
}

-(void)clearStumEntriesLog {
[stumEntriesLog removeAllObjects];
[self notify];
}


-(BOOL)curConnAvail {
return YES;
}

-(NSString *)curConnAP {
id ref = [self curConnStore];
if (ref != nil) {
id obj = [ref objectForKey:@"ssid"];
if (obj != nil) return obj;
}
return nil;
}

-(NSString *)curConnMAC {
id ref = [self curConnStore];
if (ref != nil) {
id obj = [ref objectForKey:@"idnt"];
if (obj != nil) return obj;
}
return nil;
}

-(NSString *)curConnType {
id ref = [self curConnStore];
if (ref != nil) {
id obj = [ref objectForKey:@"type"];
if (obj != nil) return obj;
}
return nil;
}

-(NSString *)curConnSignal {
id ref = [self curConnStore];
if (ref != nil) {
id obj = [ref objectForKey:@"sign"];
if (obj != nil) return obj;
}
return nil;
}

-(NSString *)curConnLink {
id ref = [self curConnStore];
if (ref != nil) {
id obj = [ref objectForKey:@"link"];
if (obj != nil) return obj;
}
return nil;
}

-(NSString *)curConnComm {
id ref = [self curConnStore];
if (ref != nil) {
id obj = [ref objectForKey:@"comm"];
if (obj != nil) return obj;
}
return nil;
}

-(NSString *)curConnNoise {
id ref = [self curConnStore];
if (ref != nil) {
id obj = [ref objectForKey:@"nois"];
if (obj != nil) return obj;
}
return nil;
}

-(id)stumEntries {
return stumEntries;
}

-(id)stumEntriesLog {
return stumEntriesLog;
}

-(id)curConnStore {
return curConnStore;
}

-(id)makeStumEntry:(WirelessNetworkInfo *)info withType:(NSString *)type {
if ((info != nil) && (type != nil)) {

id date = [NSDate date];
id ssid = [NSString stringWithCString:(char *)&(info->name)];
id sign = [NSNumber numberWithShort:info->signal];
id maxs = [NSNumber numberWithShort:info->signal];
id nois = [NSNumber numberWithShort:info->noise];
id chan = [NSNumber numberWithShort:info->channel];
id idnt = [NSString stringWithFormat:@"%.2X:%.2X:%.2X:%.2X:%.2X:%.2X",  info->macAddress[0],
																		info->macAddress[1],
																		info->macAddress[2],
																		info->macAddress[3],
																		info->macAddress[4],
																		info->macAddress[5]];
																		
id vend = [NSString stringWithString:[self vendorForMAC:idnt]];

if ((ssid != nil) && (date != nil) && (sign != nil) && (maxs != nil) && (nois != nil) && (chan != nil) && (idnt != nil) && (vend != nil)) {
NSMutableDictionary *ret = [NSMutableDictionary dictionary];

[ret setObject:ssid forKey:@"ssid"];
[ret setObject:date forKey:@"date"];
[ret setObject:sign forKey:@"sign"];
[ret setObject:maxs forKey:@"maxs"];
[ret setObject:nois forKey:@"nois"];
[ret setObject:chan forKey:@"chan"];
[ret setObject:idnt forKey:@"idnt"];
[ret setObject:type forKey:@"ntyp"];
[ret setObject:vend forKey:@"vend"];

if (info->flags & kWINetworkEncryptedFlag) {

	[ret setObject:@"Yes" forKey:@"wep"];
	//[ret setObject:FOO forKey:@"wep"];
} else {
	[ret setObject:@"No" forKey:@"wep"];
	//[ret setObject:FOO forKey:@"wep"];
}


if (ret != nil) {
return ret;
}
}
}
return nil;
}

-(void)addStumEntry:(id)entry {
if (entry != nil) {
[stumEntries addObject:entry];



id ref = [self stumEntriesLog];
int ref_cnt = [(NSMutableArray *)ref count];
int i;

for (i = 0; i < ref_cnt; i++) {

id obj = [ref objectAtIndex:i];

if ([[obj objectForKey:@"idnt"] isEqualTo:[entry objectForKey:@"idnt"]]) {
[obj setObject:[NSDate date] forKey:@"date"];


id orign = [obj objectForKey:@"maxs"];
id newn = [entry objectForKey:@"maxs"];

if ([newn intValue] > [orign intValue]) {
[obj setObject:newn forKey:@"maxs"];
}
return;
}


}

if ([[entry objectForKey:@"wep"] isEqualToString:@"No"]) {

[GrowlApplicationBridge
notifyWithTitle:@"Open Network Discovered"
	description:[entry objectForKey:@"ssid"]
notificationName: GROWL_OPEN_NET
		iconData:nil
		priority:0
		isSticky:NO
	clickContext:nil];

[self playNoWEPSound];
if ((![[entry objectForKey:@"ssid"] isEqualToString:[self curConnAP]]) || ([self curConnAP] == nil))  {
if ([self canAutoConnect] == YES) {
[self joinNetworkWithSSID:[entry objectForKey:@"ssid"]];
}
}
} else {


[GrowlApplicationBridge
notifyWithTitle:@"Encrypted Network Discovered"
	description:[entry objectForKey:@"ssid"]
notificationName: GROWL_CLOSED_NET
		iconData:nil
		priority:0
		isSticky:NO
	clickContext:nil];


[self playWEPSound];
}


[ref insertObject:entry atIndex: 0];
}
}

-(void)canStumble:(BOOL)yn {
canStumble = yn;
if ((canStumble == YES) || (canCurConn == YES)) {
[self startTimer];
} else {
[self killTimer];
}
}

-(void)canCurConn:(BOOL)yn {
canCurConn = yn;
if ((canStumble == YES) || (canCurConn == YES)) {
[self startTimer];
} else {
[self killTimer];
}
}

-(BOOL)canStumble {
return canStumble;
}

-(BOOL)canCurConn {
return canCurConn;
}

-(void)canAutoConnect:(BOOL)yn {
canAutoConnect = yn;
}

-(BOOL)canAutoConnect {
return canAutoConnect;
}

-(void)canPlaySound:(BOOL)yn {
canPlaySound = yn;
}

-(BOOL)canPlaySound {
return canPlaySound;
}

-(void)playWEPSound {
if ([self canPlaySound] == YES) {
[[NSSound soundNamed:@"Submarine"] play];
}
}

-(void)playNoWEPSound {
if ([self canPlaySound] == YES) {
[[NSSound soundNamed:@"Glass"] play];
}
}

-(void)shouldNotify:(BOOL)yn {
shouldNotify = yn;
}

-(BOOL)shouldNotify {
return shouldNotify;
}

-(void)loadVendors {
NSString *path = [[NSBundle mainBundle] bundlePath];
path = [path stringByAppendingString:@"/Contents/Resources/Vendor.plist"];
venDict = [NSDictionary dictionaryWithContentsOfFile:path];
if (venDict != nil) {
[venDict retain];
} else {
NSRunInformationalAlertPanel(@"Error Initializing Vendors", @"Error Opening Vendor File.", @"OK", nil, nil);
}
}

-(NSString *)vendorForMAC:(NSString *)mac {
NSString *res = [venDict objectForKey:[self parseMAC:mac]];
if (res != nil) return res;
return @"Unknown";
}

-(NSString *)parseMAC:(NSString *)mac {
NSArray *addrItem = [mac componentsSeparatedByString:@":"];
NSMutableString *ret = [NSMutableString string];
[ret appendString:[addrItem objectAtIndex:0]];
[ret appendString:[addrItem objectAtIndex:1]];
[ret appendString:[addrItem objectAtIndex:2]];
if (ret != nil) {
return [NSString stringWithString:ret];
}
return nil;
}

@end
