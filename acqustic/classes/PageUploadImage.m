//
//  PageUploadImage.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageUploadImage.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "Performer.h"
#import "Group.h"
#import "WSDataManager.h"
#import "MenuItem.h"
#import "FormItemSubitem.h"
#import "UIImageView+AFNetworking.h"
#import "FormBuilder.h"
#import "FormItemHeader.h"
#import "FormItemSubitem.h"
#import "FormItemSubnote.h"

void (^PageUploadImageChanged)(NSString * item) = nil;


@interface PageUploadImage ()

@end

@implementation PageUploadImage

@synthesize vHeader, svContent, vHeaderEdit, vImageHolder, ivImage, vDelete, ivMessage, lblImage;

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageUploadImage"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = [context paramByName:@"sectionTitle"];
    
    int yPos = 0;
    
    NSString * uploadMessage = [context paramByName:@"uploadMessage"];
    imageSrc = [context paramByName:@"imageSource"];

    if (uploadMessage) {
        self.lblImage.text = uploadMessage;
    }
    
    if (imageSrc != nil && ![imageSrc isEqualToString:@"(null)"] && ![imageSrc isEqualToString:@""]) {
        [self.ivImage setImageWithURL:[NSURL URLWithString:imageSrc]];
        self.ivImage.hidden = NO;
        self.lblImage.hidden = YES;
        self.ivMessage.hidden = YES;
    } else {
        self.ivImage.hidden = YES;
        self.vDelete.hidden = YES;
        self.ivDelete.hidden = YES;
        self.ivImage.hidden = YES;
    }
    
    [Utils setOnClick:vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        // Guardamos los cambios...
        if (PageUploadImageChanged)
            PageUploadImageChanged(self->imageSrc);
        [theApp.pages goBack];
    }];
    
    [Utils setOnClick:self.vDelete withBlock:^(UIView *sender) {
        [self deleteImage];
    }];
    
    [Utils setOnClick:self.vImageHolder withBlock:^(UIView *sender) {
        [self captura];
    }];
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) deleteImage {
    [theApp QueryMessage:@"¿Seguro que quieres borrar esta imagen?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            self.ivImage.image = nil;
            self.ivDelete.hidden = YES;
            self.vDelete.hidden = YES;
            self.ivMessage.hidden = NO;
            self.lblImage.hidden = NO;
            self.ivImage.hidden = YES;
            self->imageSrc = @"";
        }
    }];
}


-(void) captura {
    NSArray * options = @[@"De la cámara", @"De la biblioteca de imágenes"];
    PageUploadImage * refThis = self;
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
        UIImage * dest = [PageUploadImage imageWithImage:chosenImage scaledToSize:newSize];
        // Ahora nos quedamos con la parte central...
        //CGRect cropRect = CGRectMake(xOffset,yOffset, 204,204);
        //CGImageRef imageRef = CGImageCreateWithImageInRect([dest CGImage], cropRect);
        // or use the UIImage wherever you like
        //dest = [UIImage imageWithCGImage:imageRef];
        //CGImageRelease(imageRef);
        // Ahora guardamos la imagen a una carpeta temporal
        NSString * newFile = [PageUploadImage saveImage:dest withName:[NSString stringWithFormat:@"image_%ld.jpg", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
        // La miramos de subir al servidor...
        [theApp showBlockView];
        [WSDataManager uploadImage:newFile withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                // Actualizamos la imagen...
                self->imageSrc = (NSString *)result;
                [self.ivImage setImageWithURL:[NSURL URLWithString:self->imageSrc]];
                self.ivImage.hidden = NO;
                self.vDelete.hidden = NO;
                self.ivDelete.hidden = NO;
                self.ivMessage.hidden = YES;
                self.lblImage.hidden = YES;
            } else {
                [theApp stdError:code];
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
