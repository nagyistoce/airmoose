

#import <Cocoa/Cocoa.h>
#import "ASOutput.h"
#include <unistd.h>


int main(int argc, char *argv[])
{
    if (argc > 2)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        int arc;
        
        while((arc = getopt(argc, argv, "cs")) != -1)
        {
            switch(arc)
            {
                case 'c':
                    [[ASOutput sharedOutput] stdoutConnStats];
                    break;
                    
                case 's':
                    [[ASOutput sharedOutput] stdoutStumEntries];
                    break;
            }
        }
        
        [pool release];
    }
    else
    {
        return NSApplicationMain(argc, argv);
    }
    
    return 0;
}
