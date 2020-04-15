//
//   DownOptionsPicker.h
// --------------------------------------------------------
//      Lightweight DropDownList/ComboBox control for iOS
//
// by Darkseal, 2013-2015 - MIT License
//
// Website: http://www.ryadel.com/
// GitHub:  http://www.ryadel.com/
//

#import <UIKit/UIKit.h>

@class DownOptionsPicker;

typedef void (^DownOptionsPicker_onValueChange)(DownOptionsPicker * picker);

@interface DownOptionsPicker : UIControl<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    UIPickerView* pickerView;
    IBOutlet UITextField* textField;
    NSArray* dataArray;
    NSArray* valuesArray;
    NSString* placeholder;
    NSString* placeholderWhileSelecting;
	NSString* toolbarDoneButtonText;
    NSString* toolbarCancelButtonText;
	UIBarStyle toolbarStyle;
}

@property (nonatomic) NSString* text;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) DownOptionsPicker_onValueChange onValueChange;

-(id)initWithTextField:(UITextField *)tf;
-(id)initWithTextField:(UITextField *)tf withData:(NSArray*) data;
-(id)initWithTextField:(UITextField *)tf withData:(NSArray*) data andValues:(NSArray *)values;

@property (nonatomic) BOOL shouldDisplayCancelButton;

/**
 Sets an alternative image to be show to the right part of the textbox (assuming that showArrowImage is set to TRUE).
 @param image
 A valid UIImage
 */
-(void) setArrowImage:(UIImage*)image;

-(void) setData:(NSArray*) data;
-(void) setValues:(NSArray*) values;
-(void) setPlaceholder:(NSString*)str;
-(void) setPlaceholderWhileSelecting:(NSString*)str;
-(void) setAttributedPlaceholder:(NSAttributedString *)attributedString;
-(void) setToolbarDoneButtonText:(NSString*)str;
-(void) setToolbarCancelButtonText:(NSString*)str;
-(void) setToolbarStyle:(UIBarStyle)style;

/**
 TRUE to show the rightmost arrow image, FALSE to hide it.
 @param b
 TRUE to show the rightmost arrow image, FALSE to hide it.
 */
-(void) showArrowImage:(BOOL)b;

-(UIPickerView*) getPickerView;
-(UITextField*) getTextField;

/**
 Retrieves the string value at the specified index.
 @return
 The value at the given index or NIL if nothing has been selected yet.
 */
-(NSString*) getDataAtIndex:(NSInteger)index;
-(NSString*) getValueAtIndex:(NSInteger)index;
-(NSString*) getSelectedValue;
/**
 Sets the zero-based index of the selected item: -1 can be used to clear selection.
 @return
 The value at the given index or NIL if nothing has been selected yet.
 */
-(void) setValueAtIndex:(NSInteger)index;
-(void) setValue:(NSString *)value;

-(void) reset;
@end
