//
//  SettingsTableViewController.m
//  Song Guessr
//
//  Created by Roger on 10/19/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ViewController.h"

@interface SettingsTableViewController ()

@property (nonatomic, strong) NSArray *firstRowItems;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)firstRowItems
{
    if (!_firstRowItems) _firstRowItems = @[@"Use Song Art", @"Background Color", @"Text Color"];
    return _firstRowItems;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
    //reset section
    //artist/album/sort section? optional. if possible
    //desabling or enabling of images
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        return 2; //sort section/enabling of images/changing color of background
    } else if (section == 1) {
        return 1; //reset button
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetail" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 1) {
        cell.detailTextLabel.text = @"Reset Points";
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.textLabel.text = @"";
    } else if (indexPath.section == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        cell.textLabel.text = self.firstRowItems[indexPath.item];
        if (indexPath.item == 0 && [defaults boolForKey:@"artwork"]) {
            //song Art
            cell.detailTextLabel.text = @"✓";
        } /*else if (indexPath.item == 1 && [defaults objectForKey:@"backgroundColor"]) {
            //background color
            cell.detailTextLabel.text = [defaults objectForKey:@"backgroundColor"];
        } else if (indexPath.item == 2 && [defaults objectForKey:@"textColor"]) {
            //text color
            cell.detailTextLabel.text = [defaults objectForKey:@"textColor"];
        } */
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 1) {
        NSLog(@"???");
        [defaults setInteger:0 forKey:@"points"];
        [defaults setInteger:0 forKey:@"hits"];
        [defaults setInteger:0 forKey:@"misses"];
        [defaults synchronize];
    } else if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            //artwork
            bool old = [defaults boolForKey:@"artwork"];
            [defaults setBool:!old forKey:@"artwork"];
            [defaults synchronize];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetail" forIndexPath:indexPath];
            cell.textLabel.text = self.firstRowItems[indexPath.item];
            if (old)
            {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"✓";
            }
        } else if (indexPath.item == 1) {
            //backgroundColor
        } else if (indexPath.item == 2) {
            //textColor
        }
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"%@", [segue destinationViewController]);
    if ([[segue destinationViewController] isKindOfClass:[ViewController class]]) {
        ViewController *destVC = (ViewController *)[segue destinationViewController];
        [destVC loadVars];
    }
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *theVC = (UINavigationController *)[segue destinationViewController];
        if ([[theVC topViewController] isKindOfClass:[ViewController class]]) {
            ViewController *realVC = (ViewController *)theVC.topViewController;
            [realVC loadVars];
        }
    }
}


@end
