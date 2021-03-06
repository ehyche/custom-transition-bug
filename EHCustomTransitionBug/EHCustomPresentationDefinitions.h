//
//  EHCustomPresentationDefinitions.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/9/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

typedef NS_ENUM(NSUInteger, EHCustomPresentationStyle) {
    EHCustomPresentationStyleFullScreen,
    EHCustomPresentationStyleCustomSizeDimmedBackground,
    EHCustomPresentationStyleCustomSizeBlurredBackground,
    EHCustomPresentationStyleCount
};

typedef NS_ENUM(NSUInteger, EHCustomTransitionStyle) {
    EHCustomTransitionStyleCoverVertical,
    EHCustomTransitionStyleCrossDissolve,
    EHCustomTransitionStyleZoomInWithBounce,
    EHCustomTransitionStyleCount
};
