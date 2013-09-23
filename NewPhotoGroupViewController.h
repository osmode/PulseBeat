//
//  NewPhotoGroupViewController.h
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoGroup;
@interface NewPhotoGroupViewController : UIViewController <UIImagePickerControllerDelegate>
{
    NSString *key;
    
    __weak IBOutlet UILabel *groupNameLabel;
    __weak IBOutlet UILabel *groupDescriptionLabel;
    __weak IBOutlet UITextField *groupNameTextField;
    __weak IBOutlet UITextView *groupNameTextView;
    __weak IBOutlet UIImageView *imageView;
    

}
@property (nonatomic, strong) PhotoGroup *photoGroup;
-(void)savePhotoGroup;

@end
