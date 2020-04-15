//
//  FormImageInput.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "FormImageInput.h"
#import "Nestor.h"
#import "AppDelegate.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation FormImageInput

@synthesize contentView, lblTitle, lblSubtitle, vDropImage, ivDropImage;



-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit];
    }
    return self;
}

-(void)internalInit {
    NSBundle * bundle = [NSBundle bundleForClass:self.class];
    if (bundle) {
        [bundle loadNibNamed:@"FormImageInput" owner:self options:nil];
        if (self.contentView) {
            [self addSubview:self.contentView];
            self.contentView.frame = self.bounds;
        }
    }
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    [self.contentView prepareForInterfaceBuilder];
}

-(int) setup:(NSDictionary *)config lang:(NSString *)lang value:(NSString *)value error:(NSString *)error {
    lblTitle.text = config[[NSString stringWithFormat:@"title_%@", lang]];
    if (config[[NSString stringWithFormat:@"desc_%@", lang]]) {
        lblSubtitle.text = config[[NSString stringWithFormat:@"desc_%@", lang]];
    } else {
        lblSubtitle.hidden = YES;
    }
    if (error) {
        self.lblRACCError.text = error;
    } else {
        self.lblRACCError.hidden = YES;
    }
    if (config[@"range"]) {
        NSString * allRange = [config[@"range"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if ([allRange containsString:@"-"]) {
            NSArray * parts = [allRange componentsSeparatedByString:@"-"];
            rangeMin = [parts[0] intValue];
            rangeMax = [parts[1] intValue];
        } else {
            rangeMin = 0;
            rangeMax = [allRange  intValue];
        }
    } else {
        rangeMin = rangeMax = 0;
    }
    [Utils setOnClick:self.vDropImage withBlock:^(UIView *sender) {
        [self captura];
    }];
    // Miramos de cargar los valores...
    images = [[NSMutableArray alloc] init];
    _images = [[NSMutableArray alloc] init];
    if (value && ![value isEqualToString:@""]) {
        NSArray * parts = [value componentsSeparatedByString:@";"];
        for (int i=0;i<parts.count;i++) {
            [images addObject: parts[i]];
        }
    }
    [self fillInImages];
    if (images.count > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self checkContent];
        });
    }
    return [self adjustSize];
}

-(void)fillInImages {
    for (int i=0;i<images.count;i++) {
        NSString * image = images[i];
        UIImageView * iv = [[UIImageView alloc] initWithFrame:self.vDropImage.frame];
        if ([image hasPrefix:@"http"]) {
            [iv setImageWithURL:[NSURL URLWithString:image]];
        } else {
            [iv setImage:[UIImage imageWithContentsOfFile:image]];
        }
        [self.contentView addSubview:iv];
        [_images addObject: iv];
    }
}

-(void)addImage:(NSString *)fileName {
    [images insertObject:fileName atIndex:0];
    UIImageView * iv = [[UIImageView alloc] initWithFrame:self.vDropImage.frame];
    [iv setImage:[UIImage imageWithContentsOfFile:fileName]];
    [self.contentView addSubview:iv];
    [_images insertObject:iv atIndex:0];
    [self adjustSize];
    [self checkContent];
}

-(int)adjustSize {
    int yPos = 0;
    CGRect fr;
    [Utils adjustUILabelSize:self.lblTitle forWidth:self.lblTitle.frame.size.width];
    [Utils adjustUILabelSize:self.lblSubtitle forWidth:self.lblSubtitle.frame.size.width];
    yPos = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height + 30; //Sep 30
    if (!self.lblSubtitle.hidden) {
        fr = self.lblSubtitle.frame;
        fr.origin.y = yPos;
        self.lblSubtitle.frame = fr;
        yPos += fr.size.height += 10; // Separador 10
    }
    if (!self.lblRACCError.hidden) {
        [Utils adjustUILabelSize:self.lblRACCError forWidth:self.lblRACCError.frame.size.width];
        fr = self.lblRACCError.frame;
        fr.origin.y = yPos;
        self.lblRACCError.frame = fr;
        yPos += fr.size.height += 10; // Separador 10
    }
    yPos += 10; // Sep 10 más...
    fr = self.vDropImage.frame;
    fr.origin.y = yPos;
    self.vDropImage.frame = fr;
    yPos += fr.size.height + 10;
    for (int i=0;i<_images.count;i++) {
        UIImageView * iv = _images[i];
        fr = iv.frame;
        fr.origin.y = yPos;
        iv.frame = fr;
        yPos += fr.size.height + 10; // Separador 10
    }
    //fr = self.contentView.frame;
    //fr.size.height = yPos;
    //self.contentView.frame = fr;
    fr = self.frame;
    fr.size.height = yPos;
    self.frame = fr;
    return yPos;
}

-(void) captura {
    NSArray * options = @[@"De la cámara", @"De la biblioteca de imágenes"];
    FormImageInput * refThis = self;
    [theApp Menu:@"Añadir imagen" withOptions:options onCommand:^(Popup * pm, int command, NSObject * data) {
        UIImagePickerController *picker = nil;
        if (command == 100) { // CAMARA
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = refThis;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (command == 101) { // CARRETE
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = refThis;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        if (picker != nil) {
            [theApp.viewController presentViewController:picker animated:YES completion:NULL];
        }
    }];
}

+(UIImage *)imageWithImage:(UIImage*)img scaledToSize:(CGSize)newSize
{
    CGFloat scale = img.scale; //[[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *)saveImage:(UIImage *)image withName:(NSString *)name {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * tempDirectory = NSTemporaryDirectory();
    NSString *fullPath = [tempDirectory stringByAppendingPathComponent:name];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    return fullPath;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    // Ajustamos el tamaño de la imagen a 204x204
    if (chosenImage != nil) {
        CGSize size = chosenImage.size;
        CGSize newSize;
        CGFloat xOffset, yOffset;
        if (size.width > size.height) {
            newSize.height = 1200;
            newSize.width = (int)(size.width * 1200/size.height);
            yOffset = 0;
            xOffset = (int)((newSize.width-1200)/2);
        } else {
            newSize.width = 1200;
            newSize.height = (int)(size.height * 1200/size.width);
            xOffset = 0;
            yOffset = (int)((newSize.height-1200)/2);
        }
        UIImage * dest = [FormImageInput imageWithImage:chosenImage scaledToSize:newSize];
        // Ahora nos quedamos con la parte central...
        //CGRect cropRect = CGRectMake(xOffset,yOffset, 204,204);
        //CGImageRef imageRef = CGImageCreateWithImageInRect([dest CGImage], cropRect);
        // or use the UIImage wherever you like
        //dest = [UIImage imageWithCGImage:imageRef];
        //CGImageRelease(imageRef);
        // Ahora guardamos la imagen a una carpeta temporal
        NSString * newFile = [FormImageInput saveImage:dest withName:[NSString stringWithFormat:@"image_%ld.jpg", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
        // Actualizamos la imagen...
        [self addImage:newFile];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void) checkContent {
    BOOL error = NO;
    if (rangeMax != 0) {
        NSInteger size = images.count;
        if (size < rangeMin) {
            error = YES;
        } else if (size > rangeMax) {
            error = YES;
        }
    }
    if (error) {
        if (onValue) {
            onValue(self, nil, nil, 0);
        }
    } else {
        if (onValue) {
            onValue(self, [images componentsJoinedByString:@";"], [images componentsJoinedByString:@";"], 0);
        }
    }
}


@end
