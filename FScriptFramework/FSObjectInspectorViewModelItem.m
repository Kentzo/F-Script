//
//  FSObjectInspectorViewModelItem.m
//  FScript
//
//  Created by Anthony Dervish on 16/11/2014.
//
//

#import "FSObjectInspectorViewModelItem.h"
#import "FSBoolean.h"
#import "FSNamedNumber.h"
#import "FSNumber.h"
#import "FSObjectEnumInfo.h"

static void *FLOAT_CHANGED_CTX = &FLOAT_CHANGED_CTX;

@interface FSNamedInteger : NSObject
@property NSInteger integer;
@property NSString* name;
@end
@implementation FSNamedInteger

+ (instancetype)integer:(NSInteger)num withName:(NSString*)name
{
        FSNamedInteger* n = [self new];
        n.integer = num;
        n.name = name.copy;
        return n;
}
@end

static NSArray *sBOOLEnum = nil;
@implementation FSObjectInspectorViewModelItem

+(void)initialize
{
        if (self == FSObjectInspectorViewModelItem.class) {
                sBOOLEnum = @[[FSNamedInteger integer:NO withName:@"NO"],
                              [FSNamedInteger integer:YES withName:@"YES"]];
        }
}

-(id)representedObject
{
        return [super representedObject] ?: self.value;
}

- (instancetype)initWithRepresentedObject:(id)modelObject
{
        self = [super initWithRepresentedObject:modelObject];
        if (self) {
                self.minValue = NSIntegerMin;
                self.maxValue = NSIntegerMax;
                [self addObserver:self
                       forKeyPath:@"float1"
                          options:nil
                          context:&FLOAT_CHANGED_CTX
                 ];
                [self addObserver:self
                       forKeyPath:@"float2"
                          options:nil
                          context:&FLOAT_CHANGED_CTX
                 ];
                [self addObserver:self
                       forKeyPath:@"float3"
                          options:nil
                          context:&FLOAT_CHANGED_CTX
                 ];
                [self addObserver:self
                       forKeyPath:@"float4"
                          options:nil
                          context:&FLOAT_CHANGED_CTX
                 ];
        }
        return self;
}


- (void)dealloc
{
        [self removeObserver:self forKeyPath:@"float1"];
        [self removeObserver:self forKeyPath:@"float2"];
        [self removeObserver:self forKeyPath:@"float3"];
        [self removeObserver:self forKeyPath:@"float4"];
}

-(void)setValue:(id)value
{
        _value = value;
        NSValue *val = value;
        switch (self.valueType) {
                case FS_ITEM_SIZE: {
                        NSSize sz = val.sizeValue;
                        _float1 = sz.width;
                        _float2 = sz.height;
                }
                        break;
                case FS_ITEM_RECT: {
                        NSRect rect = val.rectValue;
                        _float1 = rect.origin.x;
                        _float2 = rect.origin.y;
                        _float3 = rect.size.width;
                        _float4 = rect.size.height;
                }
                        break;
                case FS_ITEM_POINT: {
                        NSPoint point = val.pointValue;
                        _float1 = point.x;
                        _float2 = point.y;
                }
                        break;
                case FS_ITEM_RANGE: {
                        NSRange rng = val.rangeValue;
                        _float1 = rng.location;
                        _float2 = rng.length;
                        
                }
                        break;
                default:
                        break;
        }
        
}

- (NSString*)displayValue
{
        switch (self.valueType) {
        case FS_ITEM_HEADER:
                return self.name;
                break;
        case FS_ITEM_ENUM:
                return [self.value description];
                break;
        case FS_ITEM_OPTIONS:
                return [self.value description];
                break;
        case FS_ITEM_NUMBER:
                return [self.value description];
                break;
        case FS_ITEM_SIZE:
                return NSStringFromSize([(NSValue*)self.value sizeValue]);
                break;
        case FS_ITEM_RECT:
                return NSStringFromRect([(NSValue*)self.value rectValue]);
                break;
        case FS_ITEM_OBJECT:
                return [[self.value description] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                break;
        case FS_ITEM_POINT:
                return NSStringFromPoint([(NSValue*)self.value pointValue]);
                break;
        case FS_ITEM_RANGE:
                return NSStringFromRange([(NSValue*)self.value rangeValue]);
                break;
        case FS_ITEM_BOOL:
                return [self.value description];
                break;
        default:
                break;
        }
        return @"";
}

- (NSArray*)enumObjects
{
        NSArray* objs = nil;
        if (self.valueType == FS_ITEM_ENUM) {
                NSMutableArray *enumObjs = [NSMutableArray new];
                for (NSNumber* num in self.enumBiDict.allKeys) {
                        [enumObjs addObject:[FSNamedInteger integer:num.integerValue withName:self.enumBiDict[num]]];
                }
                objs = enumObjs;
        }
        else if (self.valueType == FS_ITEM_BOOL) {
                objs = sBOOLEnum;
        }
        return objs;
}


- (double)numValue
{
        return [self.value doubleValue];
}

- (void)setNumValue:(double)value
{
        switch (self.valueType) {
                case FS_ITEM_ENUM:
                        self.value = [FSNamedNumber namedNumberWithDouble:value name:self.enumBiDict[@(value)]] ?: [FSNumber numberWithDouble:value];
                        break;
                case FS_ITEM_OPTIONS:
                        self.value = objectFromOptions(value, self.enumBiDict, self.optsMask);
                        break;
                case FS_ITEM_NUMBER:
                        self.value = [FSNumber numberWithDouble:value];
                        break;
                case FS_ITEM_BOOL:
                        self.value = [FSBoolean booleanWithBool:value];
                        break;
                default:
                        break;
        }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
        if (context == FLOAT_CHANGED_CTX) {
                [self refreshValue];
        }
}

// A 'floatX' has changed: update our aggregate value
-(void)refreshValue
{
        [self willChangeValueForKey:@"value"];
        switch (self.valueType) {
                case FS_ITEM_SIZE:
                        _value = [NSValue valueWithSize:NSMakeSize(self.float1, self.float2)];
                        break;
                case FS_ITEM_RECT:
                        _value = [NSValue valueWithRect:NSMakeRect(self.float1, self.float2, self.float3, self.float4)];
                        break;
                case FS_ITEM_POINT:
                        _value = [NSValue valueWithPoint:NSMakePoint(self.float1, self.float2)];
                        break;
                case FS_ITEM_RANGE:
                        _value = [NSValue valueWithRange:NSMakeRange(self.float1, self.float2)];
                        break;
                default:
                        break;
        }
        [self didChangeValueForKey:@"value"];
        
}

+ (NSSet*)keyPathsForValuesAffectingDisplayValue
{
        return [NSSet setWithObject:@"value"];
}

@end
