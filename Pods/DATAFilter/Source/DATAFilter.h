@import CoreData;

typedef NS_OPTIONS(NSUInteger, DATAFilterOperation) {
    DATAFilterOperationInsert = 1 << 0,
    DATAFilterOperationUpdate = 1 << 1,
    DATAFilterOperationDelete = 1 << 2,
    DATAFilterOperationAll = 0xFFFFFFFF
};

@interface DATAFilter : NSObject

+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
localPrimaryKey:(NSString *)localPrimaryKey
remotePrimaryKey:(NSString *)remotePrimaryKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *JSON))inserted
        updated:(void (^)(NSDictionary *JSON, NSManagedObject *updatedObject))updated;

+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
      predicate:(NSPredicate *)predicate
     operations:(DATAFilterOperation)operations
localPrimaryKey:(NSString *)localPrimaryKey
remotePrimaryKey:(NSString *)remotePrimaryKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *JSON))inserted
        updated:(void (^)(NSDictionary *JSON, NSManagedObject *updatedObject))updated;

+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
       localKey:(NSString *)localKey
      remoteKey:(NSString *)remoteKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *objectJSON))inserted
        updated:(void (^)(NSDictionary *objectJSON, NSManagedObject *updatedObject))updated
__attribute__((deprecated("localKey renamed to localPrimaryKey and remoteKey renamed to remotePrimaryKey")));

+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
      predicate:(NSPredicate *)predicate
     operations:(DATAFilterOperation)operations
       localKey:(NSString *)localKey
      remoteKey:(NSString *)remoteKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *objectJSON))inserted
        updated:(void (^)(NSDictionary *objectJSON, NSManagedObject *updatedObject))updated
__attribute__((deprecated("localKey renamed to localPrimaryKey and remoteKey renamed to remotePrimaryKey")));

@end
