#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Foundation/Foundation.h>

typedef struct RGBPixel {
	UInt8 alpha, red, green, blue;
} RGBPixel;

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */
int clamp(int value, int min, int max) {
	return value > max ? max : value < min ? min : value;
}

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSString *filepath = [(__bridge NSURL *)url path];
	NSData *logData = [NSData dataWithContentsOfFile:filepath];
	NSData *descriptionLenBuf = [logData subdataWithRange:NSMakeRange(0, 4)];
	int descriptionLen = CFSwapInt32BigToHost(*(int*)([descriptionLenBuf bytes]));
	
	NSData *descriptionBuf = [logData subdataWithRange:NSMakeRange(4, descriptionLen)];
	
	int imgLenBufStart = 4 + descriptionLen;
	NSData *imgLenBuf = [logData subdataWithRange:NSMakeRange(imgLenBufStart, 4)];
	int imgLen = CFSwapInt32BigToHost(*(int*)([imgLenBuf bytes]));
	
	NSData *imgBuf = [logData subdataWithRange:NSMakeRange(imgLenBufStart + 4, imgLen)];
	uint8_t *imgBytes = (uint8_t *)[imgBuf bytes];
	
	uint8* rgbPixelArray = malloc(100000 * sizeof(uint8));
	
	int pixelArrayIndex, i;
	
	pixelArrayIndex = 0;
	
	for (i=0; i<imgLen - 3; i+=4) {
		uint8 y1, u, y2, v;
		y1 = imgBytes[i + 0];
		u = imgBytes[i + 1];
		y2 = imgBytes[i + 2];
		v = imgBytes[i + 3];
		
		int y = y1;
		
		int c = y - 16;
		int d = u - 128;
		int e = v - 128;
		
		int r = clamp((298*c + 409*e + 128) >> 8,         0, 255);
		int g = clamp((298*c - 100*d - 208*e + 128) >> 8, 0, 255);
		int b = clamp((298*c + 516*d + 128) >> 8,         0, 255);
		
		rgbPixelArray[pixelArrayIndex] = r;
		rgbPixelArray[pixelArrayIndex + 1] = g;
		rgbPixelArray[pixelArrayIndex + 2] = b;
		rgbPixelArray[pixelArrayIndex + 3] = 0xff;
		pixelArrayIndex += 4;
		
		y = y2;
		
		c = y - 16;
		d = u - 128;
		e = v - 128;
		
		r = clamp((298*c + 409*e + 128) >> 8,         0, 255);
		g = clamp((298*c - 100*d - 208*e + 128) >> 8, 0, 255);
		b = clamp((298*c + 516*d + 128) >> 8,         0, 255);
		
		rgbPixelArray[pixelArrayIndex] = r;
		rgbPixelArray[pixelArrayIndex + 1] = g;
		rgbPixelArray[pixelArrayIndex + 2] = b;
		rgbPixelArray[pixelArrayIndex + 3] = 0xff;
		pixelArrayIndex += 4;
	}
	
	
	NSSize canvasSize = NSMakeSize(600, 400);
	
	// begin making the context
	CGContextRef cgContext = QLPreviewRequestCreateContext(preview, *(CGSize *)&canvasSize, true, NULL);
	
	CGBitmapInfo bminfo = CGBitmapContextGetBitmapInfo(cgContext);
	
	CGDataProviderRef providerRef = CGDataProviderCreateWithData(&bminfo, rgbPixelArray, pixelArrayIndex * sizeof(uint8), nil);
	
	CGImageRef cgimage;
	
	if (imgLen > 200000) {
		cgimage = CGImageCreate(640, 480, 8, 32, 640 * 4 * sizeof(uint8), CGColorSpaceCreateDeviceRGB(), bminfo, providerRef, nil, YES, kCGRenderingIntentDefault);
	} else {
		cgimage = CGImageCreate(320, 240, 8, 32, 320 * 4 * sizeof(uint8), CGColorSpaceCreateDeviceRGB(), bminfo, providerRef, nil, YES, kCGRenderingIntentDefault);
	}
	
	
//	NSString *stringToPrint = [NSString stringWithFormat:@"%d", imgLen];
//	NSFileHandle *stdout = [NSFileHandle fileHandleWithStandardOutput];
//	NSData *strData = [stringToPrint dataUsingEncoding: NSASCIIStringEncoding];
//	printf("\n");
//	[stdout writeData: strData];
//	printf("\n\n");
	
	// if the context
	if (cgContext) {
		CGContextDrawImage(cgContext, CGRectMake(0, 0, 640, 480), cgimage);
		
		QLPreviewRequestFlushContext(preview, cgContext);
		CFRelease(cgContext);
	}
	return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
