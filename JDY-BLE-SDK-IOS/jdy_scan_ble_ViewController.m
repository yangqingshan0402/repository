//
//  ViewController.m
//  77777
//
//  Created by LXXAVR on 14-1-9.
//  Copyright (c) 2014年 LXXAVR. All rights reserved.
//

#import "jdy_scan_ble_ViewController.h"
//#import "RefreshHeaderAndFooterView.h"
//#import "YGHTabBarController.h"
#import "TY_ViewController.h"
//#import "iBeacon_ViewController.h"




@interface jdy_scan_ble_ViewController ()<JDY_BLE_Delegate>
{
    //YGHTabBarController *tabBarViewController_;
    
    TY_ViewController *touchuang_view;
//    iBeacon_ViewController *ibeacon_view;
    
    
    Byte selected_type;
    
    int select_index ;
    
    Byte de_type ;
    //UIBarButtonItem *editButton;
}
@end

@implementation jdy_scan_ble_ViewController
//@synthesize refreshControl;








#define PASS_ENABLE   1   //true时表示采用加密  false表示不采用加密


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSLog(@"Creating Variable in Memory");
        
        
        UITabBarItem *tbi2 = [[UITabBarItem alloc]
                              initWithTabBarSystemItem:UITabBarSystemItemFavorites
                              tag:0];
        [self setTabBarItem:tbi2];
    }
    return self;
}
-(void)BLE_TX_Data:(NSString*)str{}
- (void)viewDidLoad
{
    [super viewDidLoad];
    de_type = 0;
    self.title = @"设备";
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
        editButton = [[UIBarButtonItem alloc]
                      initWithTitle:@"扫描"
                      style:UIBarButtonItemStyleDone
                      target:self
                      action:@selector(toggleEdit:)];
        editButton.tag=1;
        self.navigationItem.rightBarButtonItem = editButton;
    
    
    //    editButton1 = [[UIBarButtonItem alloc]
    //                   initWithTitle:@"信息"
    //                   style:UIBarButtonItemStyleBordered
    //                   target:self
    //                   action:@selector(toggleEdit:)];
    //    editButton.tag=1;
    //    self.navigationItem.leftBarButtonItem = editButton1;
    int t55=0;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSLog(@"这个设备是iphone");
        if(self.view.frame.size.height>480){t55=0;NSLog(@"这个设备是iphone5");}
        else {t55=65;NSLog(@"这个设备是iphone4");}
        tt6=0;
    } else {
        NSLog(@"这个设备是ipad");
        t55=0;
        tt6=1;
    }
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version > 5.1) {
        NSLog(@"ios6以上");
        hb=1;
    }else{
        NSLog(@"ios5");
        hb=0;
    }
    NSLog(@"ios000000");
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    t = [[JDY_BLE alloc] init];
    //    [t controlSetup:1];
    t.delegate = self;
    
    tab=[[UITableView alloc]initWithFrame:CGRectMake(0, (t55!=0)?(hb==1)?10:20:0, self.view.frame.size.width, self.view.frame.size.height-20)];
    [self.view addSubview:tab];
    [tab setDataSource:self ];
    [tab setDelegate:self];
    [tab setBackgroundColor:[UIColor whiteColor]];
    
    dfg=0;
    //判断是否是连接状态
//    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f                                    target: self                                 selector: @selector(handleTimer99)//设定定时器回调
//                                           userInfo: nil
//                                            repeats: YES];
    //连接时间
    //    time_11 = [NSTimer scheduledTimerWithTimeInterval: 2.0f                                    target: self                                 selector: @selector(handleTimer11)//设定定时器回调
    //                                           userInfo: nil
    //                                            repeats: YES];
    
    //    [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(read_rssi_event) userInfo:nil repeats:YES];
    
    
    
    
    
    //    gn_view_ap=[[gn_view alloc]init];
    //    gn_view_ap.dele=self;
    
    
    NSLog(@"==55==%@",self.navigationController);
    
    
    
    [self setConect_status:0];
    [self setSelect_st:0];
    
    
    
    // [time_11 setFireDate:[NSDate distantFuture]];
    
    
    select_index = 0;
    
    aPeripheral8=nil;
    cont_status=0;
    
    
    ivt=0;
    dly=0;
    hbn=0;
    //[self Scan];
    
    
    select_index = 0;
    

     [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
}
- (void) scanTimer:(NSTimer *)timer
{
    NSLog( @"send_data: %d",111 );
    select_index = 0;
    
    [t start_scan_ble];
    NSLog(@"Scan_Dev");
    [tab reloadData];
}


