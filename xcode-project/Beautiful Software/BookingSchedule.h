//
//  BookingSchedule.h
//  Beautiful Software
//
//  Created by Jesse Black on 12/11/08.
//  Copyright 2008 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Beautiful_Software_AppDelegate;
@class PageView;
@class ClientDatabase;
@class EmployeeSelect;

@class PasswordController;
/* HARMONY SPECIFIC */
@class HarmonyDatabase;
/* */
@class StaffController;

@interface BookingSchedule : NSObject {
	IBOutlet StaffController * staffController;
	IBOutlet PasswordController * passwordController;
	NSDate * lastSelectedDate;
	IBOutlet NSWindow * makeAppointmentWindow;
	IBOutlet PageView * pageView;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	
	NSManagedObjectContext * moc;
	NSError * error;
	IBOutlet NSDatePicker * mainDatePicker;
	//outlets to make/edit
	
	IBOutlet NSTextField * creditField;
	IBOutlet NSTextField * clientField;
	IBOutlet NSTextField * vcrField;
	IBOutlet NSTextField * homePhoneField;
	IBOutlet NSTextField * workPhoneField;
	IBOutlet NSTextField * mobilePhoneField;
	IBOutlet NSTextField * emailField;
	IBOutlet NSTextView * specialNoteField;
	IBOutlet NSTextField * stylistField;
	IBOutlet NSTextField * dateField;
	IBOutlet NSTextField * timeField;
	
	IBOutlet NSButton * maleButton;
	IBOutlet NSButton * femaleButton;
	
	IBOutlet NSView * extraTimesView;
	IBOutlet NSView * servicesView;
	
	IBOutlet ClientDatabase * clientDatabase;
	IBOutlet EmployeeSelect * employeeSelect;
	
	IBOutlet NSTextView * appointmentDescription;
	/* HARMONY SPECIFIC */
	IBOutlet HarmonyDatabase * harmonyDatabase;
	/* */

	IBOutlet NSWindow * getStartTimeWindow;
	IBOutlet NSTextField * newLengthField;
	IBOutlet NSWindow * changeApptLengthWindow;
	IBOutlet NSDatePicker * startTimePicker;
	NSDate * startBound;
	BOOL squeezeAboveTest;
	NSManagedObject * affectedAppt;
	
	//viewing stylistday snapshot
	IBOutlet NSWindow * stylistDayWindow;
	IBOutlet NSArrayController * stylistDayArrayController;
	
	//transfer reschedule shortcuts
	int weeksAheadInFetch;
	IBOutlet NSWindow * transferRescheduleWindow;
	BOOL cancelAfterTransfer;
	IBOutlet NSButton * transferRescheduleButton;
	IBOutlet NSTextField * selectedStylistNameForTransfer;
	IBOutlet NSView * availableAppointmentsViewForTransfer;
	IBOutlet NSView * stylistViewForTransfer;
	NSButton * selectedStylistButtonForTransfer;
	NSMutableArray * availableAppointmentsForTransfer;
	NSMutableArray * appointmentsToBook;
	
	// confirmations
	IBOutlet NSWindow * confirmationsWindow;
	IBOutlet NSArrayController * confirmationsController;
	NSString * confirmingSignature;
	IBOutlet NSTextView * appointmentDescriptionForConfirmations;
	IBOutlet NSTableView * confirmationsTable;
	NSString * neverConfirmPath;
	
	// waitlist
	IBOutlet NSWindow * waitlistWindow;
	IBOutlet NSArrayController * waitlistController;
	NSString * waitlistPath;
	IBOutlet NSTextView * waitlistDescription;
	IBOutlet NSTableView * waitlistTable;
	
	
	//cancellations
	NSString * cancellationsPath;
	IBOutlet NSArrayController * cancellationsController;
	IBOutlet NSWindow * cancellationsWindow;
	
	//Stylist Preview
	IBOutlet NSWindow * stylistPreviewWindow;
	IBOutlet NSView * stylistViewForPreview;
	IBOutlet NSTextView * stylistPreviewTextView;
	
	//add color file
	IBOutlet NSWindow  * addColorFileWindow;
	IBOutlet NSDatePicker * colorFileDatePicker;
	IBOutlet NSTextView * colorFile;
	IBOutlet NSTextField * clientNameForColorFile;
	NSManagedObject * clientForAddColorFile;
	
	//view bookedAppointments
	IBOutlet NSWindow * bookedAppointmentsWindow;
	IBOutlet NSArrayController * bookedTodayController;
	
	IBOutlet NSWindow * walkinsWindow;
	IBOutlet NSArrayController * walkinsController;
	
	//addSchedule
	IBOutlet NSWindow * addPageWindow;
	IBOutlet NSObjectController * employeeForAddPage;
	IBOutlet NSDatePicker * startDatePicker;
	IBOutlet NSDatePicker * lastDatePicker;
	IBOutlet NSTextField * addApptLengthField;
	
	NSString * passwordLevelsPath;
	
	
	
	// booking convenience
	BOOL modalRejected;
	IBOutlet NSArrayController * clientsToChooseFrom;
	IBOutlet NSWindow * selectClientWindow;
	IBOutlet NSWindow * createOrFindWindow;
	
