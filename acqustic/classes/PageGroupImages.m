//
//  PageGroupImages.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupImages.h"
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
#import "ImageItem.h"

void (^PageGroupImagesChanged)(NSArray * items) = nil;


@interface PageGroupImages ()

@end

@implementation PageGroupImages

@synthesize vHeader, svContent, vHeaderEdit, vDelete;

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageGroupImages"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = [context paramByName:@"sectionTitle"];
    
    int yPos = 0;
    
    groupId = [context intParamByName:@"groupId"];
    NSString * content = [context paramByName:@"imageSources" withDefault:@""];
    
    if (content == nil || [content isEqualToString:@""]) {
        items = [[NSMutableArray alloc] init];
    } else {
        items = [NSMutableArray arrayWithArray:[content componentsSeparatedByString:@","]];
    }
    
    /*
    [pc addParam:@"sectionTitle" withValue:@"Redes"];
    [pc addParam:@"sectionSubtitle" withValue:@"Redes sociales del grupo"];
    [pc addParam:@"sectionHint" withValue:@"Pulsa el botón + para añadir un nuevo enlace a tus redes sociales como Facebook, Instagram o Twitter"];
    [pc addParam:@"itemName" withValue:@"enlace a redes sociales"];
    [pc addParam:@"content" withValue:self->group.social];
     */
    
    // Añadimos los eventos
    FormItemHeader * hitems = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hitems.lblLabel.text = [context paramByName:@"sectionSubtitle"];
    [Utils setOnClick:hitems.vIcon withBlock:^(UIView *sender) {
        [self addItem];
    }];
    [self.svContent addSubview:hitems];
    yPos += 55;
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:sep];
    yPos++;

    itemsYpos = yPos;
    [self fillInItems];

    [Utils setOnClick:vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        // Guardamos los cambios...
        if (PageGroupImagesChanged)
            PageGroupImagesChanged(self->items);
        [theApp.pages goBack];
    }];
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) fillInItems {
    if (itemsList != nil) {
        for (int i=0;i<itemsList.count;i++) {
            [itemsList[i] removeFromSuperview];
        }
        [itemsList removeAllObjects];
    } else {
        itemsList = [[NSMutableArray alloc] init];
    }
    if (footerSep)
        [footerSep removeFromSuperview];
    if (footerSubnote)
        [footerSubnote removeFromSuperview];

    int yPos = itemsYpos;
    for (int i=0;i<items.count;i++) {
        if (i > 0) {
            FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
            [self.svContent addSubview:sep];
            yPos++;
            [itemsList addObject:sep];
        }
        NSString * s = items[i];
        int marginH = 20;
        int marginV = 10;
        yPos += marginV;
        Imageitem * item = [[Imageitem alloc] initWithFrame:CGRectMake(0+marginH,yPos, self.svContent.frame.size.width-2*marginH, 244)];
        [item.ivImage setImageWithURL:[NSURL URLWithString:s]];
        item.tag = i;
        item.vDelete.tag = i;
        [Utils setOnClick:item.vDelete withBlock:^(UIView *sender) {
            [self deleteImage:sender];
        }];
        [Utils setOnClick:item withBlock:^(UIView *sender) {
            NSInteger index = sender.tag;
            self->itemIndex = index;
            [self captura];
        }];
        [self.svContent addSubview:item];
        [itemsList addObject:item];
        yPos += 244 + marginV;
    }
    
    
    footerSep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:footerSep];
    yPos++;
    yPos += 20;
    footerSubnote = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    footerSubnote.lblLabel.text = [_ctx paramByName:@"sectionHint"];
    [footerSubnote updateSize];
    [self.svContent addSubview:footerSubnote];
    yPos += footerSubnote.frame.size.height;
    
    [itemsList addObject:footerSep];
    [itemsList addObject:footerSubnote];
    
    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) addItem {
    itemIndex = 0;
    [self captura];
}


-(void) deleteImage:(UIView *)sender {
    NSInteger index = sender.tag;
    [theApp QueryMessage:@"¿Seguro que quieres borrar esta imagen?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [self->items removeObjectAtIndex:index];
            [self fillInItems];
        }
    }];
}


-(void) captura {
    NSArray * options = @[@"De la cámara", @"De la biblioteca de imágenes"];
    PageGroupImages * refThis = self;
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
        UIImage * dest = [PageGroupImages imageWithImage:chosenImage scaledToSize:newSize];
        // Ahora nos quedamos con la parte central...
        //CGRect cropRect = CGRectMake(xOffset,yOffset, 204,204);
        //CGImageRef imageRef = CGImageCreateWithImageInRect([dest CGImage], cropRect);
        // or use the UIImage wherever you like
        //dest = [UIImage imageWithCGImage:imageRef];
        //CGImageRelease(imageRef);
        // Ahora guardamos la imagen a una carpeta temporal
        NSString * newFile = [PageGroupImages saveImage:dest withName:[NSString stringWithFormat:@"image_%ld.jpg", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
        // La miramos de subir al servidor...
        [theApp showBlockView];
        [WSDataManager uploadImage:newFile withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                // Actualizamos la imagen...
                if (self->itemIndex > 0) {
                    // Estamos modificando un elemento actual
                    [self->items setObject:(NSString*)result atIndexedSubscript:self->itemIndex];
                } else {
                    [self->items addObject:(NSString *)result];
                }
                [self fillInItems];
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
