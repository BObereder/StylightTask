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

@interface STLMainViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation STLMainViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    //check if there are persistet items
    NSArray *array = [STLItem MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    
    if (array.count ==0) {
        [self loadItemsForPage:0];
    }
    
    //setup fetchedResultsController
    self.fetchedResultsController = [STLItem MR_fetchAllGroupedBy:nil
                                                       withPredicate:[NSPredicate predicateWithValue:YES]
                                                            sortedBy:@"timeStamp"
                                                           ascending:YES
                                                            delegate:self
                                                           inContext:[NSManagedObjectContext MR_defaultContext]];
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



#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    id sectionInfo = [self.fetchedResultsController.sections objectAtIndexedSubscript:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STLCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    
    // Configure the cell...
    STLItem *dbItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = dbItem.name;
    cell.detailTextLabel.text = dbItem.creator;
    [cell.imageView setImageWithURL:[NSURL URLWithString:dbItem.imageURL] placeholderImage:[UIImage imageNamed:@"stylight.jpg"]];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == self.fetchedResultsController.fetchedObjects.count - 4) {
        
        STLWebService *webservice = [STLWebService sharedService];
        
        int pageToLoad = (self.fetchedResultsController.fetchedObjects.count / webservice.batchsize)+1;
        
        [self loadItemsForPage:pageToLoad];
    }
}


#pragma mark -
#pragma mark - NSFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
