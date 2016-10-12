//
//  NSNumber+Utilites.m
//
//  Created by Sergey Lenkov on 06.11.10.
//

#import "NSNumber+Utilites.h"

@implementation NSNumber (Utilites)

- (NSString *)moneyRepresentation {
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setPositiveFormat:[NSString stringWithFormat:@"#,##0.00"]];
    
    return [formatter stringFromNumber:self];
}

- (NSString *)byte1000Representation {
    unsigned long long size = [self longLongValue];
    
    if (size < 999) {
        return [NSString stringWithFormat:@"%.2f KB", (float)size];
    }
    
    if (size < 999999999) {
        return [NSString stringWithFormat:@"%.2f MB", size / 1000000.0];
    }
    
    if (size < 999999999999) {
        return [NSString stringWithFormat:@"%.2f GB", size / 1000000000.0];
    }
    
    return [NSString stringWithFormat:@"%.2f TB", size / 1000000000000.0];
}

- (NSString *)byte1024Representation {
    unsigned long long size = [self longLongValue];
    
    if (size < 999) {
        return [NSString stringWithFormat:@"%.2f KB", (float)size];
    }
    
    if (size < 999999999) {
        return [NSString stringWithFormat:@"%.2f MB", size / 1048576.0];
    }
    
    if (size < 999999999999) {
        return [NSString stringWithFormat:@"%.2f GB", size / 1073741824.0];
    }
    
    return [NSString stringWithFormat:@"%.2f TB", size / 1099511627776.0];
}

- (NSString *)bitRepresentation {
    unsigned long long size = [self longLongValue];
    
    if (size < 999) {
        return [NSString stringWithFormat:@"%.2f Kbps", (float)size];
    }
    
    if (size < 999999999) {
        return [NSString stringWithFormat:@"%.2f Mbps", size / 1000000.0];
    }
    
    if (size < 999999999999) {
        return [NSString stringWithFormat:@"%.2f Gbps", size / 1000000000.0];
    }
    
    return [NSString stringWithFormat:@"%.2f Tbps", size / 1000000000000.0];
}

- (NSString *)durationRepresentationWithHours {
    int totalSeconds = [self intValue];
    
    int hours = totalSeconds / 3600;
    int minutes = (totalSeconds - (hours * 3600)) / 60;
    int seconds = totalSeconds - ((hours * 3600) + (minutes * 60));
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (NSString *)durationRepresentationWithMinutes {
    int totalSeconds = [self intValue];
    
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

@end
