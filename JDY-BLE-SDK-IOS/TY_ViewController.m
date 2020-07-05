//
//  TY_ViewController.m
//  YGHTabBar
//
//  Created by apple on 17/2/8.
//  Copyright © 2017年 YangGH. All rights reserved.
//

#import "TY_ViewController.h"

@interface TY_ViewController ()
{
    //    UIImageView *chek_image_button1;
    //    UIImageView *chek_image_button2;
    //
    
    
    Boolean check1,check2;
    
    Boolean io1,io2,io3,io4;
    
    
//    NSMutableString *string_buffer ;
    NSString *string_buffer;
    
    int rx_len_count;
    int tx_len_count;
    
}
@end

@implementation TY_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"透传"];
//    string_buffer = [[NSMutableString alloc] initWithString:@""];
    string_buffer = @"";
    
    check1 = false;
    check2 = false;
    
    io1 = false;
    io2 = false;
    io3 = false;
    io4 = false;
    
    rx_len_count = 0;
    tx_len_count = 0;
    
    
    
        self.chek_image_button1.image = [UIImage imageNamed:@"check_false.png"];
        self.chek_image_button1.userInteractionEnabled = YES;//打开用户交互
        self.chek_image_button1.tag = 10000;
        //初始化一个手势
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress1:)];
        //为图片添加手势
        [self.chek_image_button1 addGestureRecognizer:singleTap1];
        //显示
    
    self.chek_image_button2.image = [UIImage imageNamed:@"check_false.png"];
    self.chek_image_button2.userInteractionEnabled = YES;//打开用户交互
    self.chek_image_button2.tag = 10001;
    //初始化一个手势
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress1:)];
    //为图片添加手势
    [self.chek_image_button2 addGestureRecognizer:singleTap2];
    //显示
    
    
    
    self.IO_Button1.image = [UIImage imageNamed:@"close_image1000.png"];
    self.IO_Button1.userInteractionEnabled = YES;//打开用户交互
    self.IO_Button1.tag = 20000;
    UITapGestureRecognizer *singleTap11 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress1:)];
    [self.IO_Button1 addGestureRecognizer:singleTap11];
    
    self.IO_Button2.image = [UIImage imageNamed:@"close_image1000.png"];
    self.IO_Button2.userInteractionEnabled = YES;//打开用户交互
    self.IO_Button2.tag = 20001;
    UITapGestureRecognizer *singleTap12 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress1:)];
    [self.IO_Button2 addGestureRecognizer:singleTap12];
    
    self.IO_Button3.image = [UIImage imageNamed:@"close_image1000.png"];
    self.IO_Button3.userInteractionEnabled = YES;//打开用户交互
    self.IO_Button3.tag = 20002;
    UITapGestureRecognizer *singleTap13 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress1:)];
    [self.IO_Button3 addGestureRecognizer:singleTap13];
    
    self.IO_Button4.image = [UIImage imageNamed:@"close_image1000.png"];
    self.IO_Button4.userInteractionEnabled = YES;//打开用户交互
    self.IO_Button4.tag = 20003;
    UITapGestureRecognizer *singleTap14 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress1:)];
    [self.IO_Button4 addGestureRecognizer:singleTap14];
    
    
    self.send_button.tag = 30000;
    self.clear_button.tag = 30001;
    
    self.pwm1_pulse_slide.maximumValue = 255;
    self.pwm1_pulse_slide.minimumValue = 0;
    self.pwm2_pulse_slide.maximumValue = 255;
    self.pwm2_pulse_slide.minimumValue = 0;
    self.pwm3_pulse_slide.maximumValue = 255;
    self.pwm3_pulse_slide.minimumValue = 0;
    self.pwm4_pulse_slide.maximumValue = 255;
    self.pwm4_pulse_slide.minimumValue = 0;
    
    self.rx_len_text.text = @"接收：0Bytes";
    self.tx_len_text.text = @"发送：0Bytes";
    
    self.rx_text.text = @"";
    self.rx_text.font=[UIFont systemFontOfSize:12];
    self.rx_text.textColor=[UIColor blackColor];
    self.rx_text.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    self.rx_text.scrollEnabled = YES;//是否可以拖动
    [self.rx_text setEditable:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    self.tx_text.text = @"F10100FFFF004101010FA00000";
    self.tx_text.delegate =self;
    self.switch_pwm.on = false;
    
    
}
//


