//
//  FormItem.h
//  Acqustic
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormItem.h"

#define FIELD_TYPE_TEXT                 1
#define FIELD_TYPE_FULLTEXT             2
#define FIELD_TYPE_SELECT               3
#define FIELD_TYPE_BOOLEAN              4
#define FIELD_TYPE_INTEGER              5
#define FIELD_TYPE_DOUBLE               6
#define FIELD_TYPE_DATE                 7
#define FIELD_TYPE_TIME                 8
#define FIELD_TYPE_DATETIME             9
#define FIELD_TYPE_EMAIL                10
#define FIELD_TYPE_TELEPHONE            11
#define FIELD_TYPE_NIF                  12
#define FIELD_TYPE_PASSWORD             13
#define FIELD_TYPE_MULTISELECT          14
#define FIELD_TYPE_LONGMULTISELECT      15
#define FIELD_TYPE_PERCENT              16
#define FIELD_TYPE_SEARCH               17
#define FIELD_TYPE_IMAGE                18
#define FIELD_TYPE_AUDIO                19

#define FIELD_TYPE_SECTION              100
#define FIELD_TYPE_SUBNOTE              101
#define FIELD_TYPE_NOTE                 102

#define FIELD_TYPE_CUSTOM               200

@class FBItem;
@class LinearLayoutView;

typedef void (^FormItem_onSearch)(FBItem * sender, NSString * search);

typedef UIView * (^FormItem_custom_getView)(FBItem * sender, int width, NSString * name);
typedef void (^FormItem_custom_setupField)(FBItem * sender, NSObject * data, BOOL readOnly);
typedef void (^FormItem_custom_updateField)(FBItem * sender, NSObject * data);
typedef NSString * (^FormItem_custom_validate)(FBItem * sender, id value);


@interface FBValidator : NSObject
    -(NSString *)validate:(FBItem *)item value:(id)value;
@end

@interface FBRequiredValidator : FBValidator
    -(NSString *)validate:(FBItem *)item value:(id)value;
@end

@interface FBTelephoneValidator : FBValidator
    -(NSString *)validate:(FBItem *)item value:(id)value;
@end

@interface FBCIFValidator : FBValidator
    -(NSString *)validate:(FBItem *)item value:(id)value;
@end

@interface FBEmailValidator : FBValidator
    -(NSString *)validate:(FBItem *)item value:(id)value;
@end


@interface FBItem : NSObject <UIDocumentMenuDelegate, UIDocumentPickerDelegate> {
    NSString * name;
    NSString * fieldName;
    NSString * fieldDescription;
    NSString * imageType;
    int fieldType;
    NSString * valuesIndex;

    UIView * layout;
    int layoutHeight;
    UILabel * labelHolder;
    UITextField * valueHolder;
    UITextView * valueHolderTV;
    NSString * internalValue; // Sólo para algunos casos muy específicos (archivos...)

    int minValue;
    int maxValue;
    NSString *minValueText;
    
    NSObject * picker;

    // Custom
    FormItem_custom_getView onCustomGetView;
    FormItem_custom_setupField onCustomSetupField;
    FormItem_custom_updateField onCustomUpdateField;
    FormItem_custom_validate onCustomValidate;

    // Search
    FormItem_onSearch onSearch;

    // Validación
    NSMutableArray * validators; // FBValidatorDelegate
}

@property NSString * name;
@property NSString * fieldName;
@property NSString * fieldDescription;
@property NSString * imageType;
@property int fieldType;
@property NSString * valuesIndex;
@property UIView * layout;
@property int layoutHeight;
@property UILabel * labelHolder;
@property UITextField * valueHolder;
@property UITextView * valueHolderTV;
@property NSString * internalValue; // Sólo para algunos casos muy específicos (archivos...)
@property int minValue;
@property int maxValue;
@property NSString * minValueText;
@property NSObject * picker;
// Custom
@property FormItem_custom_getView onCustomGetView;
@property FormItem_custom_setupField onCustomSetupField;
@property FormItem_custom_updateField onCustomUpdateField;
@property FormItem_custom_validate onCustomValidate;
// Search
@property FormItem_onSearch onSearch;
// Validación
@property NSMutableArray * validators; // FBValidatorDelegate


-(id) init:(NSString *)name fieldType:(int)fieldType;
-(id) init:(NSString *)name fieldType:(int)fieldType fieldName:(NSString *)fieldName;
-(void) addValidator:(FBValidator *)validator;
-(id) getValue:(NSObject *)obj;
-(void) saveValue:(NSObject *)obj;
-(NSString *) validate;
-(id) getFormValue;
-(void) setupAsReadOnly;
-(UIView *) createLayout:(NSObject *)data forWidth:(int)width readOnly:(BOOL)readOnly;
-(UIView *) updateContent:(NSObject *)data readOnly:(BOOL)readOnly;


@end



@interface FormBuilder : NSObject {
    NSMutableArray * items;
    BOOL readOnly;
}

@property BOOL readOnly;

-(id) init;
-(void) add:(FBItem *)fi;
-(int) fillInForm:(UIView *)container from:(int)yTop withData:(NSObject *)data;
-(void) updateForm:(NSObject *) data;
-(FBItem *) findItem:(NSString *)fieldName;
-(NSString *)validate;
-(void) save:(NSObject *) data;

@end
