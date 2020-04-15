//
//  FormItem.m
//  Acqustic
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "FormBuilder.h"
#import "FormItem.h"
#import "FormItemHeader.h"
#import "FormItemAudio.h"
#import "FormItemFulltext.h"
#import "FormItemImage.h"
#import "FormItemLongoption.h"
#import "FormItemPercent.h"
#import "FormItemSearchtext.h"
#import "FormItemSep.h"
#import "FormItemSepfull.h"
#import "FormItemSimpleoption.h"
#import "FormItemSimpletext.h"
#import "FormItemNote.h"
#import "FormItemSubnote.h"
#import "FormItemSwitch.h"
#import "DownDatePicker.h"
#import "DownOptionsPicker.h"
#import "DownMOptionsPicker.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"
#import "AppConfig.h"
#import "PageUploadImage.h"
#import <MobileCoreServices/MobileCoreServices.h>




@implementation FBValidator

-(NSString *)validate:(FBItem *)item value:(id)value {
    return nil;
}

@end

@implementation FBRequiredValidator

-(NSString *)validate:(FBItem *)item value:(id)value {
    NSString * error = [NSString stringWithFormat:@"El campo %@ es obligatorio", item.name];
    if (value == nil) {
        return error;
    }
    NSObject * v = (NSObject *)value;
    if ([v isKindOfClass:NSString.class] && [((NSString *)v) isEqualToString:@""]) {
        return error;
    }
    return nil;
}

@end

@implementation FBTelephoneValidator

-(NSString *)validate:(FBItem *)item value:(id)value {
    NSString * error = [NSString stringWithFormat:@"El campo %@ no es un teléfono válido", item.name];
    if (value == nil)
        return nil;
    if ([value isEqualToString:@""])
        return nil;
    NSString * v = [NSString stringWithFormat:@"%@", value];
    if ([Utils isValidPhone:v])
        return nil;
    return error;
}

@end

@implementation FBCIFValidator

-(NSString *)validate:(FBItem *)item value:(id)value {
    NSString * error = [NSString stringWithFormat:@"El campo %@ no es un NIF/NIE/CIF válido", item.name];
    if (value == nil)
        return nil;
    if ([value isEqualToString:@""])
        return nil;
    NSString * v = [NSString stringWithFormat:@"%@", value];
    if ([Utils isValidNIF:v])
        return nil;
    return error;
}

@end

@implementation FBEmailValidator

-(NSString *)validate:(FBItem *)item value:(id)value {
    NSString * error = [NSString stringWithFormat:@"El campo %@ no es un email válido", item.name];
    if (value == nil)
        return nil;
    if ([value isEqualToString:@""])
        return nil;
    NSString * v = [NSString stringWithFormat:@"%@", value];
    if ([Utils isValidEmail:v])
        return nil;
    return error;
}

@end





@implementation FBItem

@synthesize name, fieldName, fieldDescription, imageType, fieldType, valuesIndex, layout, layoutHeight, labelHolder, valueHolder, valueHolderTV;
@synthesize internalValue, minValue, maxValue, minValueText, picker;
// Custom
@synthesize  onCustomGetView;
@synthesize  onCustomSetupField;
@synthesize  onCustomUpdateField;
@synthesize  onCustomValidate;
// Search
@synthesize  onSearch;
// Validación
@synthesize  validators; // FBValidatorDelegate


