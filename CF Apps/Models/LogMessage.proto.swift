// Generated by the protocol buffer compiler.  DO NOT EDIT!
// Source file LogMessage.proto

import Foundation
import ProtocolBuffers


public func == (lhs: LogMessage, rhs: LogMessage) -> Bool {
  if (lhs === rhs) {
    return true
  }
  var fieldCheck:Bool = (lhs.hashValue == rhs.hashValue)
  fieldCheck = fieldCheck && (lhs.hasMessage_ == rhs.hasMessage_) && (!lhs.hasMessage_ || lhs.message_ == rhs.message_)
  fieldCheck = fieldCheck && (lhs.hasMessageType == rhs.hasMessageType) && (!lhs.hasMessageType || lhs.messageType == rhs.messageType)
  fieldCheck = fieldCheck && (lhs.hasTimestamp == rhs.hasTimestamp) && (!lhs.hasTimestamp || lhs.timestamp == rhs.timestamp)
  fieldCheck = fieldCheck && (lhs.hasAppId == rhs.hasAppId) && (!lhs.hasAppId || lhs.appId == rhs.appId)
  fieldCheck = fieldCheck && (lhs.hasSourceId == rhs.hasSourceId) && (!lhs.hasSourceId || lhs.sourceId == rhs.sourceId)
  fieldCheck = fieldCheck && (lhs.drainUrls == rhs.drainUrls)
  fieldCheck = fieldCheck && (lhs.hasSourceName == rhs.hasSourceName) && (!lhs.hasSourceName || lhs.sourceName == rhs.sourceName)
  fieldCheck = (fieldCheck && (lhs.unknownFields == rhs.unknownFields))
  return fieldCheck
}

public func == (lhs: LogEnvelope, rhs: LogEnvelope) -> Bool {
  if (lhs === rhs) {
    return true
  }
  var fieldCheck:Bool = (lhs.hashValue == rhs.hashValue)
  fieldCheck = fieldCheck && (lhs.hasRoutingKey == rhs.hasRoutingKey) && (!lhs.hasRoutingKey || lhs.routingKey == rhs.routingKey)
  fieldCheck = fieldCheck && (lhs.hasSignature == rhs.hasSignature) && (!lhs.hasSignature || lhs.signature == rhs.signature)
  fieldCheck = fieldCheck && (lhs.hasLogMessage == rhs.hasLogMessage) && (!lhs.hasLogMessage || lhs.logMessage == rhs.logMessage)
  fieldCheck = (fieldCheck && (lhs.unknownFields == rhs.unknownFields))
  return fieldCheck
}

public struct LogMessageRoot {
  public static var sharedInstance : LogMessageRoot {
   struct Static {
       static let instance : LogMessageRoot = LogMessageRoot()
   }
   return Static.instance
  }
  public var extensionRegistry:ExtensionRegistry

  init() {
    extensionRegistry = ExtensionRegistry()
    registerAllExtensions(extensionRegistry)
  }
  public func registerAllExtensions(registry:ExtensionRegistry) {
  }
}

final public class LogMessage : GeneratedMessage, GeneratedMessageProtocol {


    //Enum type declaration start 

    public enum MessageType:Int32, CustomDebugStringConvertible, CustomStringConvertible {
      case Out = 1
      case Err = 2

      public var debugDescription:String { return getDescription() }
      public var description:String { return getDescription() }
      private func getDescription() -> String { 
          switch self {
              case .Out: return ".Out"
              case .Err: return ".Err"
          }
      }
    }

    //Enum type declaration end 

  public private(set) var message_:NSData = NSData()

  public private(set) var hasMessage_:Bool = false
  public private(set) var messageType:LogMessage.MessageType = LogMessage.MessageType.Out
  public private(set) var hasMessageType:Bool = false
  public private(set) var timestamp:Int64 = Int64(0)

  public private(set) var hasTimestamp:Bool = false
  public private(set) var appId:String = ""

  public private(set) var hasAppId:Bool = false
  public private(set) var sourceId:String = ""

  public private(set) var hasSourceId:Bool = false
  public private(set) var drainUrls:Array<String> = Array<String>()
  public private(set) var sourceName:String = ""

