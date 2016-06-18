# NSEntityDescription-SYNCPrimaryKey

[![CI Status](http://img.shields.io/travis/hyperoslo/NSEntityDescription-SYNCPrimaryKey.svg?style=flat)](https://travis-ci.org/hyperoslo/NSEntityDescription-SYNCPrimaryKey)
[![Version](https://img.shields.io/cocoapods/v/NSEntityDescription-SYNCPrimaryKey.svg?style=flat)](https://cocoapods.org/pods/NSEntityDescription-SYNCPrimaryKey)
[![License](https://img.shields.io/cocoapods/l/NSEntityDescription-SYNCPrimaryKey.svg?style=flat)](https://cocoapods.org/pods/NSEntityDescription-SYNCPrimaryKey)
[![Platform](https://img.shields.io/cocoapods/p/NSEntityDescription-SYNCPrimaryKey.svg?style=flat)](https://cocoapods.org/pods/NSEntityDescription-SYNCPrimaryKey)

## Usage

By default **NSEntityDescription-SYNCPrimaryKey** gives `id` for remote primary key and `id` for the local primary key. 

You can mark any attribute as primary key by adding `hyper.isPrimaryKey` and the value `YES` or `true`. You can also map it to any remote JSON attribute by adding `hyper.remoteKey` and the value the primary key in your JSON or remote entity such as `contract_id`.

**NSEntityDescription-SYNCPrimaryKey** will first look for a custom local primary key, then it will look for `id` and finally for `remoteID`, if after this no primary key is found, it will crash and burn.

![Custom primary key](https://raw.githubusercontent.com/hyperoslo/Sync/master/Images/custom-primary-key-v2.png)

## Interface

```objc
- (NSAttributeDescription *)sync_primaryKeyAttribute;

- (NSString *)sync_localPrimaryKey;

- (NSString *)sync_remotePrimaryKey;
```

## Installation

**NSEntityDescription-SYNCPrimaryKey** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NSEntityDescription-SYNCPrimaryKey'
```

## Author

Hyper Interaktiv AS, ios@hyper.no

## License

**NSEntityDescription-SYNCPrimaryKey** is available under the MIT license. See the LICENSE file for more info.
