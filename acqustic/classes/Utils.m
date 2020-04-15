//
//  Utils.m
//  juegoortografia
//
//  Created by Javier Garcés González on 10/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Utils.h"
#import "UIGestureRecognizer+Blocks.h"
#import "NSDate+Utilities.h"
@import CoreTelephony;


#define USER_VALID_CHARS        @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 'áéíóúàèìòùäëïöüâêîôûÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛçÇÑñ_-"
#define PASSWORD_VALID_CHARS    @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"

@implementation Utils

static BOOL initialized = NO;
static float screenScale = 1.0;

// Inicialización de las utilidades
+ (BOOL)initialize
{
    UIScreen *screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)])
    {
        UIImage * image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"menuinf_inicio_off" ofType:@"png"]];
        screenScale = image.scale;
    }
    //NSLog(@"SCALE GENERAL: %f", screenScale);

    initialized = YES;
    return YES;
}



// FUNCION PARA INDICAR SI SE TRATA DE IPAD/IPHONE
+ (BOOL)isIPad
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    else
        return NO;
}

// Detectar si es pantalla retina
+ (BOOL)isRetinaDisplay
{
    if (initialized == NO)
        [Utils initialize];
    
    if (screenScale == 2.0)
        return YES;
    else
        return NO;
}

// Detectar si es un iPhone 5
+ (BOOL)isIPhone5
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if ([Utils isIPad] == NO && screenBounds.size.height > 480)
        return YES;
    else
        return NO;
}



+ (BOOL) resourceExists:(NSString *)fileName
{
    if (initialized == NO)
        [Utils initialize];
    
    NSString * name, * ext;
    name = [[fileName lastPathComponent] stringByDeletingPathExtension];
    ext = [fileName pathExtension];
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (NSString *) resourcePath:(NSString *)fileName
{
    NSString * name, * ext;
    name = [[fileName lastPathComponent] stringByDeletingPathExtension];
    ext = [fileName pathExtension];
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    return path;
}


// Crear una imagen correctamente para todos los dispositivos (retina y no retina)
+ (UIImage *) imageFromMainBundle: (NSString *)fileName
{
    if (initialized == NO)
        [Utils initialize];
    
    NSString * name, * ext;
    name = [[fileName lastPathComponent] stringByDeletingPathExtension];
    ext = [fileName pathExtension];
    UIImage * image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
    
    //NSLog(@"IFMB: %@ %f", fileName, image.scale);
    
    return image;
}


// Función auxiliar RetinaAwareUIGraphicsBeginImageContext
// Esta función está pensada como sustituto de UIGraphicsBeginImageContext
// pero que tenga en cuenta las pantallas retinas. Básicamente, lo que
// hace es mirar si estamos en pantalla retina y en ese caso usar la nueva
// rutina (SDK 4.0) UIGraphicsBeginImageContextWithOpcions en vez
// de la original, que se usa para pantallas normales.
static void RetinaAwareUIGraphicsBeginImageContext(CGSize size)
{
    static CGFloat scale = -1.0;
    if (scale < 0.0)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
        {
            scale = screenScale; //[screen scale];
        }
        else
        {
            scale = 0.0;    // mean use old api
        }
    }
    
    //NSLog(@"RAUIGBIC: %f", scale);
    
    if (scale > 0.0)
        UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    else
        UIGraphicsBeginImageContext(size);
    
}


+(NSString *)getSIMCurrentCountryCode {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    NSString * isoCode = [carrier isoCountryCode];
    if (isoCode != nil) {
        return [isoCode lowercaseString];
    }
    return NSLocalizedString(@"lang", nil);
    //return @"br";
}



/*
+ (UIImage *)blendImages: (ImageBlendItem *)items
{
    if (initialized == NO)
        [Utils initialize];
    
    if (items == NULL)
        return nil;
    
    // Cargamos el fondo y éste fija el tamaño de la imagen final
    UIImage * current = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:items->bundleFile ofType:items->bundleExt]];
    if (current == nil)
        return nil;
    
    //NSLog(@"BI: %@ %f", items->bundleFile, current.scale);
    
    // Inicializamos el contexto (Atención... rutina alternativa que tiene en cuenta las pantallas retina)
    RetinaAwareUIGraphicsBeginImageContext( current.size );
    // copiamos el primer elemento
    [current drawInRect:CGRectMake(items->left,items->top,current.size.width,current.size.height)];
    
    [current release];
    
    while (items->bundleFile != nil)
    {
        UIImage * current = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:items->bundleFile ofType:items->bundleExt]];
        //NSLog(@"BI: %@ %f", items->bundleFile, current.scale);
        
        if (current != nil)
            [current drawInRect:CGRectMake(items->left,items->top,current.size.width,current.size.height)];
        
        [current release];
        
        items++;
    }
    // Creamos el UIImage final
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // Liberamos el contexto
    UIGraphicsEndImageContext();
    
    //NSLog(@"BI FINAL: %f", newImage.scale);
    
    // Retornamos la imagen
    return newImage;
}
 */

