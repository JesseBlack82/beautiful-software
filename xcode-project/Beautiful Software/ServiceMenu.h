//
//  ServiceMenu.h
//  Beautiful Software
//
//  Created by Jesse Black on 1/3/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Beautiful_Software_AppDelegate;
@class BookingSchedule;
@class PasswordController;
	
@interface ServiceMenu : NSObject {
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	IBOutlet NSWindow * serviceMenuWindow;
	NSManagedObjectContext * moc;
	NSError * error;
	BOOL editMode;
	IBOutlet PasswordController * passwordController;
	IBOutlet NSArrayController * serviceController;
	
	NSString * passwordLevelsPath;
}
@property (retain) NSString * passwordLevelsPath;
-(void)test;
-(IBAction)goToServiceMenuAction:(id)sender;
-(IBAction)goToServiceMenuEditMode:(id)sender;
-(void)goToServiceMenu:(NSManagedObject *)password;
-(void)loadServices;
-(IBAction)addNewService:(id)sender;
-(IBAction)removeService:(id)sender;
-(void)adjustServiceListOrder;
@end
