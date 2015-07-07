//
//  SimpleCellTVC.h
//  Stitches2
//
//  Created by Nicole Yarroch on 6/12/15.
//  Copyright (c) 2015 Nicole Yarroch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleCellTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbNailView;
@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UILabel *projectAuthor;
@property (weak, nonatomic) IBOutlet UILabel *projectCraft;
@property (weak, nonatomic) IBOutlet UILabel *favoriteNumber;

@end
