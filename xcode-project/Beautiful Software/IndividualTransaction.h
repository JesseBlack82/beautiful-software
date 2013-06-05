//
//  IndividualTransaction.h
//  Beautiful Software
//
//  Created by Jesse Black on 1/14/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RetailController;
@class TransactionController;
@interface IndividualTransaction : NSObject {
	
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
	NSManagedObjectContext * moc;
	NSError * error;
	
	NSMutableArray * retailSaleDual;
	NSMutableArray * serviceListDual;
	NSMutableArray * priceFieldsDual;
	NSManagedObject * appointmentDual;
	TransactionController * transactionDual;
}

/*
-(IBAction)removeSelectedObjectsFromShoppingCartDual:(id)sender;
-(void)closeWindowDual;


-(NSManagedObject *)appointmentDual;
-(IBAction)closeTransactionActionDual:(id)sender;
-(void)updateServiceTotalDual;
-(void)updateRetailCartDual;
-(IBAction)addToShoppingCartDual:(id)sender;

-(void)setUpServicesDual;

-(IBAction)barcodeEnteredDual:(id)sender;
*/
@end
