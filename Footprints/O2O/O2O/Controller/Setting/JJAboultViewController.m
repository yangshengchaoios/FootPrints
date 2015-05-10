//
//  JJAboultViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/11.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJAboultViewController.h"
#import "JJAppDelegate.h"
#import "JJReportViewController.h"
#import "JJIntroductionController.h"
@interface JJAboultViewController ()
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) IBOutlet UILabel *cRightLabel;

@property (strong, nonatomic) UILabel *version;
@end

@implementation JJAboultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.titles = @[@"版本更新",@"功能介绍",@"意见反馈",@"给我评分"];
    self.title = @"关于微秀";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    
    self.version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-30, 44)];
    self.version.text = AppVersion;
    self.version.textAlignment = NSTextAlignmentRight;
    self.version.font = [UIFont systemFontOfSize:14];
    
    self.cRightLabel.frame = CGRectMake(0, SCREEN_HEIGHT-64-30, SCREEN_WIDTH, 30);
    [self.view addSubview:self.cRightLabel];
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
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = self.titles[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row==0) {
        [cell addSubview:self.version];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self checkUpdate];
            break;
        case 1:
        {
            JJIntroductionController *controller = [[JJIntroductionController alloc] initWithNibName:@"JJIntroductionController" bundle:nil];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 2:
        {
            JJReportViewController *report = [[JJReportViewController alloc] initWithNibName:@"JJReportViewController" bundle:nil];
            [self.navigationController pushViewController:report animated:YES];
        }
            break;
        case 3:
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/%@",kAPPItunesId]];
            [[UIApplication sharedApplication] openURL:url];
        }
            break;
        default:
            break;
    }
}

- (void)checkUpdate{
 
    JJAppDelegate *appDelegate = (JJAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate checkVersion:YES andCanSkip:NO];
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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
