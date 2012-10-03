//
//  ViewController.h
//  OSLocateMe
//
//  Created by rmurray on 02/10/2012.
//  Copyright (c) 2012 OrdnanceSurvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSMap/OSMap.h"

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet OSMapView *mapView;

- (IBAction)locateMeTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *locateMeBtn;

@property (weak, nonatomic) IBOutlet UITextView *textView;


@end
