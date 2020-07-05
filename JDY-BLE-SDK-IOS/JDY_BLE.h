
//
//  Created by JDY on 14-8-8.
//  Copyright (c) 2014年 JDY. All rights reserved.
//


//clang: error: linker command failed with exit code 1 (use -v to see invocation)





#import <Foundation/Foundation.h>



#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
//#import "hd.h"

#ifndef mokuai_t1_Header1_h
#define mokuai_t1_Header1_h

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
//获取设备的物理高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

//获取设备的物理宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#endif

typedef enum//iBeacon模式设备类型  === 0xe0
{
    ibeacon = 0xe0,//iBeacon设备
    sensor_temp,//温度传感器
    sensor_humid,//湿度传感器
    sensor_temp_humid,//湿湿度传感器
    sensor_fanxiangji,//芳香机香水用量显示仪
    sensor_zhilanshuibiao,//智能水表传感器，抄表仪
    sensor_dianyabiao,//电压传感器
    sensor_dianliu,//电流传感器
    sensor_zhonglian,//称重传感器
    sensor_pm2_5,//PM2.5传感器
    
    //透传
    touchuang = 0xa0,//透传
    touchuang1,// 表示连接后串口无连接状态输出
    
    
    //PWM --按摩器类
    pwm_anmoqi_0 = 0xa5,//成人用品按摩棒    APP默认选择
    pwm_anmoqi_1,//按摩胸围罩
    pwm_anmoqi_2,//按摩椅
    
    //pwm --纹眉器
    pwm_wenmei = 0xa8,
    
    
    //PWM --LED灯
    pwm_dentiao=0xb1,//LED灯带
    pwm_denpao,//LED灯球泡
    pwm_xiaoyeiden,//LED蜡烛灯
    
    //IO --开关类
    io_key1 = 0xc1,//单路开关控制器
    io_key2 = 0xc2,//双路开关控制器
    io_key3 = 0xc3,//三路开关控制器
    io_key4 = 0xc4,//四路开关控制器    APP默认选择
    
    //空气净化器类
    kongqi_1 = 0xd1,//PM2_5显示
    
    //饮水机类
    
} jdy_dev_bj_type ;








@protocol JDY_BLE_Delegate
@optional
-(void) JDY_BLE_Ready;//模块连接后会调用此函数

@required
-(void)rx_data_event:(Byte *)bytes :(int)len;// 透传通道 数据回调函数
-(void)rx_function_event:(Byte *)bytes :(int)len;//功能配置 通道回调函数

- (void) discoveryDidRefresh;//扫描到列表时调用此函数

@end

@interface JDY_BLE : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    BOOL                pendingInit;
    
}



@property (nonatomic,assign) id <JDY_BLE_Delegate> delegate;

@property (retain, nonatomic) NSMutableArray    *foundPeripherals;
@property (retain, nonatomic) NSMutableArray    *MAC_ADDRESS;
@property (retain, nonatomic) NSMutableArray    *JDY_BLE_NAME;
//@property (retain, nonatomic) NSMutableArray    *JDY_BLE_NAME;
@property (strong, nonatomic) CBPeripheral *activePeripheral;


-(void)disconnectPeripheral;//断开连接
- (void) clearDevices;//清除扫描列表

-(void)enable_JDY_BLE_function:(CBPeripheral *)p;//使能JDY系列BLE模块的功能配置Notify服务
-(void)enable_JDY_BLE_uart:(CBPeripheral *)p;//使能JDY系列BLE模块的串口Notify服务

-(void)enable_JDY_BLE_uart_duart;
-(void)enable_JDY_BLE_function;//使能JDY系列BLE模块的功能配置Notify服务
-(void)enable_JDY_BLE_uart;//使能JDY系列BLE模块的串口Notify服务




//-(void) initConnectButtonPointer:(UIButton *)b;
-(void) send_uart_data:(Byte*)data p:(CBPeripheral *)p pp:(int)len;//发送串口透传数据
-(void) send_function_data:(Byte*)data p:(CBPeripheral *)p pp:(int)len;//发送功能配置数据（ IO、PWM、设备名、广播间隔、iBeacon ）

-(void) send_uart_data:(Byte*)data  pp:(int)len;//发送串口透传数据
-(void) send_function_data:(Byte*)data pp:(int)len;//发送功能配置数据（ IO、PWM、设备名、广播间隔、iBeacon ）




-(void) start_scan_ble;//开始扫描设备
-(void) stop_scan_ble;//停止扫描设备

-(void) disconnected_JDY_BLE:(NSInteger )indexPath;//连接列表设备
-(void) connect_JDY_BLE:(NSInteger )indexPath;//断开连接列表调和



-(Boolean)get_connected_status;//
-(Boolean)get_jdy_ble_Peripheral;//




-(NSString*)get_mac_address:(int) index;//
-(Byte )get_jdy_ble_type:(int) index;//
-(Byte )get_jdy_ble_vid:(int)index;//


-(NSString*)get_ibeacon_major:(int)index;//

-(NSString*)get_ibeacon_minor:(int)index;//

-(NSString*)get_sensor_temp:(int)index;//

-(NSString*)get_sensor_humid:(int)index;//

-(NSString*)get_sensor_batt:(int)index;//

-(int) get_rssi:(int)index;//


-(void)delay_ms:(int)ms;


-(NSData*)stringToByte:(NSString*)string;

-(NSString*)Byte_to_hexString:(Byte *)bytes :(int)len;//十六进制转 十六进制字符串
-(NSString*)Byte_to_String:(Byte *)bytes :(int)len;//十六进制转 字符串

-(void) set_VID:(Byte)ID;//设置厂家VID 默认为JDY厂家VID为0X88




@end
