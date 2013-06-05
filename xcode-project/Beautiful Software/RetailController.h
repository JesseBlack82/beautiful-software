//
//  RetailController.h
//  Beautiful Software
//
//  Created by Jesse Black on 1/8/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PasswordController;
@class Beautiful_Software_AppDelegate;
@interface RetailController : NSObject {
	
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	NSManagedObjectContext * moc;
	NSError * error;

	IBOutlet PasswordController * passwordController;
	IBOutlet NSTableView * editRetailTable;
	IBOutlet NSArrayController * allRetailItemsForEdit;
	IBOutlet NSWindow * editRetailPriceListWindow;
	
	//
	IBOutlet NSWindow * allInventoryWindow;
	IBOutlet NSArrayController * allInventoryController;
	IBOutlet NSTableView * allInventoryTable;
	
	//
	IBOutlet NSArrayController * matchingProductsBarcodeWindow;
	IBOutlet NSTextField * barcodeBarcodeWindow;
	IBOutlet NSTextField * companyBarcodeWindow;
	IBOutlet NSTextField * itemCodeBarcodeWindow;
	IBOutlet NSTextField * invoiceDescriptionBarcodeWindow;
	IBOutlet NSTextField * unitPriceBarcodeWindow;
	IBOutlet NSTextField * quantityBarcodeWindow;
	IBOutlet NSTextField * productDescriptionBarcodeWindow;
	IBOutlet NSWindow * createInventoryFromBarcodeWindow;
	IBOutlet NSButton * createAdjustInventoryItem;
	
	//
	IBOutlet NSWindow * addRetailWindow;
	IBOutlet NSArrayController * allRetailItems;
	IBOutlet NSTextField * addCompany;
	IBOutlet NSTextField * addProductDescription;
	IBOutlet NSTextField * addSalonCost;
	IBOutlet NSTextField * addRetailPrice;
	IBOutlet NSButton * addColorBool;
	
	//
	NSMutableArray * invoiceEntries;
	NSString * invoicePath;
	IBOutlet NSWindow * invoiceWindow;
	IBOutlet NSTextField * barcodeInvoiceWindow;
	IBOutlet NSTextField * quantitySoFar;
	IBOutlet NSTextField * lastScannedInvoice;
	
	
	NSString * passwordLevelsPath;
	//
	IBOutlet NSWindow * backBarEntryWindow;
	IBOutlet NSArrayController * backBarEntryMatches;
	IBOutlet NSArrayController * backBarEntryController;
	IBOutlet NSTextField * backBarEntrySearchField;
	IBOutlet NSTextField * backBarEntryBarcodField;
}
@property (retain) NSString * passwordLevelsPath;
@property(retain) NSString * invoicePath;
@property(retain) NSMutableArray * invoiceEntries;
-(BOOL)selling:(int)clientOrder ofThisProduct:(NSString *)productDescription;
-(IBAction)removeItemFromPriceList:(id)sender;
-(NSMutableArray *)searchForProductDescription:(NSString *)productDescription;
-(void)test;



-(IBAction)editRetailPriceListAction:(id)sender;

-(void)undoSellingFromTransaction:(NSManagedObject *)transaction;

-(IBAction)goToAllInventory:(id)sender;
-(void)passwordEnteredOnAllInventory:(NSManagedObject*)password;

-(IBAction)removeEntry:(id)sender;
-(IBAction)squeezeEntry:(id)sender;
-(IBAction)newEntry:(id)sender;
-(IBAction)sortByName:(id)sender;

-(IBAction)goToCreateInventoryFromBarcodeMode:(id)sender;
-(IBAction)searchProductDescriptionOnBarcodeMode:(id)sender;
-(IBAction)createInventoryFromBarcodeWindow:(id)sender;

-(IBAction)goToAddToRetailPriceList:(id)sender;
-(IBAction)addToRetailPriceList:(id)sender;
-(IBAction)barcodeEnteredOnBarcodeWindow:(id)sender;

-(IBAction)goToCreateInvoice:(id)sender;
-(IBAction)barcodeEnteredOnInvoiceWindow:(id)sender;
-(IBAction)viewInvoiceSummary:(id)sender;

-(IBAction)goToUseBackbarItemWindow:(id)sender;
-(IBAction)recordBackbarUsage:(id)sender;
-(IBAction)removeEntryFromBackbarTable:(id)sender;
@end
