//
//  UniProperty.m
//  Unicorn
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <objc/message.h>
#import <sqlite3.h>

#import "UniClass.h"
#import "UniDB.h"
#import "UniProtocol.h"

static __inline__ __attribute__((always_inline)) NSString * uni_encodingDesc(UniEncodingType encodingType){
    NSMutableString * type = [NSMutableString string];
    UniEncodingType mask=encodingType&UniEncodingTypeMask;
    switch (mask) {
        case UniEncodingTypeBool: [type appendString:@"bool"]; break;
        case UniEncodingTypeInt8: [type appendString:@"int8"]; break;
        case UniEncodingTypeUInt8: [type appendString:@"uint8"]; break;
        case UniEncodingTypeInt16: [type appendString:@"int16"]; break;
        case UniEncodingTypeUInt16: [type appendString:@"uint16"]; break;
        case UniEncodingTypeInt32: [type appendString:@"int32"]; break;
        case UniEncodingTypeUInt32: [type appendString:@"uint32"]; break;
        case UniEncodingTypeInt64: [type appendString:@"int64"]; break;
        case UniEncodingTypeUInt64: [type appendString:@"uint64"]; break;
        case UniEncodingTypeFloat: [type appendString:@"float"]; break;
        case UniEncodingTypeDouble: [type appendString:@"double"]; break;
        case UniEncodingTypeLongDouble: [type appendString:@"longDouble"]; break;
        case UniEncodingTypeNSObject: [type appendString:@"object"]; break;
        case UniEncodingTypeNSString: [type appendString:@"string"]; break;
        case UniEncodingTypeNSNumber: [type appendString:@"number"]; break;
        case UniEncodingTypeNSDate: [type appendString:@"date"]; break;
        case UniEncodingTypeNSData: [type appendString:@"data"]; break;
        default: [type appendString:@"unknow"]; break;
    }
    mask=encodingType&UniEncodingTypeQualifierMask;
    if(mask&UniEncodingTypeQualifierConst) [type appendString:@" const"];
    if(mask&UniEncodingTypeQualifierIn) [type appendString:@" in"];
    if(mask&UniEncodingTypeQualifierInout) [type appendString:@" inout"];
    if(mask&UniEncodingTypeQualifierBycopy) [type appendString:@" byCopy"];
    if(mask&UniEncodingTypeQualifierByref) [type appendString:@" byref"];
    if(mask&UniEncodingTypeQualifierOneway) [type appendString:@" oneway"];
    mask=encodingType&UniEncodingTypePropertyMask;
    if(mask&UniEncodingTypePropertyReadonly) [type appendString:@" readonly"];
    if(mask&UniEncodingTypePropertyCopy) [type appendString:@" copy"];
    if(mask&UniEncodingTypePropertyRetain) [type appendString:@" retain"];
    if(mask&UniEncodingTypePropertyNonatomic) [type appendString:@" nonatomic"];
    if(mask&UniEncodingTypePropertyWeak) [type appendString:@" weak"];
    if(mask&UniEncodingTypePropertyCustomGetter) [type appendString:@" customGetter"];
    if(mask&UniEncodingTypePropertyCustomSetter) [type appendString:@" customSetter"];
    if(mask&UniEncodingTypePropertyDynamic) [type appendString:@" dynamic"];
    return type;
}
    
