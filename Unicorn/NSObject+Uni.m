//
//  NSObject+Uni.m
//  Unicorn
//
//  Created by emsihyo on 2018/2/24.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <objc/message.h>

#import "NSObject+Uni.h"
#import "UniClass.h"

#if TARGET_OS_IOS || TARGET_OS_TV

static __inline__ __attribute__((always_inline)) NSString* uni_NSStringFromCATransform3D(CATransform3D transform3D){
    NSMutableArray *comps=[NSMutableArray array];
    CGFloat *p=(CGFloat *)&transform3D;
    for (int i=0;i<12;i++){ [comps addObject:[NSString stringWithFormat:@"%f",*p]]; p++; }
    return [NSString stringWithFormat:@"{%@}",[comps componentsJoinedByString:@","]];
}

static __inline__ __attribute__((always_inline)) CATransform3D uni_CATransform3DFromNSString(NSString *string){
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex=[[NSRegularExpression alloc]initWithPattern:@"^\\{(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1}\\}$" options:0 error:nil];
    });
    CATransform3D transform3D=(CATransform3D){0};
    if (string.length==0) return transform3D;
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (!result) return transform3D;
    CGFloat *p=(CGFloat*)&transform3D;
    for (NSInteger i=1;i<13;i++){ *p=[[string substringWithRange:[result rangeAtIndex:i]] doubleValue]; p++; }
    return transform3D;
}

NSString * _Nonnull UNI_NSStringFromCATransform3D(CATransform3D transform3D){
    return uni_NSStringFromCATransform3D(transform3D);
}

CATransform3D UNI_CATransform3DFromNSString(NSString * _Nullable string){
    return uni_CATransform3DFromNSString(string);
}

#endif

#if TARGET_OS_OSX

static __inline__ __attribute__((always_inline)) NSString* uni_NSStringFromNSEdgeInsets(NSEdgeInsets edgeInsets){
    NSMutableArray *comps=[NSMutableArray array];
    CGFloat *p=(CGFloat *)&edgeInsets;
    for (int i=0;i<4;i++){ [comps addObject:[NSString stringWithFormat:@"%f",*p]];p++; }
    return [NSString stringWithFormat:@"{%@}",[comps componentsJoinedByString:@","]];
}

static __inline__ __attribute__((always_inline)) NSEdgeInsets uni_NSEdgeInsetsFromNSString(NSString *string){
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex=[[NSRegularExpression alloc]initWithPattern:@"^\\{(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1},(\\s*\\-?[0-9]+\\.?[0-9]*\\s*){1}\\}$" options:0 error:nil];
    });
    NSEdgeInsets insets=(NSEdgeInsets){0,0,0,0};
    if (string.length==0) return insets;
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (!result) return insets;
    CGFloat *p=(CGFloat*)&insets;
    for (NSInteger i=1;i<5;i++){ *p=[[string substringWithRange:[result rangeAtIndex:i]] doubleValue]; p++; }
    return insets;
}

NSString* _Nonnull UNI_NSStringFromNSEdgeInsets(NSEdgeInsets edgeInsets){
    return uni_NSStringFromNSEdgeInsets(edgeInsets);
}
NSEdgeInsets UNI_NSEdgeInsetsFromNSString(NSString * _Nullable string){
    return uni_NSEdgeInsetsFromNSString(string);
}
#endif

static __inline__ __attribute__((always_inline)) NSNumberFormatter *UNI_NumberFormatter(){
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ formatter=[[NSNumberFormatter alloc]init]; });
    return formatter;
}

