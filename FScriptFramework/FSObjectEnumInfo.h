//
//  FSObjectEnumInfo.h
//  FScript
//
//  Created by Anthony Dervish on 16/11/2014.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


typedef NSUInteger NSGlyphStorageLayoutOptions;
typedef CGFloat NSStatusItemLength;
typedef NSUInteger NSToolbarItemVisibilityPriority;
typedef CGWindowLevelKey NSWindowLevel;
typedef NSUInteger NSWindowMask;
typedef id NSMergePolicyMarker;
@class NSMutableDictionary;

#define BIMAP_CLASS_METHODS_DECL(_name)                 \
        +(id)objectFor##_name : (NS##_name)mask;        \
        +(NSMutableDictionary*)optionsFor##_name; \
        extern id objectFrom##_name(NS##_name _name);   \
        extern const NSUInteger _name##Mask ;

extern const NSUInteger CellTypeMask;
extern const NSUInteger MergePolicyMarkerMask;

@interface FSObjectEnumInfo : NSObject

BIMAP_CLASS_METHODS_DECL(AlertStyle);
BIMAP_CLASS_METHODS_DECL(AnimationBlockingMode);
BIMAP_CLASS_METHODS_DECL(AnimationCurve);
BIMAP_CLASS_METHODS_DECL(AttributeType);
BIMAP_CLASS_METHODS_DECL(AutoresizingMaskOptions);
BIMAP_CLASS_METHODS_DECL(BackgroundStyle);
BIMAP_CLASS_METHODS_DECL(BackingStoreType);
BIMAP_CLASS_METHODS_DECL(BezelStyle);
BIMAP_CLASS_METHODS_DECL(BitmapFormat);
BIMAP_CLASS_METHODS_DECL(BorderType);
BIMAP_CLASS_METHODS_DECL(BoxType);
BIMAP_CLASS_METHODS_DECL(BrowserColumnResizingType);
BIMAP_CLASS_METHODS_DECL(CellImagePosition);
BIMAP_CLASS_METHODS_DECL(CellStateValue);
BIMAP_CLASS_METHODS_DECL(CellStyleMask);
BIMAP_CLASS_METHODS_DECL(CellType);
BIMAP_CLASS_METHODS_DECL(CharacterCollection);
BIMAP_CLASS_METHODS_DECL(ColorPanelMode);
BIMAP_CLASS_METHODS_DECL(ColorRenderingIntent);
BIMAP_CLASS_METHODS_DECL(ComparisonPredicateModifier);
BIMAP_CLASS_METHODS_DECL(ComparisonPredicateOptions);
BIMAP_CLASS_METHODS_DECL(CompositingOperation);
BIMAP_CLASS_METHODS_DECL(CompoundPredicateType);
BIMAP_CLASS_METHODS_DECL(ControlSize);
BIMAP_CLASS_METHODS_DECL(ControlTint);
BIMAP_CLASS_METHODS_DECL(DatePickerElementFlags);
BIMAP_CLASS_METHODS_DECL(DatePickerMode);
BIMAP_CLASS_METHODS_DECL(DatePickerStyle);
BIMAP_CLASS_METHODS_DECL(DeleteRule);
BIMAP_CLASS_METHODS_DECL(DrawerState);
BIMAP_CLASS_METHODS_DECL(EventButtonMask);
BIMAP_CLASS_METHODS_DECL(EventModifierFlags);
BIMAP_CLASS_METHODS_DECL(EventSubtype);
BIMAP_CLASS_METHODS_DECL(EventType);
BIMAP_CLASS_METHODS_DECL(ExpressionType);
BIMAP_CLASS_METHODS_DECL(FetchRequestResultType);
BIMAP_CLASS_METHODS_DECL(FocusRingType);
BIMAP_CLASS_METHODS_DECL(FontRenderingMode);
BIMAP_CLASS_METHODS_DECL(GlyphStorageLayoutOptions);
BIMAP_CLASS_METHODS_DECL(GradientType);
BIMAP_CLASS_METHODS_DECL(ImageAlignment);
BIMAP_CLASS_METHODS_DECL(ImageCacheMode);
BIMAP_CLASS_METHODS_DECL(ImageFrameStyle);
BIMAP_CLASS_METHODS_DECL(ImageInterpolation);
BIMAP_CLASS_METHODS_DECL(ImageScaling);
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7
BIMAP_CLASS_METHODS_DECL(LayoutAttribute);
#endif
BIMAP_CLASS_METHODS_DECL(LevelIndicatorStyle);
BIMAP_CLASS_METHODS_DECL(LineBreakMode);
BIMAP_CLASS_METHODS_DECL(LineCapStyle);
BIMAP_CLASS_METHODS_DECL(LineJoinStyle);
BIMAP_CLASS_METHODS_DECL(MatrixMode);
BIMAP_CLASS_METHODS_DECL(MergePolicyMarker);
BIMAP_CLASS_METHODS_DECL(EventModifierFlags);
BIMAP_CLASS_METHODS_DECL(PathStyle);
BIMAP_CLASS_METHODS_DECL(PointingDeviceType);
BIMAP_CLASS_METHODS_DECL(PopUpArrowPosition);
BIMAP_CLASS_METHODS_DECL(PredicateOperatorType);
BIMAP_CLASS_METHODS_DECL(ProgressIndicatorStyle);
BIMAP_CLASS_METHODS_DECL(RectEdge);
BIMAP_CLASS_METHODS_DECL(RuleEditorNestingMode);
BIMAP_CLASS_METHODS_DECL(RulerOrientation);
BIMAP_CLASS_METHODS_DECL(ScrollArrowPosition);
BIMAP_CLASS_METHODS_DECL(ScrollerPart);
BIMAP_CLASS_METHODS_DECL(SegmentSwitchTracking);
BIMAP_CLASS_METHODS_DECL(SelectionAffinity);
BIMAP_CLASS_METHODS_DECL(SelectionDirection);
BIMAP_CLASS_METHODS_DECL(SelectionGranularity);
BIMAP_CLASS_METHODS_DECL(SliderType);
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9
BIMAP_CLASS_METHODS_DECL(StackViewGravity);
#endif
BIMAP_CLASS_METHODS_DECL(StatusItemLength);
BIMAP_CLASS_METHODS_DECL(StringEncoding);
BIMAP_CLASS_METHODS_DECL(TIFFCompression);
BIMAP_CLASS_METHODS_DECL(TabState);
BIMAP_CLASS_METHODS_DECL(TabViewType);
BIMAP_CLASS_METHODS_DECL(TableColumnResizingOptions);
BIMAP_CLASS_METHODS_DECL(TableViewColumnAutoresizingStyle);
BIMAP_CLASS_METHODS_DECL(TableViewGridLineStyle);
BIMAP_CLASS_METHODS_DECL(TableViewSelectionHighlightStyle);
BIMAP_CLASS_METHODS_DECL(TextAlignment);
BIMAP_CLASS_METHODS_DECL(TextBlockValueType);
BIMAP_CLASS_METHODS_DECL(TextBlockVerticalAlignment);
BIMAP_CLASS_METHODS_DECL(TextFieldBezelStyle);
BIMAP_CLASS_METHODS_DECL(TextListOptions);
BIMAP_CLASS_METHODS_DECL(TextStorageEditedOptions);
BIMAP_CLASS_METHODS_DECL(TextTabType);
BIMAP_CLASS_METHODS_DECL(TextTableLayoutAlgorithm);
BIMAP_CLASS_METHODS_DECL(TitlePosition);
BIMAP_CLASS_METHODS_DECL(TokenStyle);
BIMAP_CLASS_METHODS_DECL(ToolbarDisplayMode);
BIMAP_CLASS_METHODS_DECL(ToolbarItemVisibilityPriority);
BIMAP_CLASS_METHODS_DECL(ToolbarSizeMode);
BIMAP_CLASS_METHODS_DECL(TrackingAreaOptions);
BIMAP_CLASS_METHODS_DECL(TypesetterBehavior);
BIMAP_CLASS_METHODS_DECL(UsableScrollerParts);
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9
BIMAP_CLASS_METHODS_DECL(UserInterfaceLayoutOrientation);
#endif
BIMAP_CLASS_METHODS_DECL(WindingRule);
BIMAP_CLASS_METHODS_DECL(WindowBackingLocation);
BIMAP_CLASS_METHODS_DECL(WindowCollectionBehavior);
BIMAP_CLASS_METHODS_DECL(WindowLevel);
BIMAP_CLASS_METHODS_DECL(WindowMask);
BIMAP_CLASS_METHODS_DECL(WindowSharingType);
BIMAP_CLASS_METHODS_DECL(WritingDirection);
id objectFromTickMarkPosition(NSTickMarkPosition tickMarkPosition, BOOL isVertical);

@end

id objectFromOptions(NSUInteger opts, NSMutableDictionary *dict, NSUInteger mask);