	IBOutlet NSTextField * bookWithName;
	IBOutlet NSTextField * bookWithPhone;

	
	
	//
	NSString * preferencesPath;
	
	NSString * lastBookedBy;
}
@property (retain) NSString * lastBookedBy;
@property (retain) NSString * preferencesPath;
@property (retain) NSString * passwordLevelsPath;
@property (retain) NSManagedObject * clientForAddColorFile;
@property (retain) NSString * neverConfirmPath;
@property (retain) NSString * cancellationsPath;
@property (retain) NSString * waitlistPath;
@property (retain) NSString * confirmingSignature;
@property (retain) NSMutableArray * availableAppointmentsForTransfer;
@property (retain) NSMutableArray * appointmentsToBook;
@property (retain) NSDate * lastSelectedDate;
@property (retain) NSDate * startBound;


-(void)bookSelectedAppointmentWithClient:(NSManagedObject *)client;

-(void)awake;

-(IBAction)creditFieldEntered:(id)sender;

-(void)updateAppointmentDescription;
-(void)setBookedBy:(NSManagedObject *)bookedBy;
-(IBAction)clientNameEntered:(id)sender;
-(IBAction)clientPhoneEntered:(id)sender;


-(NSMutableArray *)availableExtraAppointments;
-(void)findAvailableExtraAppointments;
-(void)createServiceMenu;
-(IBAction)selectingGenderOnMakeAppointment:(id)sender;
-(void)initialStart;
-(void)makeEditAppointment;
-(IBAction)makeEditAppointmentAction:(id)sender;
-(void)bookFiller:(NSManagedObject *)filler withClient:(NSManagedObject *)client;
-(void)setLastSelectedDate:(NSDate*)date;
-(NSMutableArray *)blankScheduleForStylist:(NSManagedObject *)stylist date:(NSDate*)date;
-(IBAction)changeDateOnMainPageAction:(id)sender;
-(void)changeDateOnMainPage;
-(NSManagedObject *)defaultBookingSchedule;
-(void)goToMakeEditAppointment;
-(IBAction)goToMakeEditAppointmentAction:(id)sender;
-(IBAction)goToTransferAppointmentAction:(id)sender;
-(IBAction)goToRescheduleAppointmentAction:(id)sender;
-(void)setUpTransferRescheduleWindow;
-(void)stylistSelectedOnTransferRescheduleWindow:(id)sender;
-(IBAction)viewNextDayOnTransfer:(id)sender;
-(IBAction)viewNextWeekOnTranser:(id)sender;
-(void)transferAdvanceData:(NSManagedObject *)employee;
-(void)transferRescheduleData:(NSManagedObject *)employee;
-(void)fetchAvailableAppointmentsForStylist;
-(NSString *)clientDescription;
-(NSString *)appointmentDescriptionForTransfer;
-(IBAction)checkinAppointment:(id)sender;
-(IBAction)transferOrRescheduleAppointment:(id)sender;
-(IBAction)addAppointmentAbove:(id)sender;
-(IBAction)addAppointmentBelow:(id)sender;
-(IBAction)squeezeAppointmentAbove:(id)sender;
-(IBAction)squeezeAppointmentBelow:(id)sender;
-(IBAction)startTimeEntered:(id)sender;
-(IBAction)addScheduleForStylist:(id)sender;
-(IBAction)changeAppointmentLength:(id)sender;
-(IBAction)newLengthEntered:(id)sender;
-(IBAction)removeAppointmentAction:(id)sender;
-(IBAction)cancelAppointmentAction:(id)sender;
-(void)stylistClicked:(NSEvent *)aEvent sender:(id)sender;
-(void)viewStylistDay:(NSString *)stylist;
-(void)upgradeStylistDayForAppointment:(NSMutableDictionary *)appointment;
-(void)updateAppointmentDescriptionOnConfirmations;
-(IBAction)goToConfirmationsWindow:(id)sender;
-(IBAction)markAsConfirmed:(id)sender;
-(IBAction)markThatLeftMessage:(id)sender;

-(IBAction)goToWaitlistWindow:(id)sender;
-(IBAction)addToWaitlist:(id)sender;
-(IBAction)removeFromWaitlist:(id)sender;
-(IBAction)scheduleAppointmentFromWaitlist:(id)sender;
-(void)saveWaitlist;

-(IBAction)viewCancellations:(id)sender;

-(IBAction)goToStylistMonthPreview:(id)sender;

-(NSString*)serviceDescription:(NSMutableSet *)services;

-(IBAction)goToAddColorFile:(id)sender;
-(IBAction)addColorFile:(id)sender;

-(IBAction)neverConfirmForThisClient:(id)sender;

-(IBAction)viewAppointmentsBookedToday:(id)sender;
-(IBAction)viewWalkinsForDay:(id)sender;
-(IBAction)viewWalkinsForWeek:(id)sender;

-(IBAction)addPageForStylist:(id)sender;

-(IBAction)makeAppointmentWithSelectedClient:(id)sender;
-(IBAction)makeAppointmentWithNewClient:(id)sender;
-(IBAction)automaticallyConfirmAppointments:(id)sender;

-(IBAction)createNewClient:(id)sender;
-(IBAction)findExistingClient:(id)sender;
-(void)notifyEmployeeOfScheduleChange;
@end
