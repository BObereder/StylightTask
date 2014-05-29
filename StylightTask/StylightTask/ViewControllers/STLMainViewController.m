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
{

    
}

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
                                                         delegate:self
                                                        inContext:[NSManagedObjectContext MR_defaultContext]];    }
    
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

- (void)loadItemsForPage:(int)page{

    STLWebService *webService = [STLWebService sharedService];
    [webService retrievBlocksForPage:page
                 WithCompletionBlock:^(NSError *error) {
                     NSLog(@"error: %@",error);
                 }];
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    id sectionInfo = [self.fetchedResultsController.sections objectAtIndexedSubscript:section];
    return [sectionInfo numberOfObjects];}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return self.fetchedResultsController.sections.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    return CGSizeMake(250, self.view.frame.size.height) ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
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

- (void)configureCollectionViewCell:(STLCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [self.sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [self.objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([self.sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in self.objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [self.sectionChanges removeAllObjects];
    [self.objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

@end
