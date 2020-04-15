//
//Copyright (c) 2011, Tim Cinel
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions are met:
//* Redistributions of source code must retain the above copyright
//notice, this list of conditions and the following disclaimer.
//* Redistributions in binary form must reproduce the above copyright
//notice, this list of conditions and the following disclaimer in the
//documentation and/or other materials provided with the distribution.
//* Neither the name of the <organization> nor the
//names of its contributors may be used to endorse or promote products
//derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//åLOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ActionSheetMStringPicker.h"

@interface ActionSheetMStringPicker()
@property (nonatomic,strong) NSArray *data;
@property (nonatomic,strong) NSMutableArray * selectedIndexes;
@end

@implementation ActionSheetMStringPicker

+ (instancetype)showPickerWithTitle:(NSString *)title rows:(NSArray *)strings initialSelection:(NSArray *)indexes doneBlock:(ActionMStringDoneBlock)doneBlock cancelBlock:(ActionMStringCancelBlock)cancelBlockOrNil origin:(id)origin {
    ActionSheetMStringPicker * picker = [[ActionSheetMStringPicker alloc] initWithTitle:title rows:strings initialSelection:indexes doneBlock:doneBlock cancelBlock:cancelBlockOrNil origin:origin];
    [picker showActionSheetPicker];
    return picker;
}

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray *)strings initialSelection:(NSArray *)indexes doneBlock:(ActionMStringDoneBlock)doneBlock cancelBlock:(ActionMStringCancelBlock)cancelBlockOrNil origin:(id)origin {
    self = [self initWithTitle:title rows:strings initialSelection:indexes target:nil successAction:nil cancelAction:nil origin:origin];
    if (self) {
        self.onActionSheetDone = doneBlock;
        self.onActionSheetCancel = cancelBlockOrNil;
    }
    return self;
}

+ (instancetype)showPickerWithTitle:(NSString *)title rows:(NSArray *)data initialSelection:(NSArray *)indexes target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin {
    ActionSheetMStringPicker *picker = [[ActionSheetMStringPicker alloc] initWithTitle:title rows:data initialSelection:indexes target:target successAction:successAction cancelAction:cancelActionOrNil origin:origin];
    [picker showActionSheetPicker];
    return picker;
}

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray *)data initialSelection:(NSArray *)indexes target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin {
    self = [self initWithTarget:target successAction:successAction cancelAction:cancelActionOrNil origin:origin];
    if (self) {
        self.data = data;
        self.selectedIndexes = [NSMutableArray arrayWithArray:indexes];
        self.title = title;
    }
    
    return self;
}


- (UIView *)configuredPickerView {
    if (!self.data)
        return nil;
    CGRect pickerFrame = CGRectMake(0, 40, self.viewSize.width, 216);
    UIPickerView *stringPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    stringPicker.delegate = self;
    stringPicker.dataSource = self;
    //[stringPicker selectRow:self.selectedIndex inComponent:0 animated:NO];
    if (self.data.count == 0) {
        stringPicker.showsSelectionIndicator = NO;
        stringPicker.userInteractionEnabled = NO;
    } else {
        stringPicker.showsSelectionIndicator = YES;
        stringPicker.userInteractionEnabled = YES;
    }

    //need to keep a reference to the picker so we can clear the DataSource / Delegate when dismissing
    self.pickerView = stringPicker;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerTapped:)];
    tapRecognizer.delegate = self;
    [self.pickerView addGestureRecognizer:tapRecognizer];
    

    return stringPicker;
}

- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction origin:(id)origin {
    if (self.onActionSheetDone) {
        NSMutableArray * objs = [[NSMutableArray alloc] initWithCapacity:self.selectedIndexes.count];
        for (int i=0;i<self.selectedIndexes.count;i++) {
            NSUInteger index = [self.selectedIndexes[i] integerValue];
            [objs addObject:self.data[index]];
        }
        _onActionSheetDone(self, self.selectedIndexes, objs);
        return;
    }
    else if (target && [target respondsToSelector:successAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:successAction withObject:self.selectedIndexes withObject:origin];
#pragma clang diagnostic pop
        return;
    }
    NSLog(@"Invalid target/action ( %s / %s ) combination used for ActionSheetPicker and done block is nil.", object_getClassName(target), sel_getName(successAction));
}

- (void)notifyTarget:(id)target didCancelWithAction:(SEL)cancelAction origin:(id)origin {
    if (self.onActionSheetCancel) {
        _onActionSheetCancel(self);
        return;
    }
    else if (target && cancelAction && [target respondsToSelector:cancelAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:cancelAction withObject:origin];
#pragma clang diagnostic pop
    }
}

