

#import <Foundation/Foundation.h>


@interface ASOutput : NSObject {

}

+(ASOutput *)sharedOutput;
-(ASOutput *)init;

-(NSString *)connStats;
-(NSString *)stumEntriesText;
-(NSString *)stumEntriesLogText;
-(NSMutableArray *)stumEntriesPlist;
-(NSMutableArray *)stumEntriesLogPlist;

-(void)stdoutConnStats;
-(void)stdoutStumEntries;
-(void)stdoutStumEntryLog;

-(void)saveStumEntryLogAsPlist;
-(void)saveStumEntryLogAsText;

-(void)saveLogPlistAtPath:(NSString *)path;
-(void)saveLogTextAtPath:(NSString *)path;

-(void)openLogPlist;
-(void)openLogPlistAtPath:(NSString *)path;


@end