-(void)handleTimer11
{
    if([t get_connected_status ])
    {
        
    }else{
        bmmn++;
        if(bmmn>5)
        {
            bmmn=0;
            [t disconnectPeripheral ];
            //t.activePeripheral = nil;
            aPeripheral8= nil;
            //[time_11 setFireDate:[NSDate distantFuture]];
        }
    }
    
}
//

//uart_function_select=true表示透传
//uart_function_select=false表示功能
//hex_or_string=true表示十六进制发
//hex_or_string=false表示字符串发
-(void) TY_send_data_hex:(NSString*)data : (Boolean) uart_function_select :(Boolean)hex_or_string
{
    if( uart_function_select)//透传 UUID FFE1
    {
        //NSLog( @"TY_send_data: %@",data );
        if( hex_or_string )
        {
            if([data length]>0);
            else return;
            //Str=[NSString stringWithFormat:@"%@",Str];
            NSData *da2=[t stringToByte:data];
            Byte *testbyte=(Byte*)[da2 bytes];
            
            int len=(int)[da2 length];
            [ t send_uart_data:testbyte pp:len ];
        }
        else
        {
            NSData *dat = [data dataUsingEncoding:NSUTF8StringEncoding];
            Byte *testbyte=(Byte*)[dat bytes];
            [ t send_uart_data:testbyte pp:(int)dat.length ];
        }
        
        
        //[t send_function_data:testbyte p:[t activePeripheral] pp:len];
        
    }
    else//功能 UUID FFE2
    {
        NSLog( @"send_data: %@",data );
        
        if([data length]>0);
        else return;
        //Str=[NSString stringWithFormat:@"%@",Str];
        NSData *da2=[t stringToByte:data];
        Byte *testbyte=(Byte*)[da2 bytes];
        NSLog(@"hh=%@",data);
        int len=(int)[da2 length];
        
        
        //[t send_function_data:testbyte p:[t activePeripheral] pp:len];
        [ t send_function_data:testbyte pp:len ];
    }
}

//-(void) tabBar_send_data_hex:(NSString*)data : (Boolean) p
//{
//    if( p )//透传 UUID FFE1
//    {
//        NSLog( @"send_data: %@",data );
//
//        if([data length]>0);
//        else return;
//        //Str=[NSString stringWithFormat:@"%@",Str];
//        NSData *da2=[self stringToByte:data];
//        Byte *testbyte=(Byte*)[da2 bytes];
//        NSLog(@"hh=%@",data);
//        int len=(int)[da2 length];
//
//
//        //[t send_function_data:testbyte p:[t activePeripheral] pp:len];
//        [ t send_uart_data:testbyte pp:len ];
//    }
//    else//功能 UUID FFE2
//    {
//        NSLog( @"send_data: %@",data );
//
//        if([data length]>0);
//        else return;
//        //Str=[NSString stringWithFormat:@"%@",Str];
//        NSData *da2=[self stringToByte:data];
//        Byte *testbyte=(Byte*)[da2 bytes];
//        NSLog(@"hh=%@",data);
//        int len=(int)[da2 length];
//
//
//        //[t send_function_data:testbyte p:[t activePeripheral] pp:len];
//        [ t send_function_data:testbyte pp:len ];
//    }
//}

-(void) tabBar_Delegate_send_data_hex:(NSString*)data
{
    NSLog( @"send_data: %@",data );
    
    if([data length]>0);
    else return;
    //Str=[NSString stringWithFormat:@"%@",Str];
    NSData *da2=[t stringToByte:data];
    Byte *testbyte=(Byte*)[da2 bytes];
    NSLog(@"hh=%@",data);
    int len=(int)[da2 length];
    
    
    //[t send_function_data:testbyte p:[t activePeripheral] pp:len];
    [ t send_function_data:testbyte pp:len ];
    
    //-(void) send_function_data:(Byte*)data pp:(int)len;/
    
}
-(void)read_rssi_event
{
    //    if(t.activePeripheral.state){
    //        [t.activePeripheral readRSSI];
    //        int rssi_value=(int)t.activePeripheral.RSSI.intValue;
    //        if(gn_view_ap!=nil){
    //            [gn_view_ap BLE_RSSI:rssi_value p:true];
    //        }
    //    }else{
    //        if(gn_view_ap!=nil){
    //            [gn_view_ap BLE_RSSI:0 p:false];
    //        }
    //    }
}