// Crear un botón sin imagen pero activo (un Hotspot, vamos)
+ (UIButton *) touchArea:(CGRect)frame withTarget:(id)target andSelector:(SEL)sel;
{
    if (initialized == NO)
        [Utils initialize];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchDown];
    return btn;
}


+ (UIButton *) imageAsButton: (UIImage *)image withTarget:(id)target andSelector:(SEL)sel
{
    if (initialized == NO)
        [Utils initialize];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,image.size.width,image.size.height);
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateHighlighted];
    [btn setImage:image forState:UIControlStateSelected];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchDown];
    return btn;
}

// Crear un botón a partir de una única imagen (del main bundle)
+ (UIButton *) buttonFromResource: (NSString *)resource withTarget:(id)target andSelector:(SEL)sel
{
    if (initialized == NO)
        [Utils initialize];
    
    UIImage * image = [Utils imageFromMainBundle:resource];
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,image.size.width,image.size.height);
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateHighlighted];
    [btn setImage:image forState:UIControlStateSelected];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchDown];
    return btn;
}

// Crear un botón a partir de dos imágenes del main bundle
+ (UIButton *) buttonFromResources:(NSString *)resourceOne and:(NSString *)resourceTwo withTarget:(id)target andSelector:(SEL)sel
{
    if (initialized == NO)
        [Utils initialize];
    
    UIImage * imageNormal = [Utils imageFromMainBundle:resourceOne];
    UIImage * imageClicked = [Utils imageFromMainBundle:resourceTwo];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,imageNormal.size.width,imageNormal.size.height);
    [btn setImage:imageNormal forState:UIControlStateNormal];
    [btn setImage:imageClicked forState:UIControlStateHighlighted];
    [btn setImage:imageClicked forState:UIControlStateSelected];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


+(void) adjustUILabelHeight: (UILabel *) label
{
    if (initialized == NO)
        [Utils initialize];
    
	// Ajusto la altura del subtítlo para que quepan...
	CGRect lblFrame = label.frame;
    CGSize maximumSize = CGSizeMake(lblFrame.size.width, 9999);
    NSString *dateString = label.text;
    CGSize stringSize = [dateString sizeWithFont:label.font constrainedToSize:maximumSize lineBreakMode: label.lineBreakMode];
    CGRect finalFrame = CGRectMake(lblFrame.origin.x, lblFrame.origin.y, lblFrame.size.width, stringSize.height);
    label.frame = finalFrame;
}

+(void) adjustUILabelSize: (UILabel *) label
{
    if (initialized == NO)
        [Utils initialize];
    
	// Ajusto la altura del subtítlo para que quepan...
	CGRect lblFrame = label.frame;
    CGSize maximumSize = CGSizeMake(9999, 9999);
    NSString *dateString = label.text;
    CGSize stringSize = [dateString sizeWithFont:label.font constrainedToSize:maximumSize lineBreakMode: label.lineBreakMode];
    CGRect finalFrame = CGRectMake(lblFrame.origin.x, lblFrame.origin.y, stringSize.width, stringSize.height);
    label.frame = finalFrame;
}

+(void) adjustUILabelSize:(UILabel *)label forWidth:(int)width;
{
    if (initialized == NO)
        [Utils initialize];
    
	// Ajusto la altura del subtítlo para que quepan...
	CGRect lblFrame = label.frame;
    CGSize maximumSize = CGSizeMake(width, 9999);
    NSString *dateString = label.text;
    CGSize stringSize = [dateString sizeWithFont:label.font constrainedToSize:maximumSize lineBreakMode: label.lineBreakMode];
    CGRect finalFrame = CGRectMake(lblFrame.origin.x, lblFrame.origin.y, /*stringSize.width*/width, stringSize.height);
    label.frame = finalFrame;
}