  public private(set) var hasSourceName:Bool = false
  required public init() {
       super.init()
  }
  override public func isInitialized() -> Bool {
    if !hasMessage_ {
      return false
    }
    if !hasMessageType {
      return false
    }
    if !hasTimestamp {
      return false
    }
    if !hasAppId {
      return false
    }
   return true
  }
  override public func writeToCodedOutputStream(output:CodedOutputStream) throws {
    if hasMessage_ {
      try output.writeData(1, value:message_)
    }
    if hasMessageType {
      try output.writeEnum(2, value:messageType.rawValue)
    }
    if hasTimestamp {
      try output.writeSInt64(3, value:timestamp)
    }
    if hasAppId {
      try output.writeString(4, value:appId)
    }
    if hasSourceId {
      try output.writeString(6, value:sourceId)
    }
    if !drainUrls.isEmpty {
      for oneValuedrainUrls in drainUrls {
        try output.writeString(7, value:oneValuedrainUrls)
      }
    }
    if hasSourceName {
      try output.writeString(8, value:sourceName)
    }
    try unknownFields.writeToCodedOutputStream(output)
  }
  override public func serializedSize() -> Int32 {
    var serialize_size:Int32 = memoizedSerializedSize
    if serialize_size != -1 {
     return serialize_size
    }

    serialize_size = 0
    if hasMessage_ {
      serialize_size += message_.computeDataSize(1)
    }
    if (hasMessageType) {
      serialize_size += messageType.rawValue.computeEnumSize(2)
    }
    if hasTimestamp {
      serialize_size += timestamp.computeSInt64Size(3)
    }
    if hasAppId {
      serialize_size += appId.computeStringSize(4)
    }
    if hasSourceId {
      serialize_size += sourceId.computeStringSize(6)
    }
    var dataSizeDrainUrls:Int32 = 0
    for oneValuedrainUrls in drainUrls {
        dataSizeDrainUrls += oneValuedrainUrls.computeStringSizeNoTag()
    }
    serialize_size += dataSizeDrainUrls
    serialize_size += 1 * Int32(drainUrls.count)
    if hasSourceName {
      serialize_size += sourceName.computeStringSize(8)
    }
    serialize_size += unknownFields.serializedSize()
    memoizedSerializedSize = serialize_size
    return serialize_size
  }
  public class func parseArrayDelimitedFromInputStream(input:NSInputStream) throws -> Array<LogMessage> {
    var mergedArray = Array<LogMessage>()
    while let value = try parseFromDelimitedFromInputStream(input) {
      mergedArray += [value]
    }
    return mergedArray
  }
  public class func parseFromDelimitedFromInputStream(input:NSInputStream) throws -> LogMessage? {
    return try LogMessage.Builder().mergeDelimitedFromInputStream(input)?.build()
  }
  public class func parseFromData(data:NSData) throws -> LogMessage {
    return try LogMessage.Builder().mergeFromData(data, extensionRegistry:LogMessageRoot.sharedInstance.extensionRegistry).build()
  }
  public class func parseFromData(data:NSData, extensionRegistry:ExtensionRegistry) throws -> LogMessage {
    return try LogMessage.Builder().mergeFromData(data, extensionRegistry:extensionRegistry).build()
  }
  public class func parseFromInputStream(input:NSInputStream) throws -> LogMessage {
    return try LogMessage.Builder().mergeFromInputStream(input).build()
  }
  public class func parseFromInputStream(input:NSInputStream, extensionRegistry:ExtensionRegistry) throws -> LogMessage {
    return try LogMessage.Builder().mergeFromInputStream(input, extensionRegistry:extensionRegistry).build()
  }
  public class func parseFromCodedInputStream(input:CodedInputStream) throws -> LogMessage {
    return try LogMessage.Builder().mergeFromCodedInputStream(input).build()
  }
  public class func parseFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) throws -> LogMessage {
    return try LogMessage.Builder().mergeFromCodedInputStream(input, extensionRegistry:extensionRegistry).build()
  }
  public class func getBuilder() -> LogMessage.Builder {
    return LogMessage.classBuilder() as! LogMessage.Builder
  }
  public func getBuilder() -> LogMessage.Builder {
    return classBuilder() as! LogMessage.Builder
  }
  public override class func classBuilder() -> MessageBuilder {
    return LogMessage.Builder()
  }
  public override func classBuilder() -> MessageBuilder {
    return LogMessage.Builder()
  }
  public func toBuilder() throws -> LogMessage.Builder {
    return try LogMessage.builderWithPrototype(self)
  }
  public class func builderWithPrototype(prototype:LogMessage) throws -> LogMessage.Builder {
    return try LogMessage.Builder().mergeFrom(prototype)
  }
  override public func getDescription(indent:String) throws -> String {
    var output:String = ""
    if hasMessage_ {
      output += "\(indent) message_: \(message_) \n"
    }
    if (hasMessageType) {
      output += "\(indent) messageType: \(messageType.description)\n"
    }
    if hasTimestamp {
      output += "\(indent) timestamp: \(timestamp) \n"
    }
    if hasAppId {
      output += "\(indent) appId: \(appId) \n"
    }
    if hasSourceId {
      output += "\(indent) sourceId: \(sourceId) \n"
    }
    var drainUrlsElementIndex:Int = 0
    for oneValuedrainUrls in drainUrls  {
        output += "\(indent) drainUrls[\(drainUrlsElementIndex)]: \(oneValuedrainUrls)\n"
        drainUrlsElementIndex += 1
    }
    if hasSourceName {
      output += "\(indent) sourceName: \(sourceName) \n"
    }
    output += unknownFields.getDescription(indent)
    return output
  }
  override public var hashValue:Int {
      get {
          var hashCode:Int = 7
          if hasMessage_ {
             hashCode = (hashCode &* 31) &+ message_.hashValue
          }
          if hasMessageType {
             hashCode = (hashCode &* 31) &+ Int(messageType.rawValue)
          }
          if hasTimestamp {
             hashCode = (hashCode &* 31) &+ timestamp.hashValue
          }
          if hasAppId {
             hashCode = (hashCode &* 31) &+ appId.hashValue
          }
          if hasSourceId {
             hashCode = (hashCode &* 31) &+ sourceId.hashValue
          }
          for oneValuedrainUrls in drainUrls {
              hashCode = (hashCode &* 31) &+ oneValuedrainUrls.hashValue
          }
          if hasSourceName {
             hashCode = (hashCode &* 31) &+ sourceName.hashValue
          }
          hashCode = (hashCode &* 31) &+  unknownFields.hashValue
          return hashCode
      }
  }


  //Meta information declaration start

  override public class func className() -> String {
      return "LogMessage"
  }
  override public func className() -> String {
      return "LogMessage"
  }
  override public func classMetaType() -> GeneratedMessage.Type {
      return LogMessage.self
  }
  //Meta information declaration end

  final public class Builder : GeneratedMessageBuilder {
    private var builderResult:LogMessage = LogMessage()
    public func getMessage() -> LogMessage {
        return builderResult
    }

    required override public init () {
       super.init()
    }
    public var hasMessage_:Bool {
         get {
              return builderResult.hasMessage_
         }
    }
    public var message_:NSData {
         get {
              return builderResult.message_
         }
         set (value) {
             builderResult.hasMessage_ = true
             builderResult.message_ = value
         }
    }
    public func setMessage_(value:NSData) -> LogMessage.Builder {
      self.message_ = value
      return self
    }
    public func clearMessage_() -> LogMessage.Builder{
         builderResult.hasMessage_ = false
         builderResult.message_ = NSData()
         return self
    }
      public var hasMessageType:Bool{
          get {
              return builderResult.hasMessageType
          }
      }
      public var messageType:LogMessage.MessageType {
          get {
              return builderResult.messageType
          }
          set (value) {
              builderResult.hasMessageType = true
              builderResult.messageType = value
          }
      }
      public func setMessageType(value:LogMessage.MessageType) -> LogMessage.Builder {
        self.messageType = value
        return self
      }
      public func clearMessageType() -> LogMessage.Builder {
         builderResult.hasMessageType = false
         builderResult.messageType = .Out
         return self
      }
    public var hasTimestamp:Bool {
         get {
              return builderResult.hasTimestamp
         }
    }
    public var timestamp:Int64 {
         get {
              return builderResult.timestamp
         }
         set (value) {
             builderResult.hasTimestamp = true
             builderResult.timestamp = value
         }
    }
    public func setTimestamp(value:Int64) -> LogMessage.Builder {
      self.timestamp = value
      return self
    }
    public func clearTimestamp() -> LogMessage.Builder{
         builderResult.hasTimestamp = false
         builderResult.timestamp = Int64(0)
         return self
    }
    public var hasAppId:Bool {
         get {
              return builderResult.hasAppId
         }
    }
    public var appId:String {
         get {
              return builderResult.appId
         }
         set (value) {
             builderResult.hasAppId = true
             builderResult.appId = value
         }
    }
    public func setAppId(value:String) -> LogMessage.Builder {
      self.appId = value
      return self
    }
    public func clearAppId() -> LogMessage.Builder{
         builderResult.hasAppId = false
         builderResult.appId = ""
         return self
    }
    public var hasSourceId:Bool {
         get {
              return builderResult.hasSourceId
         }
    }
    public var sourceId:String {
         get {
              return builderResult.sourceId
         }
         set (value) {
             builderResult.hasSourceId = true
             builderResult.sourceId = value
         }
    }
    public func setSourceId(value:String) -> LogMessage.Builder {
      self.sourceId = value
      return self
    }
    public func clearSourceId() -> LogMessage.Builder{
         builderResult.hasSourceId = false
         builderResult.sourceId = ""
         return self
    }
    public var drainUrls:Array<String> {
         get {
             return builderResult.drainUrls
         }
         set (array) {
             builderResult.drainUrls = array
         }
    }
    public func setDrainUrls(value:Array<String>) -> LogMessage.Builder {
      self.drainUrls = value
      return self
    }
    public func clearDrainUrls() -> LogMessage.Builder {
       builderResult.drainUrls.removeAll(keepCapacity: false)
       return self
    }
    public var hasSourceName:Bool {
         get {
              return builderResult.hasSourceName
         }
    }
    public var sourceName:String {
         get {
              return builderResult.sourceName
         }
         set (value) {
             builderResult.hasSourceName = true
             builderResult.sourceName = value
         }
    }
    public func setSourceName(value:String) -> LogMessage.Builder {
      self.sourceName = value
      return self
    }
    public func clearSourceName() -> LogMessage.Builder{
         builderResult.hasSourceName = false
         builderResult.sourceName = ""
         return self
    }
    override public var internalGetResult:GeneratedMessage {
         get {
            return builderResult
         }
    }
    public override func clear() -> LogMessage.Builder {
      builderResult = LogMessage()
      return self
    }
    public override func clone() throws -> LogMessage.Builder {
      return try LogMessage.builderWithPrototype(builderResult)
    }
    public override func build() throws -> LogMessage {
         try checkInitialized()
         return buildPartial()
    }
    public func buildPartial() -> LogMessage {
      let returnMe:LogMessage = builderResult
      return returnMe
    }
    public func mergeFrom(other:LogMessage) throws -> LogMessage.Builder {
      if other == LogMessage() {
       return self
      }
      if other.hasMessage_ {
           message_ = other.message_
      }
      if other.hasMessageType {
           messageType = other.messageType
      }
      if other.hasTimestamp {
           timestamp = other.timestamp
      }
      if other.hasAppId {
           appId = other.appId
      }
      if other.hasSourceId {
           sourceId = other.sourceId
      }
      if !other.drainUrls.isEmpty {
          builderResult.drainUrls += other.drainUrls
      }
      if other.hasSourceName {
           sourceName = other.sourceName
      }
      try mergeUnknownFields(other.unknownFields)
      return self
    }
    public override func mergeFromCodedInputStream(input:CodedInputStream) throws -> LogMessage.Builder {
         return try mergeFromCodedInputStream(input, extensionRegistry:ExtensionRegistry())
    }
    public override func mergeFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) throws -> LogMessage.Builder {
      let unknownFieldsBuilder:UnknownFieldSet.Builder = try UnknownFieldSet.builderWithUnknownFields(self.unknownFields)
      while (true) {
        let protobufTag = try input.readTag()
        switch protobufTag {
        case 0: 
          self.unknownFields = try unknownFieldsBuilder.build()
          return self

        case 10 :
          message_ = try input.readData()

        case 16 :
          let valueIntmessageType = try input.readEnum()
          if let enumsmessageType = LogMessage.MessageType(rawValue:valueIntmessageType){
               messageType = enumsmessageType
          } else {
               try unknownFieldsBuilder.mergeVarintField(2, value:Int64(valueIntmessageType))
          }

        case 24 :
          timestamp = try input.readSInt64()

        case 34 :
          appId = try input.readString()

        case 50 :
          sourceId = try input.readString()

        case 58 :
          drainUrls += [try input.readString()]

        case 66 :
          sourceName = try input.readString()

        default:
          if (!(try parseUnknownField(input,unknownFields:unknownFieldsBuilder, extensionRegistry:extensionRegistry, tag:protobufTag))) {
             unknownFields = try unknownFieldsBuilder.build()
             return self
          }
        }
      }
    }
  }

}

