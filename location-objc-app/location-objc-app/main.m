//
//  main.m
//  location-objc-app
//
//  Created by Nathan Henrie on 2023-03-17.
//

#import "Location.h"    

int main(int argc, const char * argv[]) {
    Location loc;
    int status = get_current_location(&loc);
    
    NSLog(@"status: %d\n", status);
    NSLog(@"%f.%f\n", loc.coordinate.latitude, loc.coordinate.longitude);
}
