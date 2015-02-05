//
//  NeedlesTableViewController.m
//  Stitches2
//
//  Created by Nicole Yarroch on 1/31/15.
//  Copyright (c) 2015 Nicole Yarroch. All rights reserved.
//

#import "NeedlesTableViewController.h"
#import "RaverlyOAuth.h"

@interface NeedlesTableViewController ()
@property (strong, nonatomic) NSDictionary *needles;
@end

@implementation NeedlesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RaverlyOAuth *myEngine = [RaverlyOAuth sharedInstance];
    
    NSLog(@"MyEngine.username %@", myEngine.userName);
    NSString *url = [NSString stringWithFormat:@"https://api.ravelry.com/people/%@/needles/list.json", myEngine.userName];
    
    [myEngine.ravelryClient getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //        NSDictionary *responseArray = (NSDictionary *)responseObject;
        //        NSLog(@"%@", [[responseArray valueForKey:@"color_families"] valueForKey:@"name"]); // PRINT name values
        NSLog(@"%@", responseObject);
        self.needles = (NSDictionary *)responseObject;
        self.title = @"Needles retrieved";
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Colors"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[self.needles objectForKey:@"needle_records"] valueForKey:@"id"] count];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[[self.needles objectForKey:@"needle_records"] objectAtIndex:indexPath.row] valueForKey:@"id"] ;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
