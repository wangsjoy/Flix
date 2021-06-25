//
//  TrailerViewController.m
//  Flix
//
//  Created by Sophia Joy Wang on 6/24/21.
//

#import "TrailerViewController.h"
#import "DetailsViewController.h"
#import <WebKit/WebKit.h>

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webkitView;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    NSString *partOneAPI = @"https://api.themoviedb.org/3/movie/";
//    NSString *partTwoAPI = @"/videos?api_key=f95fc0b1f5e8e70f10befe96260c1cd5&language=en-US";
//
//    NSString *stringPartialURL = [partOneAPI stringByAppendingString:self.movieKey];
//    NSString *stringURL = [stringPartialURL stringByAppendingString:partTwoAPI];
//
//    NSLog(@"API Request: ");
//    NSLog(@"%@", stringURL);
//
//    // Convert the url String to a NSURL object.
//    NSURL *url = [NSURL URLWithString:stringURL];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
//
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//           if (error != nil) {
//               NSLog(@"%@", [error localizedDescription]);
//           }
//           else {
//
//               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//
//               NSLog(@"%@", dataDictionary);
//
//               NSString *trailerEnd = dataDictionary[@"results"][0][@"key"];
//               NSString *trailerStart = @"https://www.youtube.com/watch?v=";
//               NSString *trailerString = [trailerStart stringByAppendingString:trailerEnd];
//               NSURL *trailerURL = [NSURL URLWithString:trailerString];
//
//               // Place the URL in a URL Request.
//               NSURLRequest *request = [NSURLRequest requestWithURL:trailerURL
//                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                    timeoutInterval:10.0];
//               // Load Request into WebView.
//               [self.webkitView loadRequest:request];
//           }
//       }];
//
//    [task resume];
    
    [self fetchTrailer];
}

- (void)fetchTrailer{
    // Load Trailer URL
    NSString *partOneAPI = @"https://api.themoviedb.org/3/movie/";
    NSString *partTwoAPI = @"/videos?api_key=f95fc0b1f5e8e70f10befe96260c1cd5&language=en-US";
    NSString *stringPartialURL = [partOneAPI stringByAppendingString:self.movieKey];
    NSString *stringURL = [stringPartialURL stringByAppendingString:partTwoAPI];
    
    NSLog(@"API Request: ");
    NSLog(@"%@", stringURL);
    
    // Convert the url String to a NSURL object.
    NSURL *url = [NSURL URLWithString:stringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {

               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

               NSLog(@"%@", dataDictionary);

               NSString *trailerEnd = dataDictionary[@"results"][0][@"key"];
               NSString *trailerStart = @"https://www.youtube.com/watch?v=";
               NSString *trailerString = [trailerStart stringByAppendingString:trailerEnd];
               NSURL *trailerURL = [NSURL URLWithString:trailerString];

               // Place the URL in a URL Request.
               NSURLRequest *request = [NSURLRequest requestWithURL:trailerURL
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                    timeoutInterval:10.0];
               // Load Request into WebView.
               [self.webkitView loadRequest:request];
           }
       }];
        
    [task resume];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
