//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Sophia Joy Wang on 6/23/21.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSArray *filteredData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set up the data source and the delegate
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    [self fetchMovies];
    
    //set up layout and adjust spacing between items and lines
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    //ensure 2 posters per life
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)fetchMovies{
    
    //Send API Get Request for Now Playing Movie Controls
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
                                                                    [self fetchMovies]; //attempt to reload page
                                                                }];
               // add the OK action to the alert controller
               [alert addAction:okAction];
               [self presentViewController:alert animated:YES completion:^{
               }];
               
           }
           else {

               //parse through the returned JSON dictionary
               NSLog(@"Started Animation");
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"%@", dataDictionary);
               self.movies = dataDictionary[@"results"];
               
               //debugging logging
               NSLog(@"Printing Movies:");
               for (NSDictionary *movie in self.movies){
                   NSLog(@"%@", movie);
                   NSLog(@"%@", movie[@"title"]);
               }

               //set data and filteredData properties here
               self.data = self.movies;
               self.filteredData = self.data;
               
               //reload collectionView once the network call is complete
               [self.collectionView reloadData];
           }
       }];
    [task resume];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailsSegue"]){ //check segue identifier
        //transfer movie data from tappedCell into DetailsViewController object
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
        NSDictionary *movie = self.filteredData[indexPath.item];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.movie = movie;
        NSLog(@"Tapping into Poster Cell!");
    } else {
        NSLog(@"Error occurred");
    }
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //create reusable cell (dequeue procedure)
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
   
    //load movie data related to index path
    NSDictionary *movie = self.filteredData[indexPath.item]; //right movie associated with right item
    
    //concatenate posterURL and load image
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil; //clear out the last image since cells are reused and need to be reloaded
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredData.count; //return filteredData cells
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length != 0) { //if there is text in the search bar
        NSLog(@"Search greater than 1");
        
        //create predicate logic object for filtering
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredData = [self.data filteredArrayUsingPredicate:predicate]; //reset filtered data
        
        NSLog(@"%@", self.filteredData); //debugging logging

    }
    else {
        self.filteredData = self.data; //reset filteredData to all movie data
    }

    [self.collectionView reloadData]; //reload collectionView
}

//cancel button functionality
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @""; //reset text in search bar to empty string when cancel is pressed
    [self.searchBar resignFirstResponder];
    
    self.filteredData = self.data; //reset filters
    [self.collectionView reloadData]; //reload collection view
    
}

@end
