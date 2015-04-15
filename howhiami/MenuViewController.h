//
//  MenuViewController.h
//  howhiami
//
//  Created by Matthew Helm on 4/14/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuDrawerViewController;

@interface MenuViewController : UITableViewController
@property(nonatomic, weak) MenuDrawerViewController* menuDrawerViewController;

@end