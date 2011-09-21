//
//  AddPOIController.h
//  Mixare
//
//  Created by David Ho on 9/18/11.
//  Copyright 2011 Peer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddPOIController : UIViewController {

	NSString *_initialName;
	NSString *_initialLat;
	NSString *_initialLon;
	
	IBOutlet UILabel *labelName;
	IBOutlet UILabel *labelLat;
	IBOutlet UILabel *labelLon;
	
	IBOutlet UITextField *textFieldName;
	IBOutlet UITextField *textFieldLat;
	IBOutlet UITextField *textFieldLon;
	
	IBOutlet UIButton *saveNewPOIButton;
	
	NSMutableArray * source;
}

@property (nonatomic, retain) NSString *initialName;
@property (nonatomic, retain) NSString *initialLat;
@property (nonatomic, retain) NSString *initialLon;

@property (nonatomic, retain) IBOutlet UILabel *labelName;
@property (nonatomic, retain) IBOutlet UILabel *labelLat;
@property (nonatomic, retain) IBOutlet UILabel *labelLon;

@property (nonatomic, retain) IBOutlet UITextField *textFieldName;	
@property (nonatomic, retain) IBOutlet UITextField *textFieldLat;	
@property (nonatomic, retain) IBOutlet UITextField *textFieldLon;	

@property (nonatomic, retain) IBOutlet UIButton *saveNewPOIButton;		   

@property (nonatomic, retain) NSMutableArray *dataSourceArray;

- (IBAction) SaveNewPOI;

@end
