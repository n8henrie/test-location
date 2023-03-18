//
//  Location.h
//  location-objc-app
//
//  Created by Nathan Henrie on 2023-03-17.
//

#ifndef Location_h
#define Location_h
#endif /* Location_h */

#import <CoreLocation/CoreLocation.h>

typedef struct _Location {
    CLLocationCoordinate2D coordinate;
    double altitude;
    double horizontalAccuracy;
    double verticalAccuracy;
    //NSTimeInterval timestamp;
} Location;

//Location *get_current_location();
int get_current_location(Location *loc);
