//
//  BuildingTextField.h
//  Beautiful Software
//
//  Created by Jesse Black on 4/6/10.
//  Copyright 2010 Jesse Black. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BuildingBlock;
@interface BuildingTextField : NSTextField {
	BuildingBlock * buildingBlock;
}
@property (retain) BuildingBlock * buildingBlock;

@end
