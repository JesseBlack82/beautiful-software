//
//  DailyReport.h
//  Beautiful Software
//
//  Created by Jesse Black on 2/3/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BookingSchedule;
@class PasswordController;
@class Beautiful_Software_AppDelegate;
@class StaffController;
@interface DailyReport : NSObject {
	IBOutlet StaffController * staffController;
	
	IBOutlet PasswordController * passwordController;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	IBOutlet BookingSchedule * bookingSchedule;
	NSManagedObjectContext * moc;
	NSError * error;
	
	IBOutlet NSWindow * retailSoldDailyWindow;
	IBOutlet NSArrayController * retailSoldDailyController;
	IBOutlet NSWindow * retailSoldWeeklyWindow;
	IBOutlet NSArrayController * retailSoldWeeklyController;
	
	
	IBOutlet NSDatePicker * mainDatePicker;
	IBOutlet NSWindow * dailyInfoWindow;
	IBOutlet NSWindow * weeklyInfoWindow;
	IBOutlet NSWindow * initialCountWindow;
	IBOutlet NSWindow * countRegisterWindow;
	BOOL finalCount;
	IBOutlet NSButton * countRegisterButton;
	BOOL override;
	IBOutlet NSTextField * startOnes;
	IBOutlet NSTextField * startFives;
	IBOutlet NSTextField * startTens;
	IBOutlet NSTextField * startTwenties;
	IBOutlet NSTextField * startFifties;
	IBOutlet NSTextField * startHundreds;
	IBOutlet NSTextField * startChange;
	IBOutlet NSTextField * fullChange;
	IBOutlet NSTextField * fullOnes;
	IBOutlet NSTextField * fullFives;
	IBOutlet NSTextField * fullTens;
	IBOutlet NSTextField * fullTwenties;
	IBOutlet NSTextField * fullFifties;
	IBOutlet NSTextField * fullHundreds;
	IBOutlet NSTextField * checks;
	IBOutlet NSTextField * creditBatchTotal;
	IBOutlet NSTextField * creditBatchTips;
	
	IBOutlet NSTextField * dailyDate;
	IBOutlet NSTextField * weeklyDate;
	IBOutlet NSArrayController * dailyArrayController;
	IBOutlet NSArrayController * weeklyArrayController;
	
	double serviceTotal;
	double serviceTaxCollected;
	double retailTotal;
	double retailTaxCollected;
	double miscPlus;
	double miscMinus;
	double payouts;
	double employeePlusMinus;
	double start;
	double expected;
	double have;
	double cash;
	double creditTotal;
	double creditTips;
	double checkTotal;
	double dailyPlusMinus;
	
	double cashCollected;
	double checkCollected;
	double creditBaseCollected;
	// productivity
	IBOutlet NSWindow * productivityWindow;
	IBOutlet NSTextView * productivityView;
	
	// more than one week reports
	IBOutlet NSProgressIndicator * progressIndicator;
	IBOutlet NSWindow * reportSetUpPage;
	IBOutlet NSArrayController * reportItemsController;
	IBOutlet NSDatePicker * firstWeekPicker;
	IBOutlet NSDatePicker * lastWeekPicker;
	
	// more than one week reports calendar format
	IBOutlet NSProgressIndicator * progressIndicatorCalendarFormat;
	IBOutlet NSWindow * reportSetUpPageCalendarFormat;
	IBOutlet NSArrayController * reportItemsControllerCalendarFormat;
	IBOutlet NSDatePicker * firstWeekPickerCalendarFormat;
	IBOutlet NSDatePicker * lastWeekPickerCalendarFormat;
	
	IBOutlet NSWindow * retentionWindow;
	
	IBOutlet NSDatePicker * firstWeekPickerRetention;
	IBOutlet NSDatePicker * lastWeekPickerRetention;
	IBOutlet NSTextField * retentionRate;
	
	//refunds
	IBOutlet NSWindow * refundsForDayWindow;
	IBOutlet NSWindow * refundsForWeekWindow;
	IBOutlet NSArrayController * refundsForDayController;
	IBOutlet NSArrayController * refundsForWeekController;
	
	NSString * retailRefundedPath;
	NSString * passwordLevelsPath;
	
	
	//search by service
	IBOutlet NSView * servicesView;
	IBOutlet NSWindow * searchByServiceWindow;
	
	IBOutlet NSDatePicker * searchStartDate;
	IBOutlet NSDatePicker * searchEndDate;
	IBOutlet NSButton * searchAllTime;
	IBOutlet NSButton * searchSpecificTime;
	
	
	IBOutlet NSButton * atLeastTheseServices;
	IBOutlet NSButton * exactlyTheseServices;
	
