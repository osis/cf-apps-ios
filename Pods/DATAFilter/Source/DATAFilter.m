#import "DATAFilter.h"

#import "DATAObjectIDs.h"

@implementation DATAFilter

+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
localPrimaryKey:(NSString *)localPrimaryKey
remotePrimaryKey:(NSString *)remotePrimaryKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *JSON))inserted
        updated:(void (^)(NSDictionary *JSON, NSManagedObject *updatedObject))updated {
    return [self changes:changes
           inEntityNamed:entityName
               predicate:nil
              operations:DATAFilterOperationAll
         localPrimaryKey:localPrimaryKey
        remotePrimaryKey:remotePrimaryKey
                 context:context
                inserted:inserted
                 updated:updated];
}

+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
      predicate:(NSPredicate *)predicate
     operations:(DATAFilterOperation)operations
localPrimaryKey:(NSString *)localPrimaryKey
remotePrimaryKey:(NSString *)remotePrimaryKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *JSON))inserted
        updated:(void (^)(NSDictionary *JSON, NSManagedObject *updatedObject))updated {
    NSDictionary *dictionaryIDAndObjectID = [DATAObjectIDs objectIDsInEntityNamed:entityName
                                                              withAttributesNamed:localPrimaryKey
                                                                          context:context
                                                                        predicate:predicate];

    NSArray *fetchedObjectIDs = [dictionaryIDAndObjectID allKeys];
    NSMutableArray *remoteObjectIDs = [[changes valueForKey:remotePrimaryKey] mutableCopy];
    [remoteObjectIDs removeObject:[NSNull null]];

    NSDictionary *remoteIDAndChange = [NSDictionary dictionaryWithObjects:changes
                                                                  forKeys:remoteObjectIDs];

    NSMutableSet *intersection = [NSMutableSet setWithArray:remoteObjectIDs];
    [intersection intersectSet:[NSSet setWithArray:fetchedObjectIDs]];
    NSArray *updatedObjectIDs = intersection.allObjects;

    NSMutableArray *deletedObjectIDs = [fetchedObjectIDs mutableCopy];
    [deletedObjectIDs removeObjectsInArray:remoteObjectIDs];

    NSMutableArray *insertedObjectIDs = [remoteObjectIDs mutableCopy];
    [insertedObjectIDs removeObjectsInArray:fetchedObjectIDs];

    if (operations & DATAFilterOperationDelete) {
        for (id fetchedID in deletedObjectIDs) {
            NSManagedObjectID *objectID = dictionaryIDAndObjectID[fetchedID];
            if (objectID) {
                NSManagedObject *object = [context objectWithID:objectID];
                if (object) {
                    [context deleteObject:object];
                }
            }
        }
    }

    if (operations & DATAFilterOperationInsert) {
        for (id fetchedID in insertedObjectIDs) {
            NSDictionary *objectDictionary = remoteIDAndChange[fetchedID];
            if (inserted) {
                inserted(objectDictionary);
            }
        }
    }

    if (operations & DATAFilterOperationUpdate) {
        for (id fetchedID in updatedObjectIDs) {
            NSDictionary *objectDictionary = remoteIDAndChange[fetchedID];
            NSManagedObjectID *objectID = dictionaryIDAndObjectID[fetchedID];
            if (objectID) {
                NSManagedObject *object = [context objectWithID:objectID];
                if (object && updated) {
                    updated(objectDictionary, object);
                }
            }
        }
    }
}

+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
       localKey:(NSString *)localKey
      remoteKey:(NSString *)remoteKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *objectJSON))inserted
        updated:(void (^)(NSDictionary *objectJSON, NSManagedObject *updatedObject))updated {
    [self changes:changes
    inEntityNamed:entityName
  localPrimaryKey:localKey
 remotePrimaryKey:remoteKey
          context:context
         inserted:inserted
          updated:updated];
}

+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
      predicate:(NSPredicate *)predicate
     operations:(DATAFilterOperation)operations
       localKey:(NSString *)localKey
      remoteKey:(NSString *)remoteKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *objectJSON))inserted
        updated:(void (^)(NSDictionary *objectJSON, NSManagedObject *updatedObject))updated {
    [self changes:changes
    inEntityNamed:entityName
        predicate:predicate
       operations:operations
  localPrimaryKey:localKey
 remotePrimaryKey:remoteKey
          context:context
         inserted:inserted
          updated:updated];
}

@end