static __inline__ __attribute__((always_inline)) void uni_set_value(id target,UniProperty *property,id value){
    if (!value) return;
    switch (property.typeEncoding) {
        case UniTypeEncodingBool:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,BOOL))(void *) objc_msgSend)(target, property.setter,[value boolValue]);
            else if ([value isKindOfClass:NSString.class]) {
                NSString *low=[value lowercaseString];
                ((void (*)(id, SEL,bool))(void *) objc_msgSend)(target, property.setter,[low isEqualToString:@"true"]||[low isEqualToString:@"yes"]||[value boolValue]);
            }else if(value==(id)kCFNull) ((void (*)(id, SEL,BOOL))(void *) objc_msgSend)(target, property.setter,NO);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingInt8:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,[value charValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() numberFromString:value] charValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingUInt8:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,[value unsignedCharValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() numberFromString:value] unsignedCharValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingInt16:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,[value shortValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() numberFromString:value] shortValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingUInt16:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,[value unsignedShortValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() numberFromString:value] unsignedShortValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingInt32:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,[value intValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() numberFromString:value] intValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingUInt32:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,[value unsignedIntValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() numberFromString:value] unsignedIntValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingInt64:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,[value longLongValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() numberFromString:value] longLongValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        }break;
        case UniTypeEncodingUInt64:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,[value unsignedLongLongValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() numberFromString:value] unsignedLongLongValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingFloat:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,[value floatValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,[value floatValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingDouble:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,[value doubleValue]);
            else if ([value isKindOfClass:NSString.class])  ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,[value doubleValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingLongDouble:
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,(long double)[value doubleValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,(long double)[value doubleValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingClass:
            if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,Class))(void *) objc_msgSend)(target, property.setter,NSClassFromString(value));
            else if(value==(id)kCFNull) ((void (*)(id, SEL,Class))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingSEL:
            if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,SEL))(void *) objc_msgSend)(target, property.setter,NSSelectorFromString(value));
            else if(value==(id)kCFNull) ((void (*)(id, SEL,Class))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSRange:
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSRange))(void *) objc_msgSend)(target, property.setter,[value rangeValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSRange))(void *) objc_msgSend)(target, property.setter, NSRangeFromString(value));
            else if(value==(id)kCFNull) ((void (*)(id, SEL,NSRange))(void *) objc_msgSend)(target, property.setter,(NSRange){0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
#if TARGET_OS_IOS || TARGET_OS_TVOS
        case UniTypeEncodingCATansform3D:
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,CATransform3D))(void *) objc_msgSend)(target, property.setter,[value CATransform3DValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,CATransform3D))(void *) objc_msgSend)(target, property.setter, uni_CATransform3DFromNSString(value));
            else if(value==(id)kCFNull) ((void (*)(id, SEL,CATransform3D))(void *) objc_msgSend)(target, property.setter,(CATransform3D){0,0,0,0,0,0,0,0,0,0,0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
#endif
        case UniTypeEncodingPoint:
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSPoint))(void *) objc_msgSend)(target, property.setter,[value CGPointValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSPoint))(void *) objc_msgSend)(target, property.setter,CGPointFromString(value));
#else
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSPoint))(void *) objc_msgSend)(target, property.setter,[value pointValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSPoint))(void *) objc_msgSend)(target, property.setter,NSPointFromString(value));
#endif
            else if(value==(id)kCFNull) ((void (*)(id, SEL,NSPoint))(void *) objc_msgSend)(target, property.setter,(NSPoint){0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        break;
        case UniTypeEncodingSize:
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSSize))(void *) objc_msgSend)(target, property.setter,[value CGSizeValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSSize))(void *) objc_msgSend)(target, property.setter,CGSizeFromString(value));
#else
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSSize))(void *) objc_msgSend)(target, property.setter,[value sizeValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSSize))(void *) objc_msgSend)(target, property.setter,NSSizeFromString(value));
#endif
            else if(value==(id)kCFNull) ((void (*)(id, SEL,NSSize))(void *) objc_msgSend)(target, property.setter,(NSSize){0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingRect:
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSRect))(void *) objc_msgSend)(target, property.setter,[value CGRectValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSRect))(void *) objc_msgSend)(target, property.setter,CGRectFromString(value));
#else
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSRect))(void *) objc_msgSend)(target, property.setter,[value rectValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSRect))(void *) objc_msgSend)(target, property.setter,NSRectFromString(value));
#endif
            else if(value==(id)kCFNull) ((void (*)(id, SEL,NSRect))(void *) objc_msgSend)(target, property.setter,(NSRect){0,0,0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingEdgeInsets:
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSEdgeInsets))(void *) objc_msgSend)(target, property.setter,[value UIEdgeInsetsValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSEdgeInsets))(void *) objc_msgSend)(target, property.setter,UIEdgeInsetsFromString(value));
#else
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSEdgeInsets))(void *) objc_msgSend)(target, property.setter,[value edgeInsetsValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,NSEdgeInsets))(void *) objc_msgSend)(target, property.setter,uni_NSEdgeInsetsFromNSString(value));
#endif
            else if(value==(id)kCFNull) ((void (*)(id, SEL,NSEdgeInsets))(void *) objc_msgSend)(target, property.setter,(NSEdgeInsets){0,0,0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
        case UniTypeEncodingCGVector:
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,CGVector))(void *) objc_msgSend)(target, property.setter,[value CGVectorValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,CGVector))(void *) objc_msgSend)(target, property.setter,CGVectorFromString(value));
            else if(value==(id)kCFNull) ((void (*)(id, SEL,CGVector))(void *) objc_msgSend)(target, property.setter,(CGVector){0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingCGAffineTransform:
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,CGAffineTransform))(void *) objc_msgSend)(target, property.setter,[value CGAffineTransformValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,CGAffineTransform))(void *) objc_msgSend)(target, property.setter,CGAffineTransformFromString(value));
            else if(value==(id)kCFNull) ((void (*)(id, SEL,CGAffineTransform))(void *) objc_msgSend)(target, property.setter,(CGAffineTransform){0,0,0,0,0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingUIOffset:
            if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,UIOffset))(void *) objc_msgSend)(target, property.setter,[value UIOffsetValue]);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,UIOffset))(void *) objc_msgSend)(target, property.setter,UIOffsetFromString(value));
            else if(value==(id)kCFNull) ((void (*)(id, SEL,UIOffset))(void *) objc_msgSend)(target, property.setter,(UIOffset){0,0});
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSDirectionalEdgeInsets:
#if TARGET_OS_IOS
            if (@available(iOS 11.0, *)) {
#endif
#if TARGET_OS_TV
                if (@available(tvOS 11.0, *)) {
#endif
#if TARGET_OS_WATCH
                    if (@available(watchOS 4.0, *)) {
#endif
                        if([value isKindOfClass:NSValue.class]) ((void (*)(id, SEL,NSDirectionalEdgeInsets))(void *) objc_msgSend)(target, property.setter,[value directionalEdgeInsetsValue]);
                        else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,UIOffset))(void *) objc_msgSend)(target, property.setter,UIOffsetFromString(value));
                        else if(value==(id)kCFNull) ((void (*)(id, SEL,NSDirectionalEdgeInsets))(void *) objc_msgSend)(target, property.setter,(NSDirectionalEdgeInsets){0});
                        else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
                    }
            break;
