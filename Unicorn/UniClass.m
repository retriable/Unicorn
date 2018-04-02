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

@property (nonatomic, assign) Class cls;
@property (nonatomic, strong) NSString      *name;
@property (nonatomic, strong) NSArray       *propertyArr;
@property (nonatomic, strong) NSDictionary  *propertyDict;
@property (nonatomic, strong) NSArray       *jsonPropertyArr;
@property (nonatomic, strong) UniProperty   *primaryProperty;
@property (nonatomic, strong) NSArray       *dbPropertyArr;
@property (nonatomic, copy  ) NSString      *dbSelectSql;
@property (nonatomic, copy  ) NSString      *dbUpdateSql;
@property (nonatomic, copy  ) NSString      *dbInsertSql;
@property (nonatomic, strong) NSSet         *relatedClassNameSet;
@property (nonatomic, strong) NSMapTable    *mm;
@property (nonatomic, strong) UniDB         *db;
@property (nonatomic, assign) BOOL          isConformsToUniJSON;
@property (nonatomic, assign) BOOL          isConformsToUniMM;
@property (nonatomic, assign) BOOL          isConformsToUniDB;
@property (nonatomic, strong) NSDictionary  *jsonKeyPathsDict;
@property (nonatomic, copy  ) NSString      *primaryKey;
@property (nonatomic, strong) NSArray       *dbColumnArr;

@end

@interface UniProperty ()

@property (nonatomic, strong) NSString *               name;
@property (nonatomic, strong) NSString *               ivar;
@property (nonatomic, assign) UniEncodingType          encodingType;
@property (nonatomic, assign) SEL                      setter;
@property (nonatomic, assign) SEL                      getter;
@property (nonatomic, strong) NSNumberFormatter        *numberFormatter;
@property (nonatomic, strong) NSArray                  *jsonKeyPathArr;
@property (nonatomic, strong) UniBlockValueTransformer *jsonValueTransformer;
@property (nonatomic, assign) UniColumnType            columnType;
@property (nonatomic, strong) UniBlockValueTransformer *dbValueTransformer;
@property (nonatomic, assign) Class                    cls;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@implementation UniClass

