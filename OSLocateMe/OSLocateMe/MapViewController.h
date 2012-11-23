//
//  MapViewController.h
//  OSLocateMe
//
//  Created by rmurray on 02/10/2012.
//  Copyright (c) 2012 OrdnanceSurvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSMap/OSMap.h"

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet OSMapView *mapView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *locateMeBtn;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic, getter = isSea) IBOutlet UISearchBar *searchBar;


- (IBAction)locateMeTapped:(id)sender;

@end
