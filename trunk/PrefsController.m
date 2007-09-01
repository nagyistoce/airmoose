//
//  PrefsController.m
//  AirMoose
//
//  Created by Geoffrey Garside on 31/08/2007.
//  Copyright 2007 AirMoose. All rights reserved.
//

#import "PrefsController.h"

#define TOOLBAR_GENERAL @"TOOLBAR_GENERAL"
#define TOOLBAR_SOUNDS  @"TOOLBAR_SOUNDS"
#define TOOLBAR_UPDATER @"TOOLBAR_UPDATER"

#define SPARKLE_DAILY @"Daily"
#define SPARKLE_DAILY_VALUE 86400
#define SPARKLE_WEEKLY @"Weekly"
#define SPARKLE_WEEKLY_VALUE 604800
#define SPARKLE_NEVER @"Never"

static PrefsController * _sharedPrefsController = nil;

@interface PrefsController (Private)

- (void) setPrefView: (id) sender;

@end

@implementation PrefsController

+ (PrefsController *) sharedPrefsController
{
    if (_sharedPrefsController == nil)
        _sharedPrefsController = [[PrefsController alloc] initWithWindowNibName: @"PrefsWindow"];
    return _sharedPrefsController;
}

- (id) initWithWindowNibName:(NSString *) windowNibName
{
    self = [super initWithWindowNibName: windowNibName];
    
    if (self != nil)
    {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        // Set the version
        [currentVersionTextField setStringValue: @"1.1"];
        
        // Get the system sounds
        NSMutableArray *sounds = [NSMutableArray array];
        NSEnumerator *soundsEnumerator;
        
        if (soundsEnumerator = [[NSFileManager defaultManager] enumeratorAtPath: @"/System/Library/Sounds"])
        {
            NSString *sound;
            while ((sound = [soundsEnumerator nextObject]))
            {
                sound = [sound stringByDeletingPathExtension];
                if ([NSSound soundNamed: sound])
                    [sounds addObject: sound];
            }
        }
        
        systemSounds = [[sounds sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)] retain];
    }
    
    return self;
}

- (void) dealloc
{
    [_sparkleIntervalAllowedIdentifiers dealloc];
    [systemSounds dealloc];
    [super dealloc];
}

- (void) awakeFromNib
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier: @"AirmoosePreferencesToolbar"];
    [toolbar setDelegate: self];
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode: NSToolbarSizeModeRegular];
    [[self window] setToolbar: toolbar];
    [[self window] setShowsToolbarButton: NO];
    
    [toolbar setSelectedItemIdentifier: TOOLBAR_GENERAL];
    [self setPrefView: nil];
}

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
      itemForItemIdentifier: (NSString *) identifier
  willBeInsertedIntoToolbar: (BOOL) flag
{
    NSToolbarItem *item;
    item = [[NSToolbarItem alloc] initWithItemIdentifier: identifier];
    
    if ([identifier isEqualToString: TOOLBAR_GENERAL])
    {
        [item setLabel: NSLocalizedString(@"General", @"Preferences: General toolbar item title")];
        [item setImage: [NSImage imageNamed: @"Pref.tif"]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else if ([identifier isEqualToString: TOOLBAR_SOUNDS])
    {
        [item setLabel: NSLocalizedString(@"Sounds", @"Preferences: Sounds toolbar item title")];
        [item setImage: [NSImage imageNamed: @"SoundPref.tif"]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else if ([identifier isEqualToString: TOOLBAR_UPDATER])
    {
        [item setLabel: NSLocalizedString(@"Update", @"Preferences: Update toolbar item title")];
        [item setImage: [NSImage imageNamed: @"UpdatePref.tif"]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else
    {
        [item release];
        return nil;
    }
    
    return item;
}

- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar
{
    return [self toolbarDefaultItemIdentifiers: toolbar];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
    return [self toolbarAllowedItemIdentifiers: toolbar];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects: TOOLBAR_GENERAL, TOOLBAR_SOUNDS, TOOLBAR_UPDATER, nil];
}

// TODO: Check to see if using these in KeyValueCoding might actually be causing a memory leak
- (NSArray *) sparkleIntervalAllowedItemIdentifiers
{
    //	if (_sparkleIntervalAllowedIdentifiers == nil)
    //		_sparkleIntervalAllowedIdentifiers = [NSArray arrayWithObjects: SPARKLE_DAILY, SPARKLE_WEEKLY, SPARKLE_NEVER, nil];
    //	return _sparkleIntervalAllowedIdentifiers;
    return [NSArray arrayWithObjects: SPARKLE_DAILY, SPARKLE_WEEKLY, SPARKLE_NEVER, nil];
}

- (int) sparkleIntervalFromIdentifier: (NSString *) identifier
{
    int interval = 0;
    
    if ([identifier isEqualToString: SPARKLE_DAILY])
        interval = SPARKLE_DAILY_VALUE;
    else if ([identifier isEqualToString: SPARKLE_WEEKLY])
        interval = SPARKLE_WEEKLY_VALUE;
    
    return interval;
}

- (NSString *) sparkleInterval
{
    int interval = [[NSUserDefaults standardUserDefaults] integerForKey: SUScheduledCheckIntervalKey];
    
    if (interval == SPARKLE_DAILY_VALUE)
        return SPARKLE_DAILY;
    else if (interval == SPARKLE_WEEKLY_VALUE)
        return SPARKLE_WEEKLY;
    else
        return SPARKLE_NEVER;
}

- (IBAction) setSparkleInterval: (id) sender
{
    // We can set the user default to 0 and it is the same as being off - we hope
    [sparkleUpdater scheduleCheckWithInterval: [self sparkleIntervalFromIdentifier: sender]];
    [[NSUserDefaults standardUserDefaults] setInteger: [self sparkleIntervalFromIdentifier: sender] 
                                               forKey: SUScheduledCheckIntervalKey];
}

@end

@implementation PrefsController (Private)

- (void) setPrefView: (id) sender
{
    NSView *view = generalView;
    
    if (sender)
    {
        NSString * identifier = [sender itemIdentifier];
        if ([identifier isEqualToString: TOOLBAR_SOUNDS])
            view = soundsView;
        else if ([identifier isEqualToString: TOOLBAR_UPDATER])
            view = updaterView;
        else;
    }
    
    NSWindow * window = [self window];
    if ([window contentView] == view)
        return;
    
    NSRect windowRect = [window frame];
    
    float x_diff = ([view frame].size.width - [[window contentView] frame].size.width) * [window userSpaceScaleFactor];
    windowRect.origin.x -= x_diff;
    windowRect.size.width += x_diff;
    
    float y_diff = ([view frame].size.height - [[window contentView] frame].size.height) * [window userSpaceScaleFactor];
    windowRect.origin.y -= y_diff;
    windowRect.size.height += y_diff;
    
    
    [view setHidden: YES];
    [window setContentView: view];
    [window setFrame: windowRect display: YES animate: YES];
    [view setHidden: NO];
    
    //set title label
    if (sender)
        [window setTitle: [sender label]];
    else
    {
        NSToolbar * toolbar = [window toolbar];
        NSString * itemIdentifier = [toolbar selectedItemIdentifier];
        NSEnumerator * enumerator = [[toolbar items] objectEnumerator];
        NSToolbarItem * item;
        while ((item = [enumerator nextObject]))
        {
            if ([[item itemIdentifier] isEqualToString: itemIdentifier])
            {
                [window setTitle: [item label]];
                break;
            }
        }
    }
}

@end
