//
//  UniProperty.m
//  Unicorn
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <objc/message.h>
#import <sqlite3.h>

#import "UniCompat.h"
#import "NSObject+Uni.h"
#import "UniClass.h"
static UniColumnType columnTypeOfProperty(Class cls,UniProperty* property){
    switch (property.typeEncoding) {
        case UniTypeEncodingBool:
        case UniTypeEncodingInt8:
        case UniTypeEncodingUInt8:
        case UniTypeEncodingInt16:
        case UniTypeEncodingUInt16:
        case UniTypeEncodingInt32:
        case UniTypeEncodingUInt32:
        case UniTypeEncodingInt64:
        case UniTypeEncodingUInt64:
            if([cls respondsToSelector:@selector(uni_columnType:)]){
                NSCAssert(![cls uni_columnType:property.name], @"property can be process automatically,you should not implement uni_columnType: for property: %@",property.name);
            }
            if([cls respondsToSelector:@selector(uni_dbTransformer:)]){
                NSCAssert(![cls uni_dbTransformer:property.name], @"property can be process automatically,you should not implement uni_dbTransformer: for property: %@",property.name);
            }
            return UniColumnTypeInteger;
        case UniTypeEncodingFloat:
        case UniTypeEncodingDouble:
        case UniTypeEncodingLongDouble:
            if([cls respondsToSelector:@selector(uni_columnType:)]){
                NSCAssert(![cls uni_columnType:property.name], @"property can be process automatically,you should not implement uni_columnType: for property: %@",property.name);
            }
            if([cls respondsToSelector:@selector(uni_dbTransformer:)]){
                NSCAssert(![cls uni_dbTransformer:property.name], @"property can be process automatically,you should not implement uni_dbTransformer: for property: %@",property.name);
            }
            return UniColumnTypeReal;
        case UniTypeEncodingClass:
        case UniTypeEncodingSEL:
        case UniTypeEncodingNSRange:
        case UniTypeEncodingCATansform3D:
        case UniTypeEncodingPoint:
        case UniTypeEncodingSize:
        case UniTypeEncodingRect:
        case UniTypeEncodingEdgeInsets:
        case UniTypeEncodingCGVector:
        case UniTypeEncodingCGAffineTransform:
        case UniTypeEncodingUIOffset:
        case UniTypeEncodingNSDirectionalEdgeInsets:
        case UniTypeEncodingNSString:
        case UniTypeEncodingNSMutableString:
        case UniTypeEncodingNSURL:
        case UniTypeEncodingNSNumber:
        case UniTypeEncodingNSDecimalNumber:
            if([cls respondsToSelector:@selector(uni_columnType:)]){
                NSCAssert(![cls uni_columnType:property.name], @"property can be process automatically,you should not implement uni_columnType: for property: %@",property.name);
            }
            if([cls respondsToSelector:@selector(uni_dbTransformer:)]){
                NSCAssert(![cls uni_dbTransformer:property.name], @"property can be process automatically,you should not implement uni_dbTransformer: for property: %@",property.name);
            }
            return UniColumnTypeText;
        case UniTypeEncodingNSDate:
            if([cls respondsToSelector:@selector(uni_columnType:)]){
                NSCAssert(![cls uni_columnType:property.name], @"property can be process automatically,you should not implement uni_columnType: for property: %@",property.name);
            }
            if([cls respondsToSelector:@selector(uni_dbTransformer:)]){
                NSCAssert(![cls uni_dbTransformer:property.name], @"property can be process automatically,you should not implement uni_dbTransformer: for property: %@",property.name);
            }
            return UniColumnTypeReal;
        case UniTypeEncodingNSData:
        case UniTypeEncodingNSMutableData:
            if([cls respondsToSelector:@selector(uni_columnType:)]){
                NSCAssert(![cls uni_columnType:property.name], @"property can be process automatically,you should not implement uni_columnType: for property: %@",property.name);
            }
            if([cls respondsToSelector:@selector(uni_dbTransformer:)]){
                NSCAssert(![cls uni_dbTransformer:property.name], @"property can be process automatically,you should not implement uni_dbTransformer: for property: %@",property.name);
            }
            return UniColumnTypeBlob;
        case UniTypeEncodingNSObject:{
            UniClass *clz=[[UniClass alloc]initWithClass:property.cls];
            if (clz.isConformingToUniDB||clz.isConformingToUniDB){
                return columnTypeOfProperty(clz.cls, clz.primaryProperty);
            }else{
                property.dbTransformer = [cls uni_dbTransformer:property.name];
                return [cls uni_columnType:property.name];
            }
        }
        default:
            property.dbTransformer = [cls uni_dbTransformer:property.name];
            return [cls uni_columnType:property.name];
    }
}
static __inline__ __attribute__((always_inline)) NSString * uni_encodingDesc(UniTypeEncoding typeEncoding,UniPropertyEncoding propertyEncoding,UniMethodEncoding methodEncoding){
    NSMutableString * type = [NSMutableString string];
    switch (typeEncoding) {
        case UniTypeEncodingBool: [type appendString:@"bool"]; break;
        case UniTypeEncodingInt8: [type appendString:@"int8"]; break;
        case UniTypeEncodingUInt8: [type appendString:@"uint8"]; break;
        case UniTypeEncodingInt16: [type appendString:@"int16"]; break;
        case UniTypeEncodingUInt16: [type appendString:@"uint16"]; break;
        case UniTypeEncodingInt32: [type appendString:@"int32"]; break;
        case UniTypeEncodingUInt32: [type appendString:@"uint32"]; break;
        case UniTypeEncodingInt64: [type appendString:@"int64"]; break;
        case UniTypeEncodingUInt64: [type appendString:@"uint64"]; break;
        case UniTypeEncodingFloat: [type appendString:@"float"]; break;
        case UniTypeEncodingDouble: [type appendString:@"double"]; break;
        case UniTypeEncodingLongDouble: [type appendString:@"longDouble"]; break;
        case UniTypeEncodingClass: [type appendString:@"class"]; break;
        case UniTypeEncodingSEL: [type appendString:@"sel"]; break;
        case UniTypeEncodingNSRange: [type appendString:@"range"]; break;
        case UniTypeEncodingCATansform3D: [type appendString:@"tansform3D"]; break;
        case UniTypeEncodingPoint: [type appendString:@"point"]; break;
        case UniTypeEncodingSize: [type appendString:@"size"]; break;
        case UniTypeEncodingRect: [type appendString:@"rect"]; break;
        case UniTypeEncodingEdgeInsets: [type appendString:@"edgeInsets"]; break;
        case UniTypeEncodingCGVector: [type appendString:@"vector"]; break;
        case UniTypeEncodingCGAffineTransform: [type appendString:@"affineTransform"]; break;
        case UniTypeEncodingUIOffset: [type appendString:@"UIOffset"]; break;
        case UniTypeEncodingNSDirectionalEdgeInsets: [type appendString:@"directionalEdgeInsets"]; break;
        case UniTypeEncodingBlock: [type appendString:@"block"]; break;
        case UniTypeEncodingNSString: [type appendString:@"string"]; break;
        case UniTypeEncodingNSMutableString: [type appendString:@"mutable string"]; break;
        case UniTypeEncodingNSNumber: [type appendString:@"number"]; break;
        case UniTypeEncodingNSDecimalNumber: [type appendString:@"decimal number"]; break;
        case UniTypeEncodingNSDate: [type appendString:@"date"]; break;
        case UniTypeEncodingNSData: [type appendString:@"data"]; break;
        case UniTypeEncodingNSMutableData:[type appendString:@"mutable data"]; break;
        case UniTypeEncodingNSArray: [type appendString:@"array"]; break;
        case UniTypeEncodingNSMutableArray: [type appendString:@"mutable array"]; break;
        case UniTypeEncodingNSSet: [type appendString:@"set"]; break;
        case UniTypeEncodingNSMutableSet: [type appendString:@"mutable set"]; break;
        case UniTypeEncodingNSDictionary: [type appendString:@"dictionary"]; break;
        case UniTypeEncodingNSMutableDictionary: [type appendString:@"mutable dictionary"]; break;
        case UniTypeEncodingPointer: [type appendString:@"pointer"]; break;
        case UniTypeEncodingStruct: [type appendString:@"struct"]; break;
        case UniTypeEncodingUnion: [type appendString:@"union"]; break;
        case UniTypeEncodingCString: [type appendString:@"cstring"]; break;
        case UniTypeEncodingCArray: [type appendString:@"carray"]; break;
        case UniTypeEncodingNSObject: [type appendString:@"object"]; break;
        default: [type appendString:@"unknow"]; break;
    }
    if(methodEncoding&UniMethodEncodingConst) [type appendString:@" const"];
    if(methodEncoding&UniMethodEncodingIn) [type appendString:@" in"];
    if(methodEncoding&UniMethodEncodingInout) [type appendString:@" inout"];
    if(methodEncoding&UniMethodEncodingBycopy) [type appendString:@" byCopy"];
    if(methodEncoding&UniMethodEncodingByref) [type appendString:@" byref"];
    if(methodEncoding&UniMethodEncodingOneway) [type appendString:@" oneway"];
    if(propertyEncoding&UniPropertyEncodingReadonly) [type appendString:@" readonly"];
    if(propertyEncoding&UniPropertyEncodingCopy) [type appendString:@" copy"];
    if(propertyEncoding&UniPropertyEncodingRetain) [type appendString:@" retain"];
    if(propertyEncoding&UniPropertyEncodingNonatomic) [type appendString:@" nonatomic"];
    if(propertyEncoding&UniPropertyEncodingWeak) [type appendString:@" weak"];
    if(propertyEncoding&UniPropertyEncodingCustomGetter) [type appendString:@" customGetter"];
    if(propertyEncoding&UniPropertyEncodingCustomSetter) [type appendString:@" customSetter"];
    if(propertyEncoding&UniPropertyEncodingDynamic) [type appendString:@" dynamic"];
    return type;
}

