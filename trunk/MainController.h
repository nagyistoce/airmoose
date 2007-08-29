

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

@interface MainController : NSObject <GrowlApplicationBridgeDelegate> {
IBOutlet NSTableView *entryView;
IBOutlet NSTableView *logView;

IBOutlet NSProgressIndicator *snooch;

IBOutlet NSTextField *statusFld;
IBOutlet NSTextField *curConnName;
IBOutlet NSTextField *curConnMAC;
IBOutlet NSTextField *curConnSignal;
IBOutlet NSTextField *curConnComm;
IBOutlet NSTextField *curConnNoise;
IBOutlet NSTextField *curConnLink;

IBOutlet NSWindow *mainWindow;
IBOutlet NSWindow *prefWindow;
IBOutlet NSWindow *logWindow;
IBOutlet NSDrawer *statDrawer;

IBOutlet id prefControl;

IBOutlet NSWindow *joinWindow;
IBOutlet NSTextField *joinPassFld;
IBOutlet NSButton *joinConnectBtn;

NSString *selSSID;
BOOL selIsWEP;
}


- (NSDictionary *) registrationDictionaryForGrowl;

-(IBAction)toggleScanSelected:(id)sender;
-(IBAction)joinNetworkSelected:(id)sender;
-(IBAction)dropNetworkSelected:(id)sender;
-(IBAction)openLogSelected:(id)sender;
-(IBAction)saveLogSelected:(id)sender;
-(IBAction)showLogSelected:(id)sender;
-(IBAction)clearLogSelected:(id)sender;
-(IBAction)prefsSelected:(id)sender;
-(IBAction)curConnStatSelected:(id)sender;

-(void)registerNote;
-(void)receivedNote:(NSNotification *)note;
-(void)unregisterNote;

- (void)startAnimation:(id)sender;
- (void)stopAnimation:(id)sender;


-(void)updateUI;
-(void)uiNotConnected;

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
-(int)numberOfRowsInTableView:(NSTableView *)aTableView;
-(IBAction)rowSelected:(id)sender;

-(void)showJoinWindow;
-(void)hideJoinWindow;
-(IBAction)joinCancel:(id)sender;
-(IBAction)joinAction:(id)sender;

-(IBAction)gotoN9Site:(id)sender;
-(IBAction)gotoN9KDX:(id)sender;
-(IBAction)gotoSBCUSite:(id)sender;

@end
