//
//  LGHomeViewController.h
//  CFMusicLight
//
//  Created by 金港 on 16/6/16.
//
//

#import <UIKit/UIKit.h>
#import "LGModelBsaViewController.h"
@interface LGHomeViewController :LGModelBsaViewController {

  NSMutableArray *imageLabel;
}
- (void)adjustbyte:(Byte)value1;
//-(void)adjustColor:(NSString*)Value1;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray* dataSource;//模型类数据源
@property (nonatomic, strong) NSIndexPath* selectIndexPath;//被打开的cell的indexPath，但是不记录总开关的
@property (nonatomic, strong) NSIndexPath* mainSelectIndexPath;


@end
