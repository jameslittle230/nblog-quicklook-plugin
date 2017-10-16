#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Foundation/Foundation.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSString *filepath = [(__bridge NSURL *)url absoluteString];
	NSData *logData = [NSData dataWithContentsOfFile:filepath];
	
	NSSize canvasSize = NSMakeSize(600, 400);
	
	// begin making the context
	CGContextRef cgContext = QLPreviewRequestCreateContext(preview, *(CGSize *)&canvasSize, true, NULL);
	
	// if the context
	if (cgContext) {
		CGContextSetRGBFillColor(cgContext, 1, 0, 0, 1);
		CGContextFillRect(cgContext, CGRectMake(15, 15, 100, 100));
		
		QLPreviewRequestFlushContext(preview, cgContext);
		CFRelease(cgContext);
	}
	return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
