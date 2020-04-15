//
//   DownDatePicker.h
// --------------------------------------------------------
//      Lightweight DropDownList/ComboBox control for iOS
//
// by Darkseal, 2013-2015 - MIT License
//
// Website: http://www.ryadel.com/
// GitHub:  http://www.ryadel.com/
//

#import <UIKit/UIKit.h>

@class DownDatePicker;

typedef void (^DownDatePicker_onValueChange)(DownDatePicker * picker);

@interface DownDatePicker : UIControl <UITextFieldDelegate>
{
    UIDatePicker* pickerView;
    IBOutlet UITextField* textField;
    NSDate * date;
    UIDatePickerMode mode;
    NSString* placeholder;
    NSString* placeholderWhileSelecting;
	NSString* toolbarDoneButtonText;
    NSString* toolbarCancelButtonText;
	UIBarStyle toolbarStyle;
}

@property (nonatomic) NSString * text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;
//@property (nonatomic, strong) NSString * dateFormat;
@property UIDatePickerMode datePickerMode;
@property (nonatomic, strong) DownDatePicker_onValueChange onValueChange;

-(id)initWithTextField:(UITextField *)tf;
-(id)initWithTextField:(UITextField *)tf mode:(UIDatePickerMode)mode withDate:(NSDate*) date;
-(void)refreshDate;

@property (nonatomic) BOOL shouldDisplayCancelButton;

/**
 Sets an alternative image to be show to the right part of the textbox (assuming that showArrowImage is set to TRUE).
 @param image
 A valid UIImage
 */
-(void) setArrowImage:(UIImage*)image;

-(void) setDate:(NSDate*) date;
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

-(UIDatePicker*) getPickerView;
-(UITextField*) getTextField;

@end