static __inline__ __attribute__((always_inline)) NSString * uni_columnDesc(UniColumnType columnType){
    static NSArray * arr=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{arr=@[@"unknown",@"integer",@"real",@"text",@"blob"];});
    return arr[columnType];
}
static __inline__ __attribute__((always_inline)) UniEncodingType UniPropertyGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return UniEncodingTypeUnknown;
    if (strlen(type) == 0) return UniEncodingTypeUnknown;
    UniEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': qualifier |= UniEncodingTypeQualifierConst; type++; break;
            case 'n': qualifier |= UniEncodingTypeQualifierIn; type++; break;
            case 'N': qualifier |= UniEncodingTypeQualifierInout; type++; break;
            case 'o': qualifier |= UniEncodingTypeQualifierOut; type++; break;
            case 'O': qualifier |= UniEncodingTypeQualifierBycopy; type++; break;
            case 'R': qualifier |= UniEncodingTypeQualifierByref; type++; break;
            case 'V': qualifier |= UniEncodingTypeQualifierOneway; type++; break;
            default: prefix = false; break;
        }
    }
    if (strlen(type) == 0)return UniEncodingTypeUnknown | qualifier;
    switch (*type) {
        case 'B': return UniEncodingTypeBool | qualifier;
        case 'c': return UniEncodingTypeInt8 | qualifier;
        case 'C': return UniEncodingTypeUInt8 | qualifier;
        case 's': return UniEncodingTypeInt16 | qualifier;
        case 'S': return UniEncodingTypeUInt16 | qualifier;
        case 'i': return UniEncodingTypeInt32 | qualifier;
        case 'I': return UniEncodingTypeUInt32 | qualifier;
        case 'l': return UniEncodingTypeInt32 | qualifier;
        case 'L': return UniEncodingTypeUInt32 | qualifier;
        case 'q': return UniEncodingTypeInt64 | qualifier;
        case 'Q': return UniEncodingTypeUInt64 | qualifier;
        case 'f': return UniEncodingTypeFloat | qualifier;
        case 'd': return UniEncodingTypeDouble | qualifier;
        case 'D': return UniEncodingTypeLongDouble | qualifier;
        case '@': return UniEncodingTypeNSObject | qualifier;
        default: return UniEncodingTypeUnknown | qualifier;
    }
}

static __inline__ __attribute__((always_inline)) bool uni_check_column(UniDB *db, NSString *table, NSString *column){
    BOOL ret = NO;
    NSArray *sets = [db executeQuery:@"SELECT * FROM sqlite_master WHERE tbl_name=? AND type='table'" arguments:@[table] error:nil];
    if (sets.count > 0) {
        for (NSDictionary *set in sets) {
            NSString *createSql = set[@"sql"];
            if (createSql && [createSql rangeOfString:[NSString stringWithFormat:@"'%@'", column]].location != NSNotFound) ret = YES; break;
        }
    }
    return ret;
}

static __inline__ __attribute__((always_inline)) bool uni_check_index(UniDB *db, NSString *table, NSString *index){
    __block BOOL ret = NO;
    NSArray *sets = [db executeQuery:@"SELECT * FROM sqlite_master WHERE tbl_name=? AND type='index'" arguments:@[table] error:nil];
    if (sets.count > 0) {
        for (NSDictionary *set in sets) {
            if ([set[@"name"] isEqualToString:index]) return YES;
        }
    }
    return ret;
}

@interface UniClass ()

@property (nonatomic, assign) Class                  cls;
@property (nonatomic, strong) NSString               *name;
@property (nonatomic, strong) NSArray                *properties;
@property (nonatomic, strong) NSDictionary           *propertyDict;
@property (nonatomic, strong) NSArray               *jsonProperties;
@property (nonatomic, strong) id                     jsonPrimaryKeyPaths; //NSString NSArray
@property (nonatomic, strong) UniProperty            *primaryProperty;
@property (nonatomic, strong) NSArray                *dbProperties;
@property (nonatomic, strong) NSString               *dbSelectSql;
@property (nonatomic, strong) NSString               *dbUpdateSql;
@property (nonatomic, strong) NSString               *dbInsertSql;
@property (nonatomic, assign) CFMutableDictionaryRef context;
@property (nonatomic, strong) NSArray                *relatedClasses;
@property (nonatomic, strong) NSMapTable             *mm;
@property (nonatomic, strong) UniDB                  *db;

@property (nonatomic, assign) BOOL         isConformsToUniJSON;
@property (nonatomic, assign) BOOL         isConformsToUniMM;
@property (nonatomic, assign) BOOL         isConformsToUniDB;
@end

