//
//  MapViewController.m
//  OSLocateMe
//
//  Created by rmurray on 02/10/2012.
//  Copyright (c) 2012 OrdnanceSurvey. All rights reserved.
//

#import "MapViewController.h"

/**
 * This API Key is registered for this application.
 *
 * Define your own OS Openspace API KEY details below
 * @see http://www.ordnancesurvey.co.uk/oswebsite/web-services/os-openspace/index.html
 */
static NSString *const kOSApiKey = @"E2BE1E5D60273BF3E0430B6CA40ACE3B";
static BOOL const kOSIsPro = NO;

/**
 * The name of the Offline gazetteer search database
 */
static NSString *const kOSPoiDBFilename = @"db.ospoi";



@interface MapViewController () <OSMapViewDelegate, UISearchBarDelegate>
{
    OSGeocoder * osGeocoder;
}

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    
    {
        //create web tile source with API details
        id<OSTileSource> webSource = [OSMapView webTileSourceWithAPIKey:kOSApiKey openSpacePro:kOSIsPro];
        _mapView.tileSources = [NSArray arrayWithObjects:webSource, nil];
        
        [_mapView setDelegate:self];
        
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        NSLog(@"Using SDK Version: %@",[OSMapView SDKVersion]);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //Stop tracking user location
    if( _mapView.showsUserLocation )
    {
        _mapView.showsUserLocation = NO;
    }
    
    //This can be recreated when a search is requested and cancel a request if isGeocoding
    if( osGeocoder && [osGeocoder isGeocoding] ){
        
        [osGeocoder cancelGeocode];
        
    }
    osGeocoder = nil;
}

/*
 * display an NSArray of placemarks
 */
-(void)displaySearchResults:(NSArray*)placemarks
{

    //remove all OSPlacemark annotations
    for ( id<OSAnnotation>annotation in _mapView.annotations ) {
        
        if ( [annotation isKindOfClass:[OSPlacemark class]] )
        {
            [_mapView removeAnnotation:annotation];
        }
        
    }
    
    NSArray * searchResults = [placemarks copy];
    [_mapView addAnnotations:searchResults];
}

/*
 * handle OSGeocoder errors
 */
-(void)showAlertForError:(NSError*)error
{
    if ( !error )
    {
        return;
    }
    NSString * errorTitle = nil;
    NSString * errorMessage = nil;

    if ( [error.domain isEqualToString:OSGeocoderErrorDomain] )
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
    
    if ( !errorTitle )
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
    
    //toggle button style to show selected/not selected
    _locateMeBtn.style = ( showsUserLocation ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered );

}
-(void)mapViewDidStopLocatingUser:(OSMapView *)mv
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    bool showsUserLocation = 0;
    _locateMeBtn.style = ( showsUserLocation ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered );

}

-(void)mapView:(OSMapView *)mv didChangeUserTrackingMode:(OSUserTrackingMode)mode animated:(BOOL)animated
{
    NSLog(@"%s %d %d", __PRETTY_FUNCTION__, mode, animated);
    
    //do nothing with this delegate method at the moment

}

- (void)mapView:(OSMapView *)mapView didUpdateUserLocation:(OSUserLocation *)userLocation
{
    
    //update display
    OSGridPoint gp = OSGridPointForCoordinate(userLocation.coordinate);
    NSString * gridRef = NSStringFromOSGridPoint(gp, 4);
    
    //test if point is within GB
    if( !OSGridPointIsWithinBounds(gp) )
    {
        gridRef = @"Invalid";
        gp = OSGridPointInvalid;
    }
    
    //update view
    _textView.text = [NSString stringWithFormat:@"/* \r"
                      "* You are: \r"
                      "* Lat,Lng: %.06f,%.06f \r"
                      "* E,N: %.f,%.f Grid Ref: %@ \r"
                      "*/",userLocation.coordinate.latitude, userLocation.coordinate.longitude,
                      gp.easting, gp.northing, gridRef];
    
}

-(OSAnnotationView*)mapView:(OSMapView *)mapView viewForAnnotation:(id<OSAnnotation>)annotation
{
    // Use the default user location view.
    if ( [annotation isKindOfClass:[OSUserLocation class]] )
    {
        return nil;
    }
    
    //differentiate between standard annotion and placemark annotation
    OSPinAnnotationColor pinColor = OSPinAnnotationColorRed;
    if ( [annotation isKindOfClass:[OSPlacemark class]] )
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
    
    //remove OSPlacemark annotations
    for ( id<OSAnnotation>annotation in _mapView.annotations ) {
        
        if ( [annotation isKindOfClass:[OSPlacemark class]] )
        {
            [_mapView removeAnnotation:annotation];
        }
        
    }
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    NSString * searchString = [searchBar.text copy];
    
    //Define search type
    OSGeocodeType type;
    
    /**
     * Get the search bar scope... and map to search type.
     *  This configuration uses the Online services for Gazetteer[1] & Postcodes[2]
     *  and the local db.ospoi for Road names[1] and Gazetteer & Postcode combined[default]
     */
    NSInteger buttonIndex = searchBar.selectedScopeButtonIndex;
    switch (buttonIndex)
    {
        case 0:
            type = OSGeocodeTypeRoad;
            break;
        case 1:
            type = OSGeocodeTypeOnlineGazetteer;
            break;
        case 2:
            type = OSGeocodeTypeOnlinePostcode;
            break;
        default:
            type = OSGeocodeTypeCombined2;
            break;
    }
            
    
    //Location of the local geocoder database
    NSURL *url = [[NSBundle mainBundle] URLForResource:kOSPoiDBFilename withExtension:nil];
    NSString *dbPath = [url path];
    
    //create new instance of OSGeocoder if necessary
    if( !osGeocoder ){
        
        osGeocoder  = [[OSGeocoder alloc] initWithDatabase:dbPath apiKey:kOSApiKey openSpacePro:kOSIsPro];
        
    }else{
        
        //OSGeocoder does not support running multiple queries so cancel any that are in progress
        if( [osGeocoder isGeocoding] )
        {
            [osGeocoder cancelGeocode];
        }
        
    }
    
    
    
    //We need a OSGridRect to search in, if we're showing the user location then
    // get a GridRect close to user, if not then use the whole country
    OSGridRect rect;
    if( _mapView.showsUserLocation ){
        
        /*
         * Define how large the local search GridRect will be
         * Here we will just make a simple square around the users location
         */
        static int localSearchDelta = 5000;
        
        OSGridPoint sw = OSGridPointForCoordinate(_mapView.userLocation.coordinate);
        
        rect = OSGridRectMake(sw.easting - (localSearchDelta/2), sw.northing - (localSearchDelta/2), localSearchDelta, localSearchDelta);
        
    }else{
        
        rect = OSNationalGridBounds;
        
    }
    
    // define a number (and offset) of results to return
    NSRange range = {NSNotFound, 0};
    
    //Pass search args to geocoder with completion handler block
    [osGeocoder geocodeString:searchString
                         type:type
               inBoundingRect:rect
                    withRange:range
            completionHandler:^(NSArray *placemarks, NSError *error) {
        
        [self showAlertForError:error];
        if ( [placemarks count] )
        {
            [self displaySearchResults:placemarks];
        }
        
    }];
    

    
}



@end