- (instancetype)initWithClass:(Class)cls context:(NSMutableDictionary *)context{
    self=[self init];
    if (!self) return nil;
    if (!context) context=[NSMutableDictionary dictionary];
    self.cls=cls;
    self.name=NSStringFromClass(cls);
    NSMutableArray *propertyArr = [NSMutableArray array];
    NSMutableDictionary *propertyDict=[NSMutableDictionary dictionary];
    NSMutableArray *jsonPropertyArr;
    NSMutableArray *dbPropertyArr;
    if ([cls conformsToProtocol:@protocol(UniJSON)]) {
        self.isConformsToUniJSON=YES;
        self.jsonKeyPathsDict=[cls uni_keyPaths];
    }
    if ([cls conformsToProtocol:@protocol(UniMM)]) {
        context[self.name]=self;
        self.isConformsToUniMM=YES;
        self.primaryKey=[cls uni_primary];
        jsonPropertyArr=[NSMutableArray array];
    }
    if ([cls conformsToProtocol:@protocol(UniDB)]){
        self.isConformsToUniDB=YES;
        self.dbColumnArr=[cls uni_columns];
        dbPropertyArr=[NSMutableArray array];
    }
  
    [self enumeratePropertiesUsingBlock:^(objc_property_t p) {
        UniProperty *property = [[UniProperty alloc] initWithProperty:p];
        if (((property.encodingType&UniEncodingTypePropertyMask)&UniEncodingTypePropertyReadonly)) return;
        [propertyArr addObject:property];
        propertyDict[property.name]=property;
        UniClass *propertyCls;
        if ((property.encodingType&UniEncodingTypeMask)==UniEncodingTypeNSObject) {
            NSString *propertyClassName;
            propertyClassName=NSStringFromClass(property.cls);
            propertyCls=context[propertyClassName];
            if (![propertyCls isKindOfClass:UniClass.class]){
                propertyCls=[[UniClass alloc]initWithClass:property.cls context:context];
            }else{
                if (propertyCls.isConformsToUniMM) NSLog(@"****\n\nwarning!circular reference maybe happen between %@ and %@\n\n****",propertyClassName,self.name);
            }
        }
        if (self.isConformsToUniJSON) {
            NSArray *jsonKeyPathArr=self.jsonKeyPathsDict[property.name];
            if (jsonKeyPathArr) {
                NSMutableArray *jsonKeyPathArrParsed=[NSMutableArray array];
                for (NSString *jsonKeyPath in jsonKeyPathArr){
                    [jsonKeyPathArrParsed addObject:[jsonKeyPath componentsSeparatedByString:@"."]];
                }
                property.jsonKeyPathArr=jsonKeyPathArrParsed;
                if ([cls respondsToSelector:@selector(uni_jsonValueTransformer:)]) {
                    property.jsonValueTransformer=[cls uni_jsonValueTransformer:property.name];
                    if (property.jsonValueTransformer) {
                        for (NSString *className in [property.jsonValueTransformer anonymousClassNames]){\
                            if (!context[className]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
                                [[UniClass alloc]initWithClass:NSClassFromString(className) context:context];
#pragma clang diagnostic pop
                            }
                        }
                    }
                }
                [jsonPropertyArr addObject:property];
            }
        }
        if (self.isConformsToUniMM) {
            if ([property.name isEqualToString:self.primaryKey]) {
                self.primaryProperty = property;
            }
        }
        if (self.isConformsToUniDB) {
            if ([self.dbColumnArr containsObject:property.name]) {
                [dbPropertyArr addObject:property];
                if ([cls respondsToSelector:@selector(uni_dbValueTransformer:)]){
                    property.dbValueTransformer=[self.cls uni_dbValueTransformer:property.name];
                    if (property.dbValueTransformer) {
                        UniColumnType columnType=[self.cls uni_columnType:property.name];
                        property.columnType=columnType;
                        NSParameterAssert(property.columnType);
                        for (NSString *className in [property.dbValueTransformer anonymousClassNames]){\
                            if (!context[className]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
                                [[UniClass alloc]initWithClass:NSClassFromString(className) context:context];
#pragma clang diagnostic pop
                            }
                        }
                        return;
                    }
                }
                switch (property.encodingType&UniEncodingTypeMask) {
                    case UniEncodingTypeBool:
                    case UniEncodingTypeInt8:
                    case UniEncodingTypeUInt8:
                    case UniEncodingTypeInt16:
                    case UniEncodingTypeUInt16:
                    case UniEncodingTypeInt32:
                    case UniEncodingTypeUInt32:
                    case UniEncodingTypeInt64:
                    case UniEncodingTypeUInt64: property.columnType=UniColumnTypeInteger; break;
                    case UniEncodingTypeFloat:
                    case UniEncodingTypeDouble:
                    case UniEncodingTypeLongDouble: property.columnType=UniColumnTypeReal; break;
                    case UniEncodingTypeNSString: property.columnType=UniColumnTypeText; break;
                    case UniEncodingTypeNSURL: property.columnType=UniColumnTypeText; break;
                    case UniEncodingTypeNSNumber: property.columnType=UniColumnTypeText; break;
                    case UniEncodingTypeNSDate: property.columnType=UniColumnTypeReal; break;
                    case UniEncodingTypeNSData: property.columnType=UniColumnTypeBlob; break;
                    case UniEncodingTypeNSObject: {
                        if (propertyCls.isConformsToUniDB) {
                            property.columnType=propertyCls.primaryProperty.columnType;
                            property.dbValueTransformer=propertyCls.primaryProperty.dbValueTransformer;
                        }
                    } break;
                    default: NSParameterAssert(0); break;
                }
            }
        }
    }];
    if (self.isConformsToUniMM) {
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
    self.propertyArr=propertyArr;
    self.propertyDict=propertyDict;
    self.jsonPropertyArr=jsonPropertyArr;
    self.dbPropertyArr=dbPropertyArr;
    self.relatedClassNameSet=[NSSet setWithArray:[context allKeys]];
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
    if (self.isConformsToUniMM) self.mm=[NSMapTable strongToWeakObjectsMapTable];
    if(self.isConformsToUniDB){
        self.dbSelectSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=?;", self.name, self.primaryProperty.name];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", self.name];
        NSMutableString *sql1 = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", self.name];
        NSMutableString *sql2 = [NSMutableString stringWithFormat:@" VALUES ("];
        for (UniProperty *property in self.dbPropertyArr){
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
    for (UniProperty *property in self.dbPropertyArr){
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
    if ([self.cls respondsToSelector:@selector(uni_indexes)]) [indexes addObjectsFromArray:[self.cls uni_indexes]];
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
    for (NSString * clsName in self.relatedClassNameSet){
        lock=[mt objectForKey:clsName];
        if (lock) break;
    }
    if (!lock) {
        lock=[[NSRecursiveLock alloc]init];
    }
    for (NSString *clsName in self.relatedClassNameSet){
        [mt setObject:lock forKey:clsName];
    }
    dispatch_semaphore_signal(semaphore);
    [lock lock];
    for (NSString *clsName in self.relatedClassNameSet){
        UniClass *cls=[UniClass classWithClass:NSClassFromString(clsName)];
        if (cls.db) [cls.db beginTransaction];
    }
    block();
    for (NSString *clsName in self.relatedClassNameSet){
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
    for (UniProperty *property in self.jsonPropertyArr){
        NSMutableString *a=[NSMutableString string];
        [a appendString:@"["];
        for (NSArray *jsonKeyPath in property.jsonKeyPathArr){
                for (id keyPath in jsonKeyPath){
                    [a appendFormat:@"%@.",keyPath];
                }
        }
        if (a.length>0) [a deleteCharactersInRange:NSMakeRange(a.length-1, 1)];
        [a appendString:@"]"];
        [s appendFormat:@"%@:%@,",property.name,a];
    }
    if (s.length>0) [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
    NSMutableString *ss=[NSMutableString string];
    for (UniProperty *property in self.dbPropertyArr){
        [ss appendFormat:@"%@,",property.name];
    }
    if (ss.length>0) [ss deleteCharactersInRange:NSMakeRange(ss.length-1, 1)];
    NSMutableString *r = [NSMutableString string];
    for (NSString * c in self.relatedClassNameSet){
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
****",self.name,self.primaryProperty.name,self.dbSelectSql,self.dbInsertSql,self.dbUpdateSql,r,s,ss,self.propertyArr];
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
                if (attr.value) self.ivar=[NSString stringWithUTF8String:attr.value];
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

- (NSString*)description{
    NSMutableString *s=[NSMutableString string];
    for (NSArray *jsonKeyPath in self.jsonKeyPathArr){
        for (NSString * keyPath in jsonKeyPath){
            [s appendFormat:@"%@.",keyPath];
        }
        [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
        [s appendString:@","];
    }
    [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
    return [NSString stringWithFormat:@"\n\
    name                   : %@\n\
    encoding type          : %@\n\
    setter                 : %@\n\
    getter                 : %@\n\
    jsonKeyPaths           : %@\n\
    column type            : %@\n\
    json value transformer : %@\n\
    db value transformer   : %@\n    \
",self.name,uni_encodingDesc(self.encodingType),NSStringFromSelector(self.setter),NSStringFromSelector(self.getter),s,uni_columnDesc(self.columnType),self.jsonValueTransformer,self.dbValueTransformer];
}
@end
