

#import "ToolbarController.h"
#import "MainController.h"

static NSString *AirMooseToolbarIdentifier = @"AirMooseToolbarIdentifier";
static NSString *AirMooseToggleScan = @"AirMooseToggleScan";
static NSString *AirMooseJoinNetwork = @"AirMooseJoinNetwork";
static NSString *AirMooseDropNetwork = @"AirMooseDropNetwork";
static NSString *AirMooseOpenLog = @"AirMooseOpenLog";
static NSString *AirMooseSaveLog = @"AirMooseSaveLog";
static NSString *AirMooseShowLog = @"AirMooseShowLog";
static NSString *AirMooseClearLog = @"AirMooseClearLog";
static NSString *AirMoosePrefs = @"AirMoosePrefs";
static NSString *AirMooseStatus = @"AirMooseStatus";


@implementation ToolbarController

-(void)awakeFromNib {
[self load];
}

-(void)load {
toolbar = [[NSToolbar alloc] initWithIdentifier:AirMooseToolbarIdentifier];
[toolbar setAllowsUserCustomization:YES];
[toolbar setSizeMode:NSToolbarSizeModeDefault];
[toolbar setAutosavesConfiguration:NO];
[toolbar setDelegate:self];
[window setToolbar:toolbar];
}

-(NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted {

NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdent];
[toolbarItem autorelease];

    if ([itemIdent isEqual:AirMooseToggleScan]) { 

        [toolbarItem setLabel: @"Scan"];
        [toolbarItem setPaletteLabel: @"Scan"];
        [toolbarItem setImage:[NSImage imageNamed: @"Toggle"]];
        [toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(toggleScanSelected:)];
	
	
	
	} else if ([itemIdent isEqual:AirMooseJoinNetwork]) {

		[toolbarItem setLabel: @"Join"];
		[toolbarItem setPaletteLabel: @"Join"];
		[toolbarItem setImage:[NSImage imageNamed: @"Join"]];
		[toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(joinNetworkSelected:)];



	} else if ([itemIdent isEqual:AirMooseDropNetwork]) {

		[toolbarItem setLabel: @"Drop"];
		[toolbarItem setPaletteLabel: @"Drop"];
		[toolbarItem setImage:[NSImage imageNamed: @"Drop"]];
		[toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(dropNetworkSelected:)];



	} else if ([itemIdent isEqual:AirMooseOpenLog]) {

		[toolbarItem setLabel: @"Open"];
		[toolbarItem setPaletteLabel: @"Open"];
		[toolbarItem setImage:[NSImage imageNamed: @"Open"]];
		[toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(openLogSelected:)];


	} else if ([itemIdent isEqual:AirMooseSaveLog]) {

		[toolbarItem setLabel: @"Save"];
		[toolbarItem setPaletteLabel: @"Save"];
		[toolbarItem setImage:[NSImage imageNamed: @"Save"]];
		[toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(saveLogSelected:)];



	} else if ([itemIdent isEqual:AirMooseShowLog]) {

		[toolbarItem setLabel: @"Show Log"];
		[toolbarItem setPaletteLabel: @"Show Log"];
		[toolbarItem setImage:[NSImage imageNamed: @"Show"]];
		[toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(showLogSelected:)];



	} else if ([itemIdent isEqual:AirMooseClearLog]) {

		[toolbarItem setLabel: @"Clear Log"];
		[toolbarItem setPaletteLabel: @"Clear Log"];
		[toolbarItem setImage:[NSImage imageNamed: @"Clean"]];
		[toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(clearLogSelected:)];



	} else if ([itemIdent isEqual:AirMoosePrefs]) {

		[toolbarItem setLabel: @"Prefs"];
		[toolbarItem setPaletteLabel: @"Prefs"];
		[toolbarItem setImage:[NSImage imageNamed: @"Pref"]];
		[toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(prefsSelected:)];



	} else if ([itemIdent isEqual:AirMooseStatus]) {

		[toolbarItem setLabel: @"AP Stat"];
		[toolbarItem setPaletteLabel: @"AP Stat"];
		[toolbarItem setImage:[NSImage imageNamed: @"Stat"]];
		[toolbarItem setTarget:mainControl];
		[toolbarItem setAction:@selector(curConnStatSelected:)];

} else {
return nil;
}

return toolbarItem;



}


-(NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {

return [NSArray arrayWithObjects: NSToolbarFlexibleSpaceItemIdentifier,
								  AirMooseToggleScan,
								  NSToolbarSeparatorItemIdentifier,
								  AirMooseJoinNetwork,
								  AirMooseDropNetwork,
								  NSToolbarSeparatorItemIdentifier,
								  AirMooseOpenLog,
								  AirMooseSaveLog,
								  AirMooseShowLog,
								  AirMooseClearLog,
								  NSToolbarSeparatorItemIdentifier,
								  AirMoosePrefs,
								  AirMooseStatus,
								  NSToolbarFlexibleSpaceItemIdentifier, nil];
}

-(NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {

return [NSArray arrayWithObjects: NSToolbarFlexibleSpaceItemIdentifier,
								  AirMooseToggleScan,
								  NSToolbarSeparatorItemIdentifier,
								  AirMooseJoinNetwork,
								  AirMooseDropNetwork,
								  NSToolbarSeparatorItemIdentifier,
								  AirMooseOpenLog,
								  AirMooseSaveLog,
								  NSToolbarSeparatorItemIdentifier,
								  AirMooseShowLog,
								  AirMooseClearLog,
								  NSToolbarSeparatorItemIdentifier,
								  AirMoosePrefs,
								  AirMooseStatus, 
								  NSToolbarFlexibleSpaceItemIdentifier, nil];
}

@end
