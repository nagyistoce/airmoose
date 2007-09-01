

#import <Foundation/Foundation.h>


@interface PrefController : NSObject {
    IBOutlet NSWindow *prefWin;
    IBOutlet NSWindow *mainWin;
    IBOutlet NSButton *soundBtn;
    IBOutlet NSButton *joinBtn;
    IBOutlet NSButton *saveBtn;
    IBOutlet NSButton *cancelBtn;
    IBOutlet NSSlider *intervalSld;
    IBOutlet NSTextField *intervalFld;
    IBOutlet NSTextField *labelFld;
    IBOutlet NSTextField *secondFld;
    
    BOOL useSounds;
    BOOL useAutoJoin;
    float updInterval;
}

-(BOOL)useSounds;
-(BOOL)useAutoJoin;
-(float)updInterval;

-(void)load;
-(void)defaults;
-(void)save;
-(void)loadUI;
-(void)updateCore;

-(IBAction)showClicked:(id)sender;
-(IBAction)saveClicked:(id)sender;
-(IBAction)cancelClicked:(id)sender;
-(IBAction)intervalChanged:(id)sender;


@end
