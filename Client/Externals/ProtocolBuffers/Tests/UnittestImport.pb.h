// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ProtocolBuffers.h"

@class ImportMessage;
@class ImportMessage_Builder;
typedef enum {
  ImportEnumImportFoo = 7,
  ImportEnumImportBar = 8,
  ImportEnumImportBaz = 9,
} ImportEnum;

BOOL ImportEnumIsValidValue(ImportEnum value);


@interface UnittestImportRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface ImportMessage : PBGeneratedMessage {
@private
  BOOL hasD_:1;
  int32_t d;
}
- (BOOL) hasD;
@property (readonly) int32_t d;

+ (ImportMessage*) defaultInstance;
- (ImportMessage*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ImportMessage_Builder*) builder;
+ (ImportMessage_Builder*) builder;
+ (ImportMessage_Builder*) builderWithPrototype:(ImportMessage*) prototype;

+ (ImportMessage*) parseFromData:(NSData*) data;
+ (ImportMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ImportMessage*) parseFromInputStream:(NSInputStream*) input;
+ (ImportMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ImportMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ImportMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ImportMessage_Builder : PBGeneratedMessage_Builder {
@private
  ImportMessage* result;
}

- (ImportMessage*) defaultInstance;

- (ImportMessage_Builder*) clear;
- (ImportMessage_Builder*) clone;

- (ImportMessage*) build;
- (ImportMessage*) buildPartial;

- (ImportMessage_Builder*) mergeFrom:(ImportMessage*) other;
- (ImportMessage_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ImportMessage_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasD;
- (int32_t) d;
- (ImportMessage_Builder*) setD:(int32_t) value;
- (ImportMessage_Builder*) clearD;
@end
