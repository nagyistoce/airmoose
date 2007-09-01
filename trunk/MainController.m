

#import "MainController.h"
#import "ToolbarController.h"
#import "PrefController.h"
#import "ASCore.h"
#import "ASOutput.h"

#define GROWL_OPEN_NET @"Open Network"
#define GROWL_CLOSED_NET @"Closed Network"



@implementation MainController

+ (void) initialize
{
	NSString *defaultsPath = [[NSBundle mainBundle] pathForResource: @"Defaults" ofType: @"plist"];
	[[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile: defaultsPath]];
}

//- (id) init
//{
//	self = [super init];
//	
//	if (self != nil)
//	{
//		prefsController = [[PrefsController alloc] initWithWindowNibName: @"PrefsWindow"];
//	}
//	
//	return self;
//}
    
-(void)awakeFromNib {
	[GrowlApplicationBridge setGrowlDelegate:self];
	[self registerNote];
	[[ASCore sharedCore] checkForWirelessSupport];
	[self updateUI];
}

- (NSDictionary *) registrationDictionaryForGrowl {
	//	NSArray *notifications =  [NSArray arrayWithObject: @"Network Discovered"];	
	NSArray *notifications = [NSArray arrayWithObjects: GROWL_OPEN_NET, GROWL_CLOSED_NET, nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		notifications, GROWL_NOTIFICATIONS_ALL,
		notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];		
	return (dict);
}

-(BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
	[[ASOutput sharedOutput] openLogPlistAtPath:filename];
	[self showLogSelected:self];
}



-(IBAction)toggleScanSelected:(id)sender {
	id core = [ASCore sharedCore];
	[core canStumble: ![core canStumble]];
}

-(IBAction)joinNetworkSelected:(id)sender {
	if (selSSID != nil) {
		id ref = [ASCore sharedCore];
		if (selIsWEP == YES) {
			[self showJoinWindow];
		} else {
			[ref joinNetworkWithSSID:selSSID];
			selSSID = nil;
		}
	}
}

-(IBAction)dropNetworkSelected:(id)sender {
	[[ASCore sharedCore] dropNetwork];
}

-(IBAction)openLogSelected:(id)sender {
	[[ASOutput sharedOutput] openLogPlist];
}


-(IBAction)saveLogSelected:(id)sender {
	[[ASOutput sharedOutput] saveStumEntryLogAsPlist];
}

-(IBAction)showLogSelected:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[logWindow setHidesOnDeactivate: NO];
	[logWindow makeKeyAndOrderFront:nil];
}

-(IBAction)clearLogSelected:(id)sender {
	[[ASCore sharedCore] clearStumEntriesLog];
}

-(IBAction)prefsSelected:(id)sender {
	NSWindow * window = [[PrefsController sharedPrefsController] window];
    if (![window isVisible])
        [window center];
    
    [window makeKeyAndOrderFront: nil];
}

-(IBAction)curConnStatSelected:(id)sender {
	[statDrawer toggle:nil];
	id ref = [ASCore sharedCore];
	
	if ([statDrawer state] == NSDrawerClosedState) {
		[ref canCurConn:NO];
	} else if ([statDrawer state] == NSDrawerOpeningState) {
		[ref canCurConn:YES];
	} else if ([statDrawer state] == NSDrawerOpenState) {
		[ref canCurConn:YES];
	} else if ([statDrawer state] == NSDrawerClosingState) {
		[ref canCurConn:NO];
	}
}


-(void)registerNote {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(receivedNote:) name:@"ASCoreUpdateNotify" object:nil];
}

-(void)receivedNote:(NSNotification *)note {
	[self updateUI];
}

