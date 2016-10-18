//
//  MyMessageViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "MyMessageViewController.h"
#import "TabBarViewController.h"
#import "LeftViewController.h"
#import "HomeNavViewController.h"

@interface MyMessageViewController ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSInteger sexy;
    NSInteger count;
    NSString *memberSex;
    NSString *birthdayDate;
    NSString *identificationcard;
    int offset;
    BOOL flag;
}
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong,nonatomic) ECSlidingViewController *slidingVc;
@property (strong,nonatomic) NSDictionary *dict;

//
@property(strong, nonatomic)UIImagePickerController *imagePC;

@end

@implementation MyMessageViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMessage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置button字体偏右
    _birthday.contentHorizontalAlignment= UIControlContentHorizontalAlignmentRight;
    //设置button字体颜色
    [_birthday setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    
    _nickName.delegate = self;
    _cardID.delegate = self;

    [_gender addTarget:self action:@selector(changeGender:) forControlEvents:UIControlEventTouchUpInside];
    
    count = 1;
    flag = YES;
    sexy = 1;
    
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    _datePicker.backgroundColor = [UIColor clearColor];

    _datePicker.hidden = YES;
    [self.view addSubview:_datePicker];
    
    _headImg.userInteractionEnabled = true;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseHeadImg:)];
    [_headImg addGestureRecognizer:tap];
    
    [_birthday addTarget:self action:@selector(GO) forControlEvents:UIControlEventTouchUpInside];
    
    //监听是否重新进入程序程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)chooseHeadImg:(UITapGestureRecognizer *)sender{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takeCamera = [UIAlertAction actionWithTitle:@"选取自相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self PickImage:UIImagePickerControllerSourceTypeCamera];
    }];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"选取自图片库" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self PickImage:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:takeCamera];
    [actionSheet addAction:takePhoto];
    [actionSheet addAction:cancelAction];
    //model形式跳到actionSheet
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - privateFuncton

