//
//  PrefsController.h
//  AirMoose
//
//  Created by Geoffrey Garside on 31/08/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>

@interface PrefsController : NSWindowController {
	NSUserDefaults					*_userDefaults;
	NSArray							*systemSounds;
	
	// Our views
	IBOutlet NSView					*generalView,
									*soundsView,
									*updaterView;
	
	// General View Outlets
	IBOutlet NSButton				*autoJoinNetworksCheckBox;
	IBOutlet NSSlider				*updateIntervalSlider;
	IBOutlet NSTextField			*updateIntervalValue;
	
	// Sounds View Outlets
	IBOutlet NSButton				*useSoundsCheckBox;
	IBOutlet NSPopUpButton			*unprotectedPopupButton,
									*protectedWepPopupButton,
									*protectedWpaPopupButton;
	
	// Updater View Outlets
	IBOutlet NSPopUpButton			*checkForUpdatesPopupButton;
	IBOutlet NSTextField			*currentVersionTextField;
	IBOutlet NSButton				*checkNowButton;
	IBOutlet NSProgressIndicator	*checkNowProgressIndicator;
	IBOutlet SUUpdater				*sparkleUpdater;
}

+ (PrefsController *) sharedPrefsController;

- (NSArray *) sparkleIntervalAllowedItemIdentifiers;
- (NSString *) sparkleInterval;
- (IBAction) setSparkleInterval: (id) sender;

@end
