//
//  NewPhotoGroupViewController.m
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "NewPhotoGroupViewController.h"
#import "PhotoGroup.h"
#import "PhotoGroupStore.h"
#import "PhotoArchiveStore.h"

@interface NewPhotoGroupViewController ()

@end
@implementation NewPhotoGroupViewController
@synthesize photoGroup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *photoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
        
        //[[self navigationItem] setRightBarButtonItem:photoButton];
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePhotoGroup)];
        
        NSArray *rightBarButtonItems = [[NSArray alloc] initWithObjects:photoButton, saveButton, nil];
        
        [[self navigationItem] setRightBarButtonItems:rightBarButtonItems];
        
        // Create a new PhotoGroup object
        photoGroup = [[PhotoGroup alloc] init];
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)savePhotoGroup
{
    [[self photoGroup] setPhotoGroupName:[groupNameTextField text]];
    [[self photoGroup] setPhotoGroupDescription:[groupNameTextView text]];
    [[self photoGroup] setImageKey:key];
    [[PhotoGroupStore sharedStore] addPhotoGroup:photoGroup];
    NSLog(@"saving PhotoGroup %@", [[self photoGroup] photoGroupName]);
    BOOL result = [[PhotoGroupStore sharedStore] saveChanges];
    if (!result) {
        NSLog(@"Unable to save new PhotoGroup to PhotoGroupStore!");
    }
    [[self navigationController] popViewControllerAnimated:YES];
    
}
-(IBAction)takePicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([ UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // Create a CFUUID object (unique)
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    // Use that unique ID to set our item's imageKey
    key = (__bridge NSString *)newUniqueIDString;
    
    // Put that image onto screen in our imag view
    [imageView setImage:image];
    [[self photoGroup] setImageKey:key];
    [[PhotoArchiveStore sharedStore] setImage:image forKey:[[self photoGroup] imageKey]];
    
    CFRelease(newUniqueID);
    CFRelease(newUniqueIDString);
    
    [imageView setImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