@interface UniProperty ()

@property (nonatomic, strong) NSString *         name;
@property (nonatomic, strong) NSString *         ivar;
@property (nonatomic, assign) UniEncodingType    encodingType;
@property (nonatomic, assign) SEL                setter;
@property (nonatomic, assign) SEL                getter;
@property (nonatomic, strong) NSNumberFormatter  *numberFormatter;
@property (nonatomic, strong) NSArray            *jsonkeyPaths; // NSString NSArray
@property (nonatomic, strong) NSValueTransformer *jsonValueTransformer;
@property (nonatomic, assign) UniColumnType      columnType;
@property (nonatomic, strong) NSValueTransformer *dbValueTransformer;
@property (nonatomic, assign) Class              cls;

- (instancetype)initWithProperty:(objc_property_t)property;

- (void)deployWithOwnCls:(Class)cls context:(CFMutableDictionaryRef)context;

@end

@implementation UniClass

- (instancetype)initWithClass:(Class)cls context:(CFMutableDictionaryRef)context{
    self=[self init];
    if (!self) return nil;
    void (^block)(CFMutableDictionaryRef context)=^(CFMutableDictionaryRef context){
        self.cls=cls;
        self.name=NSStringFromClass(cls);
        NSMutableArray *properties = [NSMutableArray array];
        NSMutableDictionary *propertyDict=[NSMutableDictionary dictionary];
        [self enumeratePropertiesUsingBlock:^(objc_property_t p) {
            UniProperty *property = [[UniProperty alloc] initWithProperty:p];
            if (!((property.encodingType&UniEncodingTypePropertyMask)&UniEncodingTypePropertyReadonly)) {
                [properties addObject:property];
                [propertyDict setObject:property forKey:property.name];
            }
        }];
        self.properties=properties;
        self.propertyDict=propertyDict;
        if ([cls conformsToProtocol:@protocol(UniJSON)]) {
            self.isConformsToUniJSON=YES;
            NSDictionary *jsonKeyPaths=[cls uni_keyPaths];
            NSMutableArray *jsonProperties=[NSMutableArray array];
            [jsonKeyPaths enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull jsonKeyPaths, BOOL * _Nonnull stop) {
                UniProperty *property=self.propertyDict[key];
                if(!property) {NSParameterAssert(0); return;}
                [jsonProperties addObject:property];
                property.jsonkeyPaths=jsonKeyPaths;
                if ([cls respondsToSelector:@selector(uni_jsonValueTransformer:)]) property.jsonValueTransformer=[cls uni_jsonValueTransformer:property.name];
            }];
            self.jsonProperties=jsonProperties;
        }
        if ([cls conformsToProtocol:@protocol(UniMM)]) {
            self.isConformsToUniMM=YES;
            self.primaryProperty = self.propertyDict[[self.cls uni_primary]];
            if ([cls conformsToProtocol:@protocol(UniJSON)]) {
                self.jsonPrimaryKeyPaths=self.primaryProperty.jsonkeyPaths;
            }
            NSParameterAssert(self.primaryProperty);
            NSParameterAssert(({
                //Try to meet the requirements as much as possible and avoid certain problems,so only support the following types.
                BOOL valid=NO;
                switch (self.primaryProperty.encodingType&UniEncodingTypeMask) {
                    case UniEncodingTypeBool:
                    case UniEncodingTypeInt8:
                    case UniEncodingTypeUInt8:
                    case UniEncodingTypeInt16:
                    case UniEncodingTypeUInt16:
                    case UniEncodingTypeInt32:
                    case UniEncodingTypeUInt32:
                    case UniEncodingTypeInt64:
                    case UniEncodingTypeUInt64:
                    case UniEncodingTypeFloat:
                    case UniEncodingTypeDouble:
                    case UniEncodingTypeLongDouble:
                    case UniEncodingTypeNSString:
                    case UniEncodingTypeNSNumber:
                    case UniEncodingTypeNSURL: valid=YES; break;
                    default: break;
                }
                valid;
            }));
        }
        if([self.cls conformsToProtocol:@protocol(UniDB)]){
            self.isConformsToUniDB=YES;
        }
        CFDictionarySetValue(context, (__bridge const void *)self.cls, (__bridge const void *)self);
        for (UniProperty *property in self.properties){
            [property deployWithOwnCls:cls context:context];
        }
    };
    if (context==NULL) {
        context = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        self.context=context;
        block(context);
        long count=CFDictionaryGetCount(context);
        if (count>0) {
            void *k=malloc(sizeof(void *)*count);
            void **key=k;
            CFDictionaryGetKeysAndValues(context, (const void **)key, nil);
            NSMutableArray *array=[NSMutableArray array];
            for (long i=0;i<count;i++){
                [array addObject:NSStringFromClass((__bridge Class)key[i])];
            }
            free(k);
            self.relatedClasses=array;
        }
        CFRelease(context);
        self.context=NULL;
    }else{
        block(context);
    }
    return self;
}

