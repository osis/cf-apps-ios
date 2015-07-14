@import CoreData;

static NSString * const SYNCDefaultLocalPrimaryKey = @"remoteID";
static NSString * const SYNCDefaultRemotePrimaryKey = @"id";

static NSString * const SYNCCustomLocalPrimaryKey = @"hyper.isPrimaryKey";
static NSString * const SYNCCustomRemoteKey = @"hyper.remoteKey";

@interface NSEntityDescription (SYNCPrimaryKey)

- (NSAttributeDescription *)sync_primaryKeyAttribute;

- (NSString *)sync_localKey;

- (NSString *)sync_remoteKey;

@end
