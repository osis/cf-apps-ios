#import "NSEntityDescription+SYNCPrimaryKey.h"

#import "NSString+HYPNetworking.h"

@implementation NSEntityDescription (SYNCPrimaryKey)

- (NSAttributeDescription *)sync_primaryKeyAttribute {
    __block NSAttributeDescription *primaryKeyAttribute;

    [self.propertiesByName enumerateKeysAndObjectsUsingBlock:^(NSString *key,
                                                               NSAttributeDescription *attributeDescription,
                                                               BOOL *stop) {
        NSString *isPrimaryKey = attributeDescription.userInfo[SYNCCustomLocalPrimaryKey];
        BOOL hasCustomPrimaryKey = (isPrimaryKey &&
                                    [isPrimaryKey isEqualToString:@"YES"]);
        if (hasCustomPrimaryKey) {
            primaryKeyAttribute = attributeDescription;
            *stop = YES;
        }

        if ([key isEqualToString:SYNCDefaultLocalPrimaryKey]) {
            primaryKeyAttribute = attributeDescription;
        }
    }];

    return primaryKeyAttribute;
}

- (NSString *)sync_localKey {
    NSAttributeDescription *primaryAttribute = [self sync_primaryKeyAttribute];
    NSString *localKey = primaryAttribute.name;

    return localKey;
}

- (NSString *)sync_remoteKey {
    NSAttributeDescription *primaryAttribute = [self sync_primaryKeyAttribute];
    NSString *remoteKey = primaryAttribute.userInfo[SYNCCustomRemoteKey];

    if (!remoteKey) {
        if ([primaryAttribute.name isEqualToString:SYNCDefaultLocalPrimaryKey]) {
            remoteKey = SYNCDefaultRemotePrimaryKey;
        } else {
            remoteKey = [primaryAttribute.name hyp_remoteString];
        }

    }

    return remoteKey;
}

@end
