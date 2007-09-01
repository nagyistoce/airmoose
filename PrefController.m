

#import "PrefController.h"
#import "ASCore.h"


@implementation PrefController

-(void)awakeFromNib {
    [self load];
}

-(BOOL)useSounds {
    return useSounds;
}

-(BOOL)useAutoJoin {
    return useAutoJoin;
}

-(float)updInterval {
    return updInterval;
}

-(void)load {
    [self defaults];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([[d stringForKey:@"SoundEnabled"] isEqualTo:@"True"]) useSounds = YES;
    if ([[d stringForKey:@"SoundEnabled"] isEqualTo:@"False"]) useSounds = NO;
    if ([[d stringForKey:@"AutoJoin"] isEqualTo:@"True"]) useAutoJoin = YES;
    if ([[d stringForKey:@"AutoJoin"] isEqualTo:@"False"]) useAutoJoin = NO;
    updInterval = [d floatForKey:@"UpdateInterval"];
    [self loadUI];
    [self updateCore];
}

-(void)defaults {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([d stringForKey:@"SoundEnabled"] == nil) [d setObject:@"True" forKey:@"SoundEnabled"];
    if ([d stringForKey:@"AutoJoin"] == nil) [d setObject:@"False" forKey:@"AutoJoin"];
    if ([d floatForKey:@"UpdateInterval"] == nil) [d setFloat:3.0 forKey:@"UpdateInterval"];
    if ([d floatForKey:@"UpdateInterval"] < 0.1) [d setFloat:0.1 forKey:@"UpdateInterval"];
}

-(void)save {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([soundBtn state] == NSOnState) [d setObject:@"True" forKey:@"SoundEnabled"];
    if ([soundBtn state] == NSOffState) [d setObject:@"False" forKey:@"SoundEnabled"];
    if ([joinBtn state] == NSOnState) [d setObject:@"True" forKey:@"AutoJoin"];
    if ([joinBtn state] == NSOffState) [d setObject:@"False" forKey:@"AutoJoin"];
    [d setFloat:[intervalSld floatValue] forKey:@"UpdateInterval"];
    [self updateCore];
}

-(void)loadUI {
    
    [intervalSld setMinValue:0.1];
    [intervalSld setMaxValue:10.0];
    [intervalSld setFloatValue:[self updInterval]];
    [self intervalChanged:intervalSld];
    
    BOOL s = [self useSounds];
    BOOL a = [self useAutoJoin];
    
    if (s == YES) [soundBtn setState:NSOnState];
    if (s == NO) [soundBtn setState:NSOffState];
    if (a == YES) [joinBtn setState:NSOnState];
    if (a == NO) [joinBtn setState:NSOffState];
    
    
}

-(void)updateCore {
    id ref = [ASCore sharedCore];
    [ref canAutoConnect:[self useAutoJoin]];
    [ref canPlaySound:[self useSounds]];
    [ref setUpdateFrequency:[NSNumber numberWithFloat:[self updInterval]]];
}

-(IBAction)showClicked:(id)sender {
    [NSApp beginSheet:prefWin modalForWindow:mainWin modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

-(IBAction)saveClicked:(id)sender {
    [self save];
    [prefWin orderOut:nil];
    [NSApp endSheet:prefWin];
}

-(IBAction)cancelClicked:(id)sender {
    [prefWin orderOut:nil];
    [NSApp endSheet:prefWin];
}

-(IBAction)intervalChanged:(id)sender {
    NSNumber *blah = [NSNumber numberWithFloat:[sender floatValue]];
    updInterval = [sender floatValue];
    [intervalFld setStringValue:[blah stringValue]];
}


@end
