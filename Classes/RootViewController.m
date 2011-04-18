//
//  RootViewController.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-11.
//  Copyright 2011 DDMap. All rights reserved.
//

#import "RootViewController.h"
#import "ColorLog.h"


@implementation RootViewController

//@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;


#pragma mark -
#pragma mark View lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        consumer = [[OAConsumer alloc]initWithKey:SINA_APP_KEY secret:SINA_APP_SECRET];
        provider = [[OAHMAC_SHA1SignatureProvider alloc] init];        
    }
    return self;
}

- (void)dealloc {
    [consumer release];
    [provider release];
    [token release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self startRequestToken];
	
}

// Step 1
- (void)startRequestToken  {

    SinaOAURLRequest *request = [[[SinaOAURLRequest alloc] initWithURL:[NSURL URLWithString:SINA_REQUEST_TOKEN_URL]
                               consumer:consumer
                                token:NULL
                               realm:NULL
                               signatureProvider:provider
                                 ]autorelease] ;
    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    
    [fetcher fetchDataWithRequest:request 
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:finishedWithData:)
                  didFailSelector:@selector(requestTokenTicket:failedWithError:)
     ];
    

}

- (void)requestTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data {
    NIF_INFO();
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NIF_INFO(@"responseString : %@", responseString);
    token = [[OAToken alloc] initWithHTTPResponseBody:responseString];
    
    [responseString release];
  
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedVerifier:) name:kSinaOAuthCallBackNotification object:NULL];
    NSString *urlString = [SINA_AUTHORIZE_URL stringByAppendingFormat:@"?%@&oauth_callback=ddsharebox://%@",responseString,kSinaOAuthCallBackNotification];
    NSURL *url = [NSURL URLWithString:urlString];

    [[UIApplication sharedApplication] openURL:url];
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error {
	NSLog(@"%@",error);
    
}

// Step 2
- (void)recievedVerifier:(NSNotification *)notification {
    
    // SINA 
    if ([[notification name] isEqualToString:kSinaOAuthCallBackNotification]) {
        NSString *responseString = [[notification userInfo] objectForKey:kSinaOAuthCallBackNotification];
        //token = [[OAToken alloc] initWithHTTPResponseBody:responseString];
        NSArray *verifierArr = [responseString componentsSeparatedByString:@"oauth_verifier="];
       // NIF_INFO(LCL_RED @"verifierArr - %@", verifierArr);
        if (!verifierArr || ![verifierArr count] == 2) {
            return;
        }
        NSString *verifier = [verifierArr objectAtIndex:1];
        
        SinaOAURLRequest *request = [[[SinaOAURLRequest alloc]
                                         initWithURL:[NSURL URLWithString:SINA_ACCESS_TOKEN_URL]
                                         consumer:consumer
                                         token:token
                                         realm:NULL
                                        verifier:verifier
                                         signatureProvider:provider
                                         ]autorelease] ;

        [request setHTTPMethod:@"POST"];
        OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
        
        [fetcher fetchDataWithRequest:request 
                             delegate:self
                    didFinishSelector:@selector(accessTokenTicket:finishedWithData:)
                      didFailSelector:@selector(accessTokenTicket:failedWithError:)
         ];
        
        
        
        
        return;
    }
    
    
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data {
    NIF_INFO(LCL_YELLOW @"%s",_cmd);
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NIF_INFO(LCL_RED @"responseString : %@", responseString);
    [responseString release];

}


- (void)accessTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error {
    NIF_INFO(LCL_YELLOW @"%s,%@",_cmd,error);
}


// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    
//    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    cell.textLabel.text = [[managedObject valueForKey:@"timeStamp"] description];
//}


#pragma mark -
#pragma mark Add a new object

//- (void)insertNewObject {
//    
//    // Create a new instance of the entity managed by the fetched results controller.
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//    
//    // If appropriate, configure the new managed object.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//    
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}
//
//
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//
//    // Prevent new objects being added when in editing mode.
//    [super setEditing:(BOOL)editing animated:(BOOL)animated];
//    self.navigationItem.rightBarButtonItem.enabled = !editing;
//}
//
//
//#pragma mark -
//#pragma mark Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [[self.fetchedResultsController sections] count];
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
//}
//
//
//// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    // Configure the cell.
//    [self configureCell:cell atIndexPath:indexPath];
//    
//    return cell;
//}
//
//
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
//
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the managed object for the given index path
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//        
//        // Save the context.
//        NSError *error = nil;
//        if (![context save:&error]) {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }   
//}
//
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
//    // The table view should not be re-orderable.
//    return NO;
//}
//
//
//#pragma mark -
//#pragma mark Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here -- for example, create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     [detailViewController release];
//     */
//}
//
//
//#pragma mark -
//#pragma mark Fetched results controller
//
//- (NSFetchedResultsController *)fetchedResultsController {
//    
//    if (fetchedResultsController_ != nil) {
//        return fetchedResultsController_;
//    }
//    
//    /*
//     Set up the fetched results controller.
//    */
//    // Create the fetch request for the entity.
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    // Edit the entity name as appropriate.
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // Set the batch size to a suitable number.
//    [fetchRequest setFetchBatchSize:20];
//    
//    // Edit the sort key as appropriate.
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//    
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    
//    // Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
//    aFetchedResultsController.delegate = self;
//    self.fetchedResultsController = aFetchedResultsController;
//    
//    [aFetchedResultsController release];
//    [fetchRequest release];
//    [sortDescriptor release];
//    [sortDescriptors release];
//    
//    NSError *error = nil;
//    if (![fetchedResultsController_ performFetch:&error]) {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return fetchedResultsController_;
//}    
//
//
//#pragma mark -
//#pragma mark Fetched results controller delegate
//
//
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath {
//    
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
//}


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

