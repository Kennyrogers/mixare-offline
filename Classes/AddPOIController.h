//
//  AddPOIController.h
//  Mixare
//
//  Created by David Ho on 9/18/11.
//  Copyright 2011 Peer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddPOIController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> 
{

	NSString *_initialName;
	NSString *_initialLat;
	NSString *_initialLon;
    UIImage *_initialImage;
	
	IBOutlet UILabel *labelName;
	IBOutlet UILabel *labelLat;
	IBOutlet UILabel *labelLon;
	
	IBOutlet UITextField *textFieldName;
	IBOutlet UITextField *textFieldLat;
	IBOutlet UITextField *textFieldLon;
	
	IBOutlet UIButton *saveNewPOIButton;
    
    IBOutlet UIImageView *image;
    IBOutlet UIButton *capture;
    IBOutlet UIButton *choose;
	
	NSMutableArray * source;
}

@property (nonatomic, retain) NSString *initialName;
@property (nonatomic, retain) NSString *initialLat;
@property (nonatomic, retain) NSString *initialLon;
@property (nonatomic, retain) UIImage *initialImage;

@property (nonatomic, retain) IBOutlet UILabel *labelName;
@property (nonatomic, retain) IBOutlet UILabel *labelLat;
@property (nonatomic, retain) IBOutlet UILabel *labelLon;

@property (nonatomic, retain) IBOutlet UITextField *textFieldName;	
@property (nonatomic, retain) IBOutlet UITextField *textFieldLat;	
@property (nonatomic, retain) IBOutlet UITextField *textFieldLon;	

@property (nonatomic, retain) IBOutlet UIButton *saveNewPOIButton;		   

@property (nonatomic, retain) IBOutlet UIButton *capture;	
@property (nonatomic, retain) IBOutlet UIButton *choose;	

@property (nonatomic, retain) NSMutableArray *dataSourceArray;

- (IBAction)doneButtonOnKeyBoardPressed: (id)sender;

- (IBAction) SaveNewPOI;

- (IBAction) grabImage: (id)sender;

- (void)saveImage:(UIImage*)img:(NSString*)imageName;
- (UIImage*)loadImage:(NSString*)imageName;

@property (nonatomic, retain) UIImagePickerController *imgPicker;

@end