- (IBAction)button_event:(id)sender {
    UIButton *switchButton = (UIButton*)sender;
    int tag = (int)switchButton.tag;
    switch (tag) {
        case 30000:
        {
            NSLog(@"send");
            //uart_function_select=true表示透传
            //uart_function_select=false表示功能
            //hex_or_string=true表示字符串发
            //hex_or_string=false表示十六进制发
            //-(void) TY_send_data_hex:(NSString*)data : (Boolean) uart_function_select :(Boolean)hex_or_string
            
            if( check2==true )
            {
                NSString *str = _tx_text.text;
                int i_lend = (int)str.length;
                if( i_lend%2!=0 )
                {
                    str = [NSString stringWithFormat:@"%@0",str];
                }
                i_lend = (int)str.length;
                i_lend = i_lend/2;
                
                [_delegate TY_send_data_hex:str :true:check2];//发送的透传数据
                tx_len_count+=i_lend;
                str = [NSString stringWithFormat:@"发送：%dBytes",tx_len_count ];
                self.tx_len_text.text = str;
            }
            else
            {
                NSString *str = _tx_text.text;
                int i_lend = (int)str.length;
                tx_len_count+=i_lend;
                [_delegate TY_send_data_hex:str :true:check2];//发送的透传数据
                
                str = [NSString stringWithFormat:@"发送：%dBytes",tx_len_count ];
                self.tx_len_text.text = str;
                
            }
            
        }
            break;
        case 30001:
        {
            NSLog(@"clear");
            
            //string_buffer = @"";
            string_buffer = @"";
            
            
            self.rx_text.text = string_buffer;
            rx_len_count =0;
            self.rx_len_text.text = [NSString stringWithFormat:@"%@%d",@"接收：0Bytes",rx_len_count];
            
            
            tx_len_count = 0;
            NSString *str = [NSString stringWithFormat:@"发送：%dBytes",tx_len_count ];
            self.tx_len_text.text = str;
        }
            break;
        default:
            break;
    }
    
    
}
-(NSString*)Byte_to_hexString:(Byte *)bytes :(int)len
{
    NSString *hexStr=@"";
    //Byte *bytes = (Byte *)[data bytes];
    for(int i=0;i<len;i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff]; ///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

-(NSString*)Byte_to_String:(Byte *)bytes :(int)len
{
    NSString *hexStr=@"";//[t Byte_to_hexString:bytes :len];
    NSData *adata = [[NSData alloc] initWithBytes:bytes length:len];
    hexStr = [[NSString alloc] initWithData:adata encoding:NSUTF8StringEncoding];
    return hexStr;
}

-(void)rx_ble_event:(Byte *)bytes :(int)len;
{
    if( check1==false )
    {
        NSString *str = [self Byte_to_String:bytes :len ];
        rx_len_count+=len;
        self.rx_len_text.text = [NSString stringWithFormat:@"%@%dBytes",@"接收：",rx_len_count];
        
        //str=[str stringByAppendingString:@"eee" ];
        //[ string_buffer appendFormat:@"%@", str ];
        string_buffer = [NSString stringWithFormat:@"%@%@\r\n",string_buffer,str];
    
        self.rx_text.text =string_buffer;
        [self.rx_text scrollRangeToVisible:NSMakeRange(string_buffer.length, 1)];
    }
    else
    {
        NSString *str = [self Byte_to_hexString:bytes :len ];
        rx_len_count+=len;
        self.rx_len_text.text = [NSString stringWithFormat:@"%@%dBytes",@"接收：",rx_len_count];
        
        //str=[str stringByAppendingString:@"eee" ];
        //[ string_buffer appendFormat:@"%@", str ];
        string_buffer = [NSString stringWithFormat:@"%@%@\r\n",string_buffer,str];
        
        self.rx_text.text =string_buffer;
        [self.rx_text scrollRangeToVisible:NSMakeRange(string_buffer.length, 1)];
    }
    
    //NSLog( @"TY_data = %@",str );
}

- (IBAction)PWM_PULSE:(id)sender {
    UISlider *pulse = (UISlider*)sender;
    int h = pulse.value;
    h = h%10;
    if( h==0 )
    {
    if( pulse==_pwm1_pulse_slide )
    {
         [_delegate TY_send_data_hex:[NSString stringWithFormat:@"E8A3%02x",(int)pulse.value] :false:true];//设置PWM1脉宽
    }
    else if( pulse==_pwm2_pulse_slide )
    {
         [_delegate TY_send_data_hex:[NSString stringWithFormat:@"E8A4%02x",(int)pulse.value] :false:true];//设置PWM2脉宽
    }
    else if( pulse==_pwm3_pulse_slide )
    {
         [_delegate TY_send_data_hex:[NSString stringWithFormat:@"E8A5%02x",(int)pulse.value] :false:true];//设置PWM3脉宽
    }
    else if( pulse==_pwm4_pulse_slide )
    {
         [_delegate TY_send_data_hex:[NSString stringWithFormat:@"E8A6%02x",(int)pulse.value] :false:true];//设置PWM4脉宽
    }
    }
    //NSLog(@"pulse = %d", (int)pulse.value );
    
   
    
}

- (IBAction)g:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        self.pwm_pen_text.text = @"PWM开";
        [_delegate TY_send_data_hex:@"E8A200FA" :false:true];//PWM开
        [_delegate TY_send_data_hex:@"E8A101" :false:true];//PWM开
    }else {
        self.pwm_pen_text.text = @"PWM关";
        [_delegate TY_send_data_hex:@"E8A100" :false:true];//PWM开
    }
}