+(void) adjustUILabelSize:(UILabel *)label fromWidth:(int)minWidth toWidth:(int)maxWidth {
    if (initialized == NO)
        [Utils initialize];
    
    // Ajusto la altura del subtítlo para que quepan...
    CGRect lblFrame = label.frame;
    CGSize maximumSize = CGSizeMake(maxWidth, 9999);
    NSString *dateString = label.text;
    CGSize stringSize = [dateString sizeWithFont:label.font constrainedToSize:maximumSize lineBreakMode: label.lineBreakMode];
    CGFloat finalWidth = stringSize.width;
    if (finalWidth < minWidth)
        finalWidth = minWidth;
    if (finalWidth > maxWidth)
        finalWidth = maxWidth;
    CGRect finalFrame = CGRectMake(lblFrame.origin.x, lblFrame.origin.y, finalWidth, stringSize.height);
    label.frame = finalFrame;
}

+(void) adjustUITextViewSize:(UITextView *)textView fromWidth:(int)minWidth toWidth:(int)maxWidth {
    [textView sizeToFit];
    if (textView.frame.size.width < minWidth) {
        CGRect fr = textView.frame;
        fr.size.width = minWidth;
        textView.frame = fr;
    } else if (textView.frame.size.width > maxWidth) {
        CGSize newSize = [textView sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
        CGRect fr = textView.frame;
        fr.size.width = newSize.width;
        fr.size.height = newSize.height;
        textView.frame = fr;
    }
}


+(void) adjustUILabelSize:(UILabel *)label addBottom:(int)bottom
{
    [Utils adjustUILabelSize:label];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, label.frame.size.height + bottom);
}

+(void) adjustRTLabelHeight:(RTLabel *)label
{
    if (initialized == NO)
        [Utils initialize];
    
	CGRect lblFrame = label.frame;
	CGSize stringSize = [label optimumSize];
	NSInteger finalHeight = (NSInteger)(stringSize.height + 2.0); // Forzamos que sea un nº entero de píxeles...
    CGRect finalFrame = CGRectMake(lblFrame.origin.x, lblFrame.origin.y, lblFrame.size.width, finalHeight);
	label.frame = finalFrame;
}

+(void) adjustRTLabelSize:(RTLabel *)label
{
    if (initialized == NO)
        [Utils initialize];
    
	CGRect lblFrame = label.frame;
	CGSize stringSize = [label optimumSize];
    NSInteger finalWidth = (NSInteger)(stringSize.width + 2.0);
	NSInteger finalHeight = (NSInteger)(stringSize.height + 2.0); // Forzamos que sea un nº entero de píxeles...
    CGRect finalFrame = CGRectMake(lblFrame.origin.x, lblFrame.origin.y, finalWidth, finalHeight);
	label.frame = finalFrame;
}


+(UIColor *) uicolorFromARGB:(unsigned int)argb
{
    CGFloat a,r,g,b;
    a = (argb >> 24);
    r = (argb >> 16 & 0x000000FF);
    g = (argb >> 8 & 0x000000FF);
    b = (argb & 0x000000FF);
    
    a = a / 255;
    r = r / 255;
    g = g / 255;
    b = b / 255;
    
    //NSLog(@"uicolorFromARGB: %f, %f, %f, %f", r, g, b, a);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
    
}

+(void) setColorComponentsFromARGB:(unsigned int)argb in:(CGFloat *)components index:(int)index
{
    CGFloat a,r,g,b;
    a = (argb >> 24);
    r = (argb >> 16 & 0x000000FF);
    g = (argb >> 8 & 0x000000FF);
    b = (argb & 0x000000FF);
    
    a = a / 255;
    r = r / 255;
    g = g / 255;
    b = b / 255;
    
    int pos = index*4;
    
    components[pos] = r;
    components[pos+1] = g;
    components[pos+2] = b;
    components[pos+3] = a;
}

+(void) setColorComponentsFromARGBGradient:(unsigned int)argbStart argbMid:(unsigned int)argbMid argbEnd:(unsigned int)argbEnd in:(CGFloat *)components
{
    [Utils setColorComponentsFromARGB:argbStart in:components index:0];
    [Utils setColorComponentsFromARGB:argbMid in:components index:1];
    [Utils setColorComponentsFromARGB:argbEnd in:components index:2];
}

+(void) addDebugBorder:(UIView *)view {
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 2;
}

