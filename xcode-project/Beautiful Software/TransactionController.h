//
//  TransactionController.h
//  Beautiful Software
//
//  Created by Jesse Black on 1/13/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Beautiful_Software_AppDelegate;
@class PageView;
@class IndividualTransaction;
@class PasswordController;
@class EmployeeSelect;
@class RetailController;
@class BookingSchedule;
@class ClientDatabase;
@interface TransactionController : NSObject {
	IBOutlet ClientDatabase * clientDatabase;
	NSString * transactionDetailsPath;
	
	IBOutlet BookingSchedule * bookingSchedule;
	
	IBOutlet RetailController * retailController;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	IBOutlet EmployeeSelect * employeeSelect;
	NSManagedObjectContext * moc;
	NSError * error;
	IBOutlet PageView * pageView;
	int selectedTransactionIndex;
	NSWindow * selectedWindow;
	NSMutableArray * transactionController;
	NSMutableArray * appointmentsInOpenTransactions;
	IBOutlet PasswordController * passwordController;
	
	//for retail purposes
	IBOutlet NSTextField * retailTotal;
	IBOutlet NSTextField * retailTax;
	IBOutlet NSTextField * amountDue;
	IBOutlet NSWindow * sellRetailWindow;

	IBOutlet NSTextField * barcodeFieldForSellRetailOnly;
	
	IBOutlet NSTextField * retailSearchBar;
	
	IBOutlet NSArrayController * retailCartController;
	IBOutlet NSArrayController * matchesController;
	
	IBOutlet NSDatePicker * mainDatePicker;
	
	IBOutlet NSWindow * transactionsWindow;
	IBOutlet NSArrayController * allTransactionsController;

	IBOutlet NSTableView * transactionsTable;
	IBOutlet NSTextField * transactionsDate;
	IBOutlet NSTextView * transactionDescription;
	BOOL canEditTransactions;
	
	IBOutlet NSButton * removeTransactionButton;
	
	
	// Transaction---- Dual
	
	IBOutlet NSTextField * clientNameFieldDual;
	IBOutlet NSWindow * transactionWindowDual;
	IBOutlet NSView * serviceViewDual;
	IBOutlet NSTextField * serviceTotalDual;
	IBOutlet NSTextField * serviceTaxDual;
	IBOutlet NSTextField * retailTotalDual;
	IBOutlet NSTextField * retailTaxDual;
	IBOutlet NSTextField * amountDueDual;
	
	
	IBOutlet NSTextField * barcodeSearchBarDual;
	
	
	IBOutlet NSTextField * retailSearchBarDual;
	
	IBOutlet NSArrayController * retailCartControllerDual;
	IBOutlet NSArrayController * matchesControllerDual;
	
	IBOutlet NSTableView * productTableDual;
	
	NSMutableArray * retailSaleDual;
	NSMutableArray * serviceListDual;
	NSMutableArray * priceFieldsDual;
	NSMutableArray * transactionDetailsTopLevelDual;
	NSManagedObject * appointmentDual;

	
	//
	IBOutlet NSWindow * refundProductPurchaseWindow;
	IBOutlet NSTextField * barcodeSearchBarRefund;
	IBOutlet NSTextField * retailSearchBarRefund;
	IBOutlet NSArrayController * refundController;
	IBOutlet NSArrayController * refundMatches;
	IBOutlet NSTextField * refundSubtotal;
	IBOutlet NSTextField * refundTax;
	IBOutlet NSTextField * refundTotal;
	
	
	//
	NSString * retailRefundedPath;
	
	NSString * passwordLevelsPath;
	
	
	int cashTransaction;
	int checkTransaction;
	int creditTransaction;
}
@property (retain) NSString * passwordLevelsPath;
@property (retain) NSMutableArray * appointmentsInOpenTransactions;
@property (retain) NSMutableArray * transactionController;

@property (retain) NSMutableArray * priceFieldsDual;
@property (retain) NSMutableArray * serviceListDual;
@property (retain) NSMutableArray * retailSaleDual;
@property (retain) NSString * retailRefundedPath;

-(double)retailSubtotalDual;
-(double)retailTaxDual;
-(double)serviceSubtotalDual;
-(double)serviceTaxDual;
-(double)transactionTotalDual;

-(IBAction)closeTransactionDual:(id)sender;
-(NSMutableArray *)searchForProductDescription:(NSString *)productDescription;
-(IBAction)checkOutSelectedAppointmentAction:(id)sender;
-(void)checkOutSelectedAppointment;
-(IBAction)goToSellRetail:(id)sender;
-(IBAction)addRetailToShoppingCart:(id)sender;
-(IBAction)closeRetailOnlyAction:(id)sender;
-(void)setCollectedByForRetail:(NSManagedObject *)employee;

-(IBAction)viewTransactions:(id)sender;
-(IBAction)goToEditTransactions:(id)sender;
-(void)editTransactions:(NSManagedObject *)password;

-(IBAction)removeSelectedObjectsFromShoppingCart:(id)sender;

-(IBAction)removeTransaction:(id)sender;

-(IBAction)barcodeEnteredOnRetailOnly:(id)sender;
-(IBAction)barcodeEntered:(id)sender;
-(IBAction)barcodeEnteredForRefund:(id)sender;

-(IBAction)removeSelectedObjectsFromShoppingCartDual:(id)sender;
-(IBAction)addToShoppingCartDual:(id)sender;

-(IBAction)goToRefundProductPurchase:(id)sender;

-(IBAction)removeSelectedItemsFromRefund:(id)sender;
-(IBAction)addItemToRefund:(id)sender;
-(IBAction)completeRefund:(id)sender;

-(IBAction)viewTransactionsDetails:(id)sender;
-(IBAction)closeOutDualByCharge:(id)sender;
-(IBAction)closeOutDualByCheck:(id)sender;
-(IBAction)closeOutRetailByCharge:(id)sender;
-(IBAction)closeOutRetailByCheck:(id)sender;

@end
