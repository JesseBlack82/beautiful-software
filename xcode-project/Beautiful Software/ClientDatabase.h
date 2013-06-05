//
//  ClientDatabase.h
//  Beautiful Software
//
//  Created by Jesse Black on 1/6/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PageView;
@class BookingSchedule;
@class Beautiful_Software_AppDelegate;
@class PasswordController;
@class StaffController;

@interface ClientDatabase : NSObject {
	IBOutlet StaffController * staffController;
	IBOutlet PasswordController * passwordController;
	IBOutlet BookingSchedule * bookingSchedule;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	IBOutlet PageView * pageView;
	
	NSError * error;
	NSManagedObjectContext * moc;

	IBOutlet NSArrayController * clientMatches;
	IBOutlet NSArrayController * transactionHistory;
	IBOutlet NSWindow * clientHistoryWindow;
	IBOutlet NSTextField * clientEmail;
	IBOutlet NSTextField * clientHistoryName;
	IBOutlet NSTableView * clientMatchTable;
	IBOutlet NSTableView * transactionHistoryTable;
	IBOutlet NSTextView * transactionDescription;
	IBOutlet NSTextView * appointmentDescription;
	
	IBOutlet NSWindow * colorFileWindow;
	IBOutlet NSArrayController * clientMatchesForColorFile;
	IBOutlet NSTextField * colorFileName;
	IBOutlet NSTableView * clientMatchTableForColorFile;
	IBOutlet NSTextView * colorFiles;
	IBOutlet NSArrayController * futureAppointments;
	
	//clean up
	
	IBOutlet NSWindow * cleanUpWindow;
	IBOutlet NSArrayController * cleanUpController;
	IBOutlet NSTextField * correctSpelling;
	IBOutlet NSTextField * narrowByString;
	IBOutlet NSTableView * cleanUpTable;
	
	
	IBOutlet NSWindow * emailListWindow;
	IBOutlet NSTextView * emailsOnly;
	IBOutlet NSTextView * emailsWithNames;
	
	// creditCardWindow
	IBOutlet NSWindow * creditCardWindow;
	IBOutlet NSTextField * clientNameForCreditCard;
	IBOutlet NSTextField * cardNumber;
	IBOutlet NSTextView * cardNotes;
	NSManagedObject * clientForCreditCard;
	
	
	// by stylist
	IBOutlet NSWindow * clienteleByStylistWindow;
	IBOutlet NSPopUpButton * chooseStylistPopUp;
	IBOutlet NSDatePicker * clienteleByStylistStartDate;
	IBOutlet NSDatePicker * clienteleByStylistEndDate;
	IBOutlet NSTextView * clienteleByStylistResults;
	
	//view whole list
	
	//auto clean up
	
	IBOutlet NSWindow * addClientWindow;

	NSMutableArray * pendingReferrals;
	NSMutableArray * scoreTable;
	
	
	// referrals
	IBOutlet NSView * referralCategoriesHolder;
	
	
	// addNewClient
	IBOutlet NSTextField * newClientField;
	IBOutlet NSTextField * referredByField;
	IBOutlet NSTextField * referredByPhoneField;
	IBOutlet NSTextField * newCategoryField;
	IBOutlet NSTextField * nameWarning;
	IBOutlet NSArrayController * referredByMatches;
	IBOutlet NSButton * addCategoryButton;
	IBOutlet NSButton * makeClientButton;

	NSString * categoriesDescriptionPath;
	NSString * referralEntriesPath;
	NSString * referralCreditsPath;
	
	IBOutlet NSTextField * newCreditField;
	IBOutlet NSTextField * newVcrField;
	IBOutlet NSTextField * newHomePhoneField;
	IBOutlet NSTextField * newWorkPhoneField;
	IBOutlet NSTextField * newMobilePhoneField;
	IBOutlet NSTextField * newEmailField;
	
	IBOutlet NSButton * maleButton;
	IBOutlet NSButton * femaleButton;
	
	IBOutlet NSArrayController * referralsController;
	IBOutlet NSWindow * pendingReferralsWindow;
	IBOutlet NSArrayController * pendingReferralsController;
	
	
}
@property (retain) NSString * categoriesDescriptionPath;
@property (retain) NSString * referralEntriesPath;
@property (retain) NSString * referralCreditsPath;

-(IBAction)selectGenderOnNewClient:(id)sender;
-(IBAction)goToCreateNewClientForBooking:(id)sender;
-(IBAction)createNewClientForBooking:(id)sender;

-(void)loadReferralCategories;

-(IBAction)goToAddReferralCategory:(id)sender;
-(IBAction)addReferralCategory:(id)sender;
-(IBAction)goToCreateNewClientEntryAction:(id)sender;
-(void)goToCreateNewClientEntry;
-(IBAction)makeClientEntry:(id)sender;


-(void)goToCreateCreditCardForClient:(NSManagedObject *)client;
-(IBAction)generateEmailList:(id)sender;
-(IBAction)viewColorFile:(id)sender;
-(NSString * )transactionDescription;
-(IBAction)viewClientDatabase:(id)sender;
-(NSMutableArray *)clientsMatchingName:(NSString *)name;
-(NSMutableArray *)clientsMatchingPhone:(NSString *)phone;
-(IBAction)goToCleanUpWindow:(id)sender;
-(IBAction)combineClients:(id)sender;
-(IBAction)narrowClientsByString:(id)sender;
-(IBAction)fixGenderForClients:(id)sender;

-(IBAction)clienteleByStylistStartDateEntered:(id)sender;
-(IBAction)goToClienteleByStylist:(id)sender;
-(IBAction)reportClienteleByStylist:(id)sender;
-(IBAction)viewCompleteDatabase:(id)sender;
-(IBAction)makeEditCreditCardEntry:(id)sender;


-(IBAction)goToLinkClientReferral:(id)sender;
-(IBAction)attemptAutoCleanUp:(id)sender;
-(IBAction)goToPendingReferrals:(id)sender;
@end
