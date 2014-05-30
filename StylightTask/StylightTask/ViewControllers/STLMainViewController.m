//
//  STLMainViewController.m
//  StylightTask
//
//  Created by Bernhard Obereder on 12.05.14.
//  Copyright (c) 2014 Bernhard Obereder. All rights reserved.
//

#import "STLMainViewController.h"
#import "STLWebService.h"
#import "STLItem.h"
#import "UIImageView+AFNetworking.h"
#import "STLCollectionViewCell.h"


@interface STLMainViewController ()<NSFetchedResultsControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *objectChanges;
@property (strong, nonatomic) NSMutableArray *sectionChanges;

@end

@implementation STLMainViewController


#pragma mark - Setter/Getter

-(NSMutableArray *)objectChanges
{
    if (!_objectChanges)
    {
        _objectChanges = [NSMutableArray array];
    }
    
    return _objectChanges;
}

-(NSMutableArray *)sectionChanges
{
    if (!_sectionChanges)
    {
        _sectionChanges = [NSMutableArray array];
    }
    
    return _sectionChanges;
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController)
    {
        _fetchedResultsController = [STLItem MR_fetchAllGroupedBy:nil
                                                    withPredicate:[NSPredicate predicateWithValue:YES]
                                                         sortedBy:@"timeStamp"
                                                        ascending:YES
                                                         delegate:self];    }
    

    return _fetchedResultsController;
}

#pragma mark - Systemmethods

- (void)viewDidLoad
{
    [super viewDidLoad];

    //check if there are persistet items
    NSArray *array = [STLItem MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    
    if (array.count ==0)
    {
        [self loadItemsForPage:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadItemsForPage:(int)page
{
    STLWebService *webService = [STLWebService sharedService];
    [webService retrievBlocksForPage:page
                 WithCompletionBlock:^(NSError *error) {
                     NSLog(@"error: %@",error);
                 }];
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id sectionInfo = [self.fetchedResultsController.sections objectAtIndexedSubscript:section];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    return CGSizeMake(250, self.view.frame.size.height) ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STLCollectionViewCell" forIndexPath:indexPath];
    
    [self configureCollectionViewCell:cell atIndexPath:indexPath];
    
    if (indexPath.row == self.fetchedResultsController.fetchedObjects.count - 5)
    {
        STLWebService *webservice = [STLWebService sharedService];
        int pageToLoad = (self.fetchedResultsController.fetchedObjects.count / webservice.batchsize)+1;
        [self loadItemsForPage:pageToLoad];
    }
    
    return cell;
}

- (void)configureCollectionViewCell:(STLCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    // Configure the cell...
    STLItem *dbItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.descriptionTextView.text = dbItem.name;
    
    if (dbItem.creator) {
        cell.creatorLabel.text = [NSString stringWithFormat:@"by %@",dbItem.creator ];
    }
    else{
        cell.creatorLabel.text = nil;
    }
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:dbItem.imageURL] placeholderImage:[UIImage imageNamed:@"stylight.jpg"]];
}

#pragma mark - NSFetchedResultsController Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //There is a more sophisticated way to handle updates from the fetchedResultsController, where you queue the updates made through the NSFetchedResultsControllerDelegate until the controller finishes its updates.
    //But for this simple implementation just reloading the data works just as fine and is simpler and less prone to bugs.
    
    [self.collectionView reloadData];
}



@end
