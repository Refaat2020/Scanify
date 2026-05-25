#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DocumentCV : NSObject

+ (nullable NSData *)processDocument:(NSData *)imageData;
+ (nullable NSArray<NSNumber *> *)detectCorners:(NSData *)imageData;
+ (nullable NSData *)perspectiveTransform:(NSData *)imageData
                                  corners:(NSArray<NSNumber *> *)corners;

@end

NS_ASSUME_NONNULL_END