static __inline__ __attribute__((always_inline)) NSString * uni_columnDesc(UniColumnType columnType){
    static NSArray * arr=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{arr=@[@"automatically",@"integer",@"real",@"text",@"blob"];});
    return arr[columnType];
}

static __inline__ __attribute__((always_inline)) NSDictionary * uni_columns_of_table(UniDB *db, NSString *table){
    NSArray *dics = [db executeQuery:@"SELECT * FROM sqlite_master WHERE tbl_name=? AND type='table'" arguments:@[table] error:nil];
    NSDictionary *dic=dics.lastObject;
    NSString *sql=dic[@"sql"];
    if (!sql) return nil;
    NSScanner *scanner=[NSScanner scannerWithString:sql];
    if(![scanner scanUpToString:@"(" intoString:nil]) return nil;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    while (![scanner isAtEnd]) {
        NSString *column=nil;
        NSString *type=nil;
        if(![scanner scanUpToString:@"`" intoString:nil]) break;
        if (scanner.scanLocation>=scanner.string.length) break;
        scanner.scanLocation++;
        if(![scanner scanUpToString:@"`" intoString:&column]) break;
        if (scanner.scanLocation>=scanner.string.length) break;
        if(![scanner scanUpToString:@" " intoString:nil]) break;
        scanner.scanLocation++;
        if(![scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@" ,)"] intoString:&type]) break;
        dict[column]=type;
    }
    return dict;
}

