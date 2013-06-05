//
//  HarmonyDatabase.h
//  Beautiful Software
//
//  Created by Jesse Black on 3/7/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PageView;
@interface HarmonyDatabase : NSObject {

	IBOutlet PageView * pageView;
	IBOutlet NSWindow * databaseWindow;

	NSString * databaseStem;
	IBOutlet NSTextField * firstField;
	IBOutlet NSTextField * lastField;
	IBOutlet NSTextView * resultsField;
	NSMutableArray * matchingDates;
	IBOutlet NSArrayController * matchingController;
}
-(void)searchClientFromAppointment:(id)appointment;

-(NSMutableArray *)searchNames:(NSString *)name;
-(NSMutableArray *)matchingDates;
-(void)search;
-(void)newLetterInFirstName;
-(void)newLetterInLastName;
-(IBAction)searchAction:(id)sender;
-(IBAction)updateDatabaseAction:(id)sender;
-(IBAction)viewDatabase:(id)sender;
@end
