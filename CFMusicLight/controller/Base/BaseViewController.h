//
//  BaseViewController.h
//  DrawerControllerDemo
//
//  Created by cfans on 4/29/16.
//  Copyright © 2016 cfans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import "JRBLESDK.h"


@interface BaseViewController : UIViewController{
    
     JRBLESDK * _bleManager;
     UIButton * _imageBLE;
    
}

@end
