//
//  PlusMinusController.h
//  Beautiful Software
//
//  Created by Jesse Black on 2/1/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EmployeeSelect;
@class PageView;
@class DailyReport;
@class Beautiful_Software_AppDelegate;
@class StaffController;
@class PasswordController;
@interface PlusMinusController : NSObject {
	IBOutlet PasswordController * passwordController;
	IBOutlet StaffController * staffController;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	NSManagedObjectContext * moc;
	NSError * error;
	NSCalendarDate * lastSelectedDate;
	IBOutlet NSDatePicker * mainDatePicker;
	IBOutlet EmployeeSelect * employeeSelect;
	IBOutlet NSWindow * employeeInfoWindow;
	IBOutlet NSWindow * payoutsWindow;
	IBOutlet NSWindow * miscellaneousWindow;
	NSManagedObject * selectedEmployee;
	IBOutlet NSArrayController * employeePlusController;
	IBOutlet NSArrayController * employeeMinusController;
	IBOutlet NSArrayController * miscPlusController;
	IBOutlet NSArrayController * miscMinusController;
	IBOutlet NSArrayController * payoutsController;
	
	IBOutlet DailyReport * dailyReport;
	IBOutlet PageView * pageView;
	NSManagedObject * lastWhoAreYou;
	IBOutlet NSTableView * employeePlusTable;
	IBOutlet NSTableView * employeeMinusTable;
	IBOutlet NSTableView * miscellaneousPlusTable;
	IBOutlet NSTableView * miscellaneousMinusTable;
	IBOutlet NSTableView * payoutsTable;
	
	NSArrayController * workingController;
	
	//emp info
	IBOutlet NSTextField * empPlusForDay;
	IBOutlet NSTextField * empMinusForDay;
	IBOutlet NSTextField * empPlusMinusForDay;
	IBOutlet NSTextField * empPlusMinusForWeek;
	IBOutlet NSTextField * empPlusMinusIncludingToday;
	IBOutlet NSTextField * employeeBookingField;
	IBOutlet NSTextField * employeeHousField;
	//misc info + payout info
	
	IBOutlet NSTextField * miscPlusForDay;
	IBOutlet NSTextField * miscMinusForDay;
	IBOutlet NSTextField * payoutsForDay;
	
	
	//
	IBOutlet NSWindow * weeklyEmployeeInfo;
	IBOutlet NSArrayController * employeeInfoWeeklyController;
	
	// 
	IBOutlet NSWindow * plusMinusSnapshotWindow;
	IBOutlet NSTableView * snapshotEmployeePlus;
	IBOutlet NSTableView * snapshotEmployeeMinus;
	IBOutlet NSTableView * snapshotMiscellaneousPlus;
	IBOutlet NSTableView * snapshotMiscellaneousMinus;
	IBOutlet NSTableView * snapshotPayouts;
	IBOutlet NSArrayController * snapshotEmployeePlusController;
	IBOutlet NSArrayController * snapshotEmployeeMinusController;
	IBOutlet NSArrayController * snapshotMiscellaneousPlusController;
	IBOutlet NSArrayController * snapshotMiscellaneousMinusController;
	IBOutlet NSArrayController * snapshotPayoutsController;
	IBOutlet NSTextField * snapshotEmployeeField;
	IBOutlet NSTextField * snapshotMiscellaneousPlusField;
	IBOutlet NSTextField * snapshotMiscellaneousMinusField;
	IBOutlet NSTextField * snapshotPayoutsField;
	
	IBOutlet NSView * employeeInfoOverview;
	
}
@property (retain) NSManagedObject * lastWhoAreYou;
@property (retain) NSCalendarDate * lastSelectedDate;
-(void)mainDatePickerChanged:(id)sender;
-(IBAction)goToEmployeeInfo:(id)sender;
-(IBAction)goToPayouts:(id)sender;
-(IBAction)goToMiscellaneous:(id)sender;
-(void)loadPayouts;
-(void)loadEmployeeInfo;
-(void)loadMiscellaneous;
-(void)updatePayoutsInfo;
-(void)updateMiscellaneousInfo;

-(double)getEmployeeInfoForWeek:(NSManagedObject *)employee;
-(double)getEmployeeInfoForWeekUntilToday:(NSManagedObject *)employee;
-(void)updateEmployeeInfo;
-(void)loadEmployeeInfo:(NSManagedObject *)employee;
-(IBAction)addEmployeePlus:(id)sender;
-(IBAction)removeEmployeePlus:(id)sender;
-(IBAction)addEmployeeMinus:(id)sender;
-(IBAction)removeEmployeeMinus:(id)sender;
-(IBAction)addMiscPlus:(id)sender;
-(IBAction)removeMiscPlus:(id)sender;
-(IBAction)addMiscMinus:(id)sender;
-(IBAction)removeMiscMinus:(id)sender;
-(IBAction)addPayout:(id)sender;
-(IBAction)removePayout:(id)sender;

-(IBAction)addEmployeePlus:(id)sender;
//-(IBAction)removeEmployeePlus:(id)sender;
-(IBAction)addEmployeeMinus:(id)sender;
//-(IBAction)removeEmployeeMinus:(id)sender;
-(IBAction)addMiscPlus:(id)sender;
//-(IBAction)removeMiscPlus:(id)sender;
-(IBAction)addMiscMinus:(id)sender;
//-(IBAction)removeMiscMinus:(id)sender;
-(IBAction)addPayout:(id)sender;
//-(IBAction)removePayout:(id)sender;


-(IBAction)viewEmployeePlusMinusForWeek:(id)sender;
-(IBAction)viewPlusMinusForDay:(id)sender;
-(IBAction)editPlusMinusForDay:(id)sender;

@end
