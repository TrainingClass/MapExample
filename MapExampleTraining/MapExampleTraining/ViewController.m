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
    
//    if ([CLLocationManager locationServicesEnabled]) {
//        if (nil == self.locationManager)
//            self.locationManager = [[CLLocationManager alloc] init];
////        [self.locationManager requestWhenInUseAuthorization];
////        [self.locationManager requestAlwaysAuthorization];
//
//    }
    
    //Setting an initial Location
    CLLocationDegrees latitude = 33.857362;
    CLLocationDegrees longitude = -84.428205;
    CLLocationDegrees deltaLatitude = 0.03;
    CLLocationDegrees deltaLongitude = 0.03;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(deltaLatitude, deltaLongitude);
    self.mapView.region = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setShowsUserLocation:YES];
    
    // Adding an Annotation
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = @"My Annotation";
    annotation.subtitle = [NSString stringWithFormat:@"Coordinates: %f, %f", coordinate.latitude, coordinate.longitude];
    
    [self.mapView addAnnotation:annotation];
    
    
    //Add an Annotation when long press on map
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setNewAnnotation:)];
    longPress.minimumPressDuration = 2;
    [self.mapView addGestureRecognizer:longPress];
    
    
    //getPath
    CLLocationCoordinate2D point1 = CLLocationCoordinate2DMake(33.849362, -84.420000);
    MKPlacemark *place1 = [[MKPlacemark alloc] initWithCoordinate:point1 addressDictionary:nil];
    MKMapItem *firstPoint = [[MKMapItem alloc] initWithPlacemark:place1];
    firstPoint.name = @"First Point";
    
    CLLocationCoordinate2D point2 = CLLocationCoordinate2DMake(33.846000, -84.428205);
    MKPlacemark *place2 = [[MKPlacemark alloc] initWithCoordinate:point2 addressDictionary:nil];
    MKMapItem *secondPoint = [[MKMapItem alloc] initWithPlacemark:place2];
    secondPoint.name = @"Second Point";
    
    CLLocationCoordinate2D point3 = CLLocationCoordinate2DMake(33.83500, -84.428000);
    MKPlacemark *place3 = [[MKPlacemark alloc] initWithCoordinate:point3 addressDictionary:nil];
    MKMapItem *thirdPoint = [[MKMapItem alloc] initWithPlacemark:place3];
    thirdPoint.name = @"Third Point";
    
    [self setPoint:firstPoint];
    [self setPoint:secondPoint];
    [self setPoint:thirdPoint];
    
    [self getPathFrom:firstPoint toDestiny:secondPoint];
    [self getPathFrom:secondPoint toDestiny:thirdPoint];

    
     //Calling Maps
//    NSArray *arrayMapItems = @[firstPoint, secondPoint, thirdPoint];
//    [MKMapItem openMapsWithItems:arrayMapItems launchOptions:nil];
    

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


- (void)getPathFrom:(MKMapItem*)origin toDestiny:(MKMapItem*)destiny {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = origin;
    request.destination = destiny;
    request.transportType = MKDirectionsTransportTypeWalking;
    //request.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *indications = [[MKDirections alloc] initWithRequest:request];
    [indications calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error to get the path");
        }else {
            [self showPath:response];
        }
    }];
}


- (void)showPath:(MKDirectionsResponse*)response {
    for (MKRoute *path in response.routes) {
        [self.mapView addOverlay:path.polyline level:MKOverlayLevelAboveRoads];
        for (MKRouteStep *step in path.steps) {
            NSLog(step.instructions);
        }
    }
}

-(MKPolylineRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 3.0;
    return renderer;
}


- (void)setPoint:(MKMapItem*)point {
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = point.placemark.coordinate;
    annotation.title = point.name;
    annotation.subtitle = [NSString stringWithFormat:@"%f, %f", point.placemark.coordinate.latitude, point.placemark.coordinate.longitude];
    [self.mapView addAnnotation:annotation];
}

@end
