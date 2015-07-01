//
//  FSObjectInspectorViewModelItem.h
//  FScript
//
//  Created by Anthony Dervish on 16/11/2014.
//
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, FSInspectorVMValueType) {
  FS_ITEM_HEADER,
  FS_ITEM_ENUM,
  FS_ITEM_OPTIONS,
  FS_ITEM_NUMBER,
  FS_ITEM_SIZE,
  FS_ITEM_RECT,
  FS_ITEM_OBJECT,
  FS_ITEM_POINT,
  FS_ITEM_RANGE,
  FS_ITEM_BOOL,
  FS_ITEM_GROUP,
};

@class FSObjectInspectorViewModelItem;
@class NSMutableDictionary;

typedef id(^FSGetterBlock)(id obj, FSObjectInspectorViewModelItem *item) ;
typedef void(^FSSetterBlock)(id obj, id newValue, FSObjectInspectorViewModelItem *item);


@interface FSObjectInspectorViewModelItem : NSTreeNode
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) id value;
@property (assign,nonatomic) FSInspectorVMValueType valueType;
@property (readonly,nonatomic) NSString *displayValue;
@property (assign,nonatomic) NSMutableDictionary *enumBiDict;
@property (readonly,nonatomic) NSArray *enumNames;
@property (readonly,nonatomic) NSArray *enumValues;
@property (nonatomic) double numValue;
@property (nonatomic,copy) FSGetterBlock getter;
@property (nonatomic,copy) FSSetterBlock setter;
@property (nonatomic) NSUInteger optsMask;
@property (nonatomic) NSInteger minValue;
@property (nonatomic) NSInteger maxValue;
@property (nonatomic) Class valueClass;
@property (nonatomic) CGFloat float1;
@property (nonatomic) CGFloat float2;
@property (nonatomic) CGFloat float3;
@property (nonatomic) CGFloat float4;
@end
