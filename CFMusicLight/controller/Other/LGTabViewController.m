//
//  LGTabViewController.m
//  CFMusicLight
//
//  Created by 金港 on 16/6/7.
//
//

#import "LGTabViewController.h"

@interface LGTabViewController ()

@end

@implementation LGTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//     self.navigationController.tabBarController.tabBar.tintColor =[UIColor colorWithRed:114/255.0f green:140/255.0f blue:54/255.0f alpha:1];
    //这是个祸害  设置顶部字体颜色
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:114/255.0f green:140/255.0f blue:54/255.0f alpha:1]}];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
