//
//  FSObjectInspectorViewController+NonArc.m
//  FScript
//
//  Created by Anthony Dervish on 18/11/2014.
//
//

#import "FSObjectInspectorViewController+NonArc.h"
#import "FSCompiler.h"
#import "FSInterpreter.h"
#import "FSInterpreterPrivate.h"
#import "FSInterpreterResult.h"
#import "FSExecEngine.h"
#import "FSBlock.h"
#import "FSObjectBrowserButtonCtxBlock.h"
#import "FSMiscTools.h"
#import "FSUtils.h"

@implementation FSObjectInspectorViewController (NonArc)


- (void)applyBlock:(FSBlock*)block withObject:(id)selectedObject newValue:(id)value
{
        FSInterpreter* interpreter = self.interpreter;

        @try {
                [block compilIfNeeded];
        }
        @catch (id exception)
        {
                NSRunAlertPanel(@"Syntax Error", FSErrorMessageFromException(exception), @"OK", nil, nil, nil);
                FSInspectBlocksInCallStackForException(exception);
                return;
        }

        FSObjectBrowserButtonCtxBlock* contextualizedBlock;

        contextualizedBlock = [interpreter objectBrowserButtonCtxBlockFromString:[block printString]];
        [contextualizedBlock setMaster:block];

        FSInterpreterResult* interpreterResult = [contextualizedBlock executeWithArguments:@[selectedObject, value]];
        if (!checkInterpreterResult(interpreterResult)) {
                return;
        }
}

- (BOOL)sendMessageTo:(id)receiver selectorString:(NSString*)selectorStr arguments:(FSArray*)arguments column:(NSUInteger)column putResultInMatrix:(NSMatrix*)matrix
{
        NSInteger nbarg = [arguments count];
        id args[nbarg + 2];
        SEL selector = [FSCompiler selectorFromString:selectorStr];
        NSInteger i;
        id result = nil; // To avoid a warning "might be used uninitialized"

        args[0] = receiver;
        args[1] = (__bridge id)(void*)selector;
        for (i = 0; i < nbarg; i++)
                args[i + 2] = [arguments objectAtIndex:i];

        @try {
                result = sendMsgNoPattern(receiver, selector, nbarg + 2, args, [FSMsgContext msgContext], nil);
        }
        @catch (id exception)
        {
                FSInspectBlocksInCallStackForException(exception);
                NSRunAlertPanel(@"Error", FSErrorMessageFromException(exception), @"OK", nil, nil, nil);
                return NO;
        }

        return YES;
}
@end