- (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property))block {
    Class cls = self.cls;
    while (YES) {
        if (cls == NSObject.class) break;
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        if (properties == NULL) { cls = cls.superclass; continue; }
        for (unsigned i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            block(property);
        }
        free(properties);
        cls = cls.superclass;
    }
}

- (void)prepare{
    if ([self.cls conformsToProtocol:@protocol(UniMM)]) self.mm=[NSMapTable strongToWeakObjectsMapTable];
    if([self.cls conformsToProtocol:@protocol(UniDB)]){
        NSMutableArray *dbProperties=[NSMutableArray array];
        for (NSString * name in [self.cls uni_columns]){
            [dbProperties addObject:self.propertyDict[name]];
        }
        self.dbProperties=dbProperties;
        self.dbSelectSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=?;", self.name, self.primaryProperty.name];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", self.name];
        NSMutableString *sql1 = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", self.name];
        NSMutableString *sql2 = [NSMutableString stringWithFormat:@" VALUES ("];
        for (UniProperty *property in dbProperties){
            [sql appendFormat:@"%@=?,", property.name];
            [sql1 appendFormat:@"%@,", property.name];
            [sql2 appendFormat:@"?,"];
        }
        [sql appendFormat:@"%@=?,", @"uni_update_at"];
        [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
        [sql appendFormat:@" WHERE %@=?;", self.primaryProperty.name];
        self.dbUpdateSql = sql;
        [sql1 appendFormat:@"%@,", @"uni_update_at"];
        [sql2 appendFormat:@"?,"];
        [sql1 deleteCharactersInRange:NSMakeRange(sql1.length - 1, 1)];
        [sql1 appendFormat:@")"];
        [sql2 deleteCharactersInRange:NSMakeRange(sql2.length - 1, 1)];
        [sql2 appendFormat:@")"];
        self.dbInsertSql = [NSString stringWithFormat:@"%@%@;", sql1, sql2];
        self.db=[[UniDB alloc]init];
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"Unicorn"];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        path=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite3",NSStringFromClass(self.cls)]];
        [self __open:path error:nil];
    }
}

