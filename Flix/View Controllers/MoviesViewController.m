//
//  MoviesViewController.m
//  Flix
//
//  Created by Sophia Joy Wang on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDragDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectionActivityView;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //want view controller to be datasource and delegate
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.connectionActivityView startAnimating]; //start animating activity
    [self fetchMovies];
    [self.connectionActivityView stopAnimating]; //stop animating
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0]; //so that the refresh icon doesn't hover over any cells
//    [self.tableView addSubview:self.refreshControl]; //same as insertSubview, but refresh icon may hover cells
    

//    NSLog(@"Stopped Animation");
    
}

- (void)fetchMovies{
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=f95fc0b1f5e8e70f10befe96260c1cd5"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies" message:@"The Internet Connection appears to be offline." preferredStyle:(UIAlertControllerStyleAlert)];
               // create an OK action
               UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                        // handle response here.
                                                                        [self fetchMovies];
                                                                }];
               // add the OK action to the alert controller
               [alert addAction:okAction];
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
               
           }
           else {

               NSLog(@"Started Animation");
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               NSLog(@"%@", dataDictionary);
               
               self.movies = dataDictionary[@"results"];
               
               for (NSDictionary *movie in self.movies){
                   NSLog(@"%@", movie[@"title"]);
               }
               
               [self.tableView reloadData]; //network call is slow in comparison to loading table view, make sure to reload
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data

           }
        [self.refreshControl endRefreshing]; //end refreshing
       }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return UIView
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie = self.movies[indexPath.row]; //right movie associated with right row
//    cell.textLabel.text = movie[@"title"];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil; //clear out the last image since cells are reused and need to be reloaded
    [cell.posterView setImageWithURL:posterURL];
    
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender; //sender is just table view cell that was tapped on
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell]; //grabs index path
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie; //don't configure views of the destination view controller, simply pass on the movie
    NSLog(@"Tapping on a movie!");
    
    
}


@end
