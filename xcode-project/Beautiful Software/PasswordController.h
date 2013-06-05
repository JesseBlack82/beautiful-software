//
//  PasswordController.h
//  Beautiful Software
//
//  Created by Jesse Black on 2/1/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EmployeeSelect;
@class Beautiful_Software_AppDelegate;
@interface PasswordController : NSObject {
	IBOutlet EmployeeSelect * employeeSelect;
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	NSManagedObjectContext * moc;
	NSError * error;
	NSMutableArray * arguments;
	id requestedFrom;
	SEL selector;
	IBOutlet NSWindow * passwordEntryWindow;
	IBOutlet NSSecureTextField * password;
	
	IBOutlet NSWindow * passwordControllerWindow;
	IBOutlet NSArrayController * employeeController;
	
	NSString * passwordLevelsPath;
	IBOutlet NSArrayController * highTrustController;
	IBOutlet NSArrayController * mediumTrustController;
	IBOutlet NSArrayController * lowTrustController;
	
	NSManagedObject * lastPassword;
	IBOutlet NSButton * highTrustButton;
	IBOutlet NSButton * mediumTrustButton;
	IBOutlet NSButton * lowTrustButton;
	IBOutlet NSTableView * employeeTable;
	NSManagedObject * employeeChangingPassword;
	
	
	
	IBOutlet NSWindow * changePasswordWindow;
	IBOutlet NSSecureTextField * oldPassword;
	IBOutlet NSSecureTextField * newPassword;
	IBOutlet NSSecureTextField * confirmPassword;
}
@property (retain) NSManagedObject * lastPassword;
@property (retain) NSManagedObject * employeeChangingPassword;
@property (retain) NSString * passwordLevelsPath;
@property (retain) NSMutableArray * arguments;
@property (retain) id requestedFrom;

-(IBAction)goToPasswordController:(id)sender;

-(void)closeWindow;
-(void)getPasswordFor:(id)newRequestedFrom arguments:(NSMutableArray *)newArguments selector:(SEL)newSelector;
-(void)loadPasswordEntry;
-(void)passwordEntered:(id)sender;

-(IBAction)makeEmployeeLevel3:(id)sender;
-(IBAction)makeEmployeeLevel2:(id)sender;
-(IBAction)makeEmployeeLevel1:(id)sender;

-(IBAction)moveLevel3CategoryToLevel2:(id)sender;
-(IBAction)moveLevel2CategoryToLevel3:(id)sender;
-(IBAction)moveLevel2CategoryToLevel1:(id)sender;
-(IBAction)moveLevel1CategoryToLevel2:(id)sender;


-(IBAction)changeMyPassword:(id)sender;

-(IBAction)changePassword:(id)sender;
@end
