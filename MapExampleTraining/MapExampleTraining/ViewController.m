//
//  ViewController.m
//  MapExampleTraining
//
//  Created by MCS on 3/22/16.
//  Copyright © 2016 Luis.Perez. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()

- (IBAction)segmentControlChange:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([CLLocationManager locationServicesEnabled]) {
        if (nil == self.locationManager)
            self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];

    }
    
    CLLocationDegrees latitude = 33.857362;
    CLLocationDegrees longitude = -84.428205;

    CLLocationDegrees deltaLatitude = 0.03;
    CLLocationDegrees deltaLongitude = 0.03;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(deltaLatitude, deltaLongitude);
    
    self.mapView.region = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setShowsUserLocation:YES];
    
    
    
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = @"My Annotation";
    annotation.subtitle = [NSString stringWithFormat:@"Coordinates: %f, %f", coordinate.latitude, coordinate.longitude];
    
    [self.mapView addAnnotation:annotation];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setNewAnnotation:)];
    longPress.minimumPressDuration = 2;
    [self.mapView addGestureRecognizer:longPress];

}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annot {
    //create a view for annotation using your MyAnnotation class
    static NSString *pinIdentifier = @"mypin";
    
    if ([annot isKindOfClass:[MKPointAnnotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annot reuseIdentifier:pinIdentifier];
        } else {
            annotationView.annotation = annot;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"redPin"];
        annotationView.frame = CGRectMake(0, 0, 50, 50);
        [annotationView setDraggable:YES];
        
        //create disclosure button on the callout
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(showDetail)forControlEvents:UIControlEventTouchUpInside];
        [annotationView setRightCalloutAccessoryView:button];
        
        return annotationView;
        
    }
    
    return nil;
}


// Selector button on Annotation
- (void)showDetail{
    NSLog(@"Button Pressed");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
    // Dispose of any resources that can be recreated.
}

// Show Traffic on/off
- (IBAction)SwitchTrafficMode:(UISwitch *)sender {
    self.mapView.showsTraffic = !self.mapView.showsTraffic;
    
}

// Change MapType
- (IBAction)segmentControlChange:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            self.mapView.mapType = MKMapTypeStandard;
            break;
    }
}

//
- (void)setNewAnnotation:(UIGestureRecognizer*)gestureRecognizer{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = newCoordinate;
    annotation.title = @"New Annotation";
    annotation.subtitle = [NSString stringWithFormat:@"Coordinates: %f, %f", newCoordinate.latitude, newCoordinate.longitude];
    
    [self.mapView addAnnotation:annotation];
    

    
}

@end
