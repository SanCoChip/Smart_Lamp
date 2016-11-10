//
//  LGColorlightViewController.h
//  CFMusicLight
//
//  Created by 金港 on 16/9/27.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface LGColorlightViewController : BaseViewController
//照明
- (IBAction)SW_light:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UILabel *SW_lightLabel;

@property (weak, nonatomic) IBOutlet UISwitch *SW_lightAttribute;




//彩灯
@property (weak, nonatomic) IBOutlet UILabel *SW_colorLightLabel;

- (IBAction)SW_colorLight:(UISwitch *)sender;

@property (weak, nonatomic) IBOutlet UISwitch *SW_state;


//外控开关
- (IBAction)SW_ExternalControl:(UISwitch *)sender;


//RGB灯
- (IBAction)red_Btn:(UIButton *)sender;
- (IBAction)orange_Btn:(UIButton *)sender;

- (IBAction)yellow_Btn:(UIButton *)sender;

- (IBAction)green_Btn:(UIButton *)sender;
- (IBAction)bluen_Btn:(UIButton *)sender;

- (IBAction)cyan_Btn:(UIButton *)sender;

- (IBAction)purple_Btn:(UIButton *)sender;



//滑竿改变RGB值
- (IBAction)changeRgbValue:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UISlider *Rgb_SliderValue;

//色温值
- (IBAction)slider_changeColorTempValue:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UISlider *ColorTempValue;


@end