static __inline__ __attribute__((always_inline)) NSDictionary * uni_indexes_of_table(UniDB *db, NSString *table){
    NSArray *dics = [db executeQuery:@"SELECT * FROM sqlite_master WHERE tbl_name=? AND type='index'" arguments:@[table] error:nil];
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    for (NSDictionary *dic in dics){
        NSString *index=dic[@"name"];
        dict[index]=index;
    }
    return dict;
}

@interface UniClass ()

@end

@interface UniProperty ()

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@implementation UniClass

+ (instancetype)classWithClass:(Class)cls{
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t semaphore;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    UniClass *clz = CFDictionaryGetValue(classCache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(semaphore);
    if (!clz) {
        clz = [[UniClass alloc] initWithClass:cls];
        if (!clz) return nil;
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (!CFDictionaryGetValue(classCache, (__bridge const void *)(cls))) {
            [clz prepare];
            CFDictionarySetValue(classCache, (__bridge const void *)(cls), (__bridge const void *)(clz));
        }
        dispatch_semaphore_signal(semaphore);
    }
    return clz;
}
- (instancetype)initWithClass:(Class)cls{
    self=[self init];
    if (!self) return nil;
    self.cls=cls;
    self.name=NSStringFromClass(cls);
    NSMutableArray *propertyArr=[NSMutableArray array];
    NSMutableDictionary *propertyDic=[NSMutableDictionary dictionary];
    [self enumeratePropertiesUsingBlock:^(objc_property_t p) {
        UniProperty *property=[[UniProperty alloc]initWithProperty:p];
        if (!property.setter) return;
        [propertyArr addObject:property];
        propertyDic[property.name]=property;
    }];
    self.propertyArr=propertyArr;
    self.propertyDic=propertyDic;
    if ([cls conformsToProtocol:@protocol(UniJSON)]) self.isConformingToUniJSON=YES;
    if ([cls conformsToProtocol:@protocol(UniMM)]) self.isConformingToUniMM=YES;
    if ([cls conformsToProtocol:@protocol(UniDB)]) self.isConformingToUniDB=YES;
    if (self.isConformingToUniMM||self.isConformingToUniDB) self.primaryProperty=self.propertyDic[[self.cls uni_primaryKey]];
    return self;
}

- (void)prepare{
    if (self.isConformingToUniJSON) {
        NSMutableArray *arr=[NSMutableArray array];
        [[self.cls uni_keyPaths] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableArray *jsonKeyPathArr=[NSMutableArray array];
            if ([obj isKindOfClass:NSString.class]) [jsonKeyPathArr addObject:[obj componentsSeparatedByString:@"."]];
            else if([obj isKindOfClass:NSArray.class]) [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                [jsonKeyPathArr addObject:[obj1 componentsSeparatedByString:@"."]];
            }];
            UniProperty *property=self.propertyDic[key];
            property.jsonKeyPathArr=jsonKeyPathArr;
            [arr addObject:property];
            if ([self.cls respondsToSelector:@selector(uni_jsonTransformer:)]) property.jsonTransformer=[self.cls uni_jsonTransformer:key];
        }];
        self.jsonPropertyArr=arr;
    }
    if (self.isConformingToUniMM)  self.mm=[NSMapTable strongToWeakObjectsMapTable];
    if (self.isConformingToUniDB) {
        NSMutableArray *arr=[NSMutableArray array];
        [[self.cls uni_columns] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UniProperty *property=self.propertyDic[obj];
            property.columnType=columnTypeOfProperty(self.cls, property);
            [arr addObject:property];
        }];
        self.dbPropertyArr=arr;
        self.dbSelectSql = [NSString stringWithFormat:@"SELECT * FROM `%@` WHERE `%@`=?;", self.name, self.primaryProperty.name];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE `%@` SET ", self.name];
        NSMutableString *sql1 = [NSMutableString stringWithFormat:@"INSERT INTO `%@` (", self.name];
        NSMutableString *sql2 = [NSMutableString stringWithFormat:@" VALUES ("];
        for (UniProperty *property in self.dbPropertyArr){
            [sql appendFormat:@"`%@`=?,", property.name];
            [sql1 appendFormat:@"`%@`,", property.name];
            [sql2 appendFormat:@"?,"];
        }
        [sql appendFormat:@"`%@`=?,", @"uni_update_at"];
        [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
        [sql appendFormat:@" WHERE `%@`=?;", self.primaryProperty.name];
        self.dbUpdateSql = sql;
        [sql1 appendFormat:@"`%@`,", @"uni_update_at"];
        [sql2 appendFormat:@"?,"];
        [sql1 deleteCharactersInRange:NSMakeRange(sql1.length - 1, 1)];
        [sql1 appendFormat:@")"];
        [sql2 deleteCharactersInRange:NSMakeRange(sql2.length - 1, 1)];
        [sql2 appendFormat:@")"];
        self.dbInsertSql = [NSString stringWithFormat:@"%@%@;", sql1, sql2];
        self.dbDeleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE `%@`=?;",self.name,self.primaryProperty.name];
        self.db=[[UniDB alloc]init];
        [self openAndInit:[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"Unicorn/%@.sqlite3",self.name]] error:nil];
    }
    if (self.primaryProperty) {
        NSAssert(!self.primaryProperty.jsonTransformer,@"primary property do not support transformer");
        NSAssert(!self.primaryProperty.dbTransformer,@"primary property do not support transformer");
        NSAssert({
               BOOL valid=NO;
            switch (self.primaryProperty.typeEncoding) {
                case UniTypeEncodingBool:
                case UniTypeEncodingInt8:
                case UniTypeEncodingUInt8:
                case UniTypeEncodingInt16:
                case UniTypeEncodingUInt16:
                case UniTypeEncodingInt32:
                case UniTypeEncodingUInt32:
                case UniTypeEncodingInt64:
                case UniTypeEncodingUInt64:
                case UniTypeEncodingFloat:
                case UniTypeEncodingDouble:
                case UniTypeEncodingLongDouble:
                case UniTypeEncodingClass:
                case UniTypeEncodingSEL:
                case UniTypeEncodingNSString:
                case UniTypeEncodingNSMutableString:
                case UniTypeEncodingNSURL:
                    valid=YES;
                default:
                    break;
            }
               valid;
            }, @"primary property type must be above");
    }
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