-(void)PickImage:(UIImagePickerControllerSourceType)sourceType{
    
    //判断当前的图片选择器是否可用
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        //
        _imagePC = nil;
        //初始化图片选择控制器对象
        _imagePC = [UIImagePickerController new];
        _imagePC.delegate = self;
        //设置图片选择器类型
        _imagePC.sourceType = sourceType;
        //设置选中的媒体文件是否能被编辑
        _imagePC.allowsEditing = YES;
        //设置可以被选择的媒体文件的类型
        _imagePC.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:_imagePC animated:YES completion:nil];
        
    }else{
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:sourceType == UIImagePickerControllerSourceTypeCamera ? @"啊哦,无法获取摄像头。" : @"图库获取失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *allowAction = [UIAlertAction actionWithTitle:@"(；′⌒`)好的" style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:allowAction];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

//当选择完媒体文件后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //从上面获得的图片设置为背景图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    _headImg.image = image;
    //[_imgBtn setBackgroundImage:image forState:UIControlStateNormal];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//当取消选择后调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    //用model的形式返回上一页
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSString *str;
    BOOL flags;
    if([[Utilities getUserDefaults:@"OrLogin"] boolValue]){
        //如果登录了那么这里在判断  上一次是否按了退出按钮   yse  表示按了
        if ( [[Utilities getUserDefaults:@"AddUserAndPw"] boolValue]) {
            
        }else{
            str = [Utilities getUserDefaults:@"switchUser"];
            if ([str isEqualToString:@"openUser"]) {
                if ([Utilities getUserDefaults:@"switch"]) {
                    str = [Utilities getUserDefaults:@"switch"];
                }else{
                    str = @"close";
                }
                
                if ([str isEqualToString:@"close"]) {
                    flags = NO;
                }else{
                    flags = YES;
                }
                
                if (flags) {
                    
                    SecureViewController *secureVc = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"secureVc"];
                    secureVc.touchHome = YES;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"TouchHome" object:nil];
                    [self presentViewController:secureVc animated:YES completion:nil];
                    
                }else{
                    ;
                }
            }
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getMessage{
    _headImg.userInteractionEnabled = NO;
    _userID.userInteractionEnabled = NO;
    _nickName.userInteractionEnabled = NO;
    _gender.userInteractionEnabled = NO;
    _cardID.userInteractionEnabled = NO;
    _birthday.userInteractionEnabled = NO;
    
    NSDictionary *dic = [[StorageMgr singletonStorageMgr]objectForKey:@"dict"];
    if (![dic[@"memberSex"] isEqual: [NSNull null]]) {
        NSLog(@"dic %@",[dic objectForKey:@"memberSex"]);
        memberSex = dic[@"memberSex"];
        sexy = [memberSex integerValue];
        if(sexy == 1){
            _gender.selectedSegmentIndex = 0;
        }else {
            _gender.selectedSegmentIndex = 1;
        }
    }else{
        _gender.selectedSegmentIndex = 0;
    }
    if (![dic[@"birthday"] isEqual: [NSNull null]]) {
        birthdayDate = dic[@"birthday"];
    }else{
        birthdayDate = @"";
    }
    if (![dic[@"identificationcard"] isEqual: [NSNull null]]) {
        identificationcard = dic[@"identificationcard"];
    }else{
        identificationcard = @"";
    }

    _nickName.text = [Utilities getUserDefaults:@"Username"];
    _userID.text = [NSString stringWithFormat:@"%@",dic[@"memberId"]];
    [_birthday setTitle:birthdayDate forState:UIControlStateNormal];
    _cardID.text = identificationcard;
    
}

- (void)saveMessage {
    NSString *memberId = _userID.text;
    NSString *name = _nickName.text;
    
    NSDate *date = _datePicker.date;
    NSDateFormatter *df = [[NSDateFormatter alloc]init];//格式化
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [df stringFromDate:date];
    
    NSLog(@"dateStr = %@",dateStr);
    NSLog(@"sexy = %ld",sexy);
    NSLog(@"memberId = %@",memberId);
    NSLog(@"name = %@",name);
    NSLog(@"identitificationcard = %@",identificationcard);
    
    _dict = @{@"memberId":memberId,
                          @"name":name,
                          @"gender":@(sexy),
                          @"identitificationcard":identificationcard,
                          @"birthday":dateStr
                          };
    [RequestAPI postURL:@"/mySelfController/updateMyselfInfos" withParameters:_dict success:^(id responseObject){
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            [Utilities popUpAlertViewWithMsg:@"保存成功" andTitle:nil onView:self];
            
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"dict"];
            [[StorageMgr singletonStorageMgr]addKey:@"dict" andValue:_dict];
        }else {
            [Utilities errorShow:responseObject[@"resultFlag"] onView:self];
            [self getMessage];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error.description);
        [Utilities popUpAlertViewWithMsg:@"请保持网络通畅" andTitle:nil onView:self];
        [self getMessage];
    }];
}


- (void)changeGender:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0){
        sexy = 1;
        
    } else {
        sexy = 2;
    }
}


- (IBAction)rightAction:(UIBarButtonItem *)sender {
    if (count%2 != 0 ) {
        [_rightButton setTitle:@"保存"];
        count ++;
        
        _headImg.userInteractionEnabled = YES;
        _nickName.userInteractionEnabled = YES;
        _gender.userInteractionEnabled = YES;
        _cardID.userInteractionEnabled = YES;
        _birthday.userInteractionEnabled = YES;
        
    }else {
        identificationcard = _cardID.text;
//        birthday = _birthday.text;
        birthdayDate = _birthday.titleLabel.text;
        
        if ((_nickName.text.length == 0 || _nickName.text.length > 11)) {
            [Utilities popUpAlertViewWithMsg:@"用户名不能为空，并且需要小于11为" andTitle:nil onView:self];
            _nickName.text = @"";
            return;
        }
        if (identificationcard.length == 0 || identificationcard.length == 18) {
            
        }else{
            [Utilities popUpAlertViewWithMsg:@"请输入正确的身份证号" andTitle:nil onView:self];
            _cardID.text = @"";
            return;
        }
        [self saveMessage];
        
        [_rightButton setTitle:@"编辑"];
        count ++;
        
        _headImg.userInteractionEnabled = NO;
        _userID.userInteractionEnabled = NO;
        _nickName.userInteractionEnabled = NO;
        _gender.userInteractionEnabled = NO;
        _cardID.userInteractionEnabled = NO;
        _birthday.userInteractionEnabled = NO;
    }
}

- (IBAction)returnAction:(UIBarButtonItem *)sender {
    
    if ([_rightButton.title isEqualToString:@"保存"]) {
        [_rightButton setTitle:@"编辑"];
        
        _headImg.userInteractionEnabled = NO;
        _userID.userInteractionEnabled = NO;
        _nickName.userInteractionEnabled = NO;
        _gender.userInteractionEnabled = NO;
        _cardID.userInteractionEnabled = NO;
        _birthday.userInteractionEnabled = NO;
        
        [self getMessage];
        
        count ++;
        return;
    }
//    //这里跳转到首页
//    LeftViewController * leftVc = [Utilities getStoryboard:@"Home" instanceByIdentity:@"LeftVc"];
//    TabBarViewController * tabView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"TabView"];
//    //----------------------侧滑开始 center----------------------
//    //初始化侧滑框架,并且设置中间显示的页面
//    _slidingVc = [ECSlidingViewController slidingWithTopViewController:tabView];
//    //设置侧滑 的  耗时
//    _slidingVc.defaultTransitionDuration = 0.25f;
//    //设置 控制侧滑的手势   (这里同时对触摸 和 拖拽相应)
//    _slidingVc.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
//    //设置上述手势的识别范围
//    [tabView.view addGestureRecognizer:_slidingVc.panGesture];
//    //----------------------侧滑开始 left----------------------
//    _slidingVc.underLeftViewController = leftVc;
//    //设置侧滑的开闭程度   (peek都是设置中间的页面出现的宽度 )
//    _slidingVc.anchorRightPeekAmount = UI_SCREEN_W / 4;
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuSwitchAction) name:@"MenuSwitch" object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EnableGestureAction) name:@"EnableGesture" object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DisableGestureAction) name:@"DisableGesture" object:nil];
//    
//    HomeNavViewController *homeNav = [[HomeNavViewController alloc]initWithRootViewController:_slidingVc];
//    _slidingVc.navigationController.navigationBar.hidden = YES;
//    
//    [self presentViewController:homeNav animated:YES completion:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) menuSwitchAction{
    //如果中间那扇门在在右侧，说明  已经被侧滑  因此需要关闭
    if (_slidingVc.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        //中间  页面向左滑
        [_slidingVc resetTopViewAnimated:YES];
    }else {
        //中间  页面向右滑
        [_slidingVc anchorTopViewToRightAnimated:YES];
    }
}
//激活 侧滑手势
- (void)EnableGestureAction{
    _slidingVc.panGesture.enabled = YES;
}
//关闭 侧滑手势
- (void)DisableGestureAction{
    _slidingVc.panGesture.enabled = NO;
}

#pragma mark- Textfield

- (void)textFieldDidBeginEditing:(UITextField *)textField{

}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//点空白处收回键盘
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
}


//当文本输入框中输入的内容变化是调用该方法，返回值为NO不允许调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

- (void)GO{
    if (flag) {
        _datePicker.hidden = NO;
        CGFloat heights = self.view.frame.size.height;
        
        
        offset = _birthday.frame.origin.y + _birthday.frame.size.height - (heights - _datePicker.frame.size.height);
        
        NSTimeInterval animationDuration = 0.30f;
        
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        
        [UIView setAnimationDuration:animationDuration];
        
        float width = self.view.frame.size.width;
        
        float height = self.view.frame.size.height;
        
        NSLog(@"0");
        
        if(offset > 0)
            
        {
            NSLog(@"1");
            CGRect rect = CGRectMake(0.0f, -offset,width,height + offset);
            
            self.view.frame = rect;
            
            CGRect birRect = CGRectMake(_birthday.frame.origin.x, _birthday.frame.origin.x + offset, _birthday.frame.size.width, _birthday.frame.size.height);
            _birthday.frame = birRect;
        }
        
        [UIView commitAnimations];
        flag = NO;
    }else{
        _datePicker.hidden = YES;
        
        NSTimeInterval animationDuration = 0.30f;
        
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        
        [UIView setAnimationDuration:animationDuration];
        
        if (offset > 0) {
            CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - offset);
            self.view.frame = rect;
            CGRect birRect = CGRectMake(_birthday.frame.origin.x, _birthday.frame.origin.x - offset, _birthday.frame.size.width, _birthday.frame.size.height);
            _birthday.frame = birRect;
        }
   
        [UIView commitAnimations];
        
        NSDate *date = _datePicker.date;
        NSDateFormatter *df = [[NSDateFormatter alloc]init];//格式化
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [df stringFromDate:date];
        [_birthday setTitle:dateStr forState:UIControlStateNormal];
        
        flag = YES;
    }
}
@end
