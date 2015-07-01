//
//  FSObjectEnumInfo.m
//  FScript
//
//  Created by Anthony Dervish on 16/11/2014.
//
//

#import "FSObjectEnumInfo.h"
#import "FSNamedNumber.h"
#import "FSNumber.h"
#import "FSObjectBrowserNamedObjectWrapper.h"

#import "metamacros.h"

const NSUInteger CellTypeMask = NSUIntegerMax;
const NSUInteger MergePolicyMarkerMask = NSUIntegerMax;

#define _ENUMDICT(_idx, _enum)              \
        @{ @(_enum) : @metamacro_stringify(_enum) },

#define _BIDICT(_idx, _enum)              \
        @(_enum)                          \
            : @metamacro_stringify(_enum) \
            ,

#define _BIDICT_LEADER(_name)                                   \
        static inline NSMutableDictionary* _name##Bimap() \
        {                                                       \
                static NSMutableDictionary* dict = nil;   \
                if (!dict) {                                    \
                        dict = [NSMutableDictionary new]; \


#define BIDICT(_name, ...)                                            \
        _BIDICT_LEADER(_name)                                         \
                        NSArray * enumItems = @[ metamacro_foreach(_ENUMDICT, ,__VA_ARGS__) ] ; \
                        for (NSDictionary *enumDict in enumItems) { \
                                NSNumber *key = enumDict.allKeys.firstObject; NSString *val = enumDict.allValues.firstObject; \
                                if (dict[key]) { dict[key] = [ NSString stringWithFormat:@"%@ / %@", dict[key], val ]; } else { dict[key] = val; } \
                        } \
                }                                                             \
        return dict;                                                  \
        }

#define BIDICT_LIT(_name, _dict) \
        _BIDICT_LEADER(_name)    \
                [dict addEntriesFromDictionary:_dict ];       \
        }                        \
        return dict;             \
        }

#define _IDENTITY(_idx, _val) _val

#define OPTSMASK(...) \
        metamacro_foreach(_IDENTITY, |, __VA_ARGS__)


#define BIMAP_CLASS_METHODS_DEFN(_name)                                             \
        +(id)objectFor##_name : (NS##_name)mask { return objectFrom##_name(mask); } \
        +(NSMutableDictionary*)optionsFor##_name { return (_name##Bimap()); }

#define _FS_NUMBER_WRAPPER(_name) \
        lookup ? [FSNamedNumber namedNumberWithDouble:(double)value name:lookup] : [FSNumber numberWithDouble:value]
#define _FS_OBJECT_WRAPPER(_name) \
        lookup ? [FSObjectBrowserNamedObjectWrapper namedObjectWrapperWithObject:value name:lookup] : value

#define ENUM_FUNC(_name, _lookup, _boxed_value)                   \
        id objectFrom##_name(NS##_name value)                     \
        {                                                         \
                NSMutableDictionary* dict = _name##Bimap(); \
                id lookup = dict[_boxed_value];                   \
                return _lookup;                                   \
        }

// Define a lookup function 'objectTo<Enumeration>', for simple enumerations (can take one, and only one value from the enum)
#define ENUMTOOBJ(_name, ...)                                 \
        BIDICT(_name, __VA_ARGS__)                            \
        ENUM_FUNC(_name, _FS_NUMBER_WRAPPER(_name), @(value)) \
        BIMAP_CLASS_METHODS_DEFN(_name)

// Define a lookup function 'objectTo<ObjectName>', for 'marker' objects (e.g. NSMergePolicy)
#define OBJTOOBJ_LIT(_name, _dict)                         \
        BIDICT_LIT(_name, _dict)                           \
        ENUM_FUNC(_name, _FS_OBJECT_WRAPPER(_name), value) \
        BIMAP_CLASS_METHODS_DEFN(_name)

// Same as 'ENUMTOOBJ', but use when the elements of the 'enumeration' are actually macros
#define ENUMTOOBJ_DICT(_name, _dict)                          \
        BIDICT_LIT(_name, _dict)                              \
        ENUM_FUNC(_name, _FS_NUMBER_WRAPPER(_name), @(value)) \
        BIMAP_CLASS_METHODS_DEFN(_name)

