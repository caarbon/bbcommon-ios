// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.
//
//  Modified by leebrenner on 3/8/12.
//  Copyright 2012 BigBig Bomb, LLC. All rights reserved
//



#import "UIImage+BBCommon.h"


@implementation UIImage (BBCommon)

// Returns true if the image has an alpha layer
- (BOOL)hasAlpha {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage *)imageWithAlpha {
    if ([self hasAlpha]) {
        return self;
    }

    size_t width = CGImageGetWidth(self.CGImage);
    size_t height = CGImageGetHeight(self.CGImage);
    CGColorSpaceRef imageRefColorSpace = CGImageGetColorSpace(self.CGImage);

    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          imageRefColorSpace,
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);

    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];

    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);

    return imageWithAlpha;
}

- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     (size_t)size.width,
                                                     (size_t)size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);

    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));

    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));

    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);

    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);

    return maskImageRef;
}

- (UIImage *)transparentBorderImage:(NSUInteger)borderSize {
    UIImage *image = [self imageWithAlpha];

    CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                (size_t)newRect.size.width,
                                                (size_t)newRect.size.height,
                                                CGImageGetBitsPerComponent(image.CGImage),
                                                0,
                                                colorSpace,
                                                kCGImageAlphaPremultipliedLast);

    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
    CGContextDrawImage(bitmap, imageLocation, image.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);

    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self newBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];

    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    CGColorSpaceRelease(colorSpace);

    return transparentBorderImage;
}

- (UIImage *)crop:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)resizePreservingAspect:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);

    float widthRatio = self.size.width / size.width;
    float heightRatio = self.size.height / size.height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;

    size.width = self.size.width / divisor;
    size.height = self.size.height / divisor;

    rect.size.width  = size.width;
    rect.size.height = size.height;

    if(size.height < size.width)
        rect.origin.y = size.height / 3;

    [self drawInRect: rect];

    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return resizedImage;
}

@end