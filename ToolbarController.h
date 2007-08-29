

#import <Foundation/Foundation.h>


@interface ToolbarController : NSObject {
IBOutlet NSWindow *window;
IBOutlet NSDrawer *statDrawer;
IBOutlet id mainControl;
NSToolbar *toolbar;
}

-(void)load;
-(NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted;
-(NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
-(NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;

@end
