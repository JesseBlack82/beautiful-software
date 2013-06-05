//
//  BuildingBlock.h
//  Beautiful Software
//
//  Created by Jesse Black on 12/19/08.
//  Copyright 2008 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PageView;
@interface BuildingBlock : NSView {
	NSColor * backgroundColor;
	id appointment;
	PageView * pageView;
}
@property (retain) PageView * pageView;
@property (retain) NSColor * backgroundColor;



-(BOOL)hasHit:(NSView *)hit;
-(id)appointment;
-(void)setAppointment:(id)newAppointment;
-(id)initWithAppointment:(id)appointment forPageView:(PageView *)newPageView;
-(void)selectBlock;
-(void)unselectBlock;
-(void)updateDisplay;
-(void)setSubviewAlphaValue:(float)alpha;
@end