-(void)rx_ble_event:(NSData*)value
{
    
}


-(void)buttonpress1:(UIGestureRecognizer *)ee
{
    UIView *view = [ee view];
    int tagvalue = (int)view.tag;
    switch ( tagvalue )
    {
        case 10000 ://十六进制接收还是字符串接收
        {
            if( check1==false)
            {
                check1 = true;
                self.chek_image_button1.image = [UIImage imageNamed:@"check_true.png"];
            }else{
                check1 = false;
                self.chek_image_button1.image = [UIImage imageNamed:@"check_false.png"];
            }
            break;
        }
        case 10001 ://十六进制发送还是字符串发送
        {
            if( check2==false)
            {
                check2 = true;
                self.chek_image_button2.image = [UIImage imageNamed:@"check_true.png"];
            }else{
                check2 = false;
                self.chek_image_button2.image = [UIImage imageNamed:@"check_false.png"];
            }
            break;
        }
        case 20000 :
        {
            if( io1==false)
            {
                io1 = true;
                self.IO_Button1.image = [UIImage imageNamed:@"open_image1000.png"];
                [_delegate TY_send_data_hex:@"E7F101" :false:true];//IO1高电平
            }else{
                io1 = false;
                self.IO_Button1.image = [UIImage imageNamed:@"close_image1000.png"];
                [_delegate TY_send_data_hex:@"E7F100" :false:true];//IO1低电平
            }
            break;
        }
        case 20001 :
        {
            if( io2==false)
            {
                io2 = true;
                self.IO_Button2.image = [UIImage imageNamed:@"open_image1000.png"];
                [_delegate TY_send_data_hex:@"E7F201" :false:true];//IO2高电平
            }else{
                io2 = false;
                self.IO_Button2.image = [UIImage imageNamed:@"close_image1000.png"];
                [_delegate TY_send_data_hex:@"E7F200" :false:true];//IO2低电平
            }
            break;
        }
        case 20002 :
        {
            if( io3==false)
            {
                io3 = true;
                self.IO_Button3.image = [UIImage imageNamed:@"open_image1000.png"];
                [_delegate TY_send_data_hex:@"E7F301" :false:true];//IO3高电平
            }else{
                io3 = false;
                self.IO_Button3.image = [UIImage imageNamed:@"close_image1000.png"];
                [_delegate TY_send_data_hex:@"E7F300" :false:true];//IO3低电平
            }
            break;
        }
        case 20003 :
        {
            if( io4==false)
            {
                io4 = true;
                self.IO_Button4.image = [UIImage imageNamed:@"open_image1000.png"];
                [_delegate TY_send_data_hex:@"E7F401" :false:true];//IO4高电平
            }else{
                io4 = false;
                self.IO_Button4.image = [UIImage imageNamed:@"close_image1000.png"];
                [_delegate TY_send_data_hex:@"E7F400" :false:true];//IO4低电平
            }
            break;
        }
            
            
            
            
        default:
            break;
    }
}
-(void)rx_ble_function_event:(Byte *)bytes :(int)len//接收功能配置通道数据
{
    if( len==5 )
    {
        if( bytes[0]==0xf6 )
        {
            if( bytes[1]==0x01 )
            {
                io2 = true;
                self.IO_Button1.image = [UIImage imageNamed:@"open_image1000.png"];
            }else{
                io1 = false;
                self.IO_Button1.image = [UIImage imageNamed:@"close_image1000.png"];
            }
            if( bytes[2]==0x01 )
            {
                io2 = true;
                self.IO_Button2.image = [UIImage imageNamed:@"open_image1000.png"];
            }else{
                io2 = false;
                self.IO_Button2.image = [UIImage imageNamed:@"close_image1000.png"];
            }
            if( bytes[3]==0x01 )
            {
                io3 = true;
                self.IO_Button3.image = [UIImage imageNamed:@"open_image1000.png"];
            }else{
                io3 = false;
                self.IO_Button3.image = [UIImage imageNamed:@"close_image1000.png"];
            }
            if( bytes[4]==0x01 )
            {
                io4 = true;
                self.IO_Button4.image = [UIImage imageNamed:@"open_image1000.png"];
            }else{
                io4 = false;
                self.IO_Button4.image = [UIImage imageNamed:@"close_image1000.png"];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIBarButtonItem *done =    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(leaveEditMode)] ;
    self.navigationItem.rightBarButtonItem = done;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)leaveEditMode
{
    [self.tx_text resignFirstResponder];
}

- (void)viewDidUnload
{
    [_delegate TY_send_data_hex:@"E90102" :false:true];
}
- (void)viewDidAppear:(BOOL)animated
{
    [_delegate TY_send_data_hex:@"E7F6" :false:true];//读取4路IO电平 状态
}

@end