- (BOOL)__open:(NSString*)file error:(NSError**)error{
    if(![self.db open:file error:error]){ NSParameterAssert(false); return NO; }
    NSString *dbColumnType = uni_columnDesc(self.primaryProperty.columnType);
   __block NSString *sql = nil;
    sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' %@ NOT NULL PRIMARY KEY)", self.name, self.primaryProperty.name, dbColumnType];
    [self.db executeUpdate:sql arguments:nil error:nil];
    NSString *format=@"ALTER TABLE '%@' ADD COLUMN '%@' %@";
    for (UniProperty *property in self.dbProperties){
        if (property==self.primaryProperty) continue;
        if (!uni_check_column(self.db, self.name, property.name)) {
            sql=[NSString stringWithFormat:format,self.name,property.name,uni_columnDesc(property.columnType)];
            [self.db executeUpdate:sql arguments:nil error:nil];
        }
    }
    if (!uni_check_column(self.db, self.name, @"uni_update_at")) {
        sql=[NSString stringWithFormat:format,self.name,@"uni_update_at",uni_columnDesc(UniColumnTypeReal)];
        [self.db executeUpdate:sql arguments:nil error:nil];
    }
    NSMutableArray *indexes=[NSMutableArray array];
    if ([self.cls respondsToSelector:@selector(uni_indexes)]) {
         [indexes addObjectsFromArray:[self.cls uni_indexes]];
    }
    [indexes addObject:@"uni_update_at"];
    for (NSString *idx in indexes){
        NSString *index = [NSString stringWithFormat:@"%@_%@_index", self.name, idx];
        if (!uni_check_index(self.db, self.name, index)) {
            sql=[NSString stringWithFormat:@"CREATE INDEX %@ on %@(%@)", index, self.name, idx];
            [self.db executeUpdate:sql arguments:nil error:nil];
        }
    }
    return YES;
}

+ (instancetype)classWithClass:(Class)cls{
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    UniClass *clz = CFDictionaryGetValue(classCache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    if (!clz) {
        clz = [[UniClass alloc] initWithClass:cls context:NULL];
        if (clz) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            if (!CFDictionaryGetValue(classCache, (__bridge const void *)(cls))) {
                [clz prepare];
                CFDictionarySetValue(classCache, (__bridge const void *)(cls), (__bridge const void *)(clz));
            }
            dispatch_semaphore_signal(lock);
            NSLog(@"%@",clz);
        }
    }
    return clz;
}