#pragma mark - UIPickerViewDelegate / DataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //self.selectedIndex = row;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.data.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    id obj = (self.data)[(NSUInteger) row];

    // return the object if it is already a NSString,
    // otherwise, return the description, just like the toString() method in Java
    // else, return nil to prevent exception

    if ([obj isKindOfClass:[NSString class]])
        return obj;

    if ([obj respondsToSelector:@selector(description)])
        return [obj performSelector:@selector(description)];
    
    return nil;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    id obj = (self.data)[(NSUInteger) row];
    
    // return the object if it is already a NSString,
    // otherwise, return the description, just like the toString() method in Java
    // else, return nil to prevent exception
    
    if ([obj isKindOfClass:[NSString class]])
        return [[NSAttributedString alloc] initWithString:obj attributes:self.pickerTextAttributes];
    
    if ([obj respondsToSelector:@selector(description)])
        return [[NSAttributedString alloc] initWithString:[obj performSelector:@selector(description)] attributes:self.pickerTextAttributes];
    
    return nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UITableViewCell *cell = (UITableViewCell *)view;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setBounds: CGRectMake(0, 0, cell.frame.size.width -20 , 44)];
    }
    NSLog(@"%@", self.selectedIndexes);
    if ([self.selectedIndexes indexOfObject:[NSNumber numberWithInt:row]] != NSNotFound) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    id obj = (self.data)[(NSUInteger) row];

    NSMutableAttributedString *attributeTitle = nil;
    // use the object if it is already a NSString,
    // otherwise, use the description, just like the toString() method in Java
    // else, use String with no text to ensure this delegate do not return a nil value.
    
    NSString * text;
    if ([obj isKindOfClass:[NSString class]]) {
        text = (NSString *)obj;
    }
    if ([obj respondsToSelector:@selector(description)]) {
        text = [obj performSelector:@selector(description)];
    }
    if (text == nil) {
        text = @"";
    }
    attributeTitle = [[NSMutableAttributedString alloc] initWithString:text attributes:self.pickerTextAttributes];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //paragraphStyle.lineSpacing = 1;
    paragraphStyle.minimumLineHeight = 16.f;
    paragraphStyle.maximumLineHeight = 16.f;
    [attributeTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];

    cell.textLabel.attributedText = attributeTitle;
    cell.tag = row;
    
    // Tamaño, en cas de no caber en una única línea
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.numberOfLines = 0;

    return cell;
    
    /*
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc] init];
    }
    id obj = (self.data)[(NSUInteger) row];
    
    NSAttributedString *attributeTitle = nil;
    // use the object if it is already a NSString,
    // otherwise, use the description, just like the toString() method in Java
    // else, use String with no text to ensure this delegate do not return a nil value.
    
    if ([obj isKindOfClass:[NSString class]])
        attributeTitle = [[NSAttributedString alloc] initWithString:obj attributes:self.pickerTextAttributes];
    
    if ([obj respondsToSelector:@selector(description)])
        attributeTitle = [[NSAttributedString alloc] initWithString:[obj performSelector:@selector(description)] attributes:self.pickerTextAttributes];
    
    if (attributeTitle == nil) {
        attributeTitle = [[NSAttributedString alloc] initWithString:@"" attributes:self.pickerTextAttributes];
    }
    pickerLabel.attributedText = attributeTitle;
    return pickerLabel;
     */
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return true;
}

- (void)pickerTapped:(UITapGestureRecognizer *)tapRecognizer
{
    // 3. Find out wich row was tapped (idea based on https://stackoverflow.com/a/25719326)
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat rowHeight = [((UIPickerView *)self.pickerView) rowSizeForComponent:0].height;
        CGRect selectedRowFrame = CGRectInset(self.pickerView.bounds, 0.0, (CGRectGetHeight(self.pickerView.frame) - rowHeight) / 2.0 );
        BOOL userTappedOnSelectedRow = (CGRectContainsPoint(selectedRowFrame, [tapRecognizer locationInView:self.pickerView]));
        if (userTappedOnSelectedRow) {
            NSInteger selectedRow = [((UIPickerView *)self.pickerView) selectedRowInComponent:0];
            NSUInteger index = [self.selectedIndexes indexOfObject:[NSNumber numberWithInteger:selectedRow]];
            
            if (index != NSNotFound) {
                NSLog(@"Row %ld OFF", (long)selectedRow);
                [self.selectedIndexes removeObjectAtIndex:index];
            } else {
                NSLog(@"Row %ld ON",  (long)selectedRow);
                [self.selectedIndexes addObject:[NSNumber numberWithInteger:selectedRow]];
            }
            // I don't know why calling reloadAllComponents sometimes scrolls to the first row
            //[self.pickerView reloadAllComponents];
            // This workaround seems to work correctly:
            ((UIPickerView *)self.pickerView).dataSource = self;
            NSLog(@"Rows reloaded");
        }
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.frame.size.width - 30;
}

@end
