//
//  Preferences.h
//  Beautiful Software
//
//  Created by Jesse Black on 2/3/10.
//  Copyright 2010 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Beautiful_Software_AppDelegate;
@interface Preferences : NSObject {
	IBOutlet Beautiful_Software_AppDelegate * appDelegate;
	IBOutlet NSWindow * preferencesWindow;
	
	
	IBOutlet NSTextField * serviceTaxField;
	IBOutlet NSTextField * retailTaxField;
	
	IBOutlet NSButton * reminderToCollectEmail;
	IBOutlet NSButton * phoneDash;
	IBOutlet NSButton * phoneSpaces;
	IBOutlet NSButton * phoneNoSpaces;
	IBOutlet NSButton * phoneNoFormat;
	
	IBOutlet NSTextField * emailSenderField;
	
}
-(IBAction)openPreferencesWindow:(id)sender;
-(IBAction)emailReminderPreferenceChecked:(id)sender;
-(IBAction)phonePreferenceChecked:(id)sender;
-(IBAction)applyChangesTaxAndPhoneFormat:(id)sender;
@end
