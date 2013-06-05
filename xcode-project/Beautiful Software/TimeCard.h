//
//  TimeCard.h
//  Beautiful Software
//
//  Created by Jesse Black on 4/9/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PasswordController;
@class EmployeeSelect;
@class Beautiful_Software_AppDelegate;
@class StaffController;
@interface TimeCard : NSObject {
	IBOutlet StaffController * staffController;
	IBOutlet PasswordController * passwordController;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	IBOutlet NSWindow * timeCardWindow;;
	IBOutlet EmployeeSelect * employeeSelect;
	IBOutlet NSArrayController * timeCardArrayController;
	IBOutlet NSButton * clockInClockOutButton;
	IBOutlet NSDatePicker * mainDatePicker;
	IBOutlet NSTableView * timeCardTable;
	NSManagedObjectContext * moc;
	NSError * error;
	NSManagedObject * selectedEmployee;
	BOOL edit;
	
	IBOutlet NSWindow * timeCardReview;
	NSString * passwordLevelsPath;
}
@property (retain) NSString * passwordLevelsPath;
-(IBAction)editTimeCardAction:(id)sender;
-(IBAction)goToTimeCardWindow:(id)sender;
-(void)employeeSelected:(NSManagedObject*)employee;

-(IBAction)clockInClockOut:(id)sender;

-(IBAction)reviewTimeCards:(id)sender;
@end
