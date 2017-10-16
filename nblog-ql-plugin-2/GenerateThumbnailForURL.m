#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Foundation/Foundation.h>

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
	NSSize canvasSize = NSMakeSize(600, 400);
	
	// begin making the context
	CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, *(CGSize *)&canvasSize, true, NULL);
	
	// if the context
	if (cgContext) {
		CGContextSetRGBFillColor(cgContext, 1, 0, 0, 1);
		CGContextFillRect(cgContext, CGRectMake(15, 15, 100, 100));
		
		QLThumbnailRequestFlushContext(thumbnail, cgContext);
		CFRelease(cgContext);
	}
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
