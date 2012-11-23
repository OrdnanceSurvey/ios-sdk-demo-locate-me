//
//  MapViewController.m
//  OSLocateMe
//
//  Created by rmurray on 02/10/2012.
//  Copyright (c) 2012 OrdnanceSurvey. All rights reserved.
//

#import "MapViewController.h"

#define kOS_API_KEY @"KEY_HERE"
#define kOS_URL @"URL_HERE"
#define kIS_PRO FALSE

@interface MapViewController () <OSMapViewDelegate, UISearchBarDelegate>
{
    OSGeocoder * osGeocoder;
}

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.searchBar.delegate = self;
    
    {
        //create web tile source with API details
        id<OSTileSource> webSource = [OSMapView webTileSourceWithAPIKey:kOS_API_KEY refererUrl:kOS_URL openSpacePro:kIS_PRO];
        _mapView.tileSources = [NSArray arrayWithObjects:webSource, nil];
        
        [_mapView setDelegate:self];
        
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //stop geocoding and set to nil on receive memory warning
    if([osGeocoder isGeocoding]){
        [osGeocoder cancelGeocode];
    }
    osGeocoder = nil;
}

/*
 * display an NSArray of placemarks
 */
-(void)displaySearchResults:(NSArray*)placemarks
{
    [_mapView removeAnnotations:_mapView.annotations];
    NSArray * searchResults = [placemarks copy];
    [_mapView addAnnotations:searchResults];
}

/*
 * handle OSGeocoder errors
 */
-(void)showAlertForError:(NSError*)error
{
    if (!error)
    {
        return;
    }
    NSString * errorTitle = nil;
    NSString * errorMessage = nil;

    if ([error.domain isEqualToString:OSGeocoderErrorDomain])
    {
        switch (error.code) {
            case OSGeocoderErrorNoResults:
                errorTitle = NSLocalizedString(@"No results found", nil);
                break;
            case OSGeocoderErrorCancelled:
                // Nothing to do here.
                NSLog(@"Geocode cancelled");
                return;
        }
    }
    
    if (!errorTitle)
    {
        errorTitle = error.localizedDescription;
        errorMessage = error.localizedFailureReason;
    }
    [[[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
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
    assert(mv == self.mapView && showsUserLocation == _mapView.showsUserLocation);
    
    //toggle button style to show selected/not selected
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
                      "* You are: \r"
                      "* Lat,Lng: %.06f,%.06f \r"
                      "* E,N: %.f,%.f Grid Ref: %@ \r"
                      "*/",userLocation.coordinate.latitude, userLocation.coordinate.longitude, gp.easting, gp.northing, gridRef];
    
}

-(OSAnnotationView*)mapView:(OSMapView *)mapView viewForAnnotation:(id<OSAnnotation>)annotation
{
    // Use the default user location view.
    if ([annotation isKindOfClass:[OSUserLocation class]])
    {
        return nil;
    }
    
    //differentiate between standard annotion and placemark annotation
    OSPinAnnotationColor pinColor = OSPinAnnotationColorRed;
    if ([annotation isKindOfClass:[OSPlacemark class]])
    {
        pinColor = OSPinAnnotationColorPurple;
    }
    
    OSPinAnnotationView *view = [[OSPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    view.animatesDrop = YES;
    view.canShowCallout = YES;
    view.draggable = NO;
    view.pinColor = pinColor;
    return view;
}


#pragma mark <UISearchBarDelegate>

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [_mapView removeAnnotations:_mapView.annotations];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    NSString * searchString = searchBar.text;
    
    //Location of the local geocoder database
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"offlineDB.ospoi" withExtension:nil];
    NSString *dbPath = [url path];
    
    //create new instance of OSGeocoder if not one already
    if(!osGeocoder)
    {
        osGeocoder  = [[OSGeocoder alloc] initWithDatabase:dbPath];
    }
    
    //Select a type
    OSGeocodeType type = OSGeocodeTypeCombined2;
    
    //We need a OSGridRect to search in
    OSGridRect rect = OSNationalGridBounds;
    
    //Pass search args to geocoder with completion handler
    [osGeocoder geocodeString:searchString type:type inBoundingRect:rect
            completionHandler:^(NSArray *placemarks, NSError *error) {
        
        [self showAlertForError:error];
        if ([placemarks count])
        {
            [self displaySearchResults:placemarks];
        }
        
    }];
    

    
}



@end