- (BOOL)openAndInit:(NSString*)file error:(NSError**)error{
    NSString *path=[file stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if(![self.db open:file error:error]){ NSAssert(0,@"db error %@",*error); return NO; }
    NSString *primaryColumnType = uni_columnDesc(self.primaryProperty.columnType);
    NSMutableDictionary *oldColumns = [uni_columns_of_table(self.db, self.name) mutableCopy];
    NSMutableDictionary *oldIndexes = [uni_indexes_of_table(self.db, self.name) mutableCopy];
    NSMutableArray *addPropertyArr=[NSMutableArray array];
    NSMutableArray *addIndexArr=[NSMutableArray array];
    __block NSString *sql = nil;
    if (oldColumns.count>0&&(!oldColumns[self.primaryProperty.name]||![oldColumns[self.primaryProperty.name] isEqualToString:primaryColumnType])) {
        NSAssert(0, @"dangerous operation,if the primary key changed,table will be drop and recreate");
        [self.db executeUpdate:[NSString stringWithFormat:@"DROP TABLE `%@`", self.name] arguments:nil error:nil];
    }
    [self.db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS `%@` (`%@` %@ NOT NULL PRIMARY KEY)", self.name, self.primaryProperty.name, primaryColumnType] arguments:nil error:nil];
    if (!oldColumns) oldColumns=[NSMutableDictionary dictionary];
    oldColumns[self.primaryProperty.name]=primaryColumnType;
    NSString *add=@"ALTER TABLE `%@` ADD COLUMN `%@` %@";
    for (UniProperty *property in self.dbPropertyArr){
        NSString *type=oldColumns[property.name];
        if (!type) [addPropertyArr addObject:property];
        else if (![type isEqualToString:uni_columnDesc(property.columnType)]){
                NSAssert(0, @"column: %@,old column type: %@,new column type: %@",property.name,type,uni_columnDesc(property.columnType));
        }
    }
    if ([self.cls respondsToSelector:@selector(uni_automaticalUpdatedPropertynames)])  self.automaticallyUpdatedPropertynames=[self.cls uni_automaticalUpdatedPropertynames];
    //add necessary columns
    for (UniProperty *property in addPropertyArr){
        sql=[NSString stringWithFormat:add,self.name,property.name,uni_columnDesc(property.columnType)];
        [self.db executeUpdate:sql arguments:nil error:nil];
    }
    if (!oldColumns[@"uni_update_at"]) {
        sql=[NSString stringWithFormat:add,self.name,@"uni_update_at",uni_columnDesc(UniColumnTypeReal)];
        [self.db executeUpdate:sql arguments:nil error:nil];
    }
    NSMutableArray *indexes=[NSMutableArray array];
    if ([self.cls respondsToSelector:@selector(uni_indexes)]) [indexes addObjectsFromArray:[self.cls uni_indexes]];
    [indexes addObject:@"uni_update_at"];
    for (NSString *idx in indexes){
        if (!oldIndexes[idx]){
            [addIndexArr addObject:@{@"indexname":idx,@"index":[[idx componentsSeparatedByString:@","] componentsJoinedByString:@"`,`"]}];
        }
        else oldIndexes[idx]=nil;
    }
    //add necessary indexes
    for (NSDictionary * idx in addIndexArr) [self.db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX `%@` on `%@`(`%@`)", idx[@"indexname"], self.name, idx[@"index"]] arguments:nil error:nil];
    //remove unnecessary indexes
    [oldIndexes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //do not drop autoindex
        if(![key hasPrefix:@"sqlite_autoindex_"])[self.db executeUpdate:[NSString stringWithFormat:@"DROP INDEX `%@`", key] arguments:nil error:nil];
    }];
    return YES;
}

- (void)processedClassed:(NSMutableArray*)processed synchronizedClasses:(NSMutableArray*)synchronized{
    NSString *selfCls=NSStringFromClass(self.cls);
    [processed addObject:selfCls];
    if (self.isConformingToUniMM||self.isConformingToUniDB) {
        if (![synchronized containsObject:selfCls]) [synchronized addObject:selfCls];
    }
    if ([self.cls respondsToSelector:@selector(uni_synchronizedClasses)]){
        [[self.cls uni_synchronizedClasses] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *clsName=[obj isKindOfClass:NSString.class]?obj:NSStringFromClass(obj);
            if (![synchronized containsObject:clsName]) [synchronized addObject:clsName];
        }];
    }
    [self.propertyArr enumerateObjectsUsingBlock:^(UniProperty *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.cls) return;
        if ([processed containsObject:NSStringFromClass(obj.cls)]) return;
        UniClass *cls=[[UniClass alloc]initWithClass:obj.cls];
        [cls processedClassed:processed synchronizedClasses:synchronized];
    }];
}

