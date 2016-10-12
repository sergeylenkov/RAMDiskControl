//
//  NSNumber+Utilites.h
//
//  Created by Sergey Lenkov on 06.11.10.
//

@interface NSNumber (Utilites)

- (NSString *)moneyRepresentation;
- (NSString *)byte1000Representation;
- (NSString *)byte1024Representation;
- (NSString *)bitRepresentation;
- (NSString *)durationRepresentationWithHours;
- (NSString *)durationRepresentationWithMinutes;

@end
