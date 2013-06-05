//
//  PageView.h
//  Beautiful Software
//
//  Created by Jesse Black on 12/18/08.
//  Copyright 2008 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BuildingBlock;
@class BookingSchedule;
@class Beautiful_Software_AppDelegate;
@class ResistantScroller;
@class EmployeeSelect;
@class TransactionController;
@class ClientDatabase;
@interface PageView : NSView {
	IBOutlet ClientDatabase * clientDatabase;
	IBOutlet TransactionController * transactionController;
	IBOutlet EmployeeSelect * employeeSelect;
	
	NSManagedObjectContext * moc;
	NSError * error;
	BuildingBlock * selectedBlock;
	NSMutableArray * stylistBlocks;
	NSMutableArray * stylistHeaders;
	NSCalendarDate * startTime;
	NSCalendarDate * finishTime;
	NSTextField * dateView;
	
	IBOutlet NSView * dateViewContainer;
	IBOutlet NSDatePicker * mainDatePicker;
	IBOutlet ResistantScroller * timeHeaderView;
	IBOutlet ResistantScroller * stylistHeaderView;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	IBOutlet BookingSchedule * bookingSchedule;
	
	int selectedStylistIndex;
	
	
	NSMutableArray * stylistColumns;
	NSMutableString * keyedIn;
	
}

@property (retain) NSMutableArray * stylistColumns;
@property (retain) NSMutableString * keyedIn;
@property (retain) NSCalendarDate * startTime;
@property (retain) NSCalendarDate * finishTime;
@property (retain) BuildingBlock * selectedBlock;
@property (retain) NSMutableArray * stylistBlocks;
@property (retain) NSMutableArray * stylistHeaders;
@property (retain) NSTextField * dateView;;
-(BOOL)moveLeft;
-(BOOL)moveRight;
-(BOOL)moveUp;
-(BOOL)moveDown;
-(void)calendarLeft;
-(void)calendarRight;
-(void)calendarUp;
-(void)calendarDown;
-(void)moveToToday;
-(void)refreshBlocks;
-(void)selectBlock:(BuildingBlock *)hit;
-(NSMutableArray *)fetchStylists;
-(void)prepareHeaders;
-(void)selectParent;
-(void)upgradeStylistDay;
-(NSMutableArray *)selectedStylistDay;
-(void)displayDataForStylistDays:(NSMutableArray *)newStylistDays;
-(void)selectAppointmentForTime:(NSDate *)time withStylist:(NSManagedObject *)stylist;
-(void)removeSelectedAppointment;
-(void)selectCurrentTime;
-(void)refreshBlockForAppointment:(NSManagedObject *)appointment;
-(void)updateAllAppointmentBlocks;
-(BOOL)pageLeft;
-(BOOL)pageUp;
-(BOOL)pageRight;
-(BOOL)pageDown;

@end