#define OPTSDICT(_name, ...)                                  \
        const NSUInteger _name##Mask = OPTSMASK(__VA_ARGS__); \
        BIDICT(_name, __VA_ARGS__)

// Define a lookup function 'objectTo<Enumeration>', for flag enumerations (can take a logical OR of enumeration values)
#define OPTSTOOBJ(_name, ...)                                                                                                                                      \
        OPTSDICT(_name, __VA_ARGS__)                                                                                                                               \
        id objectFrom##_name(NS##_name opts)                                                                                                                       \
        {                                                                                                                                                          \
                return objectFromOptions(opts, _name##Bimap(), _name##Mask);                                                                                                  \
        }                                                                                                                                                          \
        BIMAP_CLASS_METHODS_DEFN(_name)

id objectFromOptions(NSUInteger opts, NSMutableDictionary *dict, NSUInteger mask)
{                                                                                                                                                          
        if (mask == 0 || (opts & ~mask)) {
                return [FSNumber numberWithDouble:opts];                                                                                                   
        }                                                                                                                                                  
        NSMutableArray* result = [NSMutableArray array];
        for (NSNumber * opt in dict.allKeys) {                                                                                                             
                if (opts & opt.unsignedIntegerValue) {                                                                                                     
                        [result addObject:dict[opt]];                                                                                                      
                }                                                                                                                                          
        }                                                                                                                                                  
        return result.count ? [FSNamedNumber namedNumberWithDouble:opts name:[result componentsJoinedByString:@" + "]] : [FSNumber numberWithDouble:opts]; 
}

@implementation FSObjectEnumInfo

ENUMTOOBJ(AnimationBlockingMode,
          NSAnimationBlocking,
          NSAnimationNonblocking,
          NSAnimationNonblockingThreaded);


ENUMTOOBJ(AnimationCurve,
          NSAnimationEaseInOut,
          NSAnimationEaseIn,
          NSAnimationEaseOut,
          NSAnimationLinear);


ENUMTOOBJ(AlertStyle,
          NSWarningAlertStyle,
          NSInformationalAlertStyle,
          NSCriticalAlertStyle);


OPTSTOOBJ(AutoresizingMaskOptions,
          NSViewMinXMargin,
          NSViewWidthSizable,
          NSViewMaxXMargin,
          NSViewMinYMargin,
          NSViewHeightSizable,
          NSViewMaxYMargin);

ENUMTOOBJ(AttributeType,
          NSUndefinedAttributeType,
          NSInteger16AttributeType,
          NSInteger32AttributeType,
          NSInteger64AttributeType,
          NSDecimalAttributeType,
          NSDoubleAttributeType,
          NSFloatAttributeType,
          NSStringAttributeType,
          NSBooleanAttributeType,
          NSDateAttributeType,
          NSBinaryDataAttributeType,
          NSTransformableAttributeType);


ENUMTOOBJ(BackgroundStyle,
          NSBackgroundStyleLight,
          NSBackgroundStyleDark,
          NSBackgroundStyleRaised,
          NSBackgroundStyleLowered);


ENUMTOOBJ(BackingStoreType,
          NSBackingStoreBuffered,
          NSBackingStoreRetained,
          NSBackingStoreNonretained);


ENUMTOOBJ(BorderType,
          NSNoBorder,
          NSLineBorder,
          NSBezelBorder,
          NSGrooveBorder);

ENUMTOOBJ(BezelStyle,
          NSRoundedBezelStyle,
          NSRegularSquareBezelStyle,
          NSThickSquareBezelStyle,
          NSThickerSquareBezelStyle,
          NSDisclosureBezelStyle,
          NSShadowlessSquareBezelStyle,
          NSCircularBezelStyle,
          NSTexturedSquareBezelStyle,
          NSHelpButtonBezelStyle,
          NSSmallSquareBezelStyle,
          NSTexturedRoundedBezelStyle);


OPTSTOOBJ(BitmapFormat,
          NSAlphaFirstBitmapFormat,
          NSAlphaNonpremultipliedBitmapFormat,
          NSFloatingPointSamplesBitmapFormat);

ENUMTOOBJ(BoxType,
          NSBoxPrimary,
          NSBoxSecondary,
          NSBoxSeparator,
          NSBoxOldStyle,
          NSBoxCustom);


OPTSTOOBJ(EventButtonMask,
          NSPenTipMask,
          NSPenLowerSideMask,
          NSPenUpperSideMask);


ENUMTOOBJ(BrowserColumnResizingType,
          NSBrowserNoColumnResizing,
          NSBrowserAutoColumnResizing,
          NSBrowserUserColumnResizing);


ENUMTOOBJ(CellImagePosition,
          NSNoImage,
          NSImageOnly,
          NSImageLeft,
          NSImageRight,
          NSImageBelow,
          NSImageAbove,
          NSImageOverlaps);


OPTSTOOBJ(CellStyleMask,
          NSNoCellMask,
          NSContentsCellMask,
          NSPushInCellMask,
          NSChangeGrayCellMask,
          NSChangeBackgroundCellMask);

ENUMTOOBJ(CellStateValue,
          NSMixedState,
          NSOffState,
          NSOnState);


ENUMTOOBJ(CellType,
          NSNullCellType,
          NSTextCellType,
          NSImageCellType);


ENUMTOOBJ(CharacterCollection,
          NSIdentityMappingCharacterCollection,
          NSAdobeCNS1CharacterCollection,
          NSAdobeGB1CharacterCollection,
          NSAdobeJapan1CharacterCollection,
          NSAdobeJapan2CharacterCollection,
          NSAdobeKorea1CharacterCollection);


ENUMTOOBJ(ColorPanelMode,
          NSGrayModeColorPanel,
          NSRGBModeColorPanel,
          NSCMYKModeColorPanel,
          NSHSBModeColorPanel,
          NSCustomPaletteModeColorPanel,
          NSColorListModeColorPanel,
          NSWheelModeColorPanel,
          NSCrayonModeColorPanel);


ENUMTOOBJ(ColorRenderingIntent,
          NSColorRenderingIntentDefault,
          NSColorRenderingIntentAbsoluteColorimetric,
          NSColorRenderingIntentRelativeColorimetric,
          NSColorRenderingIntentPerceptual,
          NSColorRenderingIntentSaturation);


OPTSTOOBJ(ComparisonPredicateOptions,
          NSCaseInsensitivePredicateOption,
          NSDiacriticInsensitivePredicateOption,
          NSNormalizedPredicateOption);

ENUMTOOBJ(ComparisonPredicateModifier,
          NSDirectPredicateModifier,
          NSAllPredicateModifier,
          NSAnyPredicateModifier);


ENUMTOOBJ(CompositingOperation,
          NSCompositeClear,
          NSCompositeCopy,
          NSCompositeSourceOver,
          NSCompositeSourceIn,
          NSCompositeSourceOut,
          NSCompositeSourceAtop,
          NSCompositeDestinationOver,
          NSCompositeDestinationIn,
          NSCompositeDestinationOut,
          NSCompositeDestinationAtop,
          NSCompositeXOR,
          NSCompositePlusDarker,
          NSCompositeHighlight,
          NSCompositePlusLighter);


ENUMTOOBJ(CompoundPredicateType,
          NSNotPredicateType,
          NSAndPredicateType,
          NSOrPredicateType);


ENUMTOOBJ(ControlSize,
          NSRegularControlSize,
          NSSmallControlSize,
          NSMiniControlSize);


ENUMTOOBJ(ControlTint,
          NSDefaultControlTint,
          NSBlueControlTint,
          NSGraphiteControlTint,
          NSClearControlTint);

OPTSTOOBJ(DatePickerElementFlags,
          NSHourMinuteDatePickerElementFlag,
          NSHourMinuteSecondDatePickerElementFlag,
          NSTimeZoneDatePickerElementFlag,
          NSYearMonthDatePickerElementFlag,
          NSYearMonthDayDatePickerElementFlag,
          NSEraDatePickerElementFlag);

ENUMTOOBJ(DatePickerMode,
          NSSingleDateMode,
          NSRangeDateMode);


ENUMTOOBJ(DatePickerStyle,
          NSTextFieldAndStepperDatePickerStyle,
          NSClockAndCalendarDatePickerStyle);


ENUMTOOBJ(DeleteRule,
          NSNoActionDeleteRule,
          NSNullifyDeleteRule,
          NSCascadeDeleteRule,
          NSDenyDeleteRule);


ENUMTOOBJ(DrawerState,
          NSDrawerClosedState,
          NSDrawerOpeningState,
          NSDrawerOpenState,
          NSDrawerClosingState);


ENUMTOOBJ(EventType,
          NSLeftMouseDown,
          NSLeftMouseUp,
          NSRightMouseDown,
          NSRightMouseUp,
          NSOtherMouseDown,
          NSOtherMouseUp,
          NSMouseMoved,
          NSLeftMouseDragged,
          NSRightMouseDragged,
          NSOtherMouseDragged,
          NSMouseEntered,
          NSMouseExited,
          NSCursorUpdate,
          NSKeyDown,
          NSKeyUp,
          NSFlagsChanged,
          NSAppKitDefined,
          NSSystemDefined,
          NSApplicationDefined,
          NSPeriodic,
          NSScrollWheel,
          NSTabletPoint,
          NSTabletProximity);


ENUMTOOBJ(EventSubtype,
          NSMouseEventSubtype,
          NSTabletPointEventSubtype,
          NSTabletProximityEventSubtype);


ENUMTOOBJ(ExpressionType,
          NSConstantValueExpressionType,
          NSEvaluatedObjectExpressionType,
          NSVariableExpressionType,
          NSKeyPathExpressionType,
          NSFunctionExpressionType,
          NSUnionSetExpressionType,
          NSIntersectSetExpressionType,
          NSMinusSetExpressionType,
          NSSubqueryExpressionType,
          NSAggregateExpressionType);


ENUMTOOBJ(FetchRequestResultType,
          NSManagedObjectResultType,
          NSManagedObjectIDResultType);


ENUMTOOBJ(FocusRingType,
          NSFocusRingTypeDefault,
          NSFocusRingTypeNone,
          NSFocusRingTypeExterior);


ENUMTOOBJ(FontRenderingMode,
          NSFontDefaultRenderingMode,
          NSFontAntialiasedRenderingMode,
          NSFontIntegerAdvancementsRenderingMode,
          NSFontAntialiasedIntegerAdvancementsRenderingMode);


ENUMTOOBJ(GradientType,
          NSGradientNone,
          NSGradientConcaveWeak,
          NSGradientConcaveStrong,
          NSGradientConvexWeak,
          NSGradientConvexStrong);


OPTSTOOBJ(TableViewGridLineStyle,
          NSTableViewSolidVerticalGridLineMask,
          NSTableViewSolidHorizontalGridLineMask,
          NSTableViewDashedHorizontalGridLineMask);


ENUMTOOBJ(ImageAlignment,
          NSImageAlignCenter,
          NSImageAlignTop,
          NSImageAlignTopLeft,
          NSImageAlignTopRight,
          NSImageAlignLeft,
          NSImageAlignBottom,
          NSImageAlignBottomLeft,
          NSImageAlignBottomRight,
          NSImageAlignRight);


ENUMTOOBJ(ImageCacheMode,
          NSImageCacheDefault,
          NSImageCacheAlways,
          NSImageCacheBySize,
          NSImageCacheNever);


ENUMTOOBJ(ImageFrameStyle,
          NSImageFrameNone,
          NSImageFramePhoto,
          NSImageFrameGrayBezel,
          NSImageFrameGroove,
          NSImageFrameButton);


ENUMTOOBJ(ImageInterpolation,
          NSImageInterpolationDefault,
          NSImageInterpolationNone,
          NSImageInterpolationLow,
          NSImageInterpolationHigh);


ENUMTOOBJ(ImageScaling,
          NSImageScaleProportionallyDown,
          NSImageScaleAxesIndependently,
          NSImageScaleNone,
          NSImageScaleProportionallyUpOrDown);


OPTSTOOBJ(EventModifierFlags,
          NSAlphaShiftKeyMask,
          NSShiftKeyMask,
          NSControlKeyMask,
          NSAlternateKeyMask,
          NSCommandKeyMask,
          NSNumericPadKeyMask,
          NSHelpKeyMask,
          NSFunctionKeyMask);

OPTSTOOBJ(GlyphStorageLayoutOptions,
          NSShowControlGlyphs,
          NSShowInvisibleGlyphs,
          NSWantsBidiLevels);

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7
ENUMTOOBJ(LayoutAttribute,
          NSLayoutAttributeNotAnAttribute,
          NSLayoutAttributeLeft,
          NSLayoutAttributeRight,
          NSLayoutAttributeTop,
          NSLayoutAttributeBottom,
          NSLayoutAttributeLeading,
          NSLayoutAttributeTrailing,
          NSLayoutAttributeWidth,
          NSLayoutAttributeHeight,
          NSLayoutAttributeCenterX,
          NSLayoutAttributeCenterY,
          NSLayoutAttributeBaseline
          );

#endif

ENUMTOOBJ(LevelIndicatorStyle,
          NSRelevancyLevelIndicatorStyle,
          NSContinuousCapacityLevelIndicatorStyle,
          NSDiscreteCapacityLevelIndicatorStyle,
          NSRatingLevelIndicatorStyle);


ENUMTOOBJ(LineBreakMode,
          NSLineBreakByWordWrapping,
          NSLineBreakByCharWrapping,
          NSLineBreakByClipping,
          NSLineBreakByTruncatingHead,
          NSLineBreakByTruncatingTail,
          NSLineBreakByTruncatingMiddle);


ENUMTOOBJ(LineCapStyle,
          NSButtLineCapStyle,
          NSRoundLineCapStyle,
          NSSquareLineCapStyle);


ENUMTOOBJ(LineJoinStyle,
          NSMiterLineJoinStyle,
          NSRoundLineJoinStyle,
          NSBevelLineJoinStyle);


ENUMTOOBJ(MatrixMode,
          NSRadioModeMatrix,
          NSHighlightModeMatrix,
          NSListModeMatrix,
          NSTrackModeMatrix);


OBJTOOBJ_LIT(MergePolicyMarker, (@{
                                    NSErrorMergePolicy : @"NSErrorMergePolicy",
                                    NSMergeByPropertyStoreTrumpMergePolicy : @"NSMergeByPropertyStoreTrumpMergePolicy",
                                    NSMergeByPropertyObjectTrumpMergePolicy : @"NSMergeByPropertyObjectTrumpMergePolicy",
                                    NSOverwriteMergePolicy : @"NSOverwriteMergePolicy",
                                    NSRollbackMergePolicy : @"NSRollbackMergePolicy"
                                }));

ENUMTOOBJ(RuleEditorNestingMode,
          NSRuleEditorNestingModeSingle,
          NSRuleEditorNestingModeList,
          NSRuleEditorNestingModeCompound,
          NSRuleEditorNestingModeSimple);


ENUMTOOBJ(PathStyle,
          NSPathStyleStandard,
          NSPathStyleNavigationBar,
          NSPathStylePopUp);


ENUMTOOBJ(PointingDeviceType,
          NSUnknownPointingDevice,
          NSPenPointingDevice,
          NSCursorPointingDevice,
          NSEraserPointingDevice);


ENUMTOOBJ(PredicateOperatorType,
          NSLessThanPredicateOperatorType,
          NSLessThanOrEqualToPredicateOperatorType,
          NSGreaterThanPredicateOperatorType,
          NSGreaterThanOrEqualToPredicateOperatorType,
          NSEqualToPredicateOperatorType,
          NSNotEqualToPredicateOperatorType,
          NSMatchesPredicateOperatorType,
          NSLikePredicateOperatorType,
          NSBeginsWithPredicateOperatorType,
          NSEndsWithPredicateOperatorType,
          NSInPredicateOperatorType,
          NSCustomSelectorPredicateOperatorType,
          NSContainsPredicateOperatorType,
          NSBetweenPredicateOperatorType);


ENUMTOOBJ(ProgressIndicatorStyle,
          NSProgressIndicatorBarStyle,
          NSProgressIndicatorSpinningStyle);


ENUMTOOBJ(PopUpArrowPosition,
          NSPopUpNoArrow,
          NSPopUpArrowAtCenter,
          NSPopUpArrowAtBottom);


ENUMTOOBJ_DICT(RectEdge, (@{
                             @(NSMinXEdge) : @"NSMinXEdge",
                             @(NSMinYEdge) : @"NSMinYEdge",
                             @(NSMaxXEdge) : @"NSMaxXEdge",
                             @(NSMaxYEdge) : @"NSMaxYEdge"
                         }));


ENUMTOOBJ(RulerOrientation,
          NSHorizontalRuler,
          NSVerticalRuler);


ENUMTOOBJ(ScrollArrowPosition,
          NSScrollerArrowsDefaultSetting,
          NSScrollerArrowsNone);


ENUMTOOBJ(ScrollerPart,
          NSScrollerNoPart,
          NSScrollerDecrementPage,
          NSScrollerKnob,
          NSScrollerIncrementPage,
          NSScrollerDecrementLine,
          NSScrollerIncrementLine,
          NSScrollerKnobSlot);


ENUMTOOBJ(SegmentSwitchTracking,
          NSSegmentSwitchTrackingSelectOne,
          NSSegmentSwitchTrackingSelectAny,
          NSSegmentSwitchTrackingMomentary);


ENUMTOOBJ(SelectionAffinity,
          NSSelectionAffinityUpstream,
          NSSelectionAffinityDownstream);


ENUMTOOBJ(SelectionDirection,
          NSDirectSelection,
          NSSelectingNext,
          NSSelectingPrevious);


ENUMTOOBJ(SelectionGranularity,
          NSSelectByCharacter,
          NSSelectByWord,
          NSSelectByParagraph);


ENUMTOOBJ(TableViewSelectionHighlightStyle,
          NSTableViewSelectionHighlightStyleRegular,
          NSTableViewSelectionHighlightStyleSourceList);


ENUMTOOBJ(SliderType,
          NSLinearSlider,
          NSCircularSlider);

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9
ENUMTOOBJ(StackViewGravity,
          NSStackViewGravityTop,
          NSStackViewGravityLeading,
          NSStackViewGravityCenter,
          NSStackViewGravityBottom,
          NSStackViewGravityTrailing
          );

#endif

ENUMTOOBJ(StatusItemLength,
          NSVariableStatusItemLength,
          NSSquareStatusItemLength);

ENUMTOOBJ(StringEncoding,
          NSASCIIStringEncoding,
          NSNEXTSTEPStringEncoding,
          NSJapaneseEUCStringEncoding,
          NSUTF8StringEncoding,
          NSISOLatin1StringEncoding,
          NSSymbolStringEncoding,
          NSNonLossyASCIIStringEncoding,
          NSShiftJISStringEncoding,
          NSISOLatin2StringEncoding,
          NSUnicodeStringEncoding,
          NSWindowsCP1251StringEncoding,
          NSWindowsCP1252StringEncoding,
          NSWindowsCP1253StringEncoding,
          NSWindowsCP1254StringEncoding,
          NSWindowsCP1250StringEncoding,
          NSISO2022JPStringEncoding,
          NSMacOSRomanStringEncoding);


OPTSTOOBJ(TableColumnResizingOptions,
          NSTableColumnNoResizing,
          NSTableColumnAutoresizingMask,
          NSTableColumnUserResizingMask);

ENUMTOOBJ(TableViewColumnAutoresizingStyle,
          NSTableViewNoColumnAutoresizing,
          NSTableViewUniformColumnAutoresizingStyle,
          NSTableViewSequentialColumnAutoresizingStyle,
          NSTableViewReverseSequentialColumnAutoresizingStyle,
          NSTableViewLastColumnOnlyAutoresizingStyle,
          NSTableViewFirstColumnOnlyAutoresizingStyle);


ENUMTOOBJ(TabState,
          NSBackgroundTab,
          NSPressedTab,
          NSSelectedTab);


ENUMTOOBJ(TabViewType,
          NSTopTabsBezelBorder,
          NSLeftTabsBezelBorder,
          NSBottomTabsBezelBorder,
          NSRightTabsBezelBorder,
          NSNoTabsBezelBorder,
          NSNoTabsLineBorder,
          NSNoTabsNoBorder);


ENUMTOOBJ(TextAlignment,
          NSLeftTextAlignment,
          NSRightTextAlignment,
          NSCenterTextAlignment,
          NSJustifiedTextAlignment,
          NSNaturalTextAlignment);


ENUMTOOBJ(TextBlockValueType,
          NSTextBlockAbsoluteValueType,
          NSTextBlockPercentageValueType);


ENUMTOOBJ(TextBlockVerticalAlignment,
          NSTextBlockTopAlignment,
          NSTextBlockMiddleAlignment,
          NSTextBlockBottomAlignment,
          NSTextBlockBaselineAlignment);


ENUMTOOBJ(TextFieldBezelStyle,
          NSTextFieldSquareBezel,
          NSTextFieldRoundedBezel);

OPTSTOOBJ(TextListOptions,
          NSTextListPrependEnclosingMarker);


OPTSTOOBJ(TextStorageEditedOptions,
          NSTextStorageEditedAttributes,
          NSTextStorageEditedCharacters);

ENUMTOOBJ(TextTableLayoutAlgorithm,
          NSTextTableAutomaticLayoutAlgorithm,
          NSTextTableFixedLayoutAlgorithm);


ENUMTOOBJ(TextTabType,
          NSLeftTabStopType,
          NSRightTabStopType,
          NSCenterTabStopType,
          NSDecimalTabStopType);


ENUMTOOBJ(TIFFCompression,
          NSTIFFCompressionNone,
          NSTIFFCompressionCCITTFAX3,
          NSTIFFCompressionCCITTFAX4,
          NSTIFFCompressionLZW,
          NSTIFFCompressionJPEG,
          NSTIFFCompressionNEXT,
          NSTIFFCompressionPackBits,
          NSTIFFCompressionOldJPEG);


ENUMTOOBJ(TitlePosition,
          NSNoTitle,
          NSAboveTop,
          NSAtTop,
          NSBelowTop,
          NSAboveBottom,
          NSAtBottom,
          NSBelowBottom);


ENUMTOOBJ(TokenStyle,
          NSDefaultTokenStyle,
          NSPlainTextTokenStyle,
          NSRoundedTokenStyle);


ENUMTOOBJ(ToolbarDisplayMode,
          NSToolbarDisplayModeDefault,
          NSToolbarDisplayModeIconAndLabel,
          NSToolbarDisplayModeIconOnly,
          NSToolbarDisplayModeLabelOnly);

ENUMTOOBJ(ToolbarItemVisibilityPriority,
          NSToolbarItemVisibilityPriorityStandard,
          NSToolbarItemVisibilityPriorityLow,
          NSToolbarItemVisibilityPriorityHigh,
          NSToolbarItemVisibilityPriorityUser);


ENUMTOOBJ(ToolbarSizeMode,
          NSToolbarSizeModeDefault,
          NSToolbarSizeModeRegular,
          NSToolbarSizeModeSmall);


OPTSTOOBJ(TrackingAreaOptions,
          NSTrackingMouseEnteredAndExited,
          NSTrackingMouseMoved,
          NSTrackingCursorUpdate,
          NSTrackingActiveWhenFirstResponder,
          NSTrackingActiveInKeyWindow,
          NSTrackingActiveInActiveApp,
          NSTrackingActiveAlways,
          NSTrackingAssumeInside,
          NSTrackingInVisibleRect,
          NSTrackingEnabledDuringMouseDrag);


ENUMTOOBJ(TypesetterBehavior,
          NSTypesetterLatestBehavior,
          NSTypesetterOriginalBehavior,
          NSTypesetterBehavior_10_2_WithCompatibility,
          NSTypesetterBehavior_10_2,
          NSTypesetterBehavior_10_3,
          NSTypesetterBehavior_10_4);


ENUMTOOBJ(UsableScrollerParts,
          NSNoScrollerParts,
          NSOnlyScrollerArrows,
          NSAllScrollerParts);

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9
ENUMTOOBJ(UserInterfaceLayoutOrientation,
          NSUserInterfaceLayoutOrientationHorizontal,
          NSUserInterfaceLayoutOrientationVertical
          );
#endif


ENUMTOOBJ(WindingRule,
          NSNonZeroWindingRule,
          NSEvenOddWindingRule);

ENUMTOOBJ_DICT(WindowLevel, (@{
                                @(NSNormalWindowLevel) : @"NSNormalWindowLevel",
                                @(NSFloatingWindowLevel) : @"NSFloatingWindowLevel",
                                @(NSSubmenuWindowLevel) : @"NSSubmenuWindowLevel",
                                @(NSTornOffMenuWindowLevel) : @"NSTornOffMenuWindowLevel",
                                @(NSMainMenuWindowLevel) : @"NSMainMenuWindowLevel",
                                @(NSStatusWindowLevel) : @"NSStatusWindowLevel",
                                @(NSDockWindowLevel) : @"NSDockWindowLevel",
                                @(NSModalPanelWindowLevel) : @"NSModalPanelWindowLevel",
                                @(NSPopUpMenuWindowLevel) : @"NSPopUpMenuWindowLevel",
                                @(NSScreenSaverWindowLevel) : @"NSScreenSaverWindowLevel"
                            }));


OPTSTOOBJ(WindowMask,
          NSBorderlessWindowMask,
          NSTitledWindowMask,
          NSClosableWindowMask,
          NSMiniaturizableWindowMask,
          NSResizableWindowMask,
          NSTexturedBackgroundWindowMask,
          NSUnifiedTitleAndToolbarWindowMask,
          NSFullScreenWindowMask,
          NSFullSizeContentViewWindowMask);

ENUMTOOBJ(WindowBackingLocation,
          NSWindowBackingLocationDefault,
          NSWindowBackingLocationVideoMemory,
          NSWindowBackingLocationMainMemory);


ENUMTOOBJ(WindowCollectionBehavior,
          NSWindowCollectionBehaviorDefault,
          NSWindowCollectionBehaviorCanJoinAllSpaces,
          NSWindowCollectionBehaviorMoveToActiveSpace);


ENUMTOOBJ(WindowSharingType,
          NSWindowSharingNone,
          NSWindowSharingReadOnly,
          NSWindowSharingReadWrite);


ENUMTOOBJ(WritingDirection,
          NSWritingDirectionNatural,
          NSWritingDirectionLeftToRight,
          NSWritingDirectionRightToLeft);


id objectFromTickMarkPosition(NSTickMarkPosition tickMarkPosition, BOOL isVertical)
{
        switch (tickMarkPosition) {
        case NSTickMarkBelow:
                return [FSNamedNumber namedNumberWithDouble:tickMarkPosition name:isVertical ? @"NSTickMarkRight" : @"NSTickMarkBelow"];
        case NSTickMarkAbove:
                return [FSNamedNumber namedNumberWithDouble:tickMarkPosition name:isVertical ? @"NSTickMarkLeft" : @"NSTickMarkAbove"];
        //case NSTickMarkLeft:  return [NamedNumber namedNumberWithDouble:tickMarkPosition name:@"NSTickMarkLeft"];
        //case NSTickMarkRight: return [NamedNumber namedNumberWithDouble:tickMarkPosition name:@"NSTickMarkRight"];
        default:
                return [FSNumber numberWithDouble:tickMarkPosition];
        }
}
@end
