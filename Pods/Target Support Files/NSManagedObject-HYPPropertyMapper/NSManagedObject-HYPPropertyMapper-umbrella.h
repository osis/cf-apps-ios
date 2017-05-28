#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSDate+Parser.h"
#import "NSEntityDescription+SYNCPrimaryKey.h"
#import "NSManagedObject+HYPPropertyMapper.h"
#import "NSManagedObject+HYPPropertyMapperHelpers.h"
#import "NSString+HYPNetworking.h"

FOUNDATION_EXPORT double NSManagedObject_HYPPropertyMapperVersionNumber;
FOUNDATION_EXPORT const unsigned char NSManagedObject_HYPPropertyMapperVersionString[];