-(id) init:(NSString *)name fieldType:(int)fieldType {
    self = [super init];
    if (self) {
        self.name = name;
        self.fieldType = fieldType;
        self.validators = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) init:(NSString *)name fieldType:(int)fieldType fieldName:(NSString *)fieldName {
    self = [super init];
    if (self) {
        self.name = name;
        self.fieldType = fieldType;
        self.fieldName = fieldName;
        self.validators = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addValidator:(FBValidator *)validator {
    [self.validators addObject:validator];
}

-(id) getValue:(NSObject *)obj {
    return [obj valueForKey:self.fieldName];
}

-(void) saveValue:(NSObject *)obj {
    if (self.fieldName) {
        [obj setValue:[self getFormValue] forKey:self.fieldName];
    }
}

-(NSString *) validate {
    id value = [self getFormValue];
    if (fieldType == FIELD_TYPE_CUSTOM && self.onCustomValidate) {
        NSString * res = self.onCustomValidate(self, value);
        if (res != nil)
            return res;
    }
    for (int i=0;i<self.validators.count;i++) {
        FBValidator * validator = self.validators[i];
        NSString * res = [validator validate:self value:value];
        if (res != nil)
            return res;
    }
    return nil;
}

-(id) getFormValue {
    NSString * val;
    switch (fieldType) {
        case FIELD_TYPE_SECTION:
        case FIELD_TYPE_NOTE:
        case FIELD_TYPE_SUBNOTE:
            return nil;
        case FIELD_TYPE_IMAGE:
        case FIELD_TYPE_AUDIO:
        case FIELD_TYPE_TEXT:
        case FIELD_TYPE_EMAIL:
        case FIELD_TYPE_NIF:
        case FIELD_TYPE_TELEPHONE:
        case FIELD_TYPE_PASSWORD:
        case FIELD_TYPE_SEARCH:
            return valueHolder.text;
        case FIELD_TYPE_INTEGER:
            val = valueHolder.text;
            if (val == nil || [val isEqualToString:@""])
                return nil;
            return [NSNumber numberWithInteger:valueHolder.text.integerValue];
        case FIELD_TYPE_DOUBLE:
            val = valueHolder.text;
            if (val == nil || [val isEqualToString:@""])
                return nil;
            return [NSNumber numberWithDouble:valueHolder.text.doubleValue];
        case FIELD_TYPE_DATE:
        case FIELD_TYPE_TIME:
        case FIELD_TYPE_DATETIME: {
            NSDate * date = ((DownDatePicker *)self.picker).date;
            if (date == nil)
                return [NSNumber numberWithInteger:0];
            else
                return [NSNumber numberWithInteger:[date timeIntervalSince1970]];
        }
        case FIELD_TYPE_SELECT:
            return [((DownOptionsPicker *)self.picker) getSelectedValue];
        case FIELD_TYPE_MULTISELECT:
        case FIELD_TYPE_LONGMULTISELECT:
            return [((DownMOptionsPicker *)self.picker) getSelectedValues];
        case FIELD_TYPE_FULLTEXT:
            return valueHolderTV.text;
        case FIELD_TYPE_BOOLEAN:
            return [NSNumber numberWithBool:((FormItemSwitch *)layout).swValue.isOn];
        case FIELD_TYPE_PERCENT:
            return [((DownOptionsPicker *)self.picker) getSelectedValue];
    }
    return nil;

}

-(void) setupAsReadOnly {
    if (valueHolder != nil) {
        valueHolder.enabled = NO;
    }
}

-(UIView *) createLayout:(NSObject *)data forWidth:(int)width readOnly:(BOOL)readOnly {
    NSString * value;
    FBItem * refThis;;
    switch (fieldType) {
        case FIELD_TYPE_SECTION: {
            self.layout = [[FormItemHeader alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemHeader *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            ((FormItemHeader *)self.layout).ivIcon.hidden = YES;
            ((FormItemHeader *)self.layout).vIcon.hidden = YES;
            break;
        }
        case FIELD_TYPE_NOTE: {
            self.layout = [[FormItemNote alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemNote *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            [((FormItemNote *)self.layout) updateSize];
            break;
        }
        case FIELD_TYPE_SUBNOTE: {
            self.layout = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSubnote *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            [((FormItemSubnote *)self.layout) updateSize];
            break;
        }
        case FIELD_TYPE_IMAGE: {
            self.layout = [[FormItemImage alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemImage *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemImage *)self.layout).tfValue;
            self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            if ([self.valueHolder.text isEqualToString:@""]) {
                ((FormItemImage *)self.layout).ivIcon.image = [UIImage imageNamed:@"icon_images_off.png"];
            } else {
                ((FormItemImage *)self.layout).ivIcon.image = [UIImage imageNamed:@"icon_images_on.png"];
            }
            [((FormItemImage *)self.layout) updateSize];
            self.valueHolder.hidden = YES;
            [Utils setOnClick:layout withBlock:^(UIView *sender) {
                PageContext * ctx = [[PageContext alloc] init];
                [ctx addParam:@"sectionTitle" withValue:self->name];
                [ctx addParam:@"uploadMessage" withValue:self->fieldDescription];
                [ctx addParam:@"imageSource" withValue:self->valueHolder.text];
                PageUploadImageChanged = ^(NSString * value) {
                    self.valueHolder.text = value;
                    if (value == nil || [value isEqualToString:@""]) {
                        ((FormItemImage *)self.layout).ivIcon.image = [UIImage imageNamed:@"icon_images_off.png"];
                    } else {
                        ((FormItemImage *)self.layout).ivIcon.image = [UIImage imageNamed:@"icon_images_on.png"];
                    }
                };
                [theApp.pages jumpToPage:@"UPLOADIMAGE" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
            break;
        }
        case FIELD_TYPE_AUDIO: {
            self.layout = [[FormItemAudio alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemAudio *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemAudio *)self.layout).tfValue;
            self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            if ([self.valueHolder.text isEqualToString:@""]) {
                ((FormItemAudio *)self.layout).ivIcon.image = [UIImage imageNamed:@"icon_audios_off.png"];
            } else {
                ((FormItemAudio *)self.layout).ivIcon.image = [UIImage imageNamed:@"icon_audios_on.png"];
            }
            [((FormItemAudio *)self.layout) updateSize];
            self.valueHolder.hidden = YES;
            [Utils setOnClick:layout withBlock:^(UIView *sender) {
                UIDocumentMenuViewController * ctl = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeMP3] inMode:UIDocumentPickerModeImport];
                ctl.delegate = self;
                ctl.modalPresentationStyle = UIModalPresentationFullScreen;
                [theApp.viewController presentViewController:ctl animated:YES completion:nil];
                /*
                 PageContext ctx = new PageContext();
                 ctx.addParam("sectionTitle", name);
                 ctx.addParam("uploadMessage", fieldDescription);
                 ctx.addParam("imageSource", valueHolder.text);
                 PageUploadImage.resultListener = new PageUploadImage.UploadImageResult() {
                     @Override
                     public void onUploadImageResult(String path) {
                         valueHolder.setText(path);
                         if (valueHolder.text.equals("")) {
                             ((ImageView)layout.findViewById(R.id.iv_icon)).setImageResource(R.drawable.icon_images_off);
                         } else {
                             ((ImageView)layout.findViewById(R.id.iv_icon)).setImageResource(R.drawable.icon_images_on);
                         }

                     }
                 };
                 Acqustic.theApp.getPages().jumpToPage("UPLOADIMAGE", ctx, PageEngine.TRANS_ADVANCE, PageEngine.TRANS_BACK, false, true);

                 */
            }];
            break;
        }
        case FIELD_TYPE_TEXT:
        case FIELD_TYPE_NIF: {
            self.layout = [[FormItemSimpletext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpletext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpletext *)self.layout).tfValue;
            self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            [((FormItemSimpletext *)self.layout) updateSize];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_PASSWORD: {
            self.layout = [[FormItemSimpletext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpletext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpletext *)self.layout).tfValue;
            self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            self.valueHolder.secureTextEntry = YES;
            [((FormItemSimpletext *)self.layout) updateSize];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_EMAIL: {
            self.layout = [[FormItemSimpletext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpletext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpletext *)self.layout).tfValue;
            self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            self.valueHolder.keyboardType = UIKeyboardTypeEmailAddress;
            [((FormItemSimpletext *)self.layout) updateSize];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_TELEPHONE: {
            self.layout = [[FormItemSimpletext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpletext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpletext *)self.layout).tfValue;
            self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            self.valueHolder.keyboardType = UIKeyboardTypePhonePad;
            [((FormItemSimpletext *)self.layout) updateSize];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_INTEGER:
        case FIELD_TYPE_DOUBLE: {
            self.layout = [[FormItemSimpletext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpletext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpletext *)self.layout).tfValue;
            self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            self.valueHolder.keyboardType = UIKeyboardTypeDecimalPad;
            [((FormItemSimpletext *)self.layout) updateSize];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_DATE: {
            self.layout = [[FormItemSimpletext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpletext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpletext *)self.layout).tfValue;
            [((FormItemSimpletext *)self.layout) updateSize];
            NSDate * date = nil;
            long dateTS = [[self getValue:data] integerValue];
            if (dateTS != 0) {
                date = [NSDate dateWithTimeIntervalSince1970:dateTS];
                self.valueHolder.text = [NSString stringWithFormat:@"%@", [Utils formatDateOnly:dateTS]];
            } else {
                self.valueHolder.text = @"";
            }
            self.picker = [[DownDatePicker alloc] initWithTextField:self.valueHolder mode: UIDatePickerModeDate withDate:date];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_TIME: {
            self.layout = [[FormItemSimpletext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpletext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpletext *)self.layout).tfValue;
            [((FormItemSimpletext *)self.layout) updateSize];
            NSDate * date = nil;
            long dateTS = [[self getValue:data] integerValue];
            if (dateTS != 0) {
                date = [NSDate dateWithTimeIntervalSince1970:dateTS];
                self.valueHolder.text = [NSString stringWithFormat:@"%@", [Utils formatDate:dateTS]];
            } else {
                self.valueHolder.text = @"";
            }
            self.picker = [[DownDatePicker alloc] initWithTextField:self.valueHolder mode:UIDatePickerModeTime withDate:date];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_DATETIME: {
            self.layout = [[FormItemSimpletext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpletext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpletext *)self.layout).tfValue;
            [((FormItemSimpletext *)self.layout) updateSize];
            NSDate * date = nil;
            long dateTS = [[self getValue:data] integerValue];
            if (dateTS != 0) {
                date = [NSDate dateWithTimeIntervalSince1970:dateTS];
                self.valueHolder.text = [Utils formatDate:dateTS];
            } else {
                self.valueHolder.text = @"";
            }
            self.picker = [[DownDatePicker alloc] initWithTextField:self.valueHolder mode:UIDatePickerModeDateAndTime withDate:date];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_SELECT: {
            self.layout = [[FormItemSimpleoption alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpleoption *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpleoption *)self.layout).tfValue;
            [((FormItemSimpleoption *)self.layout) updateSize];
            //self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            //UIUtils.setOptionsPicker(layout, R.id.tf_value, valuesIndex, (String) getValue(data), nil);
            NSArray * vData = [theApp.appConfig getValues:self.valuesIndex];
            NSMutableArray * options = [[NSMutableArray alloc] init];
            NSMutableArray * values = [[NSMutableArray alloc] init];
            NSString * value = [self getValue:data];
            if (value == nil)
                value = @"";
            int selected = -1;
            for (int i=0;i<vData.count;i++) {
                NSDictionary * item = vData[i];
                [options addObject:item[@"title_es"]];
                [values addObject:[NSString stringWithFormat:@"%@",item[@"value"]]];
                if ([[NSString stringWithFormat:@"%@",item[@"value"]] isEqualToString:value]) {
                    selected = i;
                }
            }
            self.picker = [[DownOptionsPicker alloc] initWithTextField:self.valueHolder withData:options andValues:values];
            [((DownOptionsPicker *)self.picker) setSelectedIndex:selected];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_MULTISELECT: {
            self.layout = [[FormItemSimpleoption alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpleoption *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpleoption *)self.layout).tfValue;
            [((FormItemSimpleoption *)self.layout) updateSize];
            //self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            //UIUtils.setOptionsPicker(layout, R.id.tf_value, valuesIndex, (String) getValue(data), nil);
            NSArray * vData = [theApp.appConfig getValues:self.valuesIndex];
            NSMutableArray * options = [[NSMutableArray alloc] init];
            NSMutableArray * values = [[NSMutableArray alloc] init];
            NSString * value = [self getValue:data];
            if (value == nil)
                value = @"";
            for (int i=0;i<vData.count;i++) {
                NSDictionary * item = vData[i];
                [options addObject:item[@"title_es"]];
                [values addObject:[NSString stringWithFormat:@"%@",item[@"value"]]];
            }
            self.picker = [[DownMOptionsPicker alloc] initWithTextField:self.valueHolder withData:options andValues:values];
            [((DownMOptionsPicker *)self.picker) setSelectedValues:[self getValue:data]];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_LONGMULTISELECT: {
            self.layout = [[FormItemLongoption alloc] initWithFrame:CGRectMake(0,0,width, 80)];
            self.labelHolder = ((FormItemLongoption *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemLongoption *)self.layout).tfValue;
            //self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            //UIUtils.setOptionsPicker(layout, R.id.tf_value, valuesIndex, (String) getValue(data), nil);
            NSArray * vData = [theApp.appConfig getValues:self.valuesIndex];
            NSMutableArray * options = [[NSMutableArray alloc] init];
            NSMutableArray * values = [[NSMutableArray alloc] init];
            NSString * value = [self getValue:data];
            if (value == nil)
                value = @"";
            for (int i=0;i<vData.count;i++) {
                NSDictionary * item = vData[i];
                [options addObject:item[@"title_es"]];
                [values addObject:[NSString stringWithFormat:@"%@",item[@"value"]]];
            }
            self.picker = [[DownMOptionsPicker alloc] initWithTextField:self.valueHolder withData:options andValues:values];
            [((DownMOptionsPicker *)self.picker) setSelectedValues:[self getValue:data]];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_FULLTEXT: {
            self.layout = [[FormItemFulltext alloc] initWithFrame:CGRectMake(0,0,width, 160)];
            self.labelHolder = ((FormItemFulltext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolderTV = ((FormItemFulltext *)self.layout).tvValue;
            self.valueHolderTV.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_BOOLEAN: {
            self.layout = [[FormItemSwitch alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemFulltext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            value = [NSString stringWithFormat:@"%@", [self getValue:data]];
            if ([value isEqualToString:@"1"]) {
                UISwitch * sw = ((FormItemSwitch *)self.layout).swValue;
                sw.on = YES;
            } else {
                UISwitch * sw = ((FormItemSwitch *)self.layout).swValue;
                sw.on = NO;
            }
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_PERCENT: {
            self.layout = [[FormItemSimpleoption alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSimpleoption *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSimpleoption *)self.layout).tfValue;
            [((FormItemSimpleoption *)self.layout) updateSize];
            if (self.maxValue == 0)
                self.maxValue = 100;
            NSMutableArray * options = [[NSMutableArray alloc] init];
            NSMutableArray * values = [[NSMutableArray alloc] init];
            int value = 0;
            NSNumber * v = [self getValue:data];
            if (v)
                value = [v intValue];
            for (int i=self.minValue;i<=self.maxValue;i++) {
                if (i == 0 && self.minValueText != nil) {
                    [options addObject:self.minValueText];
                } else {
                    [options addObject:[NSString stringWithFormat:@"%d %%", i]];
                }
                [values addObject:[NSString stringWithFormat:@"%d", i]];
            }
            if (value < self.minValue)
                value = self.minValue;
            if (value > self.maxValue)
                value = self.maxValue;
            self.picker = [[DownOptionsPicker alloc] initWithTextField:self.valueHolder withData:options andValues:values];
            ((DownOptionsPicker *)self.picker).selectedIndex = value - self.minValue;
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
        case FIELD_TYPE_CUSTOM: {
            self.layout = self.onCustomGetView(self, width, self.name);
            self.onCustomSetupField(self, data, readOnly);
            break;
        }
        case FIELD_TYPE_SEARCH: {
            self.layout = [[FormItemSearchtext alloc] initWithFrame:CGRectMake(0,0,width, 55)];
            self.labelHolder = ((FormItemSearchtext *)self.layout).lblLabel;
            self.labelHolder.text = self.name;
            self.valueHolder = ((FormItemSearchtext *)self.layout).tfValue;
            self.valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            self.valueHolder.keyboardType = UIKeyboardTypeWebSearch;
            [((FormItemSearchtext *)self.layout) updateSize];
            refThis = self;
            [Utils setOnClick:((FormItemSearchtext *)self.layout).vIcon withBlock:^(UIView *sender) {
                if (refThis.onSearch)
                    refThis.onSearch(refThis, refThis.valueHolder.text);
            }];
            if (readOnly) {
                [self setupAsReadOnly];
            }
            break;
        }
    }
    return layout;
}

-(void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
    // Aquí escogemos el documento
    NSLog(@"document: %@", documentMenu);
    documentPicker.delegate = self;
    [theApp.viewController presentViewController:documentPicker animated:YES completion:nil];
}

-(void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    NSLog(@"URL %@", url);
}

-(UIView *) updateContent:(NSObject *)data readOnly:(BOOL)readOnly {
    NSString * temp;
    switch (fieldType) {
        case FIELD_TYPE_SECTION:
        case FIELD_TYPE_NOTE:
        case FIELD_TYPE_SUBNOTE:
            break;
        case FIELD_TYPE_IMAGE:
            valueHolder.text = self.internalValue = [NSString stringWithFormat:@"%@", [self getValue:data]];
            if ([valueHolder.text isEqualToString:@""]) {
                [((FormItemImage *)self.layout).ivIcon setImage:[UIImage imageNamed:@"icon_images_off.png"]];
            } else {
                [((FormItemImage *)self.layout).ivIcon setImage:[UIImage imageNamed:@"icon_images_on.png"]];
            }
            break;
        case FIELD_TYPE_AUDIO:
            valueHolder.text = self.internalValue = [NSString stringWithFormat:@"%@", [self getValue:data]];
            if ([valueHolder.text isEqualToString:@""]) {
                [((FormItemImage *)self.layout).ivIcon setImage:[UIImage imageNamed:@"icon_audios_off.png"]];
            } else {
                [((FormItemImage *)self.layout).ivIcon setImage:[UIImage imageNamed:@"icon_audios_on.png"]];
            }
            break;
        case FIELD_TYPE_TEXT:
        case FIELD_TYPE_NIF:
        case FIELD_TYPE_PASSWORD:
        case FIELD_TYPE_EMAIL:
        case FIELD_TYPE_TELEPHONE:
        case FIELD_TYPE_INTEGER:
        case FIELD_TYPE_DOUBLE:
        case FIELD_TYPE_SEARCH:
            valueHolder.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            break;
        case FIELD_TYPE_FULLTEXT:
            valueHolderTV.text = [NSString stringWithFormat:@"%@", [self getValue:data]];
            break;
        case FIELD_TYPE_DATE:
        case FIELD_TYPE_TIME:
        case FIELD_TYPE_DATETIME: {
            NSDate * date = nil;
            long dateTS = [[self getValue:data] integerValue];
            if (dateTS != 0) {
                date = [NSDate dateWithTimeIntervalSince1970:dateTS];
                self.valueHolder.text = [NSString stringWithFormat:@"%@", [Utils formatDate:dateTS]];
            } else {
                self.valueHolder.text = @"";
            }
            [((DownDatePicker *)self.picker) setDate:date];
            break;
        }
        case FIELD_TYPE_SELECT: {
            NSString * value = [NSString stringWithFormat:@"%@", [self getValue:data]];
            [((DownOptionsPicker *)self.picker) setValue:value];
            break;
        }
        case FIELD_TYPE_MULTISELECT:
        case FIELD_TYPE_LONGMULTISELECT: {
            //UIUtils.setMultiOptionsPicker(layout, R.id.tf_value, valuesIndex, (String) getValue(data), nil);
            break;
        }
        case FIELD_TYPE_BOOLEAN: {
                NSString * value = [NSString stringWithFormat:@"%@", [self getValue:data]];
                if ([value boolValue] == YES) {
                    ((FormItemSwitch *)self.layout).swValue.on = YES;
                } else {
                    ((FormItemSwitch *)self.layout).swValue.on = NO;
                }
            }
            break;
        case FIELD_TYPE_PERCENT: {
            NSString * value = [NSString stringWithFormat:@"%@", [self getValue:data]];
            [((DownOptionsPicker *)self.picker) setValue:value];
            break;
        }
        case FIELD_TYPE_CUSTOM:
            onCustomUpdateField(self, data);
            break;
    }
    return layout;
}

@end

@implementation FormBuilder

@synthesize readOnly;

-(id) init {
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
    }
    return self;

}

-(void) add:(FBItem *)fi {
    [items addObject:fi];
}

-(int) fillInForm:(UIView *)container from:(int)yTop withData:(NSObject *)data {
    CGRect fr;
    int width = container.frame.size.width;
    for (int i=0;i<items.count;i++) {
        FBItem * item = items[i];
        if (i > 0 && item.fieldType != FIELD_TYPE_SECTION && item.fieldType != FIELD_TYPE_NOTE && item.fieldType != FIELD_TYPE_SUBNOTE) {
            // Añadimos separador
            FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yTop,width,1)];
            [container addSubview:sep];
            yTop++;
        }
        UIView * v = [item createLayout:data forWidth:width readOnly:readOnly];
        fr = v.frame;
        fr.origin.y = yTop;
        v.frame = fr;
        [container addSubview:v];
        yTop += v.frame.size.height;
    }
    [Utils setOnClick:container withBlock:^(UIView *sender) {
        // Quitamos el teclado
    }];
    
    return yTop;
}

-(void) updateForm:(NSObject *) data {
    for (int i=0;i<items.count;i++) {
        FBItem * item = items[i];
        [item updateContent:data readOnly:readOnly];
    }
}

-(FBItem *) findItem:(NSString *)fieldName {
    for (int i=0;i<items.count;i++) {
        FBItem * item = items[i];
        if (item.fieldName && [item.fieldName isEqualToString:fieldName]) {
            return item;
        }
    }
    return nil;
}

-(NSString *)validate {
    for (int i=0;i<items.count;i++) {
        FBItem * item = items[i];
        NSString * res = [item validate];
        if (res != nil)
            return res;
    }
    return nil;
}

-(void) save:(NSObject *) data {
    for (int i=0;i<items.count;i++) {
        FBItem * item = items[i];
        [item saveValue:data];
    }
}



@end
