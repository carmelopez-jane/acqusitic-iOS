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


#import "DownDatePicker.h"
#import "Utils.h"


@implementation DownDatePicker
{
    NSDate * _previousDate;
}

-(id)initWithTextField:(UITextField *)tf
{
    return [self initWithTextField:tf mode:UIDatePickerModeDate withDate:nil];
}

-(id)initWithTextField:(UITextField *)tf mode:(UIDatePickerMode)mode withDate:(NSDate*) date
{
    self = [super init];
    if (self) {
        
        self.datePickerMode = mode;
        
        self->date = date;
        self->mode = mode;
        //self.dateFormat = @"d 'de' MMMM 'de' yyyy 'a las' HH:mm";
        self->textField = tf;
        self->textField.delegate = self;
       
        // set UI defaults
        self->toolbarStyle = UIBarStyleDefault;
		
        // set language defaults
        self->placeholder = @"";
        self->placeholderWhileSelecting = @"";
		self->toolbarDoneButtonText = @"Aceptar";
        self->toolbarCancelButtonText = @"Cancelar";
        
        // hide the caret and its blinking
        [[textField valueForKey:@"textInputTraits"]
         setValue:[UIColor clearColor]
         forKey:@"insertionPointColor"];
        
        // set the placeholder
        self->textField.placeholder = self->placeholder;
        
        // setup the arrow image
        UIImage* img = [UIImage imageNamed:@"downarrow_trans.png"];   // non-CocoaPods
        if (img != nil) self->textField.rightView = [[UIImageView alloc] initWithImage:img];
        self->textField.rightView.contentMode = UIViewContentModeScaleAspectFit;
        self->textField.rightView.clipsToBounds = YES;
        
        // show the arrow image by default
        [self showArrowImage:YES];

        // set the data array (if present)
        if (date != nil) {
            [self setDate: date];
        }
        
        self.shouldDisplayCancelButton = YES;
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self->textField.text = [dataArray objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [dataArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [dataArray objectAtIndex:row];
}
*/

-(void)doneClicked:(id) sender
{
    // Miramos de obtener la fecha actual del picker
    NSDate * newDate = pickerView.date;
    [self setDate:newDate];
    
    // hides the pickerView
    [textField resignFirstResponder];
    
    self->textField.placeholder = self->placeholder;
    if (_previousDate == nil || ![newDate isEqual:_previousDate]) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        if (self.onValueChange)
            self.onValueChange(self);
    }
}

-(void)cancelClicked:(id)sender
{
    [textField resignFirstResponder]; //hides the pickerView
    [self setDate:_previousDate];
}


- (IBAction)showPicker:(id)sender
{
    _previousDate = self->date;
    
    pickerView = [[UIDatePicker alloc]init];
    pickerView.datePickerMode = self.datePickerMode;
    pickerView.minimumDate = self.minimumDate;
    pickerView.maximumDate = self.maximumDate;
    pickerView.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"];
    //pickerView.minimumDate = [NSDate dateWithTimeIntervalSinceNow:0];
    [pickerView addTarget:self action:@selector(onDatePicked:) forControlEvents:UIControlEventValueChanged];
    
    //If the text field is empty show the place holder otherwise show the last selected option
    if (self->textField.text.length == 0)
    {
        if (self->placeholderWhileSelecting) {
            self->textField.placeholder = self->placeholderWhileSelecting;
        }
    }
    else
    {
        // Poner la fecha actual
        pickerView.date = self->date?self->date:[NSDate date];
    }

    UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = self->toolbarStyle;
    [toolbar sizeToFit];
    
    //space between buttons
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:self->toolbarDoneButtonText
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(doneClicked:)];
    
    if (self.shouldDisplayCancelButton) {
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
                                         initWithTitle:self->toolbarCancelButtonText
                                         style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(cancelClicked:)];
        
        [toolbar setItems:[NSArray arrayWithObjects:cancelButton, flexibleSpace, doneButton, nil]];
    } else {
        [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];
    }


    //custom input view
    textField.inputView = pickerView;
    textField.inputAccessoryView = toolbar;  
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField
{
    [self showPicker:aTextField];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)aTextField {
    [self doneClicked:aTextField];
    aTextField.userInteractionEnabled = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

-(void) onDatePicked:(UIDatePicker *)sender {
    [self setDate:sender.date];
}

-(void)refreshDate {
    [self formatDate];
}

-(void) formatDate {
    if (self->date != nil) {
        if (self->mode == UIDatePickerModeDate) {
            self->textField.text = [Utils formatDateOnly:[self->date timeIntervalSince1970]];
        } else if (self->mode == UIDatePickerModeTime) {
            self->textField.text = [Utils formatTime:[self->date timeIntervalSince1970]];
        } else if (self->mode == UIDatePickerModeDateAndTime) {
            self->textField.text = [Utils formatDate:[self->date timeIntervalSince1970]];
        }
        /*
        NSDateFormatter * fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"];
        fmt.dateFormat = self.dateFormat;
        self->textField.text = [fmt stringFromDate:self->date];
        */
    } else {
        self->textField.text = @"";
    }
}

-(void) setDate:(NSDate*) date
{
    self->date = date;
    [self formatDate];
}

-(NSDate *)date {
    return self->date;
}

-(void) showArrowImage:(BOOL)b
{
    if (b == YES) {
      // set the DownDatePicker arrow to the right (you can replace it with any 32x24 px transparent image: changing size might give different results)
        self->textField.rightViewMode = UITextFieldViewModeAlways;
    }
    else {
        self->textField.rightViewMode = UITextFieldViewModeNever;
    }
}

-(void) setArrowImage:(UIImage*)image
{
    [(UIImageView*)self->textField.rightView setImage:image];
}

-(void) setPlaceholder:(NSString*)str
{
    self->placeholder = str;
    self->textField.placeholder = self->placeholder;
}

-(void) setPlaceholderWhileSelecting:(NSString*)str
{
    self->placeholderWhileSelecting = str;
}

-(void) setAttributedPlaceholder:(NSAttributedString *)attributedString
{
    self->textField.attributedPlaceholder = attributedString;
}

-(void) setToolbarDoneButtonText:(NSString*)str
{
    self->toolbarDoneButtonText = str;
}

-(void) setToolbarCancelButtonText:(NSString*)str
{
    self->toolbarCancelButtonText = str;
}

-(void) setToolbarStyle:(UIBarStyle)style;
{
    self->toolbarStyle = style;
}

-(UIDatePicker*) getPickerView
{
    return self->pickerView;
}

-(UITextField*) getTextField
{
    return self->textField;
}

/**
 Getter for text property.
 @return
 The value of the selected item or NIL NIL if nothing has been selected yet.
 */
- (NSString*) text {
    return self->textField.text;
}

/**
 Setter for text property.
 @param txt
 The value of the item to select or NIL to clear selection.
 */
- (void) setText:(NSString*)txt {
}

@end
