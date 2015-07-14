# DATAFilter

[![CI Status](http://img.shields.io/travis/3lvis/DATAFilter.svg?style=flat)](https://travis-ci.org/3lvis/DATAFilter)
[![Version](https://img.shields.io/cocoapods/v/DATAFilter.svg?style=flat)](http://cocoadocs.org/docsets/DATAFilter)
[![License](https://img.shields.io/cocoapods/l/DATAFilter.svg?style=flat)](http://cocoadocs.org/docsets/DATAFilter)
[![Platform](https://img.shields.io/cocoapods/p/DATAFilter.svg?style=flat)](http://cocoadocs.org/docsets/DATAFilter)

Helps you filter insertions, deletions and updates by comparing your JSON dictionary with your Core Data local objects. It also provides uniquing for you locally stored objects and automatic removal of not found ones.

## The magic

```objc
+ (void)changes:(NSArray *)changes
  inEntityNamed:(NSString *)entityName
       localKey:(NSString *)localKey
      remoteKey:(NSString *)remoteKey
        context:(NSManagedObjectContext *)context
       inserted:(void (^)(NSDictionary *objectJSON))inserted
        updated:(void (^)(NSDictionary *objectJSON, NSManagedObject *updatedObject))updated;
```

## How to use

```objc
- (void)importObjects:(NSArray *)JSON usingContext:(NSManagedObjectContext *)context error:(NSError *)error
{
    [DATAFilter changes:JSON
          inEntityNamed:@"User"
               localKey:@"remoteID"
              remoteKey:@"id"
                context:context
              predicate:nil
               inserted:^(NSDictionary *objectJSON) {
                    ANDYUser *user = [ANDYUser insertInManagedObjectContext:context];
                    [user fillObjectWithAttributes:objectDict];
              } updated:^(NSDictionary *objectJSON, NSManagedObject *updatedObject) {
                    ANDYUser *user = (ANDYUser *)object;
                    [user fillObjectWithAttributes:objectDict];
              }];

    [context save:&error];
}
```

## Local and Remote keys

`localKey` is the name of the local primaryKey, for example `remoteID`.  
`remoteKey` is the name of the key from JSON, for example `id`.

## Predicate

Use the predicate to filter out mapped changes. For example if the JSON response belongs to only inactive users, you could have a predicate like this:

```objc
NSPredicate *predicate = [NSString stringWithFormat:@"inactive = YES"];
```

***

*As a side note, you should use a [fancier property mapper](https://github.com/hyperoslo/NSManagedObject-HYPPropertyMapper/blob/master/README.md) that does the `fillObjectWithAttributes` part for you.*

## Usage

To run the example project, clone the repo, and open the `.xcodeproj` from the Demo directory.

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