-(void)unregisterNote {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateUI {
	id ref = [ASCore sharedCore];
	
	if ([ref isScanning] == YES) {
		[snooch startAnimation: nil];
		// Find out how the fuck to change the toolbar item label.
		if (([ref canStumble] == YES) && ([ref canCurConn] == YES)) {
			[statusFld setStringValue:@"Scanning & Displaying Network Stats..."];
		} else if ([ref canStumble] == YES) {
			[statusFld setStringValue:@"Scanning..."];
		} else if ([ref canCurConn] == YES) {
			[statusFld setStringValue:@"Displaying Network Stats..."];
		}
		
		
	} else {
		[snooch stopAnimation: nil];
		[statusFld setStringValue:@""];
	}
	
	id cap = [ref curConnAP];
	id mac = [ref curConnMAC];
	id typ = [ref curConnType];
	id sig = [ref curConnSignal];
	id lnk = [ref curConnLink];
	id com = [ref curConnComm];
	id nos = [ref curConnNoise];
	
	if ((cap != nil) && (mac != nil) && (typ != nil) && (sig != nil) && (lnk != nil) && (com != nil) && (nos != nil)) {
		
		if (![mac isEqualToString:@"44:44:44:44:44:44"]) { //technically out of range..
			[curConnName setStringValue:cap];
			[curConnMAC setStringValue:mac];
			[curConnSignal setStringValue:sig];
			[curConnComm setStringValue:com];
			[curConnNoise setStringValue:nos];
			[curConnLink setStringValue:lnk];
		} else {
			[self uiNotConnected];
		}
		
	} else {
		[self uiNotConnected];
	}
	
	[entryView reloadData];
	[logView reloadData];
}

-(void)uiNotConnected {
	[curConnName setStringValue:@""];
	[curConnMAC setStringValue:@""];
	[curConnSignal setStringValue:@""];
	[curConnComm setStringValue:@""];
	[curConnNoise setStringValue:@""];
	[curConnLink setStringValue:@""];
}


-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
	
	id ref;
	id obj;
	id ret;
	
	if ([aTableView isEqualTo:entryView]) {
		ref = [[ASCore sharedCore] stumEntries];
		obj = [ref objectAtIndex:rowIndex];
		ret = [obj objectForKey:[aTableColumn identifier]];
		return ret;
	}
	
	if ([aTableView isEqualTo:logView]) {
		ref = [[ASCore sharedCore] stumEntriesLog];
		obj = [ref objectAtIndex:rowIndex];
		ret = [obj objectForKey:[aTableColumn identifier]];
		if ([[aTableColumn identifier] isEqualTo:@"date"]) return [ret descriptionWithCalendarFormat:@"%H:%M:%S %p | %m/%d/%y" timeZone:nil locale:nil];
		return ret;
	}
	return @"Error.";
}

-(int)numberOfRowsInTableView:(NSTableView *)aTableView {
	
	id ref;
	
	if ([aTableView isEqualTo:entryView]) {
		ref = [[ASCore sharedCore] stumEntries];
		return [(NSMutableArray *)ref count];
	}
	
	if ([aTableView isEqualTo:logView]) {
		ref = [[ASCore sharedCore] stumEntriesLog];
		return [(NSMutableArray *)ref count];
	}
	return 0;
}

-(IBAction)rowSelected:(id)sender {
	if ([sender isEqualTo:entryView]) {
		id ref = [[ASCore sharedCore] stumEntries];
		
		if ([entryView selectedRow] > -1) {
			id obj = [ref objectAtIndex:[entryView selectedRow]];
			id ret = [obj objectForKey:@"ssid"];
			if (ret != nil) {
				if (selSSID != nil) selSSID = nil;
				selSSID = [[NSString alloc] initWithString:ret];
				
				id w = [obj objectForKey:@"wep"];
				if ([w isEqualToString:@"Yes"]) {
					selIsWEP = YES;
				} else {
					selIsWEP = NO;
				}
				
			}
		} else {
			if (selSSID != nil) selSSID = nil;
			selIsWEP = NO;
		}
		
		
	}
}


-(void)showJoinWindow {
	[NSApp beginSheet:joinWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

-(void)hideJoinWindow {
	[joinPassFld setStringValue:@""];
	[joinWindow orderOut:nil];
	[NSApp endSheet:joinWindow];
}

-(IBAction)joinCancel:(id)sender {
	[self hideJoinWindow];
}

-(IBAction)joinAction:(id)sender {
	NSString *snd = [joinPassFld stringValue];
	if ([snd length] > 0) {
		[[ASCore sharedCore] joinNetworkWithSSID:selSSID usingPass:snd];
		selSSID = nil;
	}
	[self hideJoinWindow];
}

-(IBAction)gotoN9KDX:(id)sender {
	LSOpenCFURLRef((CFURLRef)[NSURL URLWithString:@"kdx://kdx.nexus9.org:10700"], NULL); 
}

-(IBAction)gotoN9Site22:(id)sender {
	LSOpenCFURLRef((CFURLRef)[NSURL URLWithString:@"http://www.nexus9.org"], NULL); 
}

-(IBAction)gotoSBCUSite:(id)sender {
	LSOpenCFURLRef((CFURLRef)[NSURL URLWithString:@"http://speedyb.co.uk/"], NULL); 
}



@end