- (void)sync:(void(^)(void))block{
    static dispatch_once_t onceToken;
    static NSMapTable *mt;
    static dispatch_semaphore_t semaphore;
    dispatch_once(&onceToken, ^{
        mt=[NSMapTable strongToWeakObjectsMapTable];
        semaphore=dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSRecursiveLock *lock;
    for (NSString * clsName in self.relatedClasses){
        lock=[mt objectForKey:clsName];
        if (lock) break;
    }
    if (!lock) {
        lock=[[NSRecursiveLock alloc]init];
        for (NSString *clsName in self.relatedClasses){
            [mt setObject:lock forKey:clsName];
        }
    }
    dispatch_semaphore_signal(semaphore);
    [lock lock];
    for (NSString *clsName in self.relatedClasses){
        UniClass *cls=[UniClass classWithClass:NSClassFromString(clsName)];
        if (cls.db) [cls.db beginTransaction];
    }
    block();
    for (NSString *clsName in self.relatedClasses){
        UniClass *cls=[UniClass classWithClass:NSClassFromString(clsName)];
        if (cls.db) [cls.db commit];
    }
    [lock unlock];
}

- (BOOL)open:(NSString*)file error:(NSError* __autoreleasing *)error{
    __block BOOL suc;
    [self sync:^{
        [self.db close];
        suc=[self __open:file error:error];
    }];
    return suc;
}

- (NSString*)description{
    NSMutableString *s=[NSMutableString string];
    for (UniProperty *property in self.jsonProperties){
        NSMutableString *a=[NSMutableString string];
        [a appendString:@"["];
        for (id keyPath in property.jsonkeyPaths){
            if ([keyPath isKindOfClass:[NSString class]]) {
                [a appendFormat:@"%@,",keyPath];
            }else if([keyPath isKindOfClass:[NSArray class]]){
                for (id c in keyPath){
                    [a appendFormat:@"%@.",c];
                }
            }
        }
        if (a.length>0) [a deleteCharactersInRange:NSMakeRange(a.length-1, 1)];
        [a appendString:@"]"];
        [s appendFormat:@"%@:%@,",property.name,a];
    }
    if (s.length>0) [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
    NSMutableString *ss=[NSMutableString string];
    for (UniProperty *property in self.dbProperties){
        [ss appendFormat:@"%@,",property.name];
    }
    if (ss.length>0) [ss deleteCharactersInRange:NSMakeRange(ss.length-1, 1)];
    NSMutableString *r = [NSMutableString string];
    for (NSString * c in self.relatedClasses){
        [r appendFormat:@"%@,",c];
    }
    if (r.length>0) [r deleteCharactersInRange:NSMakeRange(r.length-1, 1)];
    NSString * desc= [NSString stringWithFormat:@"****\n\
class name      : %@\n\
primary         : %@\n\
select sql      : %@\n\
insert sql      : %@\n\
update sql      : %@\n\
related classes : %@\n\
json_properties : %@\n\
db columns      : %@\n\
properties      : \n%@\n\
****",self.name,self.primaryProperty.name,self.dbSelectSql,self.dbInsertSql,self.dbUpdateSql,r,s,ss,self.properties];
    desc=[desc stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    return desc;
}

@end

@implementation UniProperty

- (instancetype)initWithProperty:(objc_property_t)property{
    if (!property) return nil;
    self=[self init];
    if (!self) return nil;
    self.name = [NSString stringWithUTF8String:property_getName(property)];
    unsigned int count;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &count);
    UniEncodingType type = 0;
    for (unsigned int i = 0; i < count; i++) {
        objc_property_attribute_t attr=attrs[i];
        switch (attr.name[0]) {
            case 'T': {
                if (attr.value) {
                    type = UniPropertyGetType(attr.value);
                    if ((type & UniEncodingTypeMask) == UniEncodingTypeNSObject) {
                        NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithUTF8String:attr.value]];
                        if (![scanner scanString:@"@\"" intoString:NULL])continue;
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) {
                                self.cls = objc_getClass(clsName.UTF8String);
                                if (self.cls==NSString.class) {
                                    type=(type&0xFFFF00)|UniEncodingTypeNSString;
                                }else if(self.cls==NSURL.class){
                                    type=(type&0xFFFF00)|UniEncodingTypeNSURL;
                                }else if(self.cls==NSNumber.class){
                                    type=(type&0xFFFF00)|UniEncodingTypeNSNumber;
                                }else if(self.cls==NSDate.class){
                                    type=(type&0xFFFF00)|UniEncodingTypeNSDate;
                                }else if(self.cls==NSData.class){
                                    type=(type&0xFFFF00)|UniEncodingTypeNSData;
                                }
                            }
                        }
                    }
                }
            } break;
            case 'V': {
                if (attr.value) {
                    self.ivar=[NSString stringWithUTF8String:attr.value];
                }
            } break;
            case 'R': type |= UniEncodingTypePropertyReadonly; break;
            case 'C': type |= UniEncodingTypePropertyCopy; break;
            case '&': type |= UniEncodingTypePropertyRetain; break;
            case 'N': type |= UniEncodingTypePropertyNonatomic; break;
            case 'D': type |= UniEncodingTypePropertyDynamic; break;
            case 'W': type |= UniEncodingTypePropertyWeak; break;
            case 'G': {
                type |= UniEncodingTypePropertyCustomGetter;
                if (attr.value) self.getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
            } break;
            case 'S': {
                type |= UniEncodingTypePropertyCustomSetter;
                if (attr.value) self.setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
            } break;
            default: break;
        }
    }
    if (attrs) free(attrs);
    self.encodingType = type;
    if (self.name.length) {
        if (!self.getter) self.getter = NSSelectorFromString(self.name);
        if (!self.setter&&!(self.encodingType&UniEncodingTypePropertyReadonly)) self.setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [self.name substringToIndex:1].uppercaseString, [self.name substringFromIndex:1]]);
    }
    return self;
}