-(void)bt_event:(UIButton*)tag
{
    NSLog(@"button_down");
}
-(void)toggleEdit:(UIBarButtonItem*)tag
{
    NSLog(@"button_down");
    if(tag.tag==0)
    {
        NSLog(@"Set_Inf");
        NSLog(@"tag==1");
        //        vvv6=[[[VV6 alloc]init]init];
        //        vvv6.title = @"信息";
        
        //        [self.navigationController pushViewController:vvv6 animated:YES];
        
        //gn_view_ap.title=@"功能";
        //[self.navigationController pushViewController:gn_view_ap animated:YES];
    }
    else if(tag.tag==1)
    {
        select_index = 0;

        [t start_scan_ble];
        NSLog(@"Scan_Dev");
        [tab reloadData];
        //gn_view_ap.title=@"功能";
        //[self.navigationController pushViewController:gn_view_ap animated:YES];
        //ivt=1;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSLog(@"yqs---%d", [t.foundPeripherals count]);
    return (NSInteger)[t.foundPeripherals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *simple = @"simple";
    SimpleTableViewCell *cell = (SimpleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
    
    CBPeripheral	*aPeripheral;
    NSString * strNSString ;
    NSInteger		row	= [indexPath row];
    aPeripheral = (CBPeripheral*)[t.foundPeripherals objectAtIndex:row];
    
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.lableTitle.text = aPeripheral.name;
    cell.lableTime.text = @"";
    cell.stat.text = @"";
    cell.ibeacon.text = @"";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger row	= [indexPath row];
    select_row=(int)(row);

    
    [t stop_scan_ble];
    
    
    
    
    if([t get_connected_status])
    {
        
        [t disconnected_JDY_BLE:row ];
    }
    else
    {

            [t connect_JDY_BLE:row];
        
    }

    
    [self setConect_status:(int)(row+1)];
}

-(void) device_alar
{
    
    if([t get_connected_status])
    {
        
    }
    
}

-(void)at
{
    
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    vvv3=nil;
    
    ivt=0;
    if ([t get_connected_status])
    {
        // [t stop_scan_ble];
        [t disconnectPeripheral ];
        //t.activePeripheral = nil;
        
        //if(aPeripheral8)aPeripheral8=nil;
        //if (t.peripherals) t.peripherals = nil;
        //t.connectedPeripheral=nil;
        //[t start_scan_ble];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    touchuang_view = nil;
//    ibeacon_view = nil;
//    tabBarViewController_ = nil;
    
    
    [t start_scan_ble];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



- (void)myTask {
    sleep(10);
}
- (void)myTask1 {
    sleep(2);
}
- (void)myProgressTask {
    //    float progress = 0.0f;
    //    while (progress < 1.0f) {
    //        progress += 0.01f;
    //        HUD.progress = progress;
    //        usleep(20000);
    //    }
    //    dly=0;
}
- (void)myMixedTask {
    //    sleep(2);
    //    HUD.mode = MBProgressHUDModeDeterminate;
    //    HUD.labelText = @"Progress";
    //    float progress = 0.0f;
    //    while (progress < 1.0f)
    //    {
    //        progress += 0.01f;
    //        HUD.progress = progress;
    //        usleep(20000);
    //    }
    //    HUD.mode = MBProgressHUDModeIndeterminate;
    //    HUD.labelText = @"Cleaning up";
    //    sleep(2);
    //    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    //    HUD.mode = MBProgressHUDModeCustomView;
    //    HUD.labelText = @"Completed";
    //    sleep(2);
}


-(void)handleTimer99
{
    //    [self Scan];
    //    hbn++;
    //    if(hbn<20)
    //    {
    //        //if(dfg==0)
    //        //{
    //        //dfg=1;
    //        [t start_scan_ble];
    //        [timer setFireDate:[NSDate distantFuture]];
    //        //}
    //    }else hbn=30;
    //
    //    if ([t get_jdy_ble_Peripheral])
    //    {
    //        if([t get_connected_status])
    //        {
    //            //NSLog(@"是连接状态\r\n");
    //            // [vvv3 rt:0];
    //        }
    //        else
    //        {
    //            //NSLog(@"已经是断开状态\r\n");
    //            //t.activePeripheral = nil;
    //            //            if(vvv3!=nil)
    //            //            {
    //            //                [vvv3 rt:1];
    //            //            }
    //
    //        }
    //    }
}



- (void)Scan {
    ivt = 0;
    [t start_scan_ble ];
    
    NSLog(@"查找设备");
    [tab reloadData];
}

- (void) batteryIndicatorTimer:(NSTimer *)timer {
    
    
    // [t readBattery:[t activePeripheral]];
    
}
-(void)battrray:(float)batt
{
    
}

-(void) accelerometerValuesUpdated:(char)x y:(char)y z:(char)z {
    
    
    
}
-(void)rx_data_event:(Byte *)bytes :(int)len
{
    //NSString *hexStr=[t Byte_to_String:bytes :len];//[t Byte_to_hexString:bytes :len];
    if( touchuang_view!=nil )
    {
        [ touchuang_view rx_ble_event:bytes :len ];
    }
    
}

-(void)rx_function_event:(Byte *)bytes :(int)len
{
    //NSString *hexStr=[t Byte_to_String:bytes :len];//[t Byte_to_hexString:bytes :len];
    if( touchuang_view!=nil )
    {
        [ touchuang_view rx_ble_function_event:bytes :len ];
    }
    
}


-(void) keyValuesUpdated:(char)sw {
    
}

-(void) JDY_BLE_Ready {
    
//    return;
    
    //    if(conect_status!=0)
    //        [self setSelect_st:conect_status-1+100];
    //cont_status=1;
    //[tab reloadData];
    
    //[NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(batteryIndicatorTimer:) userInfo:nil repeats:YES];
    
    //    [t enableButtons:[t activePeripheral]];
    //    [t enableTXPower:[t activePeripheral]];
    
    //[t enablefefe:[t activePeripheral]];
    
    [t enable_JDY_BLE_uart];
//    [t enable_JDY_BLE_function];
    [t enable_JDY_BLE_uart_duart];
    
    NSLog(@"yyyyyyyyyyyyyyy\r\n");
    NSLog(@"didSelectRowAtIndexPath－－－－－－－=%02x",selected_type);
    [tab reloadData];
    
    if(ivt==0)
    {
        [t stop_scan_ble];
        //        gn_view_ap.title=@"功能";
        //        [self.navigationController pushViewController:gn_view_ap animated:YES];
        
        
        ivt=1;
        //        tabBarViewController_ = [[YGHTabBarController alloc] init];
        //        tabBarViewController_.delegate = self;
        //        [self.navigationController pushViewController:tabBarViewController_ animated:YES];
        
        
        
        
        

        {
            touchuang_view = [[TY_ViewController alloc] init];
            touchuang_view.delegate = (id)self;
            [self.navigationController pushViewController:touchuang_view animated:YES];
        }
        
        
        NSLog(@"====================%02x\r\n",selected_type);
        
        
        
        
        
    }
    viewData[0]=0xcc;
    viewData[1]=0x33;
    viewData[2]=0xc3;
    viewData[3]=0x3c;
    viewData[4]=0x01;
    viewData[5]=0x01;
    viewData[6]=0x01;
    viewData[7]=0x01;
    viewData[8]=0x01;
    
    //[t fefe:viewData p:[t activePeripheral] pp:9];
    
}


-(void)discoveryDidRefresh
{
    [tab reloadData];
}

-(void)addstring:(NSString*)string
{
    //NSString *st=[NSString stringWithFormat:@"设置名:%@",string];
    //lab3.text=st;
}

-(void)get_alarm
{
    
}
/*
 -(void) TXPwrLevelUpdated:(char*)TXPwr {
 NSString *ss=[NSString stringWithCString:TXPwr+2 encoding:NSASCIIStringEncoding];
 int i=TXPwr[1]-0x30;
 
 if( (i>=1)&&(i<=18))
 {
 ss=[ss substringToIndex:i];
 if(vvv3!=nil)
 {
 [vvv3 recei:ss];
 }
 }
 }*/

-(void) TXPwrLevelUpdat:(NSData*)TXP
{
    Byte *bytes = (Byte *)[TXP bytes];
    NSString *hexStr=@"";
    int ii=0;
    if( (bytes[0]!=0x51)||((bytes[1]<0x1a)||(bytes[1]>0x1e)) )return;
    ii=bytes[2];
    if( (ii>=1)&&(ii<=18))
    {
        for(int i=0;i<ii;i++)
        {
            NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i+3]&0xff]; ///16进制数
            if([newHexStr length]==1)
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            else
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
        NSLog(@"bytes 的16进制数为:%s",bytes);
        //NSString *stt=[hexStr substringWithRange:NSMakeRange(5, i)];
        NSLog(@"bytes 的16进制数为:%@,str_len%d",hexStr,(int)([hexStr length]));
        
        //        if(gn_view_ap!=nil)
        //        {
        //            [gn_view_ap BLE_RX_Data:hexStr p:bytes[1]];
        //        }
    }
    
}



-(void) connectionTimer:(NSTimer *)timer {
    
}
-(void)BZZ
{
    
}
-(int)mem
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *st=[defaults objectForKey:[NSString stringWithFormat:@"value%d",39]];
    [defaults synchronize];
    int iv=[st intValue];
    return iv;
}


/*
 -(void) send:(NSString*)Str
 {
 if([Str length]>0);
 else return;
 //Str=[NSString stringWithFormat:@"%@",Str];
 NSData *da2=[self stringToByte:Str];
 Byte *testbyte=(Byte*)[da2 bytes];
 NSLog(@"hh=%@",Str);
 int len=(int)[da2 length];
 #if(PASS_ENABLE==true)
 int le=len-1;
 Byte bb[20];
 bb[0]=0x54;
 unsigned char j=255*rand();
 bb[1]=0X54^(le+1);
 bb[2]=0x54^j;
 for(int iv=0;iv<le;iv++)
 {
 bb[iv+3]=testbyte[1+iv]^j;
 }
 [t send_uart_data:bb  pp:len+2];
 #else
 
 [t send_function_data:testbyte p:[t activePeripheral] pp:len];
 #endif
 }
 */

/*
 - (void)doneLoadingViewData{
	
	//  model should call this when its done loading
	//self.reloading = NO;
 //[self.refreshHeaderAndFooterView RefreshScrollViewDataSourceDidFinishedLoading:self.myScrollView];
 }
 #pragma mark -
 #pragma mark UIScrollViewDelegate Methods
 
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
 [self.refreshHeaderAndFooterView RefreshScrollViewDidScroll:scrollView];
 
 }
 
 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
 [self.refreshHeaderAndFooterView RefreshScrollViewDidEndDragging:scrollView];
	
 }
 #pragma mark -
 #pragma mark RefreshHeaderAndFooterViewDelegate Methods
 
 - (void)RefreshHeaderAndFooterDidTriggerRefresh:(RefreshHeaderAndFooterView*)view{
	self.reloading = YES;
 if (view.refreshHeaderView.state == PullRefreshLoading) {//下拉刷新动作的内容
 NSLog(@"header");
 [self performSelector:@selector(doneLoadingViewData) withObject:nil afterDelay:3.0];
 
 }else if(view.refreshFooterView.state == PullRefreshLoading){//上拉加载更多动作的内容
 NSLog(@"footer");
 [self performSelector:@selector(doneLoadingViewData) withObject:nil afterDelay:3.0];
 }
 }
 
 - (BOOL)RefreshHeaderAndFooterDataSourceIsLoading:(RefreshHeaderAndFooterView*)view{
	
	return self.reloading; // should return if data source model is reloading
	
 }
 - (NSDate*)RefreshHeaderAndFooterDataSourceLastUpdated:(RefreshHeaderAndFooterView*)view{
 return [NSDate date];
 }
 
 */




- (void)viewDidUnload
{
    [super viewDidUnload];
    //NSLog(@"DSFDSFSDF");
    
    //    HUD=nil;
    //    HUD1=nil;
    alert=nil;
    
    
    editButton=nil;
    editButton1=nil;
    //vvv1=nil;
    //    vvv3=nil;
//    [timer invalidate];
//    timer=nil;
//    
    //    [t disableTXPower:[t activePeripheral]];
    //    [t disablefefe:[t activePeripheral]];
    
    if(aPeripheral8)aPeripheral8=nil;
    //    if (t.peripherals) t.peripherals = nil;
    [t clearDevices];
    //[t start_scan_ble];
    
    aPeripheral8=nil;
    
    //    HUD=nil;
    
    if ([timer8 isValid] == YES) {
        [timer8 invalidate];
        timer8 = nil;
    }
    //image8=nil;
    
    
    
    
    //[t start_scan_ble];
    
}
@end
