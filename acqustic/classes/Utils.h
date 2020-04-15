//
//  Utils.h
//  juegoortografia
//
//  Created by Javier Garcés González on 10/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RTLabel.h"
#import "UIGestureRecognizer+Blocks.h"

/*
typedef struct _ImageBlendItem {
    NSString * bundleFile;
    NSString * bundleExt;
    int left;
    int top;
} ImageBlendItem;
*/



typedef void (^UIView_onClicked)(UIView * sender);


@interface Utils : NSObject

// Inicialización de las utilidades
+ (BOOL)initialize;

// Detectar si estamos trabajando con un iPad o con iPhone/iPod
+ (BOOL)isIPad;

// Detectar si es pantalla retina
+ (BOOL)isRetinaDisplay;

// Detectar si es un iPhone 5
+ (BOOL)isIPhone5;

// Get SIM Country Code (2 letters lowercase) (if not, use language as reference)
+(NSString *)getSIMCurrentCountryCode;

// Mirar si un recursos existe
+ (BOOL) resourceExists:(NSString *)fileName;

// Obtener el path completo de un recurso
+ (NSString *) resourcePath:(NSString *)fileName;

// Crear una imagen correctamente para todos los dispositivos (retina y no retina)
+ (UIImage *) imageFromMainBundle: (NSString *)fileName;

/*
// Crear un UIImage a partir de una lista de archivos PNG a combinar
+(UIImage *)blendImages: (ImageBlendItem *)items;
 */


// Crear un botón sin imagen pero activo (un Hotspot, vamos)
+ (UIButton *) touchArea:(CGRect)frame withTarget:(id)target andSelector:(SEL)sel;

// Crear un UIButton con una imagen, de manera que podamos hacer algo cuando se pique en el dibujo
+ (UIButton *) imageAsButton: (UIImage *)image withTarget:(id)target andSelector:(SEL)sel;
// Crear un botón a partir de una única imagen (del main bundle)
+ (UIButton *) buttonFromResource: (NSString *)resource withTarget:(id)target andSelector:(SEL)sel;
// Crear un botón a partir de dos imágenes del main bundle
+ (UIButton *) buttonFromResources: (NSString *)resourceOne and:(NSString *)resourceTwo withTarget:(id)target andSelector:(SEL)sel;


// Ajustes de altura en el caso de campos de texto (UILabel y RTLabel
+(void) adjustUILabelHeight: (UILabel *) label;
+(void) adjustUILabelSize: (UILabel *) label;
+(void) adjustUILabelSize:(UILabel *)label forWidth:(int)width;
+(void) adjustUILabelSize:(UILabel *)label fromWidth:(int)minWidth toWidth:(int)maxWidth;
+(void) adjustUILabelSize:(UILabel *)label addBottom:(int)bottom;
+(void) adjustRTLabelHeight: (RTLabel *) label;
+(void) adjustRTLabelSize:(RTLabel *)label;
+(void) adjustUITextViewSize:(UITextView *)textView fromWidth:(int)minWidth toWidth:(int)maxWidth;

+(void) addDebugBorder:(UIView *)view;

// https://stackoverflow.com/questions/10570247/fade-edges-of-uitableview/21262188#21262188
+(void) setupScrollForBorderFades:(UIScrollView *)scroll withDelegate:(id<UIScrollViewDelegate>)delegate;
+(void) onScrollForBorderFadesDidScroll:(UIScrollView *)scroll;
+(void) adjustScrollSize:(UIScrollView *)scrollView;
+(void) adjustScrollSize:(UIScrollView *)scrollView withBottomMargin:(int)bottomMargin;

// Manipulación de colores, de formato 0xAARRGGBB a los nativos de iOS
+(UIColor *) uicolorFromARGB:(unsigned int)argb;
+(void) setColorComponentsFromARGB:(unsigned int)argb in:(CGFloat *)components index:(int)index;
+(void) setColorComponentsFromARGBGradient:(unsigned int)argbStart argbMid:(unsigned int)argbMid argbEnd:(unsigned int)argbEnd in:(CGFloat *)components;

// Manipulación de strings, ints, etc.
+(NSString *) trim:(NSString *)source;
+(BOOL) contains:(NSString *)source value:(NSString *)value;
+(NSString *) toString:(id) object;
+(int) toInt:(id) object;
+(int) toInt:(id) object withDefault:(int)defValue;

+(BOOL) isValidString:(NSString *)str withValidChars:(NSString *)chars;
+(BOOL) isValidEmail:(NSString *)email;
+(BOOL) isValidUserName:(NSString *)userName;
+(BOOL) isValidPassword:(NSString *)password;
+(BOOL) isValidPhone:(NSString *)phone;
+(BOOL) isValidNIF:(NSString *)nif;

+(NSString *)localizedFieldName:(NSString *)field;

+(void) moveViewY:(UIView *)view newY:(CGFloat)newY;

+(void) setOnClick: (UIView *)view withBlock:(UIView_onClicked)onClick;

+(void) setupVerticalRaw:(NSArray *)items sep:(int)sep;
+(void) cleanUpScrollView:(UIScrollView *)sv;

// DELAYED BLOCKS
typedef void(^SMDelayedBlockHandle)(BOOL cancel);
SMDelayedBlockHandle perform_block_after_delay(CGFloat seconds, dispatch_block_t block);
void cancel_delayed_block(SMDelayedBlockHandle delayedHandle);


// DATE AND MONEY FORMATTING
+(NSString *)formatDate:(NSInteger)timestamp;
+(NSString *)formatDateOnly:(NSInteger)timestamp;
+(NSString *)formatDate:(NSInteger)timestamp withFormat:(NSString *)format;
+(NSString *)formatTime:(NSInteger)timestamp;
+(NSString *)formatDateRelative:(NSInteger)timestamp;
+(NSString *) formatMoney:(double) amount;

@end
