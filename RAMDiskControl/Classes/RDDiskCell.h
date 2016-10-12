//
//  RAMDiskCell.h
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import <Foundation/Foundation.h>
#import "PXListViewCell.h"

@interface RDDiskCell : PXListViewCell {
    NSTrackingArea *trackingArea;
    NSButton *button;
    BOOL _isMouseOver;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *disk;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *freeSize;
@property (nonatomic, assign) SEL buttonAction;
@property (nonatomic, assign) id buttonTarget;
@property (nonatomic, assign) BOOL isMounted;

@end