- (NSArray*)synchronizedClasses{
    if (_synchronizedClasses) return _synchronizedClasses;
    NSMutableArray *processed=[NSMutableArray array];
    NSMutableArray *synchronized=[NSMutableArray array];
    [self processedClassed:processed synchronizedClasses:synchronized];
    _synchronizedClasses=synchronized;
    return _synchronizedClasses;
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
    for (NSString * clsName in self.synchronizedClasses){
        lock=[mt objectForKey:clsName];
        if (lock) break;
    }
    if (!lock) lock=[[NSRecursiveLock alloc]init];
    for (NSString *clsName in self.synchronizedClasses) [mt setObject:lock forKey:clsName];
    dispatch_semaphore_signal(semaphore);
    [lock lock];
    for (NSString *clsName in self.synchronizedClasses){
        UniClass *cls=[UniClass classWithClass:NSClassFromString(clsName)];
        if (cls.db) [cls.db beginTransaction];
    }
    block();
    for (NSString *clsName in self.synchronizedClasses){
        UniClass *cls=[UniClass classWithClass:NSClassFromString(clsName)];
        if (cls.db) [cls.db commit];
    }
    [lock unlock];
}

- (BOOL)open:(NSString*)file error:(NSError* __autoreleasing *)error{
    __block BOOL suc;
    [self sync:^{
        [self.db close];
        suc=[self openAndInit:file error:error];
    }];
    return suc;
}

