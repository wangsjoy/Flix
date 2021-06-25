//
//  DetailsViewController.m
//  Flix
//
//  Created by Sophia Joy Wang on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIView *trailerView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //add gesture recognition to the trailerView element
    UITapGestureRecognizer *fingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(onTap:)];
    [self.trailerView addGestureRecognizer:fingerTap];
    
    //load in the poster images from url (string concatenation)
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    [self.posterView setImageWithURL:posterURL];
    NSString *backdropURLString = self.movie[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    [self.backdropView setImageWithURL:backdropURL];
    
    //set title and synopsis text
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    
    //resize title and synopsis
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    //create an object from the trailerViewController class
    TrailerViewController *trailerViewController = [segue destinationViewController];
    
    //Find movie key and set property in trailer object
    int movieIntKey = [(NSNumber*) self.movie[@"id"] intValue];
    NSString* movieStringKey = [NSString stringWithFormat:@"%d", movieIntKey];
    trailerViewController.movieKey = movieStringKey;
    
    //debugging logging
    NSLog(@"Transitioning into Trailer");
    NSLog(@"Trailer Movie Key: ");
    NSLog(@"%@", trailerViewController.movieKey);
}

//The event handling method for when trailerView element is pressed
- (void)onTap:(UITapGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"trailerSegue" sender:nil];
}


@end
