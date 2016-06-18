# DATAFilter

[![Version](https://img.shields.io/cocoapods/v/DATAFilter.svg?style=flat)](http://cocoadocs.org/docsets/DATAFilter)
[![License](https://img.shields.io/cocoapods/l/DATAFilter.svg?style=flat)](http://cocoadocs.org/docsets/DATAFilter)
[![Platform](https://img.shields.io/cocoapods/p/DATAFilter.svg?style=flat)](http://cocoadocs.org/docsets/DATAFilter)

Helps you filter insertions, deletions and updates by comparing your JSON dictionary with your Core Data local objects. It also provides uniquing for you locally stored objects and automatic removal of not found ones.

## The magic

```objc
+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
localPrimaryKey:(NSString *)localPrimaryKey
remotePrimaryKey:(NSString *)remotePrimaryKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *JSON))inserted
        updated:(void (^)(NSDictionary *JSON, NSManagedObject *updatedObject))updated;
```

## How to use

```objc
- (void)importObjects:(NSArray *)JSON usingContext:(NSManagedObjectContext *)context error:(NSError *)error {
    [DATAFilter changes:JSON
          inEntityNamed:@"User"
        localPrimaryKey:@"remoteID"
       remotePrimaryKey:@"id"
                context:context
               inserted:^(NSDictionary *JSON) {
                    ANDYUser *user = [ANDYUser insertInManagedObjectContext:context];
                    [user fillObjectWithAttributes:JSON];
              } updated:^(NSDictionary *JSON, NSManagedObject *updatedObject) {
                    ANDYUser *user = (ANDYUser *)object;
                    [user fillObjectWithAttributes:JSON];
              }];

    [context save:&error];
}
```

## Local and remote primary keys

`localPrimaryKey` is the name of the local primary key, for example `id` or `remoteKey`.
`remotePrimaryKey` is the name of the key from JSON, for example `id`.

## Predicate

Use the predicate to filter out mapped changes. For example if the JSON response belongs to only inactive users, you could have a predicate like this:

```objc
NSPredicate *predicate = [NSString stringWithFormat:@"inactive = YES"];
```

---------------

*As a side note, you should use a [fancier property mapper](https://github.com/hyperoslo/NSManagedObject-HYPPropertyMapper/blob/master/README.md) that does the `fillObjectWithAttributes` part for you.*

## Operations

`DATAFilter` also provides the option to set which operations should be run when filtering, by default `DATAFilterOperationAll` is used but you could also set the option to just Insert and Update (avoiding removing items) or Update and Delete (avoiding updating items).

Usage goes like this:

```objc
// No items will be deleted here

[DATAFilter changes:JSON
      inEntityNamed:@"User"
          predicate:nil
         operations:DATAFilterOperationInsert | DATAFilterOperationUpdate
    localPrimaryKey:@"remoteID"
   remotePrimaryKey:@"id"
            context:context
           inserted:^(NSDictionary *JSON) {
               // Do something with inserted items
           } updated:^(NSDictionary *JSON, NSManagedObject *updatedObject) {
               // Do something with updated items
           }];
```

## Requirements

`iOS 7.0`, `Core Data`

## Installation

**DATAFilter** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DATAFilter'
```

## Author

Elvis Nuñez, [elvisnunez@me.com](mailto:elvisnunez@me.com)

## License

**DATAFilter** is available under the MIT license. See the [LICENSE](https://github.com/3lvis/DATAFilter/blob/master/LICENSE.md) file for more info.