- (NSString*)description{
    NSMutableString *s=[NSMutableString string];
    for (UniProperty *property in self.jsonPropertyArr){
        NSMutableString *a=[NSMutableString string];
        [a appendString:@"["];
        for (NSArray *jsonKeyPath in property.jsonKeyPathArr) for (id keyPath in jsonKeyPath) [a appendFormat:@"%@.",keyPath];
        if (a.length>0) [a deleteCharactersInRange:NSMakeRange(a.length-1, 1)];
        [a appendString:@"]"];
        [s appendFormat:@"%@:%@,",property.name,a];
    }
    if (s.length>0) [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
    NSMutableString *ss=[NSMutableString string];
    for (UniProperty *property in self.dbPropertyArr) [ss appendFormat:@"%@,",property.name];
    if (ss.length>0) [ss deleteCharactersInRange:NSMakeRange(ss.length-1, 1)];
    NSMutableString *r = [NSMutableString string];
    for (NSString * c in self.synchronizedClasses) [r appendFormat:@"%@,",c];
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
    self=[self init];
    if (!self) return nil;
    self.name = [NSString stringWithUTF8String:property_getName(property)];
    unsigned int count;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &count);
    for (int i = 0; i < count; i++) {
        objc_property_attribute_t attr=attrs[i];
        switch (attr.name[0]) {
            case 'T': {
                const char * v=attr.value;
                BOOL done=NO;
                do switch (v[0]) {
                    case 'r': self.methodEncoding |= UniMethodEncodingConst;v++;break;
                    case 'n': self.methodEncoding |= UniMethodEncodingIn;v++;break;
                    case 'N': self.methodEncoding |= UniMethodEncodingInout;v++;break;
                    case 'o': self.methodEncoding |= UniMethodEncodingOut;v++;break;
                    case 'O': self.methodEncoding |= UniMethodEncodingBycopy;v++;break;
                    case 'R': self.methodEncoding |= UniMethodEncodingByref;v++;break;
                    case 'V': self.methodEncoding |= UniMethodEncodingOneway;v++;break;
                    default: done=YES;break;
                }
                while(!done);
                switch (v[0]) {
                    case 'v': self.typeEncoding = UniTypeEncodingVoid;break;
                    case 'B': self.typeEncoding = UniTypeEncodingBool;break;
                    case 'c': self.typeEncoding = UniTypeEncodingInt8;break;
                    case 'C': self.typeEncoding = UniTypeEncodingUInt8;break;
                    case 's': self.typeEncoding = UniTypeEncodingInt16;break;
                    case 'S': self.typeEncoding = UniTypeEncodingUInt16;break;
                    case 'i': self.typeEncoding = UniTypeEncodingInt32;break;
                    case 'I': self.typeEncoding = UniTypeEncodingUInt32;break;
                    case 'l': self.typeEncoding = UniTypeEncodingInt32;break;
                    case 'L': self.typeEncoding = UniTypeEncodingUInt32;break;
                    case 'q': self.typeEncoding = UniTypeEncodingInt64;break;
                    case 'Q': self.typeEncoding = UniTypeEncodingUInt64;break;
                    case 'f': self.typeEncoding = UniTypeEncodingFloat;break;
                    case 'd': self.typeEncoding = UniTypeEncodingDouble;break;
                    case 'D': self.typeEncoding = UniTypeEncodingLongDouble;break;
                    case '#': self.typeEncoding = UniTypeEncodingClass;break;
                    case ':': self.typeEncoding = UniTypeEncodingSEL;break;
                    case '{': {
                        if(strcmp(v,@encode(NSRange))==0) self.typeEncoding=UniTypeEncodingNSRange;
                        else if(strcmp(v,@encode(NSPoint))==0) self.typeEncoding=UniTypeEncodingPoint;
                        else if(strcmp(v,@encode(NSSize))==0) self.typeEncoding=UniTypeEncodingSize;
                        else if(strcmp(v,@encode(NSRect))==0) self.typeEncoding=UniTypeEncodingRect;
                        else if(strcmp(v,@encode(NSEdgeInsets))==0) self.typeEncoding=UniTypeEncodingEdgeInsets;
#if TARGET_OS_IOS || TARGET_OS_TV
                        else if(strcmp(v,@encode(CATransform3D))==0) self.typeEncoding=UniTypeEncodingCATansform3D;
#endif
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
                        else if(strcmp(v,@encode(CGVector))==0) self.typeEncoding=UniTypeEncodingCGVector;
                        else if(strcmp(v,@encode(CGAffineTransform))==0) self.typeEncoding=UniTypeEncodingCGAffineTransform;
                        else if(strcmp(v,@encode(UIOffset))==0) self.typeEncoding=UniTypeEncodingUIOffset;
#endif
                        else{
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
                            if (@available(iOS 11.0, *)) {
                                if(@available(tvOS 11.0,*)){
                                    if (@available(watchOS 4.0, *)) {
                                        if(strcmp(v,@encode(NSDirectionalEdgeInsets))==0){
                                            self.typeEncoding=UniTypeEncodingNSDirectionalEdgeInsets;
                                            break;
                                        }
                                    }
                                }
                            }
#endif
                            self.typeEncoding=UniTypeEncodingStruct;
                        }
                    }break;
                    case '*': self.typeEncoding = UniTypeEncodingCString;break;
                    case '^': self.typeEncoding = UniTypeEncodingPointer;break;
                    case '[': self.typeEncoding = UniTypeEncodingCArray;break;
                    case '(': self.typeEncoding = UniTypeEncodingUnion;break;
                    case '@': {
                        if (strlen(v)==2&&v[1] =='?'){
                            self.typeEncoding = UniTypeEncodingBlock;
                            break;
                        }
                        NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithUTF8String:attr.value]];
                        if (![scanner scanString:@"@\"" intoString:NULL]) break;
                        NSString *clsName = nil;
                        if (![scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]||!clsName.length) break;
                        Class cls = NSClassFromString(clsName);
                        if (cls==NSString.class) self.typeEncoding=UniTypeEncodingNSString;
                        else if(cls==NSMutableString.class) self.typeEncoding=UniTypeEncodingNSMutableString;
                        else if(cls==NSURL.class) self.typeEncoding=UniTypeEncodingNSURL;
                        else if(cls==NSNumber.class) self.typeEncoding=UniTypeEncodingNSNumber;
                        else if(cls==NSDecimalNumber.class)self.typeEncoding=UniTypeEncodingNSDecimalNumber;
                        else if(cls==NSDate.class) self.typeEncoding=UniTypeEncodingNSDate;
                        else if(cls==NSData.class) self.typeEncoding=UniTypeEncodingNSData;
                        else if(cls==NSMutableData.class) self.typeEncoding=UniTypeEncodingNSMutableData;
                        else if(cls==NSArray.class) self.typeEncoding=UniTypeEncodingNSArray;
                        else if(cls==NSMutableArray.class) self.typeEncoding=UniTypeEncodingNSMutableArray;
                        else if(cls==NSSet.class) self.typeEncoding=UniTypeEncodingNSSet;
                        else if(cls==NSMutableSet.class) self.typeEncoding=UniTypeEncodingNSMutableSet;
                        else if(cls==NSDictionary.class) self.typeEncoding=UniTypeEncodingNSDictionary;
                        else if(cls==NSMutableDictionary.class) self.typeEncoding=UniTypeEncodingNSMutableDictionary;
                        else self.typeEncoding=UniTypeEncodingNSObject;
                        self.cls=cls;
                    }
                    default: break;
                }
            } break;
            case 'V': break; //ivar
            case 'R': self.propertyEncoding|=UniPropertyEncodingReadonly; break;
            case 'C': self.propertyEncoding|=UniPropertyEncodingCopy; break;
            case '&': self.propertyEncoding|=UniPropertyEncodingRetain; break;
            case 'N': self.propertyEncoding|=UniPropertyEncodingNonatomic; break;
            case 'D': self.propertyEncoding|=UniPropertyEncodingDynamic; break;
            case 'W': self.propertyEncoding|=UniPropertyEncodingWeak; break;
            case 'G': {
                self.propertyEncoding|=UniPropertyEncodingCustomGetter;
                if (strlen(attr.value)) self.getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
            } break;
            case 'S': {
                self.propertyEncoding|=UniPropertyEncodingCustomSetter;
                if (strlen(attr.value)) self.setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
            } break;
            default: break;
        }
    }
    if (attrs) free(attrs);
    if (!self.getter) self.getter = NSSelectorFromString(self.name);
    if (!self.setter&&!(self.propertyEncoding&UniPropertyEncodingReadonly)) self.setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [self.name substringToIndex:1].uppercaseString, [self.name substringFromIndex:1]]);
    return self;
}

- (NSString*)description{
    NSMutableString *s=[NSMutableString string];
    for (NSArray *jsonKeyPath in self.jsonKeyPathArr){
        for (NSString * keyPath in jsonKeyPath) [s appendFormat:@"%@.",keyPath];
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
",self.name,uni_encodingDesc(self.typeEncoding,self.propertyEncoding,self.methodEncoding),NSStringFromSelector(self.setter),NSStringFromSelector(self.getter),s,uni_columnDesc(self.columnType),self.jsonTransformer,self.dbTransformer];
}
@end
