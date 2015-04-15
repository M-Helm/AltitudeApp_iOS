//
//  DisplayContentSegue.m
//  howhiami
//
//  Created by Matthew Helm on 4/14/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "DisplayContentSegue.h"
#import "MenuViewController.h"
#import "MenuDrawViewController.h"

@implementation DisplayContentSegue

-(void)perform
{
    MenuDrawerViewController* menuDrawerViewController = ((MenuViewController*)self.sourceViewController).menuDrawerViewController;
    menuDrawerViewController.content = self.destinationViewController;
}

@end