#endif
        case UniTypeEncodingNSString:
            if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if ([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[UNI_NumberFormatter() stringFromNumber:value]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value description]);
            break;
        case UniTypeEncodingNSMutableString:
            if([value isKindOfClass:NSMutableString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value mutableCopy]);
            else if ([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[UNI_NumberFormatter() stringFromNumber:value] mutableCopy]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[value description] mutableCopy]);
            break;
        case UniTypeEncodingNSURL:
            if ([value isKindOfClass:NSURL.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[NSURL URLWithString:value]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSNumber:
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[UNI_NumberFormatter() numberFromString:value]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSDecimalNumber:
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[NSDecimalNumber decimalNumberWithString:[UNI_NumberFormatter() stringFromNumber:value]]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[NSDecimalNumber decimalNumberWithString:value]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSDate:
        case UniTypeEncodingNSData:
        case UniTypeEncodingNSArray:
        case UniTypeEncodingNSSet:
        case UniTypeEncodingNSDictionary:
            if ([value isKindOfClass:property.cls]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if (value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSMutableArray:
            if ([value isKindOfClass:NSMutableArray.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if([value isKindOfClass:NSArray.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value mutableCopy]);
            else if (value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSMutableSet:
            if ([value isKindOfClass:NSMutableSet.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if([value isKindOfClass:NSSet.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value mutableCopy]);
            else if (value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSMutableDictionary:
            if ([value isKindOfClass:NSMutableDictionary.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if([value isKindOfClass:NSDictionary.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value mutableCopy]);
            else if (value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSMutableData:
            if([value isKindOfClass:NSMutableData.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if([value isKindOfClass:NSData.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value mutableCopy]);
            else if (value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingBlock:
        case UniTypeEncodingPointer:
        case UniTypeEncodingStruct:
        case UniTypeEncodingUnion:
        case UniTypeEncodingCString:
        case UniTypeEncodingCArray:
        default: [target setValue:value forKey:property.name]; break;
    }
}

static __inline__ __attribute__((always_inline)) id uni_get_value(id target,UniProperty *property){
    switch (property.typeEncoding) {
        case UniTypeEncodingBool: return @(((BOOL (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingInt8: return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingUInt8: return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingInt16: return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingUInt16: return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingInt32: return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingUInt32: return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingInt64: return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingUInt64: return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingFloat: return @(((float (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingDouble:
        case UniTypeEncodingLongDouble: return @(((double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingClass: return ((Class (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
        case UniTypeEncodingNSRange: return [NSValue valueWithRange:((NSRange (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
#if TARGET_OS_IOS || TARGET_OS_TVOS
        case UniTypeEncodingCATansform3D: return [NSValue valueWithCATransform3D:((CATransform3D (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
#endif
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
        case UniTypeEncodingPoint: return [NSValue valueWithCGPoint:((NSPoint (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingSize: return [NSValue valueWithCGSize:((NSSize (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingRect: return [NSValue valueWithCGRect:((NSRect (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingEdgeInsets: return [NSValue valueWithUIEdgeInsets:((NSEdgeInsets (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
#else
        case UniTypeEncodingPoint: return [NSValue valueWithPoint:((NSPoint (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingSize: return [NSValue valueWithSize:((NSSize (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingRect: return [NSValue valueWithRect:((NSRect (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingEdgeInsets: return [NSValue valueWithEdgeInsets:((NSEdgeInsets (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
#endif
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
        case UniTypeEncodingCGVector: return [NSValue valueWithCGVector:((CGVector (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingCGAffineTransform: return [NSValue valueWithCGAffineTransform:((CGAffineTransform (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingUIOffset: return [NSValue valueWithUIOffset:((UIOffset (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        case UniTypeEncodingNSDirectionalEdgeInsets:
#if TARGET_OS_IOS
            if (@available(iOS 11.0, *)) {
#endif
#if TARGET_OS_TV
                if (@available(tvOS 11.0, *)) {
#endif
#if TARGET_OS_WATCH
                    if (@available(watchOS 4.0, *)) {
#endif
                        return [NSValue valueWithDirectionalEdgeInsets:((NSDirectionalEdgeInsets (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
                    }
            return nil;
#endif
        case UniTypeEncodingBlock:
        case UniTypeEncodingNSString:
        case UniTypeEncodingNSMutableString:
        case UniTypeEncodingNSURL:
        case UniTypeEncodingNSNumber:
        case UniTypeEncodingNSDecimalNumber:
        case UniTypeEncodingNSDate:
        case UniTypeEncodingNSData:
        case UniTypeEncodingNSMutableData:
        case UniTypeEncodingNSArray:
        case UniTypeEncodingNSMutableArray:
        case UniTypeEncodingNSSet:
        case UniTypeEncodingNSMutableSet:
        case UniTypeEncodingNSDictionary:
        case UniTypeEncodingNSMutableDictionary:
        case UniTypeEncodingNSObject: return ((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
        case UniTypeEncodingPointer:
        case UniTypeEncodingStruct:
        case UniTypeEncodingUnion:
        case UniTypeEncodingCString:
        case UniTypeEncodingCArray:
        default: return [target valueForKey:property.name];
    }
}

static __inline__ __attribute__((always_inline)) id uni_get_value_from_dict(NSDictionary *dict,NSArray * key){
    id value=dict;
    for (NSString *k in key) { if(k.length>0) value=value[k]; }
    return value;
}

static __inline__ __attribute__((always_inline)) void uni_bind_stmt_with_obj(__unsafe_unretained id value,  UniColumnType columnType, sqlite3_stmt *stmt, int idx){
    switch (columnType) {
        case UniColumnTypeInteger: sqlite3_bind_int64(stmt, idx, [value longLongValue]); break;
        case UniColumnTypeReal: sqlite3_bind_double(stmt, idx, [value doubleValue]); break;
        case UniColumnTypeText: sqlite3_bind_text(stmt, idx, [[value description] UTF8String], -1, SQLITE_STATIC); break;
        case UniColumnTypeBlob: sqlite3_bind_blob(stmt, idx, [value bytes], (int)[value length], SQLITE_STATIC); break;
        default: NSCAssert(0,@"unsupported db column type"); sqlite3_bind_null(stmt, idx); break;
    }
}

static __inline__ __attribute__((always_inline)) void uni_bind_stmt_with_property(id target,UniProperty *property, sqlite3_stmt *stmt, int idx) {
    if (property.dbTransformer) {
        id value = property.dbTransformer(((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter),YES);
        uni_bind_stmt_with_obj(value, property.columnType, stmt, idx); return;
    }
    switch (property.typeEncoding) {
        case UniTypeEncodingBool: sqlite3_bind_int64(stmt, idx, (long long)((bool (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingInt8: sqlite3_bind_int64(stmt, idx, (long long)((char (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingUInt8: sqlite3_bind_int64(stmt, idx, (long long)((unsigned char (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingInt16: sqlite3_bind_int64(stmt, idx, (long long)((short (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingUInt16: sqlite3_bind_int64(stmt, idx, (long long)((UInt16 (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingInt32: sqlite3_bind_int64(stmt, idx, (long long)((int (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingUInt32: sqlite3_bind_int64(stmt, idx, (long long)((UInt32 (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingInt64: sqlite3_bind_int64(stmt, idx, ((long long (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingUInt64: {
            unsigned long long v = ((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            long long dst;
            memcpy(&dst, &v, sizeof(long long));
            sqlite3_bind_int64(stmt, idx, dst);
        } break;
        case UniTypeEncodingFloat: sqlite3_bind_double(stmt, idx, (double)((float (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingDouble: sqlite3_bind_double(stmt, idx, ((double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingLongDouble: sqlite3_bind_double(stmt, idx, ((double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingClass: sqlite3_bind_text(stmt, idx, NSStringFromClass(((Class (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingSEL: sqlite3_bind_text(stmt, idx, NSStringFromSelector(((SEL (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingNSRange: sqlite3_bind_text(stmt, idx,NSStringFromRange(((NSRange (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
#if TARGET_OS_IOS || TARGET_OS_TV
        case UniTypeEncodingCATansform3D: sqlite3_bind_text(stmt, idx,uni_NSStringFromCATransform3D(((CATransform3D (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
#endif
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
        case UniTypeEncodingPoint: sqlite3_bind_text(stmt, idx,NSStringFromCGPoint(((NSPoint (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingSize: sqlite3_bind_text(stmt, idx,NSStringFromCGSize(((NSSize (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC);break;
        case UniTypeEncodingRect: sqlite3_bind_text(stmt, idx,NSStringFromCGRect(((NSRect (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingEdgeInsets: sqlite3_bind_text(stmt, idx,NSStringFromUIEdgeInsets(((NSEdgeInsets (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;

#else
        case UniTypeEncodingPoint: sqlite3_bind_text(stmt, idx,NSStringFromPoint(((NSPoint (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingSize: sqlite3_bind_text(stmt, idx,NSStringFromSize(((NSSize (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingRect: sqlite3_bind_text(stmt, idx,NSStringFromRect(((NSRect (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingEdgeInsets: sqlite3_bind_text(stmt, idx,uni_NSStringFromNSEdgeInsets(((NSEdgeInsets (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
#endif
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
        case UniTypeEncodingCGVector: sqlite3_bind_text(stmt, idx,NSStringFromCGVector(((CGVector (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingCGAffineTransform: sqlite3_bind_text(stmt, idx,NSStringFromCGAffineTransform(((CGAffineTransform (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingUIOffset: sqlite3_bind_text(stmt, idx,NSStringFromUIOffset(((UIOffset (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC); break;
        case UniTypeEncodingNSDirectionalEdgeInsets:
#if TARGET_OS_IOS
            if (@available(iOS 11.0, *)) {
#endif
#if TARGET_OS_TV
                if (@available(tvOS 11.0, *)) {
#endif
#if TARGET_OS_WATCH
                    if (@available(watchOS 4.0, *)) {
#endif
                        sqlite3_bind_text(stmt, idx,NSStringFromDirectionalEdgeInsets(((NSDirectionalEdgeInsets (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)).UTF8String, -1, SQLITE_STATIC);
                    }
            break;
#endif
        case UniTypeEncodingNSString:
        case UniTypeEncodingNSMutableString: {
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSString.class]) sqlite3_bind_text(stmt, idx, [value UTF8String], -1, SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        }break;
        case UniTypeEncodingNSURL: {
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSURL.class]) sqlite3_bind_text(stmt, idx, [[value absoluteString] UTF8String], -1, SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        }break;
        case UniTypeEncodingNSNumber:{
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSNumber.class]) sqlite3_bind_text(stmt, idx, [[UNI_NumberFormatter() stringFromNumber:value] UTF8String], -1, SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        } break;
        case UniTypeEncodingNSDecimalNumber:{
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSDecimalNumber.class]) sqlite3_bind_text(stmt, idx,[[(NSDecimalNumber*)value stringValue] UTF8String], -1, SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        } break;
        case UniTypeEncodingNSDate:{
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSDate.class]) sqlite3_bind_double(stmt, idx, [value timeIntervalSince1970]);
            else sqlite3_bind_null(stmt, idx);
        } break;
        case UniTypeEncodingNSData:
        case UniTypeEncodingNSMutableData:{
            NSData *value = ((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSData.class])sqlite3_bind_blob(stmt, idx, [value bytes], (int)[value length], SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        } break;
        case UniTypeEncodingNSObject:{
            UniClass *clz=[UniClass classWithClass:property.cls];
            if (clz.isConformingToUniDB) {
                id value=uni_get_value(target, property);
                if (value) uni_bind_stmt_with_obj(uni_get_value(value,clz.primaryProperty), property.columnType, stmt, idx);
            }else NSCAssert(0,@"property %@ should conform to UniDB",property.name);
        } break;
        default: NSCAssert(0,@"unsupported encoding type for property %@",property.name); sqlite3_bind_null(stmt, idx); break;
    }
}

static __inline__ __attribute__((always_inline)) id forward_transform_primary_value(id value,UniTransformer transformer,UniProperty * property){
    //value class maybe NSString NSNumber
    if (transformer) return transformer(value,NO);
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
        case UniTypeEncodingFloat:
        case UniTypeEncodingDouble:
        case UniTypeEncodingLongDouble:
            if([value isKindOfClass:NSNumber.class]) return value;
            else if([value isKindOfClass:NSString.class]) return [UNI_NumberFormatter() numberFromString:value];
            break;
        case UniTypeEncodingClass:
            if([value isKindOfClass:NSString.class]) return NSClassFromString(value);
            else {
                Class cls=object_getClass(value);
                if(cls&&class_isMetaClass(cls)) return cls;
            }
            break;
        case UniTypeEncodingSEL:
            if([value isKindOfClass:NSString.class]) return value;
            break;
        case UniTypeEncodingNSString:
        case UniTypeEncodingNSMutableString:
                    if([value isKindOfClass:NSString.class]) return value;
                    else if([value isKindOfClass:NSNumber.class]) return [UNI_NumberFormatter() stringFromNumber:value];
                    break;
        case UniTypeEncodingNSURL:if([value isKindOfClass:NSString.class]) return [NSURL URLWithString:value];break;
        default:break;
    }
    NSCAssert(0,@"forward trasform fail.property name: %@,value class: %@",property.name,[value class]);
    return nil;
}
            
static __inline__ __attribute__((always_inline)) void uni_merge_from_obj(id target,id source,UniClass *cls){
    for (UniProperty *property in cls.propertyArr){
        switch (property.typeEncoding) {
            case UniTypeEncodingBool: ((void (*)(id, SEL,bool))(void *) objc_msgSend)(target, property.setter,((bool (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingInt8: ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,((int8_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUInt8: ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,((uint8_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingInt16: ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,((int16_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUInt16: ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,((uint16_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingInt32: ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,((int32_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUInt32: ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,((uint32_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingInt64: ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,((int64_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUInt64: ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,((uint64_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingFloat: ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,((float (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingDouble: ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,((double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingLongDouble: ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,((long double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingNSRange:((void (*)(id, SEL,NSRange))(void *) objc_msgSend)(target, property.setter,((NSRange (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
#if TARGET_OS_IOS || TARGET_OS_TV
            case UniTypeEncodingCATansform3D:
                ((void (*)(id, SEL,CATransform3D))(void *) objc_msgSend)(target, property.setter,((CATransform3D (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));break;
#endif
            case UniTypeEncodingPoint:((void (*)(id, SEL,NSPoint))(void *) objc_msgSend)(target, property.setter,((NSPoint (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingSize:((void (*)(id, SEL,NSSize))(void *) objc_msgSend)(target, property.setter,((NSSize (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingRect:((void (*)(id, SEL,NSRect))(void *) objc_msgSend)(target, property.setter,((NSRect (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingEdgeInsets:((void (*)(id, SEL,NSEdgeInsets))(void *) objc_msgSend)(target, property.setter,((NSEdgeInsets (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
#if TARGET_OS_IOS || TARGET_OS_TV ||TARGET_OS_WATCH
            case UniTypeEncodingCGVector: ((void (*)(id, SEL,CGVector))(void *) objc_msgSend)(target, property.setter,((CGVector (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingCGAffineTransform: ((void (*)(id, SEL,CGAffineTransform))(void *) objc_msgSend)(target, property.setter,((CGAffineTransform (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUIOffset: ((void (*)(id, SEL,UIOffset))(void *) objc_msgSend)(target, property.setter,((UIOffset (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingNSDirectionalEdgeInsets:
#if TARGET_OS_IOS
                if (@available(iOS 11.0, *)) {
#endif
#if TARGET_OS_TV
                    if (@available(tvOS 11.0, *)) {
#endif
#if TARGET_OS_WATCH
                        if (@available(watchOS 4.0, *)) {
#endif
                            ((void (*)(id, SEL,NSDirectionalEdgeInsets))(void *) objc_msgSend)(target, property.setter,((NSDirectionalEdgeInsets (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
                        }
                break;
#endif
            case UniTypeEncodingClass: ((void (*)(id, SEL,Class))(void *) objc_msgSend)(target, property.setter,((Class (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingSEL: ((void (*)(id, SEL,SEL))(void *) objc_msgSend)(target, property.setter,((SEL (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingBlock:
            case UniTypeEncodingNSString:
            case UniTypeEncodingNSMutableString:
            case UniTypeEncodingNSURL:
            case UniTypeEncodingNSNumber:
            case UniTypeEncodingNSDecimalNumber:
            case UniTypeEncodingNSDate:
            case UniTypeEncodingNSData:
            case UniTypeEncodingNSMutableData:
            case UniTypeEncodingNSArray:
            case UniTypeEncodingNSMutableArray:
            case UniTypeEncodingNSSet:
            case UniTypeEncodingNSMutableSet:
            case UniTypeEncodingNSDictionary:
            case UniTypeEncodingNSMutableDictionary:
                ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingNSObject: {
                id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
                if ([property.cls conformsToProtocol:@protocol(UniMM)]||[property.cls conformsToProtocol:@protocol(UniDB)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    value=((id (*)(id, SEL,id))(void *) objc_msgSend)(value,@selector(_uni_update:),[UniClass classWithClass:property.cls]);
#pragma clang diagnostic pop
                }
                ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            } break;
            default: [target setValue:[source valueForKey:property.name] forKey:property.name]; break;
        }
    }
}

static __inline__ __attribute__((always_inline)) void uni_merge_from_stmt(id target,sqlite3_stmt *stmt,UniClass *cls){
    int count = sqlite3_data_count(stmt);
    for (int i=0;i<count;i++){
        NSString *name = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
        UniProperty *property=cls.propertyDic[name];
        if (![cls.dbPropertyArr containsObject:property]) continue;
        int type = sqlite3_column_type(stmt, i);
        if (property) {
            if (property.dbTransformer) {
                id value = nil;
                switch (type) {
                    case SQLITE_INTEGER: value=@(sqlite3_column_int64(stmt, i)); break;
                    case SQLITE_FLOAT: value=@(sqlite3_column_double(stmt, i)); break;
                    case SQLITE_TEXT: value = [[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]; break;
                    case SQLITE_BLOB:{
                        int bytes = sqlite3_column_bytes(stmt, i);
                        value = [NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:bytes];
                    } break;
                    default: break;
                }
                value = property.dbTransformer(value,NO);
                uni_set_value(target, property, value);
                return;
            }
            switch (property.typeEncoding) {
                case UniTypeEncodingBool:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,bool))(void *) objc_msgSend)(target, property.setter,sqlite3_column_int64(stmt, i)>0?true:false); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingInt8:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,(int8_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingUInt8:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,(uint8_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingInt16:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,(int16_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingUInt16:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,(uint16_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingInt32:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,(int32_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingUInt32:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,(uint32_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingInt64:
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    } break;
                case UniTypeEncodingUInt64:
                    switch (type) {
                        case SQLITE_INTEGER: {
                            int64_t v=sqlite3_column_int64(stmt, i);
                            uint64_t dst;
                            memcpy(&dst, &v, sizeof(uint64_t));
                            ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,dst);
                        }break;
                        default: break;
                    }  break;
                case UniTypeEncodingFloat:
                    switch (type) {
                        case SQLITE_FLOAT: ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,(float)sqlite3_column_double(stmt, i)); break;
                        default: break;
                    } break;
                case UniTypeEncodingDouble:
                    switch (type) {
                        case SQLITE_FLOAT: ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,sqlite3_column_double(stmt, i));
                            break;
                        default: break;
                    } break;
                case UniTypeEncodingLongDouble:
                    switch (type) {
                        case SQLITE_FLOAT: ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,(long double)sqlite3_column_double(stmt, i)); break;
                        default:break;
                    } break;
                case UniTypeEncodingClass:
                    switch (type) {
                        case SQLITE_TEXT:((void (*)(id, SEL,Class))(void *) objc_msgSend)(target, property.setter,NSClassFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
                        default: break;
                    }break;
                case UniTypeEncodingSEL:
                    switch (type) {
                        case SQLITE_TEXT:((void (*)(id, SEL,SEL))(void *) objc_msgSend)(target, property.setter,NSSelectorFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
                        default: break;
                    }break;
                case UniTypeEncodingNSRange:
                    switch (type) {
                        case SQLITE_TEXT:((void (*)(id, SEL,NSRange))(void *) objc_msgSend)(target, property.setter,NSRangeFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
                        default: break;
                    }break;
#if TARGET_OS_IOS || TARGET_OS_TV
                case UniTypeEncodingCATansform3D:
                    switch (type) {
                        case SQLITE_TEXT:((void (*)(id, SEL,CATransform3D))(void *) objc_msgSend)(target, property.setter,uni_CATransform3DFromNSString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
                        default: break;
                    }break;
#endif
                case UniTypeEncodingPoint:
                    switch (type) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
                        case SQLITE_TEXT:((void (*)(id, SEL,NSPoint))(void *) objc_msgSend)(target, property.setter,CGPointFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
#else
                        case SQLITE_TEXT:((void (*)(id, SEL,NSPoint))(void *) objc_msgSend)(target, property.setter,NSPointFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
#endif
                        default: break;
                    }break;
                case UniTypeEncodingSize:
                    switch (type) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
                        case SQLITE_TEXT:((void (*)(id, SEL,NSSize))(void *) objc_msgSend)(target, property.setter,CGSizeFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
#else
                        case SQLITE_TEXT:((void (*)(id, SEL,NSSize))(void *) objc_msgSend)(target, property.setter,NSSizeFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
#endif
                        default: break;
                    }break;
                case UniTypeEncodingRect:
                    switch (type) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
                        case SQLITE_TEXT:((void (*)(id, SEL,NSRect))(void *) objc_msgSend)(target, property.setter,CGRectFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
#else
                        case SQLITE_TEXT:((void (*)(id, SEL,NSRect))(void *) objc_msgSend)(target, property.setter,NSRectFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
#endif
                        default: break;
                    }break;
                case UniTypeEncodingEdgeInsets:
                    switch (type) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
                        case SQLITE_TEXT:((void (*)(id, SEL,NSEdgeInsets))(void *) objc_msgSend)(target, property.setter,UIEdgeInsetsFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
#else
                        case SQLITE_TEXT:((void (*)(id, SEL,NSEdgeInsets))(void *) objc_msgSend)(target, property.setter,uni_NSEdgeInsetsFromNSString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
#endif
                        default: break;
                    }break;
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
                case UniTypeEncodingCGVector:
                    switch (type) {
                        case SQLITE_TEXT:((void (*)(id, SEL,CGVector))(void *) objc_msgSend)(target, property.setter,CGVectorFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
                        default:break;
                    }break;
                case UniTypeEncodingCGAffineTransform:
                    switch (type) {
                        case SQLITE_TEXT:((void (*)(id, SEL,CGAffineTransform))(void *) objc_msgSend)(target, property.setter,CGAffineTransformFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
                        default:break;
                    }break;
                case UniTypeEncodingUIOffset:
                    switch (type) {
                        case SQLITE_TEXT:((void (*)(id, SEL,UIOffset))(void *) objc_msgSend)(target, property.setter,UIOffsetFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));break;
                        default:break;
                    }break;
                case UniTypeEncodingNSDirectionalEdgeInsets:
                    switch (type) {
                        case SQLITE_TEXT:
#if TARGET_OS_IOS
                            if (@available(iOS 11.0, *)) {
#endif
#if TARGET_OS_TV
                                if (@available(tvOS 11.0, *)) {
#endif
#if TARGET_OS_WATCH
                                    if (@available(watchOS 4.0, *)) {
#endif
                                        ((void (*)(id, SEL,NSDirectionalEdgeInsets))(void *) objc_msgSend)(target, property.setter,NSDirectionalEdgeInsetsFromString([[NSString alloc]initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]));
                                    }
                            break;
                        default:break;
                    }break;
#endif
                case UniTypeEncodingNSString:
                case UniTypeEncodingNSMutableString:
                    switch (type) {
                        case SQLITE_TEXT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[property.cls alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSURL:
                    switch (type) {
                        case SQLITE_TEXT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[property.cls alloc]initWithString:[[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSNumber:
                    switch (type) {
                        case SQLITE_TEXT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[UNI_NumberFormatter()  numberFromString:[[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSDecimalNumber:
                    switch (type) {
                        case SQLITE_TEXT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[NSDecimalNumber decimalNumberWithString:[[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSDate:
                    switch (type) {
                        case SQLITE_FLOAT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[property.cls alloc]initWithTimeIntervalSince1970:sqlite3_column_double(stmt, i)]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSData:
                case UniTypeEncodingNSMutableData:
                    switch (type) {
                        case SQLITE_BLOB:{
                            int length = sqlite3_column_bytes(stmt, i);
                            ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[property.cls alloc]initWithBytes:sqlite3_column_blob(stmt, i) length:length]);
                            ;
                        } break;
                        default: break;
                    } break;
                case UniTypeEncodingNSObject:{
                    id value =nil;
                    switch (type) {
                        case SQLITE_INTEGER: value=@(sqlite3_column_int64(stmt, i)); break;
                        case SQLITE_FLOAT: value=@(sqlite3_column_double(stmt, i)); break;
                        case SQLITE_TEXT: value = [[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]; break;
                        case SQLITE_BLOB: {
                            int bytes = sqlite3_column_bytes(stmt, i);
                            value = [NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:bytes];
                        }break;
                        default: break;
                    }
                    if (!value) break;
                    UniClass *clz = [UniClass classWithClass:property.cls];
                    __block id obj;
                    if (clz.isConformingToUniMM) obj=[clz.mm objectForKey:value];
                    if (obj) { ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,obj); break; }
                    if (!clz.isConformingToUniDB) {
                        NSCAssert(0,@"class %@ should conform to UniDB",clz.name);
                        break;
                    }
                    NSError *err;
                    if(![clz.db executeQuery:clz.dbSelectSql stmtBlock:^(sqlite3_stmt *s, int idx) {
                        switch (property.columnType) {
                            case UniColumnTypeInteger: sqlite3_bind_int64(s, idx, [value longLongValue]); break;
                            case UniColumnTypeReal: sqlite3_bind_double(s, idx, [value doubleValue]); break;
                            case UniColumnTypeText: sqlite3_bind_text(s, idx, (const char *)sqlite3_column_text(stmt, i), -1, SQLITE_STATIC); break;
                            case UniColumnTypeBlob: sqlite3_bind_blob(s, idx, [value bytes], (int)[value length], SQLITE_STATIC); break;
                            default: NSCAssert(0,@"unspported db column type in property %@",property.name); break;
                        }
                    } resultBlock:^(sqlite3_stmt *stmt, bool *stop) {
                        obj = [[clz.cls alloc]init];
                        uni_merge_from_stmt(obj, stmt, clz);
                        if (clz.isConformingToUniMM) [clz.mm setObject:obj forKey:value];
                    } error:&err]) NSCAssert(0,@"db error %@",err);
                } break;
                default: NSCAssert(0,@"unsupported encoding type in property %@",property.name); break;
            }
        }
    }
}

@implementation NSObject (Uni)

+ (instancetype)uni_parseJson:(id)json{
    if (!json) return nil;
    UniClass *cls=[UniClass classWithClass:self];
    __block id model;
    [cls sync:^{
         model=[self _uni_parseJson:json cls:cls];
    }];
    return model;
}

+ (instancetype)_uni_parseJson:(id)json cls:(UniClass*)cls{
    if (!json) return nil;
    if ([json isKindOfClass:[NSString class]]) return [self _uni_parseJsonString:json cls:cls];
    else if([json isKindOfClass:[NSDictionary class]]) return [self _uni_parseJsonDict:json cls:cls];
    else if([json isKindOfClass:[NSArray class]]) return [self _uni_parseJsonArr:json cls:cls];
    else NSAssert(0,@"unsupported json %@",json);
    return nil;
}

+ (instancetype)_uni_parseJsonString:(NSString*)str cls:(UniClass*)cls{
    id json = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if(!json) return nil;
    if ([json isKindOfClass:[NSDictionary class]]) return [self _uni_parseJsonDict:json cls:cls];
    else if([json isKindOfClass:[NSArray class]]) return [self _uni_parseJsonArr:json cls:cls];
    else NSAssert(0,@"unsupported json %@",json); return nil;
}

+ (instancetype)_uni_parseJsonDict:(NSDictionary*)dict cls:(UniClass*)cls{
    if(!cls.isConformingToUniJSON) { NSAssert(0,@"class %@ should conform to UniJSON",cls.name); return nil; }
    id model;
    id primaryValue;
    NSError *err;
    int count=(int)cls.dbPropertyArr.count;
    if (cls.isConformingToUniMM) {
        for (NSArray *keyPath in cls.primaryProperty.jsonKeyPathArr){
            primaryValue=uni_get_value_from_dict(dict, keyPath);
            if (primaryValue) break;
        }
        model = [self _uni_queryOne:primaryValue cls:cls];
        if (model) {
            [model _uni_mergeWithJsonDict:dict cls:cls];
            if(cls.isConformingToUniDB){
                if(![cls.db executeUpdate:cls.dbUpdateSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                    if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                    else if (idx == count+2) uni_bind_stmt_with_property(model, cls.primaryProperty, stmt, idx);
                    else uni_bind_stmt_with_property(model, cls.dbPropertyArr[idx-1], stmt, idx);
                } error:&err]) {
                    if (![cls.db executeUpdate:cls.dbInsertSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                        if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                        else uni_bind_stmt_with_property(model, cls.dbPropertyArr[idx-1], stmt, idx);
                    } error:&err]){ NSAssert(0,@"db error %@",err); return nil; }
                }
            }
        }else{
            model=[[self alloc]init];
            [model _uni_mergeWithJsonDict:dict cls:cls];
            [cls.mm setObject:model forKey:primaryValue];
            if(cls.isConformingToUniDB){
                if (![cls.db executeUpdate:cls.dbInsertSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                    if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                    else uni_bind_stmt_with_property(model, cls.dbPropertyArr[idx-1], stmt, idx);
                } error:&err]) {
                    if(![cls.db executeUpdate:cls.dbUpdateSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                        if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                        else if (idx == count+2) uni_bind_stmt_with_property(model, cls.primaryProperty, stmt, idx);
                        else uni_bind_stmt_with_property(model, cls.dbPropertyArr[idx-1], stmt, idx);
                    } error:&err]){ NSAssert(0,@"db error %@",err); return nil; }
                }
            }
        }
    }else{
        model=[[self alloc]init];
        [model _uni_mergeWithJsonDict:dict cls:cls];
        if(cls.isConformingToUniDB){
            if (![cls.db executeUpdate:cls.dbInsertSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                else uni_bind_stmt_with_property(model, cls.dbPropertyArr[idx-1], stmt, idx);
            } error:&err]) {
                if(![cls.db executeUpdate:cls.dbUpdateSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                    if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                    else if (idx == count+2) uni_bind_stmt_with_property(model, cls.primaryProperty, stmt, idx);
                    else uni_bind_stmt_with_property(model, cls.dbPropertyArr[idx-1], stmt, idx);
                } error:&err]){ NSAssert(0,@"db error %@",err); return nil; }
            }
        }
    }
    return model;
}

+ (id)_uni_parseJsonArr:(NSArray*)arr cls:(UniClass*)cls{
    NSMutableArray *models=[NSMutableArray array];
    for (NSDictionary * dict in arr){
        if (![dict isKindOfClass:[NSDictionary class]]) continue;
        id model = [self _uni_parseJsonDict:dict cls:cls];
        if (model) [models addObject:model];
    }
    return models;
}

- (void)_uni_mergeWithJsonDict:(NSDictionary *)dict cls:(UniClass *)cls {
    for (UniProperty *property in cls.jsonPropertyArr){
        id value;
        for (NSArray *keyPath in property.jsonKeyPathArr){
            value=uni_get_value_from_dict(dict, keyPath);
            if (value) break;
        }
        if (property.jsonTransformer) value=property.jsonTransformer(value,NO);
        else if ((property.typeEncoding)==UniTypeEncodingNSObject) {
            UniClass *clz=[UniClass classWithClass:property.cls];
            if (clz.isConformingToUniJSON) value=[property.cls _uni_parseJson:value cls:clz];
            else { NSAssert(0,@"property %@ 's class should conform to UniJSON",property.name); value=nil ;}
        }
        if (value) uni_set_value(self, property, value);
    }
}

+ (id)_uni_queryOne:(id)primary cls:(UniClass*)cls{
    if (!cls.isConformingToUniMM) { NSAssert(0,@"class %@ should conform to UniMM",cls.name); return nil; }
    __block id model = [cls.mm objectForKey:primary];
    if (model) return model;
    if (!cls.isConformingToUniDB) return nil;
    NSError *err;
    if(![cls.db executeQuery:cls.dbSelectSql stmtBlock:^(sqlite3_stmt *s, int idx) {
        switch (cls.primaryProperty.columnType) {
            case UniColumnTypeInteger: sqlite3_bind_int64(s, idx, [primary longLongValue]); break;
            case UniColumnTypeReal: sqlite3_bind_double(s, idx, [primary doubleValue]); break;
            case UniColumnTypeText:
                if ([primary isKindOfClass:NSString.class]){
                    sqlite3_bind_text(s, idx, [primary UTF8String], -1, SQLITE_STATIC); break;
                }else{
                    sqlite3_bind_text(s, idx, [[NSString stringWithFormat:@"%@",primary] UTF8String], -1, SQLITE_STATIC); break;
                }
            default: NSAssert(0,@"unsupported db column type in primary property: %@, class: %@",cls.primaryProperty.name,cls.name); sqlite3_bind_null(s, idx); break;
        }
    } resultBlock:^(sqlite3_stmt *s, bool *stop) {
        model = [[self alloc]init];
        uni_merge_from_stmt(model, s, cls);
        [cls.mm setObject:model forKey:primary];
    } error:&err]) { NSAssert(0,@"db error %@",err); return nil; }
    return model;
}

+ (id)uni_queryOne:(id)primary{
    __block id model=nil;
    UniClass *cls=[UniClass classWithClass:self];
    [cls sync:^{
        model=[self _uni_queryOne:primary cls:cls];
    }];
    return model;
}

+ (NSArray*)uni_query:(NSString*)sql args:(NSArray*)args{
    UniClass *cls=[UniClass classWithClass:self];
    if (!cls.isConformingToUniDB) { NSAssert(0,@"class %@ should comform to protocol UniDB",cls.name); return nil; }
    sql=sql.length?[NSString stringWithFormat:@"SELECT * FROM %@ %@",cls.name,sql]:[NSString stringWithFormat:@"SELECT * FROM %@",cls.name];
    NSMutableArray *arr=[NSMutableArray array];
    [cls sync:^{
        NSError *err;
        if(![cls.db executeQuery:sql arguments:args resultBlock:^(sqlite3_stmt *s, bool *stop) {
            id model;
            id m = [[self alloc]init];
            uni_merge_from_stmt(m, s, cls);
            if(cls.isConformingToUniMM){
                id primaryValue=forward_transform_primary_value(uni_get_value(m, cls.primaryProperty), nil, cls.primaryProperty);
                if (!primaryValue) { NSAssert(0,@"can not find primary value in model %@",m); return; }
                id model=[cls.mm objectForKey:primaryValue];
                if (!model) { model=m; [cls.mm setObject:model forKey:primaryValue]; }
            }else{
                model=m;
            }
            [arr addObject:model];
        } error:&err]) NSAssert(0,@"db error %@",err);
    }];
    return arr;
}

- (id)_uni_update:(UniClass *)cls{
    id model=self;
    if (cls.isConformingToUniMM){
        id primaryValue=forward_transform_primary_value(uni_get_value(self, cls.primaryProperty), nil, cls.primaryProperty);
        if (!primaryValue) {
            NSAssert(0, @"can not find primary value in model %@",self);
            return model;
        }
        model=[cls.mm objectForKey:primaryValue];
        if (model) {
            if (model!=self) for (UniProperty *property in cls.propertyArr){
                uni_merge_from_obj(model,property,uni_get_value(self, property));
            }
        }else{
            [cls.mm setObject:model forKey:primaryValue];
        }
    }
    if (cls.isConformingToUniDB){
        NSError *err;
        int count=(int)cls.dbPropertyArr.count;
        if (![cls.db executeUpdate:cls.dbInsertSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
            if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
            else uni_bind_stmt_with_property(model, cls.dbPropertyArr[idx-1], stmt, idx);
        } error:nil]) {
            if(![cls.db executeUpdate:cls.dbUpdateSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                else if (idx == count+2) uni_bind_stmt_with_property(model, cls.primaryProperty, stmt, idx);
                else uni_bind_stmt_with_property(model, cls.dbPropertyArr[idx-1], stmt, idx);
            } error:&err]) { NSAssert(0,@"db error %@",err); return self; }
        }
    }
    return model;
}

- (id)uni_update{
    __block id model = self;
    UniClass *cls=[UniClass classWithClass:self.class];
    [cls sync:^{
        model=[self _uni_update:cls];
    }];
    return model;
}

+ (NSArray*)uni_update:(NSArray*)models{
    if (models.count==0) return models;
    NSMutableArray *arr=[NSMutableArray array];
    UniClass *cls=[UniClass classWithClass:self];
    [cls sync:^{
        for (id model in models) [arr addObject:[model _uni_update:cls]];
    }];
    return arr;
}

+ (BOOL)uni_delete:(NSString*)sql args:(NSArray*)args{
    __block BOOL res;
    UniClass *cls=[UniClass classWithClass:self];
    sql=sql.length?[NSString stringWithFormat:@"DELETE FROM %@ %@",cls.name,sql]:[NSString stringWithFormat:@"DELETE FROM %@",cls.name];
    [cls sync:^{
        NSError *error=nil;
        res=[cls.db executeUpdate:sql arguments:args error:&error];
        if (!res) {
            NSLog(@"%@",error);
        }
    }];
    return res;
}
+ (BOOL)uni_deleteBeforeDate:(NSDate *)date{
    __block BOOL res;
    UniClass *cls=[UniClass classWithClass:self];
    [cls sync:^{
        NSError *error=nil;
        res=[cls.db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE uni_update_at<?",cls.name] arguments:@[@([[NSDate date] timeIntervalSince1970])] error:&error];
        if (!res) {
            NSLog(@"%@",error);
        }
    }];
    return res;
}

- (NSString*)uni_jsonString{
    return [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:[self uni_jsonDictionary] options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (NSDictionary*)uni_jsonDictionary{
    UniClass *cls=[UniClass classWithClass:self.class];
    if (!cls.isConformingToUniJSON) return nil;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    for (UniProperty *property in cls.jsonPropertyArr){
        id value=uni_get_value(self, property);
        if (property.jsonTransformer) value=property.jsonTransformer(value,YES);
        else if (property.typeEncoding==UniTypeEncodingNSObject) value=[value uni_jsonDictionary];
        if (!value) continue;
        NSArray *keyPath=property.jsonKeyPathArr[0];
        if (keyPath.count==1) {
            NSString *k=keyPath[0];
            if (k.length>0) dict[k]=value;
            else {
                if([value isKindOfClass:NSDictionary.class]){
                    [value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        dict[key]=obj;
                    }];
                }
            }
        }else{
            for (int i=0;i<[keyPath count]-1;i++){
                id k=keyPath[i];
                NSMutableDictionary *d=dict[k];
                if(!d) d=[NSMutableDictionary dictionary];
                dict[k]=d;
                dict=d;
            }
            dict[[keyPath lastObject]]=value;
        }
    }
    return dict;
}

+ (NSArray*)uni_jsonDictionaryFromModels:(NSArray*)models{
    NSMutableArray *dicts=[NSMutableArray array];
    for (id model in models){
        NSDictionary *dict=[model uni_jsonDictionary];
        if(dict) [dicts addObject:dict];
    }
    return dicts;
}

+ (BOOL)uni_open:(NSString*)file error:(NSError* __autoreleasing *)error{
    __block BOOL suc;
    UniClass *cls=[UniClass classWithClass:self];
    [cls sync:^{
        suc=[cls open:file error:error];
    }];
    return suc;
}

@end