- (void)deployWithOwnCls:(Class)ownCls context:(CFMutableDictionaryRef)context{
    if ([ownCls conformsToProtocol:@protocol(UniDB)]) {
        NSValueTransformer *valueTransformer=nil;
        if ([ownCls respondsToSelector:@selector(uni_dbValueTransformer:)]) valueTransformer=[ownCls uni_dbValueTransformer:self.name];
        if (valueTransformer) {
            UniColumnType columnType=[ownCls uni_columnType:self.name];
            NSParameterAssert(columnType);
            self.dbValueTransformer=valueTransformer;
            self.columnType=columnType;
        }
        switch (self.encodingType&UniEncodingTypeMask) {
            case UniEncodingTypeBool:
            case UniEncodingTypeInt8:
            case UniEncodingTypeUInt8:
            case UniEncodingTypeInt16:
            case UniEncodingTypeUInt16:
            case UniEncodingTypeInt32:
            case UniEncodingTypeUInt32:
            case UniEncodingTypeInt64:
            case UniEncodingTypeUInt64: self.columnType=UniColumnTypeInteger; break;
            case UniEncodingTypeFloat:
            case UniEncodingTypeDouble:
            case UniEncodingTypeLongDouble: self.columnType=UniColumnTypeReal; break;
            case UniEncodingTypeNSString: self.columnType=UniColumnTypeText; break;
            case UniEncodingTypeNSURL: self.columnType=UniColumnTypeText; break;
            case UniEncodingTypeNSNumber: self.columnType=UniColumnTypeText; break;
            case UniEncodingTypeNSDate: self.columnType=UniColumnTypeReal; break;
            case UniEncodingTypeNSData: self.columnType=UniColumnTypeBlob; break;
            case UniEncodingTypeNSObject: {
                UniClass *cls=(__bridge UniClass *)CFDictionaryGetValue(context, (__bridge const void *)self.cls);
                if ([self.cls conformsToProtocol:@protocol(UniMM)]) {
                    if (!cls) {
                        cls=[[UniClass alloc]initWithClass:self.cls context:context];
                        CFDictionarySetValue(context,  (__bridge const void *)self.cls,  (__bridge const void *)cls);
                    }else{
                        NSLog(@"****\n\nwarning!circular reference maybe happen between %@ and %@\n\n****",NSStringFromClass(self.cls),NSStringFromClass(ownCls));
                    }
                }
                if ([self.cls conformsToProtocol:@protocol(UniDB)]) {
                    self.columnType=cls.primaryProperty.columnType;
                    self.dbValueTransformer=cls.primaryProperty.dbValueTransformer;
                }else{
                    NSParameterAssert(0);
                }
            } break;
            default: NSParameterAssert(0); break;
        }
    }else if (self.cls&&[self.cls conformsToProtocol:@protocol(UniMM)]) {
        UniClass *cls=(__bridge UniClass *)CFDictionaryGetValue(context, (__bridge const void *)self.cls);
        if (!cls) {
            cls=[[UniClass alloc]initWithClass:self.cls context:context];
            CFDictionarySetValue(context, (__bridge const void *)self.cls,  (__bridge const void *)cls);
        }else{
            NSLog(@"****\n\nwarning!circular reference maybe happen between %@ and %@\n\n****",NSStringFromClass(self.cls),NSStringFromClass(ownCls));
        }
    }
}

- (NSString*)description{
    NSMutableString *s=[NSMutableString string];
    for (id keyPath in self.jsonkeyPaths){
        if ([keyPath isKindOfClass:[NSString class]]) {
            [s appendFormat:@"%@,",keyPath];
        }else if([keyPath isKindOfClass:[NSArray class]]){
            for (id c in keyPath){
                [s appendFormat:@"%@.",c];
            }
            [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
        }
        [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
    }
    return [NSString stringWithFormat:@"\n\
    name                   : %@\n\
    encoding type          : %@\n\
    setter                 : %@\n\
    getter                 : %@\n\
    jsonKeyPath            : %@\n\
    column type            : %@\n\
    json value transformer : %@\n\
    db value transformer   : %@\n    \
",self.name,uni_encodingDesc(self.encodingType),NSStringFromSelector(self.setter),NSStringFromSelector(self.getter),s,uni_columnDesc(self.columnType),self.jsonValueTransformer,self.dbValueTransformer];
}
@end