// https://stackoverflow.com/questions/10570247/fade-edges-of-uitableview/21262188#21262188
+(void) setupScrollForBorderFades:(UIScrollView *)scrollView withDelegate:(id<UIScrollViewDelegate>)delegate {
    if (!scrollView.layer.mask)
    {
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        
        /*
        maskLayer.locations = @[[NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.2],
                                [NSNumber numberWithFloat:0.8],
                                [NSNumber numberWithFloat:1.0]];
         */
        maskLayer.locations = @[[NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.1],
                                [NSNumber numberWithFloat:0.9],
                                [NSNumber numberWithFloat:1.0]];

        maskLayer.bounds = CGRectMake(0, 0,
                                      scrollView.frame.size.width,
                                      scrollView.frame.size.height);
        maskLayer.anchorPoint = CGPointZero;
        
        scrollView.layer.mask = maskLayer;
        
        scrollView.delegate = delegate;
    }
    [Utils onScrollForBorderFadesDidScroll:scrollView];

}


+(void) onScrollForBorderFadesDidScroll:(UIScrollView *)scrollView {
    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    NSArray *colors;
    
    if (scrollView.contentOffset.y + scrollView.contentInset.top <= 0) {
        //Top of scrollView
        colors = @[(__bridge id)innerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)outerColor];
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height
               >= scrollView.contentSize.height) {
        //Bottom of tableView
        colors = @[(__bridge id)outerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)innerColor];
    } else {
        //Middle
        colors = @[(__bridge id)outerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)outerColor];
    }
    ((CAGradientLayer *)scrollView.layer.mask).colors = colors;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    scrollView.layer.mask.position = CGPointMake(0, scrollView.contentOffset.y);
    [CATransaction commit];
}

+(void) adjustScrollSize:(UIScrollView *)scrollView {
    int maxY = 0;
    for (UIView * v in scrollView.subviews) {
        int y = v.frame.origin.y + v.frame.size.height;
        if (y > maxY)
            maxY = y;
    }
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, maxY);
}

+(void) adjustScrollSize:(UIScrollView *)scrollView withBottomMargin:(int)bottomMargin {
    int maxY = 0;
    for (UIView * v in scrollView.subviews) {
        int y = v.frame.origin.y + v.frame.size.height;
        if (y > maxY)
            maxY = y;
    }
    maxY += bottomMargin;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, maxY);
}


+(NSString *) trim:(NSString *)source
{
    return [source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(BOOL) contains:(NSString *)source value:(NSString *)value
{
    if ([source rangeOfString:value].location != NSNotFound)
        return YES;
    else
        return NO;
}

+(NSString *) toString:(id) object
{
    if ([object isKindOfClass:[NSString class]])
        return (NSString *)object;
    else if ([object isKindOfClass:[NSNumber class]])
        return [object stringValue];
    else
        return [NSString stringWithFormat:@"%@",object];
}

+(int) toInt:(id) object
{
    if (object == nil || object == [NSNull null])
        return 0;
    
    return [[Utils toString:object] intValue];
}

+(int) toInt:(id) object withDefault:(int)defValue
{
    if (object == nil || object == [NSNull null])
        return defValue;
    
    NSScanner * s = [NSScanner scannerWithString:[Utils toString:object]];
    int res;
    if ([s scanInt:&res])
        return res;
    return defValue;
}


+(BOOL) isValidString:(NSString *)str withValidChars:(NSString *)validChars
{
    if (validChars == nil)
        return NO;
    if ([validChars isEqualToString:@""] == YES)
        return NO;
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:validChars] invertedSet];
    
    if ([str rangeOfCharacterFromSet:set].location != NSNotFound) {
        return NO;
    }
    return YES;
}

+(BOOL) isValidEmail:(NSString *)email
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(BOOL) isValidUserName:(NSString *)userName
{
    if (userName == nil)
        return NO;
    if ([userName isEqualToString:@""] == YES)
        return NO;
    return [Utils isValidString:userName withValidChars:USER_VALID_CHARS];
}

+(BOOL) isValidPassword:(NSString *)password
{
    if (password == nil)
        return NO;
    if ([password isEqualToString:@""] == YES)
        return NO;
    return [Utils isValidString:password withValidChars:PASSWORD_VALID_CHARS];
}

+(BOOL) isValidPhone:(NSString *)phone {
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:nil];
    NSTextCheckingResult *result = [detector firstMatchInString:phone options:NSMatchingReportCompletion range:NSMakeRange(0, [phone length])];
    if ([result resultType] == NSTextCheckingTypePhoneNumber) {
        return YES;
    }
    return NO;
}

+(BOOL) isValidNIF:(NSString *)nif {
    if (nif.length == 9) {
        return YES;
    }
    return NO;
}


+(NSString *)localizedFieldName:(NSString *)field {
    NSString * lang = NSLocalizedString(@"lang", nil);
    return [NSString stringWithFormat:@"%@_%@", field, lang];
}


