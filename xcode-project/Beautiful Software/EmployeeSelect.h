//
//  EmployeeSelect.h
//  Beautiful Software
//
//  Created by Jesse Black on 2/1/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Beautiful_Software_AppDelegate;
@class StaffController;
@interface EmployeeSelect : NSView {
	IBOutlet StaffController * staffController;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	IBOutlet NSWindow * employeeSelectWindow;
	NSManagedObjectContext * moc;
	NSError * error;
	NSMutableArray * buttons;
	NSMutableArray * employees;
	id requestedFrom;
	SEL selector;
	NSMutableString * keyedIn;
	IBOutlet NSDatePicker * mainDatePicker;
	
	
}
@property (retain) NSMutableString * keyedIn;
@property (retain) NSMutableArray * employees;
@property (retain) NSMutableArray * buttons;
@property (retain) id  requestedFrom;

-(void)loadEmployeeSelectForTimeCard;
-(void)loadEmployeeSelect;
-(void)selectEmployeeFor:(id)newRequestedFrom selector:(SEL)newSelector windowTitle:(NSString *)newTitle;
@end
