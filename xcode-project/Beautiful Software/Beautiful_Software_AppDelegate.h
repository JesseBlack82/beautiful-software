//
//  Beautiful_Software_AppDelegate.h
//  Beautiful Software
//
//  Created by Jesse Black on 11/11/08.
//  Copyright Harmony 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Beautiful_Software_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
    
	NSError * appDelegateError;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;





@end