final public class LogEnvelope : GeneratedMessage, GeneratedMessageProtocol {
  public private(set) var routingKey:String = ""

  public private(set) var hasRoutingKey:Bool = false
  public private(set) var signature:NSData = NSData()

  public private(set) var hasSignature:Bool = false
  public private(set) var logMessage:LogMessage!
  public private(set) var hasLogMessage:Bool = false
  required public init() {
       super.init()
  }
  override public func isInitialized() -> Bool {
    if !hasRoutingKey {
      return false
    }
    if !hasSignature {
      return false
    }
    if !hasLogMessage {
      return false
    }
    if !logMessage.isInitialized() {
      return false
    }
   return true
  }
  override public func writeToCodedOutputStream(output:CodedOutputStream) throws {
    if hasRoutingKey {
      try output.writeString(1, value:routingKey)
    }
    if hasSignature {
      try output.writeData(2, value:signature)
    }
    if hasLogMessage {
      try output.writeMessage(3, value:logMessage)
    }
    try unknownFields.writeToCodedOutputStream(output)
  }
  override public func serializedSize() -> Int32 {
    var serialize_size:Int32 = memoizedSerializedSize
    if serialize_size != -1 {
     return serialize_size
    }

    serialize_size = 0
    if hasRoutingKey {
      serialize_size += routingKey.computeStringSize(1)
    }
    if hasSignature {
      serialize_size += signature.computeDataSize(2)
    }
    if hasLogMessage {
        if let varSizelogMessage = logMessage?.computeMessageSize(3) {
            serialize_size += varSizelogMessage
        }
    }
    serialize_size += unknownFields.serializedSize()
    memoizedSerializedSize = serialize_size
    return serialize_size
  }
  public class func parseArrayDelimitedFromInputStream(input:NSInputStream) throws -> Array<LogEnvelope> {
    var mergedArray = Array<LogEnvelope>()
    while let value = try parseFromDelimitedFromInputStream(input) {
      mergedArray += [value]
    }
    return mergedArray
  }
  public class func parseFromDelimitedFromInputStream(input:NSInputStream) throws -> LogEnvelope? {
    return try LogEnvelope.Builder().mergeDelimitedFromInputStream(input)?.build()
  }
  public class func parseFromData(data:NSData) throws -> LogEnvelope {
    return try LogEnvelope.Builder().mergeFromData(data, extensionRegistry:LogMessageRoot.sharedInstance.extensionRegistry).build()
  }
  public class func parseFromData(data:NSData, extensionRegistry:ExtensionRegistry) throws -> LogEnvelope {
    return try LogEnvelope.Builder().mergeFromData(data, extensionRegistry:extensionRegistry).build()
  }
  public class func parseFromInputStream(input:NSInputStream) throws -> LogEnvelope {
    return try LogEnvelope.Builder().mergeFromInputStream(input).build()
  }
  public class func parseFromInputStream(input:NSInputStream, extensionRegistry:ExtensionRegistry) throws -> LogEnvelope {
    return try LogEnvelope.Builder().mergeFromInputStream(input, extensionRegistry:extensionRegistry).build()
  }
  public class func parseFromCodedInputStream(input:CodedInputStream) throws -> LogEnvelope {
    return try LogEnvelope.Builder().mergeFromCodedInputStream(input).build()
  }
  public class func parseFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) throws -> LogEnvelope {
    return try LogEnvelope.Builder().mergeFromCodedInputStream(input, extensionRegistry:extensionRegistry).build()
  }
  public class func getBuilder() -> LogEnvelope.Builder {
    return LogEnvelope.classBuilder() as! LogEnvelope.Builder
  }
  public func getBuilder() -> LogEnvelope.Builder {
    return classBuilder() as! LogEnvelope.Builder
  }
  public override class func classBuilder() -> MessageBuilder {
    return LogEnvelope.Builder()
  }
  public override func classBuilder() -> MessageBuilder {
    return LogEnvelope.Builder()
  }
  public func toBuilder() throws -> LogEnvelope.Builder {
    return try LogEnvelope.builderWithPrototype(self)
  }
  public class func builderWithPrototype(prototype:LogEnvelope) throws -> LogEnvelope.Builder {
    return try LogEnvelope.Builder().mergeFrom(prototype)
  }
  override public func getDescription(indent:String) throws -> String {
    var output:String = ""
    if hasRoutingKey {
      output += "\(indent) routingKey: \(routingKey) \n"
    }
    if hasSignature {
      output += "\(indent) signature: \(signature) \n"
    }
    if hasLogMessage {
      output += "\(indent) logMessage {\n"
      if let outDescLogMessage = logMessage {
        output += try outDescLogMessage.getDescription("\(indent)  ")
      }
      output += "\(indent) }\n"
    }
    output += unknownFields.getDescription(indent)
    return output
  }
  override public var hashValue:Int {
      get {
          var hashCode:Int = 7
          if hasRoutingKey {
             hashCode = (hashCode &* 31) &+ routingKey.hashValue
          }
          if hasSignature {
             hashCode = (hashCode &* 31) &+ signature.hashValue
          }
          if hasLogMessage {
              if let hashValuelogMessage = logMessage?.hashValue {
                  hashCode = (hashCode &* 31) &+ hashValuelogMessage
              }
          }
          hashCode = (hashCode &* 31) &+  unknownFields.hashValue
          return hashCode
      }
  }


  //Meta information declaration start

  override public class func className() -> String {
      return "LogEnvelope"
  }
  override public func className() -> String {
      return "LogEnvelope"
  }
  override public func classMetaType() -> GeneratedMessage.Type {
      return LogEnvelope.self
  }
  //Meta information declaration end

  final public class Builder : GeneratedMessageBuilder {
    private var builderResult:LogEnvelope = LogEnvelope()
    public func getMessage() -> LogEnvelope {
        return builderResult
    }

    required override public init () {
       super.init()
    }
    public var hasRoutingKey:Bool {
         get {
              return builderResult.hasRoutingKey
         }
    }
    public var routingKey:String {
         get {
              return builderResult.routingKey
         }
         set (value) {
             builderResult.hasRoutingKey = true
             builderResult.routingKey = value
         }
    }
    public func setRoutingKey(value:String) -> LogEnvelope.Builder {
      self.routingKey = value
      return self
    }
    public func clearRoutingKey() -> LogEnvelope.Builder{
         builderResult.hasRoutingKey = false
         builderResult.routingKey = ""
         return self
    }
    public var hasSignature:Bool {
         get {
              return builderResult.hasSignature
         }
    }
    public var signature:NSData {
         get {
              return builderResult.signature
         }
         set (value) {
             builderResult.hasSignature = true
             builderResult.signature = value
         }
    }
    public func setSignature(value:NSData) -> LogEnvelope.Builder {
      self.signature = value
      return self
    }
    public func clearSignature() -> LogEnvelope.Builder{
         builderResult.hasSignature = false
         builderResult.signature = NSData()
         return self
    }
    public var hasLogMessage:Bool {
         get {
             return builderResult.hasLogMessage
         }
    }
    public var logMessage:LogMessage! {
         get {
             if logMessageBuilder_ != nil {
                builderResult.logMessage = logMessageBuilder_.getMessage()
             }
             return builderResult.logMessage
         }
         set (value) {
             builderResult.hasLogMessage = true
             builderResult.logMessage = value
         }
    }
    private var logMessageBuilder_:LogMessage.Builder! {
         didSet {
            builderResult.hasLogMessage = true
         }
    }
    public func getLogMessageBuilder() -> LogMessage.Builder {
      if logMessageBuilder_ == nil {
         logMessageBuilder_ = LogMessage.Builder()
         builderResult.logMessage = logMessageBuilder_.getMessage()
         if logMessage != nil {
            try! logMessageBuilder_.mergeFrom(logMessage)
         }
      }
      return logMessageBuilder_
    }
    public func setLogMessage(value:LogMessage!) -> LogEnvelope.Builder {
      self.logMessage = value
      return self
    }
    public func mergeLogMessage(value:LogMessage) throws -> LogEnvelope.Builder {
      if builderResult.hasLogMessage {
        builderResult.logMessage = try LogMessage.builderWithPrototype(builderResult.logMessage).mergeFrom(value).buildPartial()
      } else {
        builderResult.logMessage = value
      }
      builderResult.hasLogMessage = true
      return self
    }
    public func clearLogMessage() -> LogEnvelope.Builder {
      logMessageBuilder_ = nil
      builderResult.hasLogMessage = false
      builderResult.logMessage = nil
      return self
    }
    override public var internalGetResult:GeneratedMessage {
         get {
            return builderResult
         }
    }
    public override func clear() -> LogEnvelope.Builder {
      builderResult = LogEnvelope()
      return self
    }
    public override func clone() throws -> LogEnvelope.Builder {
      return try LogEnvelope.builderWithPrototype(builderResult)
    }
    public override func build() throws -> LogEnvelope {
         try checkInitialized()
         return buildPartial()
    }
    public func buildPartial() -> LogEnvelope {
      let returnMe:LogEnvelope = builderResult
      return returnMe
    }
    public func mergeFrom(other:LogEnvelope) throws -> LogEnvelope.Builder {
      if other == LogEnvelope() {
       return self
      }
      if other.hasRoutingKey {
           routingKey = other.routingKey
      }
      if other.hasSignature {
           signature = other.signature
      }
      if (other.hasLogMessage) {
          try mergeLogMessage(other.logMessage)
      }
      try mergeUnknownFields(other.unknownFields)
      return self
    }
    public override func mergeFromCodedInputStream(input:CodedInputStream) throws -> LogEnvelope.Builder {
         return try mergeFromCodedInputStream(input, extensionRegistry:ExtensionRegistry())
    }
    public override func mergeFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) throws -> LogEnvelope.Builder {
      let unknownFieldsBuilder:UnknownFieldSet.Builder = try UnknownFieldSet.builderWithUnknownFields(self.unknownFields)
      while (true) {
        let protobufTag = try input.readTag()
        switch protobufTag {
        case 0: 
          self.unknownFields = try unknownFieldsBuilder.build()
          return self

        case 10 :
          routingKey = try input.readString()

        case 18 :
          signature = try input.readData()

        case 26 :
          let subBuilder:LogMessage.Builder = LogMessage.Builder()
          if hasLogMessage {
            try subBuilder.mergeFrom(logMessage)
          }
          try input.readMessage(subBuilder, extensionRegistry:extensionRegistry)
          logMessage = subBuilder.buildPartial()

        default:
          if (!(try parseUnknownField(input,unknownFields:unknownFieldsBuilder, extensionRegistry:extensionRegistry, tag:protobufTag))) {
             unknownFields = try unknownFieldsBuilder.build()
             return self
          }
        }
      }
    }
  }

}


// @@protoc_insertion_point(global_scope)