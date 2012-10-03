//
//  MapViewController.m
//  OSLocateMe
//
//  Created by rmurray on 02/10/2012.
//  Copyright (c) 2012 OrdnanceSurvey. All rights reserved.
//

#import "MapViewController.h"

#define kOS_API_KEY @"YOUR_KEY_HERE"
#define kOS_URL @"YOUR_URL_HERE"
#define kIS_PRO FALSE

@interface MapViewController () <OSMapViewDelegate>

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    {
        //create web tile source with API details
        id<OSTileSource> webSource = [OSMapView webTileSourceWithAPIKey:kOS_API_KEY refererUrl:kOS_URL openSpacePro:kIS_PRO];
        _mapView.tileSources = [NSArray arrayWithObjects:webSource, nil];
        
        _mapView.delegate = self;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _mapView = nil;
}



#pragma mark IBAction methods

- (IBAction)locateMeTapped:(id)sender
{
    //toggle displaying user location
    _mapView.showsUserLocation = !_mapView.showsUserLocation;
}



#pragma mark OSMapViewDelegate methods


-(void)mapViewWillStartLocatingUser:(OSMapView *)mv
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    bool showsUserLocation = 1;
    assert(mv == _mapView && showsUserLocation == _mapView.showsUserLocation);
    _locateMeBtn.style = (showsUserLocation ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered);

}
-(void)mapViewDidStopLocatingUser:(OSMapView *)mv
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    bool showsUserLocation = 0;
    assert(mv == _mapView && showsUserLocation == _mapView.showsUserLocation);
    _locateMeBtn.style = (showsUserLocation ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered);

}

-(void)mapView:(OSMapView *)mv didChangeUserTrackingMode:(OSUserTrackingMode)mode animated:(BOOL)animated
{
    NSLog(@"%s %d %d", __PRETTY_FUNCTION__, mode, animated);
    
    //do nothing with this delegate method

}

- (void)mapView:(OSMapView *)mapView didUpdateUserLocation:(OSUserLocation *)userLocation
{
    
    //update display
    OSGridPoint gp = OSGridPointForCoordinate(userLocation.coordinate);
    NSString * gridRef = NSStringFromOSGridPoint(gp, 6);
    
    //test if point is within GB
    if(!OSGridPointIsWithinBounds(gp))
    {
        gridRef = @"Invalid";
        gp = OSGridPointInvalid;
    }
    
    //update view
    _textView.text = [NSString stringWithFormat:@"/* \r"
                      "* Lat,Lng: %.06f,%.06f \r"
                      "* E,N: %.f,%.f \r"
                      "* Grid Ref: %@ \r"
                      "*/",userLocation.coordinate.latitude, userLocation.coordinate.longitude, gp.easting, gp.northing, gridRef];
    
}


@end