	IBOutlet NSArrayController * transactionByServiceController;
	IBOutlet NSTextView * transactionByServiceDescription;
	IBOutlet NSTextView * appointmentByServiceDescription;
	
	IBOutlet NSTableView * transactionByServiceTable;

	
	
	// monthly report window
	IBOutlet NSDatePicker * monthlyStart;
	IBOutlet NSDatePicker * monthlyEnd;
	IBOutlet NSWindow * monthlyReportsWindow;
	
	NSString * preferencesPath;
}
@property (retain) NSString * preferencesPath;

@property (retain) NSString * passwordLevelsPath;
@property (retain) NSString * retailRefundedPath;
-(IBAction)goToInitialCount:(id)sender;
-(IBAction)goToMiddayCloseout:(id)sender;
-(IBAction)goToCloseRegister:(id)sender;

-(IBAction)registerInitialCount:(id)sender;
-(IBAction)registerFullCount:(id)sender;
-(IBAction)viewDailyPaperwork:(id)sender;
-(IBAction)viewWeeklyReport:(id)sender;

-(IBAction)viewRetailSold:(id)sender;
-(IBAction)viewRetailSoldForWeek:(id)sender;
-(double)employeeBookingForDay:(NSManagedObject *)employee;
-(double)employeeBookingForDay:(NSManagedObject *)employee forDate:(NSDate *)date;
-(NSArray *)fetchEmpPlusMinus:(NSDate *)date;
-(NSArray *)fetchMiscellaneous:(NSDate *)date;
-(NSArray *)fetchPayouts:(NSDate *)date;
-(NSArray *)fetchStylistsForDate:(NSDate *)date;
-(NSArray *)fetchStylists;
-(NSArray *)fetchAssistants;
-(NSArray *)fetchAssistantsForDate:(NSDate *)date;
-(NSArray *)timeCardsInfoForDate:(NSDate *)date;
-(NSArray *)timeCardInfoForEmployee:(NSManagedObject*)employee forWeekWithDate:(NSDate*)date;
-(NSMutableArray *)viewDailyPaperworkForDate:(NSDate *)date;
-(NSMutableArray *)viewWeeklyPaperworkForDate:(NSDate *)date;
-(NSMutableArray *)generatePaperworkStartingDate:(NSDate *)startDate endingDate:(NSDate *)endingDate;
-(NSManagedObject*)fetchFullCount;
-(NSManagedObject *)fetchInitialCount;
-(NSManagedObject *)fetchFullCount:(NSDate *)date;
-(NSManagedObject *)fetchInitialCount:(NSDate *)date;

-(NSArray *)timeCardsInfoBetweenDates:(NSDate *)startDate endDate:(NSDate *)endDate;
-(IBAction)monthlyStartChosen:(id)sender;
-(IBAction)monthlyEndChosen:(id)sender;

-(IBAction)goToMonthlyReportsWindow:(id)sender;
-(IBAction)viewMonthlyReportInAppleworks:(id)sender;
-(IBAction)viewWeeklyPaperworkInAppleworks:(id)sender;
-(IBAction)viewWeeklyRetailInAppleworks:(id)sender;
-(IBAction)goToReportForExtendedTimePeriod:(id)sender;
-(IBAction)generateReportForMultipleWeeks:(id)sender;
-(IBAction)weekChosenForMultipleReports:(id)sender;


-(IBAction)searchForTransactionsByService:(id)sender;

-(IBAction)productivityForTheWeek:(id)sender;
-(void)passwordEnteredForProductivity:(NSManagedObject*)password;


-(IBAction)generateReportForCalendarFormat:(id)sender;
-(IBAction)weekChosenForCalendarFormat:(id)sender;

-(IBAction)goToRetentionWindow:(id)sender;
-(float)generateRetentionRatesForStartingDate:(NSDate *)retentionStart toEndingDate:(NSDate *)retentionEnd;
-(IBAction)generateRetentionRatesAction:(id)sender;
-(IBAction)weekChosenForRetention:(id)sender;

-(IBAction)viewRefundsForDay:(id)sender;
-(IBAction)viewRefundsForWeek:(id)sender;

-(IBAction)performServiceSpecificSearch:(id)sender;
-(IBAction)atLeastTheseServicesSelected:(id)sender;
-(IBAction)exactlyTheseServicesSelected:(id)sender;
-(IBAction)searchAllTimeSelected:(id)sender;
-(IBAction)searchSpecificTimeSelected:(id)sender;
-(void)sendEmailReminderToServiceProviders;
@end
