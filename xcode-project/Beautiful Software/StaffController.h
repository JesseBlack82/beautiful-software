//
//  StaffController.h
//  Beautiful Software
//
//  Created by Jesse Black on 12/11/08.
//  Copyright 2008 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// part of interface
@class Beautiful_Software_AppDelegate;
@class BookingSchedule;
@class PasswordController;
@interface StaffController : NSObject {
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	NSManagedObjectContext * moc;
	NSError * error;
	BOOL hideMainWindow;
	IBOutlet NSWindow * mainWindow;
	IBOutlet NSWindow * staffWindow;
	IBOutlet BookingSchedule * bookingSchedule;
	IBOutlet PasswordController * passwordController;
	IBOutlet NSArrayController * staffArrayController;
	
	IBOutlet NSDatePicker * startTimeSunday;
	IBOutlet NSDatePicker * startTimeMonday;
	IBOutlet NSDatePicker * startTimeTuesday;
	IBOutlet NSDatePicker * startTimeWednesday;
	IBOutlet NSDatePicker * startTimeThursday;
	IBOutlet NSDatePicker * startTimeFriday;
	IBOutlet NSDatePicker * startTimeSaturday;
	IBOutlet NSDatePicker * finishTimeSunday;
	IBOutlet NSDatePicker * finishTimeMonday;
	IBOutlet NSDatePicker * finishTimeTuesday;
	IBOutlet NSDatePicker * finishTimeWednesday;
	IBOutlet NSDatePicker * finishTimeThursday;
	IBOutlet NSDatePicker * finishTimeFriday;
	IBOutlet NSDatePicker * finishTimeSaturday;
	
	IBOutlet NSTextField * appointmentLengthGeneral;
	IBOutlet NSTextField * appointmentLengthSunday;
	IBOutlet NSTextField * appointmentLengthMonday;
	IBOutlet NSTextField * appointmentLengthTuesday;
	IBOutlet NSTextField * appointmentLengthWednesday;
	IBOutlet NSTextField * appointmentLengthThursday;
	IBOutlet NSTextField * appointmentLengthFriday;
	IBOutlet NSTextField * appointmentLengthSaturday;
	IBOutlet NSTextField * note;
	
	IBOutlet NSButton * booksCheckBox;
	IBOutlet NSButton * tracksCheckBox;
	IBOutlet NSButton * worksSunday;
	IBOutlet NSButton * worksMonday;
	IBOutlet NSButton * worksTuesday;
	IBOutlet NSButton * worksWednesday;
	IBOutlet NSButton * worksThursday;
	IBOutlet NSButton * worksFriday;
	IBOutlet NSButton * worksSaturday;
	
	IBOutlet NSButton * maleButton;
	IBOutlet NSButton * femaleButton;
	
	
	IBOutlet NSTextField * name;
	IBOutlet NSTextField * email;
	IBOutlet NSTextField * workPhone;
	IBOutlet NSTextField * homePhone;
	IBOutlet NSTextField * mobilePhone;
	IBOutlet NSTextField * street;
	IBOutlet NSTextField * state;
	IBOutlet NSTextField * city;
	IBOutlet NSTextField * zip;
	
	NSMutableArray * personFields;
	NSString * passwordLevelsPath;
	
	NSMutableArray * allStaff;
}
@property (retain) NSString * passwordLevelsPath;
@property (retain) NSMutableArray * personFields;
@property (retain) NSMutableArray * allStaff;

-(void)awake;
-(IBAction)removeEmployee:(id)sender;
-(IBAction)addEmployee:(id)sender;
-(IBAction)moveUpList:(id)sender;
-(IBAction)moveDownList:(id)sender;


-(void)setTargetsForStaffWindow;
-(void)loadEmployee:(NSManagedObject *)employee;

-(void)editStaffMember;
-(void)personEdited;
-(void)loadSchedule:(NSManagedObject *)bSchedule;
-(void)initializeStaff;
-(void)test;
-(IBAction)saveChanges:(id)sender;
-(IBAction)goToEditStaffControllerAction:(id)sender;
-(void)goToEditStaffController:(NSManagedObject *)password;
-(void)loadEditStaffWindow;
-(void)booksChecked;
-(void)tracksChecked;



-(NSArray *)serviceProviders;
-(NSArray *)clockedEmployees;
-(NSArray *)workingServiceProviders:(NSDate *)notTerminatedSince;
-(NSArray *)workingClockedEmployees:(NSDate *)notTerminatedSince;
-(NSArray *)workingStaff:(NSDate *)notTerminatedSince;
-(NSArray *)allEmployees;
@end