+(void) moveViewY:(UIView *)view newY:(CGFloat)newY
{
    CGRect newFrame = CGRectMake(view.frame.origin.x, newY, view.frame.size.width, view.frame.size.height);
    view.frame = newFrame;
}


+(void) setOnClick: (UIView *)view withBlock:(UIView_onClicked)onClick {
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithBlock:^(UIGestureRecognizer * sender) {
        onClick(sender.view);
    }];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
}

+(void) setupVerticalRaw:(NSArray *)items sep:(int)sep {
    UIView * item = items[0];
    int yTop = item.frame.origin.y;
    for (int i=0;i<items.count;i++) {
        item = (UIView *)items[i];
        CGRect fr = item.frame;
        fr.origin.y = yTop;
        item.frame = fr;
        yTop += item.frame.size.height + sep;
    }
}

+(void) cleanUpScrollView:(UIScrollView *)sv {
    for (UIView *v in sv.subviews) {
      if (![v isKindOfClass:[UIImageView class]] && ![v isKindOfClass:[UIRefreshControl class]]) {
        [v removeFromSuperview];
      }
    }
}

// DELAYED BLOCKS
SMDelayedBlockHandle perform_block_after_delay(CGFloat seconds, dispatch_block_t block) {
    
    if (nil == block) {
        return nil;
    }
    
    // block is likely a literal defined on the stack, even though we are using __block to allow us to modify the variable
    // we still need to move the block to the heap with a copy
    __block dispatch_block_t blockToExecute = [block copy];
    __block SMDelayedBlockHandle delayHandleCopy = nil;
    
    SMDelayedBlockHandle delayHandle = ^(BOOL cancel){
        if (NO == cancel && nil != blockToExecute) {
            dispatch_async(dispatch_get_main_queue(), blockToExecute);
        }
        
        // Once the handle block is executed, canceled or not, we free blockToExecute and the handle.
        // Doing this here means that if the block is canceled, we aren't holding onto retained objects for any longer than necessary.
#if !__has_feature(objc_arc)
        [blockToExecute release];
        [delayHandleCopy release];
#endif
        
        blockToExecute = nil;
        delayHandleCopy = nil;
    };
        
    // delayHandle also needs to be moved to the heap.
    delayHandleCopy = [delayHandle copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (nil != delayHandleCopy) {
            delayHandleCopy(NO);
        }
    });

    return delayHandleCopy;
};

void cancel_delayed_block(SMDelayedBlockHandle delayedHandle) {
    if (nil == delayedHandle) {
        return;
    }
    
    delayedHandle(YES);
}

// DATE AND MONEY FORMATTING
+(NSString *)formatDate:(NSInteger)timestamp {
    long ts = timestamp;
    if (ts == 0)
        return @"";
    NSTimeInterval timeInterval = ts;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Tenemos la fecha. Miramos de formatearla
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}

+(NSString *)formatDateOnly:(NSInteger)timestamp {
    long ts = timestamp;
    if (ts == 0)
        return @"";
    NSTimeInterval timeInterval = ts;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Tenemos la fecha. Miramos de formatearla
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}


+(NSString *)formatDate:(NSInteger)timestamp withFormat:(NSString *)format {
    long ts = timestamp;
    if (ts == 0)
        return @"";
    NSTimeInterval timeInterval = ts;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Tenemos la fecha. Miramos de formatearla
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:format];
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}


+(NSString *)formatTime:(NSInteger)timestamp {
    long ts = timestamp;
    if (ts == 0)
        return @"";
    NSTimeInterval timeInterval = ts;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Tenemos la fecha. Miramos de formatearla
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}
        
+(NSString *)formatDateRelative:(NSInteger)timestamp {
    long ts = timestamp;
    if (ts == 0)
        return @"";
    NSTimeInterval timeInterval = ts;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    if ([date isToday]) {
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setDateFormat:@"HH:mm"];
        return [dateformatter stringFromDate:date];
    } else if ([date isYesterday]) {
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:NSLocalizedString(@"pagechat_formatdate_yesterday", nil),[dateformatter stringFromDate:date]];
    } else {
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        NSString *dateString=[dateformatter stringFromDate:date];
        return dateString;
    }
}

+(NSString *) formatMoney:(double) amount {
    if (amount) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        nf.numberStyle = NSNumberFormatterCurrencyStyle;
        nf.currencyCode = @"EUR";
        return [nf stringFromNumber:[NSNumber numberWithDouble:amount]];
    } else {
        return @"";
    }
}

@end
