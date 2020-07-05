//
//  BLE_LXXAVR.m
//  BLE_LXXAVR
//
//  Created by LXXAVR on 14-1-9.
//  Copyright (c) 2014年 LXXAVR. All rights reserved.
//

#import "JDY_BLE.h"
#define TI_KEYFOB_PROXIMITY_ALERT_UUID                     0x5678 //0x1802
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID            0x1234 //0x2a06

#define TI_KEYFOB_PROXIMITY_ALERT_ON_VAL                    0x01
#define TI_KEYFOB_PROXIMITY_ALERT_OFF_VAL                   0x00
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1

#define TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID             0x1111//0x1804
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID        0x1000
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN    1


#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
#define TI_KEYFOB_LEVEL_SERVICE_READ_LEN                    1

#define TI_KEYFOB_ACCEL_SERVICE_UUID                        0xFFA0
#define TI_KEYFOB_ACCEL_ENABLER_UUID                        0xFFA1
#define TI_KEYFOB_ACCEL_RANGE_UUID                          0xFFA2
#define TI_KEYFOB_ACCEL_READ_LEN                            1
#define TI_KEYFOB_ACCEL_X_UUID                              0xFFA3
#define TI_KEYFOB_ACCEL_Y_UUID                              0xFFA4
#define TI_KEYFOB_ACCEL_Z_UUID                              0xFFA5

#define JDY_SERVICE_UUID                         0xFFE0
#define TI_KEYFOB_KEYS_NOTIFICATION_UUID                    0xFFE1
#define JDY_FONCTION_UUID                     0xFFE2

#define TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN                1



#define uart_server_uuid 0xffe0
#define uart_data_uuid_duart 0xffe1
#define uart_data_uuid 0xffe3
#define uart_tx_uuid 0xffe2

@interface JDY_BLE ()
{
    
    
}
@property (strong, nonatomic) CBCentralManager *CM;
//@property (strong, nonatomic) CBPeripheral *activePeripheral;


@property (retain, nonatomic) CBCentralManager  *centralManager;
@property (retain, nonatomic) CBPeripheral      *connectedPeripheral;

@end


@implementation JDY_BLE
{
    NSMutableArray    *scan_data;
    NSMutableArray    *scan_type;
    NSMutableArray    *scan_rssi;
    
    NSMutableArray    *dev_count_add;
    int count ;
    
    
    Byte vid;
    
    
    NSTimer *uart_timer;
    
    Boolean is_scan ;
    int en_count;
}





@synthesize delegate;
@synthesize CM;
//@synthesize peripherals;
@synthesize activePeripheral;
/*
 @synthesize batteryLevel;
 @synthesize key1;
 @synthesize key2;
 @synthesize x;
 @synthesize y;
 @synthesize z;
 */

//@synthesize TIBLEConnectBtn;

//@synthesize foundaPeripheral;
@synthesize foundPeripherals;
@synthesize MAC_ADDRESS;
@synthesize JDY_BLE_NAME;

@synthesize centralManager;
@synthesize connectedPeripheral;





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


- (id) init
{
    self = [super init];
    if (self) {
        pendingInit = YES;
        
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:/*dispatch_get_current_queue()*/nil];
        self.foundPeripherals = [[NSMutableArray alloc] init];
        MAC_ADDRESS = [[NSMutableArray alloc] init];
        
        scan_data = [[NSMutableArray alloc] init];
        scan_type = [[NSMutableArray alloc] init];
        
        JDY_BLE_NAME = [[NSMutableArray alloc] init];
        
        scan_rssi = [[NSMutableArray alloc] init];
        
        dev_count_add = [[NSMutableArray alloc] init];
        count = 0;
        
        self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        //uart_timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f                                    target: self                                 selector: @selector(handleTimer_event)//设定定时器回调
        //                                            userInfo: nil
        //                                             repeats: YES];
        
        is_scan = false;
        en_count = 0;
        
        vid = 0x88;//默认为JDY厂家VID
        
        //[uart_timer setFireDate:[NSDate distantPast]];//开定时器
        //[uart_timer setFireDate:[NSDate distantFuture]];//关定时器
        
    }
    //NSLog(@"init");
    return self;
}

-(void) set_VID:(Byte)ID
{
    vid = ID;
}
-(void) jdy_send_data_hex:(NSString*)data
{
    if([data length]>0);
    else return;
    //Str=[NSString stringWithFormat:@"%@",Str];
    NSData *da2=[self stringToByte:data];
    Byte *testbyte=(Byte*)[da2 bytes];
    NSLog(@"hh=%@",data);
    int len=(int)[da2 length];
    [ self send_function_data:testbyte pp:len ];
}
-(void)handleTimer_event
{
    
    //NSLog(@"handleTimer_event");
    if( is_scan==false )
    {
        [self.CM stopScan];
        
        if( [self-> dev_count_add count]>0 )
        {
            if( count>=[self-> dev_count_add count] )
            {
                count =0;
            }
            
            NSNumber *tid = [dev_count_add objectAtIndex:count];
            int vf = tid.intValue;
            vf++;
            NSNumber *number = [NSNumber numberWithInt:vf];
            [self->dev_count_add replaceObjectAtIndex:count withObject:number ];
            
            NSLog( @"count:%d",vf);
            
            tid = [self-> dev_count_add objectAtIndex:count];
            vf = tid.intValue;
            if( vf>2 )
            {
                vf = 0;
                [self->foundPeripherals removeObjectAtIndex:count ];
                [self->MAC_ADDRESS removeObjectAtIndex:count ];
                [self->JDY_BLE_NAME removeObjectAtIndex:count ];
                [self->scan_rssi removeObjectAtIndex:count ];
                [self->scan_data removeObjectAtIndex:count ];
                [self->scan_type removeObjectAtIndex:count ];
                [self->dev_count_add removeObjectAtIndex:count ];
                [[self delegate] discoveryDidRefresh];//
            }
            count++;
        }
        
        [self.CM scanForPeripheralsWithServices:nil options:0];
        en_count = 0;
    }
    else
    {
        en_count++;
        if( en_count>5 )
        {
            en_count = 0;
            // [self jdy_send_data_hex:@"E90105"];
        }
        
    }
    // [self start_scan_ble];
}


- (void) deallocPeripheral
{
    if (connectedPeripheral)
    {
        [connectedPeripheral setDelegate:self];
        connectedPeripheral = nil;
    }
}

- (void) reset{
    if (connectedPeripheral) {
        connectedPeripheral = nil;
    }
}


//-(void) initConnectButtonPointer:(UIButton *)b {
//    TIBLEConnectBtn = b;
//}


-(void)fefe:(Byte *)b p:(CBPeripheral *)p pp:(int)len{
    NSData *d = [[NSData alloc] initWithBytes:b length:len];
    [self writeValue:0xfff0 characteristicUUID:0xfff6 p:p data:d];
}


-(void)enable_rx_tx:(Byte*)bit
{
    
}

-(void) enable_JDY_BLE_uart:(CBPeripheral *)p {
    [self notification:uart_server_uuid characteristicUUID:uart_data_uuid p:p on:YES];
}

-(void) enable_JDY_BLE_function:(CBPeripheral *)p {
    [self notification:uart_server_uuid characteristicUUID:uart_tx_uuid p:p on:YES];
}

-(void) enable_JDY_BLE_uart {
    [self notification:uart_server_uuid characteristicUUID:uart_data_uuid p:activePeripheral on:YES];
}

-(void)enable_JDY_BLE_uart_duart{
    [self notification:uart_server_uuid characteristicUUID:uart_data_uuid_duart p:activePeripheral on:YES];
}

-(void) enable_JDY_BLE_function {
    [self notification:uart_server_uuid characteristicUUID:uart_tx_uuid p:activePeripheral on:YES];
}

-(void) start_scan_ble
{
    if (self.activePeripheral.state)
    {
        [self.CM stopScan];
        //[self disconnectPeripheral];
        is_scan = true;
    }else{
        //        [uart_timer setFireDate:[NSDate distantPast]];//开定时器
        is_scan = false;
    }
    
    // [self.CM scanForPeripheralsWithServices:nil options:0];
    
    //[self.foundPeripherals removeAllObjects];
    
    [self clearDevices];
    //if(aPeripheral8)aPeripheral8=nil;
    //if (t.peripherals) t.peripherals = nil;
    //t.connectedPeripheral=nil;
    [self findBLEPeripherals:3];
}
-(void) stop_scan_ble;//停止扫描设备
{
    [self.CM stopScan];
    //    [uart_timer setFireDate:[NSDate distantFuture]];//关定时器
    is_scan = true;
}

-(void) send_uart_data:(Byte *)data p:(CBPeripheral *)p pp:(int)len{
    int mx = len/20;
    int mi = len%20;
    int ys = 0;
    Byte *by = data;
    
    for( int i=0;i<mx;i++ )
    {
        NSData *d = [[NSData alloc] initWithBytes:by+20*i length:20*(i+1)];
        [self writeValue:uart_server_uuid characteristicUUID:uart_tx_uuid p:p data:d];
        [self delay_ms:5000];
        ys = i;
    }
    if( mi>0 )
    {
        NSData *d = [[NSData alloc] initWithBytes:by+20*ys length:mi];
        [self writeValue:uart_server_uuid characteristicUUID:uart_tx_uuid p:p data:d];
    }
    
    
    
}

-(void) send_function_data:(Byte*)data p:(CBPeripheral *)p pp:(int)len
{
    NSData *d = [[NSData alloc] initWithBytes:data length:len];
    [self writeValue1:uart_server_uuid characteristicUUID:uart_tx_uuid p:p data:d];
}
-(void) send_uart_data:(Byte *)data  pp:(int)len{
    
    int mx = len/20;
    int mi = len%20;
    int ys = 0;
    Byte *by = data;
    if( mx>0 )
    {
        for( int i=0;i<mx;i++ )
        {
            NSData *d = [[NSData alloc] initWithBytes:by+20*i length:20 ];
            [self writeValue:uart_server_uuid characteristicUUID:uart_data_uuid p:activePeripheral data:d];
            [self delay_ms:20];
            ys++;
            //NSLog( @"mx: %@",d );
        }
    }
    if( mi>0 )
    {
        NSData *d = [[NSData alloc] initWithBytes:by+20*ys length:mi];
        [self writeValue:uart_server_uuid characteristicUUID:uart_data_uuid p:activePeripheral data:d];
        //NSLog( @"mi: %@",d );
    }
    
    
    
    //    NSData *d = [[NSData alloc] initWithBytes:data length:len];
    //    //[self writeValue:TI_KEYFOB_PROXIMITY_ALERT_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID p:p data:d];
    //    [self writeValue:uart_server_uuid characteristicUUID:uart_rx_uuid p:activePeripheral data:d];
    //    //[self writeValue:TI_KEYFOB_PROXIMITY_ALERT_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID p:p data:d];
}

-(void) send_function_data:(Byte*)data  pp:(int)len
{
    NSData *d = [[NSData alloc] initWithBytes:data length:len];
    [self writeValue1:uart_server_uuid characteristicUUID:uart_tx_uuid p:activePeripheral data:d];
}

-(void) readBattery:(CBPeripheral *)p {
    [self readValue:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:p];
}


//

-(void) enableAccelerometer:(CBPeripheral *)p {
    char data = 0x01;
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    [self writeValue:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_ENABLER_UUID p:p data:d];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_X_UUID p:p on:YES];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Y_UUID p:p on:YES];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Z_UUID p:p on:YES];
    //NSLog(@"Enabling accelerometer\r\n");
}


-(void) disableAccelerometer:(CBPeripheral *)p {
    char data = 0x00;
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    [self writeValue:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_ENABLER_UUID p:p data:d];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_X_UUID p:p on:NO];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Y_UUID p:p on:NO];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Z_UUID p:p on:NO];
    //NSLog(@"Disabling accelerometer\r\n");
}


-(void) enableButtons:(CBPeripheral *)p {
    [self notification:JDY_SERVICE_UUID characteristicUUID:TI_KEYFOB_KEYS_NOTIFICATION_UUID p:p on:YES];
}

-(void) disableButtons:(CBPeripheral *)p {
    [self notification:JDY_SERVICE_UUID characteristicUUID:TI_KEYFOB_KEYS_NOTIFICATION_UUID p:p on:NO];
}

-(void) enableTXPower:(CBPeripheral *)p {
    [self notification:JDY_SERVICE_UUID characteristicUUID:JDY_FONCTION_UUID p:p on:YES];
}

-(void) disableTXPower:(CBPeripheral *)p {
    [self notification:JDY_SERVICE_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID p:p on:NO];
}

-(void)enablefefe:(CBPeripheral *)p
{
    [self notification:0xfff0 characteristicUUID:0xfff6 p:p on:YES];
}
-(void)disablefefe:(CBPeripheral *)p
{
    [self notification:0xfff0 characteristicUUID:0xfff6 p:p on:NO];
}

-(void) writeValue1:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //NSLog(@"Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        //NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        // NSLog(@"Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        // NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}


-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //  NSLog(@"Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        //  NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p readValueForCharacteristic:characteristic];
}



-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        // NSLog(@"Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        // NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}


-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}


//- (int) controlSetup{
//    self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//    return 0;
//}


- (int) findBLEPeripherals:(int) timeout {
    
    //    if (self->CM.state  != CBCentralManagerStatePoweredOn)
    //    {
    //        //NSLog(@"CoreBluetooth not correctly initialized !\r\n");
    //        // NSLog(@"State = %d (%s)\r\n",self->CM.state,[self centralManagerStateToString:self.CM.state]);
    //        return -1;
    //    }
    
    //NSString *kLinkServicesUUID = @"5679";
    // NSArray *uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:kLinkServicesUUID], nil];
    //NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    //[self.CM scanForPeripheralsWithServices:uuidArray options:options];
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    [self.CM scanForPeripheralsWithServices:nil options:0];
    
    
    
    
    
    return 0;
}


-(void) disconnected_JDY_BLE:(NSInteger )index {
    // NSLog(@"Connecting to peripheral with UUID : %s\r\n",[self UUIDToString:peripheral.UUID]);
    activePeripheral = (CBPeripheral *)[self.foundPeripherals objectAtIndex:(int)index];;
    [self deallocPeripheral];
    [CM cancelPeripheralConnection:activePeripheral];
    
}



-(void) connect_JDY_BLE:(NSInteger )index
{
    if( foundPeripherals==NULL) return;
    
    int idd = (int)[self.foundPeripherals count];
    
    //NSLog(@"len=%d",idd);
    if( idd==0)return;
    activePeripheral = (CBPeripheral *)[self.foundPeripherals objectAtIndex:(int)index];;
    activePeripheral.delegate = self;
    [CM connectPeripheral:activePeripheral options:nil];
    
    
    //NSString*strNSString = [[NSString alloc] initWithUTF8String:[self UUIDToString:[[self activePeripheral] UUID]]];
    
    NSString *gt =[self Read_DEV_UUID:activePeripheral ];
    NSLog(@"ttt==%@",gt);
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [self deallocPeripheral];
    [CM cancelPeripheralConnection:peripheral];
}

-(void)disconnectPeripheral;
{
    [self deallocPeripheral];
    [CM cancelPeripheralConnection:activePeripheral];
}

-(Boolean)get_connected_status
{
    return (Boolean)activePeripheral.state;
}
-(Boolean)get_jdy_ble_Peripheral
{
    if( activePeripheral==NULL )return false;
    else return true;
}

- (void) clearDevices
{
    NSArray	*servicearray;
    
    
    
    for (servicearray in self.foundPeripherals) {
        [self reset];
    }
    for (servicearray in self.MAC_ADDRESS) {
        [self reset];
    }
    for (servicearray in self.JDY_BLE_NAME) {
        [self reset];
    }
    
    [self.foundPeripherals removeAllObjects];
    [self.MAC_ADDRESS removeAllObjects];
    [self.JDY_BLE_NAME removeAllObjects];
    
    [scan_rssi removeAllObjects];
    [scan_data removeAllObjects];
    [scan_type removeAllObjects];
    
    
    
    
    [self.foundPeripherals removeAllObjects];
}

- (const char *) centralManagerStateToString: (int)state{
    switch(state) {
        case CBCentralManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    return "Unknown state";
}


- (void) scanTimer:(NSTimer *)timer {
    [self.CM stopScan];
    //NSLog(@"Stopped Scanning\r\n");
    //NSLog(@"Known peripherals : %d\r\n",[self->peripherals count]);
    [self printKnownPeripherals];
}


- (void) printKnownPeripherals {
    //    int i;
    //    //NSLog(@"List of currently known peripherals : \r\n");
    //    for (i=0; i < self->peripherals.count; i++)
    //    {
    //        CBPeripheral *p = [self->peripherals objectAtIndex:i];
    //        //        CFStringRef s = CFUUIDCreateString(NULL, p.UUID);
    //        //        NSLog(@"%d  |  %s\r\n",i,CFStringGetCStringPtr(s, 0));
    //        [self printPeripheralInfo:p];
    //    }
}


- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    /*
     CFStringRef s = CFUUIDCreateString(NULL, peripheral.UUID);
     NSLog(@"------------------------------------\r\n");
     NSLog(@"Peripheral Info :\r\n");
     NSLog(@"UUID : %s\r\n",CFStringGetCStringPtr(s, 0));
     NSLog(@"RSSI : %d\r\n",[peripheral.RSSI intValue]);
     NSLog(@"Name : %@\r\n",peripheral.name);
     NSLog(@"isConnected : %d\r\n",peripheral.isConnected);
     NSLog(@"-------------------------------------\r\n");
     */
    
}



- (int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2 {
    CFUUIDBytes b1 = CFUUIDGetUUIDBytes(u1);
    CFUUIDBytes b2 = CFUUIDGetUUIDBytes(u2);
    if (memcmp(&b1, &b2, 16) == 0) {
        return 1;
    }
    else return 0;
}



-(void) getAllServicesFromKeyfob:(CBPeripheral *)p{
    //    [TIBLEConnectBtn setTitle:@"Discovering services.." forState:UIControlStateNormal];
    [p discoverServices:nil];
}


-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p{
    //    [TIBLEConnectBtn setTitle:@"Discovering characteristics.." forState:UIControlStateNormal];
    for (int i=0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        //NSLog(@"Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
}


-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}



-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}



-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    //    [UUID1.data getBytes:b1];
    //    [UUID2.data getBytes:b2];
    
    [UUID1.data getBytes:b1 length:16];
    [UUID2.data getBytes:b2 length:16];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}


-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    //    [UUID1.data getBytes:b1];
    [UUID1.data getBytes:b1 length:16];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    //    [UUID.data getBytes:b1];
    [UUID.data getBytes:b1 length:16];
    return ((b1[0] << 8) | b1[1]);
}


-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}



-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil;
}



-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil;
}


-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}
 
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    //lxxavr NSLog(@"Status of CoreBluetooth central manager changed %d (%s)\r\n",central.state,[self centralManagerStateToString:central.state]);
}

-(NSString*) get_string_data:(NSString *)src p:(int)start p2:(int)end
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//去除空格
    str = [str substringWithRange:NSMakeRange(start, end )];
    str = [str uppercaseString];
    return str;
}

-(NSString*)get_mac_address:(NSString*)src : (Boolean)p
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//
    if( p==false )
    {
        str = [str substringWithRange:NSMakeRange(5+4, 12 )];
        str = [str uppercaseString];
        
        NSMutableString* string1= [NSMutableString stringWithFormat:@"%@",str];;
        [string1 insertString:@":" atIndex:2];
        [string1 insertString:@":" atIndex:5];
        [string1 insertString:@":" atIndex:8];
        [string1 insertString:@":" atIndex:11];
        [string1 insertString:@":" atIndex:14];
        return string1;
    }
    else{
        NSString *str1 = [str substringWithRange:NSMakeRange(2, 14 )];;
        NSString *scs = [str1 substringWithRange:NSMakeRange(0, 2 )];
        //NSLog( @"mac_byte_2=====%@",scs );
        str1 = [str1 stringByReplacingOccurrencesOfString:scs withString:@""];
        
        
        str1 = [str1 stringByReplacingOccurrencesOfString:@"=<" withString:@""];
        str1 = [str1 uppercaseString];
        NSMutableString* string1= [NSMutableString stringWithFormat:@"%@",str1];;
        [string1 insertString:scs atIndex:2];
        
        [string1 insertString:@":" atIndex:2];
        [string1 insertString:@":" atIndex:5];
        [string1 insertString:@":" atIndex:8];
        [string1 insertString:@":" atIndex:11];
        [string1 insertString:@":" atIndex:14];
        return string1;
    }
}
-(Byte )get_jdy_ble_type:(NSString*)src :(Boolean)p
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//
    str = [str uppercaseString];
    NSString *out_str = NULL;
    Byte *int_type;
    //NSLog(@"ble_type_str=====%@",str);
    if( p )//ibeacon
    {
        out_str = [str substringWithRange:NSMakeRange(26, 2 )];
        NSData *ttttt=[self stringToByte:out_str];
        int_type=(Byte*)[ttttt bytes];
    }
    else//透传类型
    {
        out_str = [str substringWithRange:NSMakeRange(19-12, 2 )];//
        NSData *ttttt=[self stringToByte:out_str];
        int_type=(Byte*)[ttttt bytes];
    }
    //SLog(@"ble_type_str=====%@",str);
    //NSLog(@"ble_type1=====%@",out_str);
    
    //NSLog(@"ble_type2=====%02x",int_type[0]);
    
    return int_type[0];
}
-(Byte )get_jdy_ble_vid:(NSString*)src :(Boolean)p
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//
    str = [str uppercaseString];
    NSString *out_str = NULL;
    Byte *int_type;
    //NSLog(@"ble_vid_str-1=====%@",str);
    if( p )//ibeacon
    {
        out_str = [str substringWithRange:NSMakeRange(24, 2 )];
        NSData *ttttt=[self stringToByte:out_str];
        int_type=(Byte*)[ttttt bytes];
    }
    else//透传类型
    {
        out_str = [str substringWithRange:NSMakeRange(17-12, 2 )];//
        NSData *ttttt=[self stringToByte:out_str];
        int_type=(Byte*)[ttttt bytes];
    }
    //NSLog(@"ble_vid_str=====%@",str);
    //NSLog(@"ble_vid1=====%@",out_str);
    
    //NSLog(@"ble_vid2=====%02x",int_type[0]);
    
    return int_type[0];
}
-(NSString*)get_jdy_ibeacon_major:(NSString*)src
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//
    str = [str uppercaseString];
    NSString *out_str = NULL;
    out_str = [str substringWithRange:NSMakeRange(16, 4 )];
    //NSLog(@"get_jdy_ibeacon_major=====%@",out_str);
    return out_str;
}
-(NSString*)get_jdy_ibeacon_minor:(NSString*)src
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//
    str = [str uppercaseString];
    NSString *out_str = NULL;
    out_str = [str substringWithRange:NSMakeRange(20, 4 )];
    //NSLog(@"get_jdy_ibeacon_minor=====%@",out_str);
    return out_str;
}

-(NSString*)get_jdy_sensor_temp:(NSString*)src
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//
    str = [str uppercaseString];
    NSString *out_str = NULL;
    out_str = [str substringWithRange:NSMakeRange(28, 2 )];
    //NSLog(@"get_jdy_sensor_temp=====%@",out_str);
    return out_str;
}
-(NSString*)get_jdy_sensor_humid:(NSString*)src
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//
    str = [str uppercaseString];
    NSString *out_str = NULL;
    out_str = [str substringWithRange:NSMakeRange(30, 2 )];
    //NSLog(@"get_jdy_sensor_humid=====%@",out_str);
    return out_str;
}
-(NSString*)get_jdy_sensor_batt:(NSString*)src
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//
    str = [str uppercaseString];
    NSString *out_str = NULL;
    out_str = [str substringWithRange:NSMakeRange(32, 2 )];
    //NSLog(@"get_jdy_sensor_batt=====%@",out_str);
    return out_str;
}

-(Boolean)js_jdy_dev:(NSString*)src //透传判断设备类型
{
    NSString *str = [src stringByReplacingOccurrencesOfString:@" " withString:@""];//去除空格
    str = [str substringWithRange:NSMakeRange(1, 20 )];
    str = [str uppercaseString];
    //NSLog(@"str1=====%@",str);
    
    NSData *ttttt=[self stringToByte:str];
    Byte *testbyte=(Byte*)[ttttt bytes];
    
    Byte b1 =(testbyte[0]^0x11)-1;
    Byte b2 =(testbyte[1]^0x22)-1;
    
    Byte b3 = testbyte[7+2];
    Byte b4 = testbyte[6+2];
    
    //NSLog(@"str2=====%02x",testbyte[7]);
    //NSLog(@"str3=====%02x",testbyte[6]);
    
    if( b3==b1&&b4==b2 )
    {
        return true;
    }else return false;
    
}





-(NSString*)get_mac_address:(int) index
{
    Boolean p = false;
    NSString *sstr = [scan_data objectAtIndex:index];
    NSString *str_tp = [scan_type objectAtIndex:index];
    
    if( [str_tp isEqualToString:@"1"] ) p=true;
    NSString *str = [sstr stringByReplacingOccurrencesOfString:@" " withString:@""];//
    
    return (NSString*)[self get_mac_address:str :p];
}
-(Byte )get_jdy_ble_type:(int) index
{
    Boolean p = false;
    NSString *src = [scan_data objectAtIndex:index];
    NSString *str_tp = [scan_type objectAtIndex:index];
    
    if( [str_tp isEqualToString:@"1"] ) p=true;
    
    return [self get_jdy_ble_type:src :p];
}
-(Byte )get_jdy_ble_vid:(int)index
{
    Boolean p = false;
    NSString *src = [scan_data objectAtIndex:index];
    NSString *str_tp = [scan_type objectAtIndex:index];
    
    if( [str_tp isEqualToString:@"1"] ) p=true;
    
    return [self get_jdy_ble_vid:src :p];
}
-(NSString*)get_ibeacon_major:(int)index
{
    //    Boolean p = false;
    NSString *src = [scan_data objectAtIndex:index];
    NSString *str_tp = [scan_type objectAtIndex:index];
    
    if( [str_tp isEqualToString:@"1"] )
    {
        return [self get_jdy_ibeacon_major:src];
    }
    else
        return @"";
    
}
-(NSString*)get_ibeacon_minor:(int)index
{
    NSString *src = [scan_data objectAtIndex:index];
    NSString *str_tp = [scan_type objectAtIndex:index];
    
    if( [str_tp isEqualToString:@"1"] )
    {
        return [self get_jdy_ibeacon_minor:src];
    }
    else
        return @"";
}
-(NSString*)get_sensor_temp:(int)index
{
    NSString *src = [scan_data objectAtIndex:index];
    NSString *str_tp = [scan_type objectAtIndex:index];
    
    if( [str_tp isEqualToString:@"1"] )
    {
        return [self get_jdy_sensor_temp:src];
    }
    else
        return @"";
}
-(NSString*)get_sensor_humid:(int)index
{
    NSString *src = [scan_data objectAtIndex:index];
    NSString *str_tp = [scan_type objectAtIndex:index];
    
    if( [str_tp isEqualToString:@"1"] )
    {
        return [self get_jdy_sensor_humid:src];
    }
    else
        return @"";
}
-(NSString*)get_sensor_batt:(int)index
{
    NSString *src = [scan_data objectAtIndex:index];
    NSString *str_tp = [scan_type objectAtIndex:index];
    
    if( [str_tp isEqualToString:@"1"] )
    {
        return [self get_jdy_sensor_batt:src];
    }
    else
        return @"";
}

-(int) get_rssi:(int)index
{
    NSNumber *rss = [scan_rssi objectAtIndex:index];
    int is = [rss intValue];
    
    return is;
}



-(void)delay_ms:(int)ms
{
    [NSThread sleepForTimeInterval:0.001f];
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    //NSLog(@"scan_rssi = %d",[RSSI intValue] );
    
    
    if (![self->foundPeripherals containsObject:peripheral] && peripheral.name.length != 0)//
    {
        [self->foundPeripherals addObject:peripheral];
        NSLog(@"yqs:%@", peripheral.name);
//        [self->MAC_ADDRESS addObject:tsss];
//        [self->JDY_BLE_NAME addObject:name_jdy ];
        
        [[self delegate] discoveryDidRefresh];//
    }
    
    
    
    
    return;
    
    
    NSString *tsss=@"";
    //NSLog(@"advertisementData=====%@",advertisementData);
    //NSMutableArray *s=[advertisementData objectForKey: @"kCBAdvDataServiceUUIDs"];
    
    //NSString *sts = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    //    NSLog(@"kCBAdvDataManufacturerData=====%@",sts);
    Boolean is_iBeacon = false;// false表示默认透传模式，但为TRUE时表示是IBEACON模式
    NSValue* value6=[advertisementData objectForKey:@"kCBAdvDataLocalName"];// 透传与iBeacon通用
    
    NSValue* value3=[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];//只有透传使用
    NSValue* value100=[advertisementData objectForKey:@"kCBAdvDataServiceData"];// 只有IBEACON使用
    
    if( value6==NULL )return;
    if( value3==NULL&&value100==NULL )return;
    if( value3==NULL&&value100!=NULL )is_iBeacon=true;//IBEACON
    else if( value3!=NULL&&value100==NULL )is_iBeacon=false;//透传
    
    
    
    const char *p3=[[value3 description]cStringUsingEncoding:NSUTF8StringEncoding];
    const char *p6=[[value6 description]cStringUsingEncoding:NSUTF8StringEncoding];
    const char *p100=[[value100 description]cStringUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString *name_jdy = [[NSString alloc] initWithUTF8String:p6];
    
    NSString *all_data =@"";
    
    //NSLog(@"is_iBeacon=====%d",is_iBeacon);
    
    NSString *str_type = @"";
    if( is_iBeacon==false )//透传
    {
        all_data = [[NSString alloc] initWithUTF8String:p3];
        
        //NSLog(@"all_data.length=====%d",(int)all_data.length );
        if( all_data.length!=24 )return;
        if( [self get_jdy_ble_vid:all_data :is_iBeacon]!=vid )return ;
        
        //        [self get_jdy_ble_type:all_data :is_iBeacon];
        //NSLog(@"all_data=====%@",all_data );
        //透传判断设备
        if([self js_jdy_dev:all_data]==false )return ;
        tsss = [self get_mac_address:all_data :is_iBeacon];
        //NSLog(@"touchuang_mac_address=====%@",tsss );
        str_type = @"0";
    }
    else
    {
        NSString *ibeacon_jdy = [[NSString alloc] initWithUTF8String:p100];
        all_data =ibeacon_jdy;
        
        //NSLog(@"beacon_all_data_len=====%d",(int)all_data.length );
        // get_jdy_ble_vid:(NSString*)src :(Boolean)p
        if( ibeacon_jdy.length==47 && [self get_jdy_ble_vid:all_data :is_iBeacon]==vid )
        {
            //            [self get_jdy_ble_type:ibeacon_jdy :is_iBeacon];
            //            [self get_jdy_ble_vid:ibeacon_jdy :is_iBeacon];
            //            [self get_jdy_ibeacon_major:ibeacon_jdy];
            //            [self get_jdy_ibeacon_minor:ibeacon_jdy];
            //            [self get_jdy_sensor_temp:ibeacon_jdy];
            //            [self get_jdy_sensor_humid:ibeacon_jdy];
            //            [self get_jdy_sensor_batt:ibeacon_jdy];
            
            //NSLog(@"beacon_all_data=====%@",ibeacon_jdy );
            
            tsss = [self get_mac_address:all_data :is_iBeacon];
            //NSLog(@"beacon_mac_address=====%@",tsss );
            str_type = @"1";
        }else return ;
    }
    [peripheral  readRSSI];
    
    if( [all_data length]>=19 )
    {
        
        if( 1 )//b3==b1&&b4==b2 )//t1 )
        {
            if (![self->foundPeripherals containsObject:peripheral] )//  1B32719F-B5B9-4D83-895A-EBED1EB8A244
            {
                //int len=[peripheral.name length];                  //
                //NSString *gg=[peripheral name];
                // if((len>=8)&&(/gg==@"BT4.0---Tuner"/1) )
                // {
                [self->foundPeripherals addObject:peripheral];
                [self->MAC_ADDRESS addObject:tsss];
                [self->JDY_BLE_NAME addObject:name_jdy ];
                
                [scan_rssi addObject:RSSI ];
                
                [scan_data addObject:all_data ];
                [scan_type addObject:str_type ];
                
                int vf = 0;//tid.intValue;
                NSNumber *number = [NSNumber numberWithInt:vf];
                [self->dev_count_add addObject:number ];
                
                //foundaPeripheral.delegate = self;
                // NSString *ss=[peripheral name];
                //NSLog(@"发现一个广播设备: %@\n",ss);
                
                NSUUID *san_uuid  = peripheral.identifier;
                NSString *SS1 = [san_uuid UUIDString];
                NSString *SS2=@"";
                if( [self->foundPeripherals count]>0 )
                {
                    CBPeripheral *peripheral1  = [self->foundPeripherals objectAtIndex:0];
                    
                    NSUUID *med_uuid  = peripheral1.identifier;
                    SS2 = [med_uuid UUIDString];
                }
                //NSLog(@"UUID1=: %@\n",SS1 );
                //NSLog(@"UUID2=: %@\n",SS2 );
                
                //NSLog(@"当前找到的设备数量: %d---rssi:%d\n",(int)[self->foundPeripherals count],[RSSI intValue]);
                //              NSLog(@"当前找到的设备数量: %@\n",foundPeripherals);
                
                [[self delegate] discoveryDidRefresh];
                // }
                
            }
            else{
                NSUUID *san_uuid  = peripheral.identifier;
                for( int i=0;i<[self->foundPeripherals count];i++ )
                {
                    CBPeripheral *peripheral1   = [self->foundPeripherals objectAtIndex:i];
                    NSUUID *med_uuid  = peripheral1.identifier;
                    if( med_uuid==san_uuid )
                    {
                        //NSLog(@"scan_resut%@",@"发现有相同的设备 ");
                        
                        //                        [self->foundPeripherals  insertObject:peripheral atIndex:i+1 ];
                        //
                        //                        [self->foundPeripherals removeObjectAtIndex:i ];
                        //
                        //                        [self->foundPeripherals replaceObjectAtIndex:i withObject:peripheral ];
                        //
                        [self->MAC_ADDRESS replaceObjectAtIndex:i withObject:tsss ];
                        [self->JDY_BLE_NAME replaceObjectAtIndex:i withObject:name_jdy ];
                        [self->scan_rssi replaceObjectAtIndex:i withObject:RSSI ];
                        [self->scan_data replaceObjectAtIndex:i withObject:all_data ];
                        [self->scan_type replaceObjectAtIndex:i withObject:str_type ];
                        
                        //NSNumber *tid = [dev_count_add objectAtIndex:i];
                        int vf = 0;//tid.intValue;
                        
                        NSNumber *number = [NSNumber numberWithInt:vf];
                        
                        
                        [self->dev_count_add replaceObjectAtIndex:i withObject:number ];
                        
                        //                        [self->MAC_ADDRESS  insertObject:tsss atIndex:i+1 ];
                        //                        [self->MAC_ADDRESS removeObjectAtIndex:i ];
                        //
                        //                        [self->JDY_BLE_NAME  insertObject:name_jdy atIndex:i+1 ];
                        //                        [self->JDY_BLE_NAME removeObjectAtIndex:i ];
                        //
                        //                        [self->scan_rssi  insertObject:RSSI atIndex:i+1 ];
                        //                        [self->scan_rssi removeObjectAtIndex:i ];
                        //
                        //                        [self->scan_data  insertObject:all_data atIndex:i+1 ];
                        //                        [self->scan_data removeObjectAtIndex:i ];
                        //
                        //                        [self->scan_type  insertObject:str_type atIndex:i+1 ];
                        //                        [self->scan_type removeObjectAtIndex:i ];
                        
                        
                        
                        //NSLog( @"scan_resut:%d---RSSI:%D",(int)[self->foundPeripherals count],[RSSI intValue] );
                        
                        [[self delegate] discoveryDidRefresh];//
                        i = 10000;
                        break;
                    }
                }
                
            }
            
            
            
            
            //          NSLog(@"rssi=%@",[RSSI stringValue]);
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // NSLog(@"Connection to peripheral with UUID : %s successfull\r\n",[self UUIDToString:peripheral.UUID]);
    self.activePeripheral = peripheral;
    [self.activePeripheral discoverServices:nil];
    [central stopScan];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error)
    {
        //NSLog(@"Characteristics of service with UUID : %s found\r\n",[self CBUUIDToString:service.UUID]);
        for(int i=0; i < service.characteristics.count; i++)
        {
            //            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            //            NSLog(@"Found characteristic %s\r\n",[ self CBUUIDToString:c.UUID]);
            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if([self compareCBUUID:service.UUID UUID2:s.UUID])
            {
                //NSLog(@"Finished discovering characteristics");
                [[self delegate] JDY_BLE_Ready];
            }
        }
    }
    else {
        //NSLog(@"Characteristic discorvery unsuccessfull !\r\n");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        // NSLog(@"Services of peripheral with UUID : %s found\r\n",[self UUIDToString:peripheral.UUID]);
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else {
        //NSLog(@"Service discovery was unsuccessfull !\r\n");
    }
    //NSLog(@"777777777\r\n");
    
}
-(void)uart:(Byte *)b p:(CBPeripheral *)p pp:(int)len;
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        // NSLog(@"Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
    }
    else {
        // NSLog(@"Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
        //NSLog(@"Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
    
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    
    NSString *st=[NSString stringWithFormat:@"%hu",characteristicUUID];
    NSLog(@"jdy-ble:uuid %@\r\n",st);
    NSLog(@"jdy-ble:uuid %@\r\n",st);
    
    if (!error) {
        switch(characteristicUUID){
            case 0x2A19:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:TI_KEYFOB_LEVEL_SERVICE_READ_LEN];
                //self.batteryLevel = (float)batlevel;
                //[[self delegate]battrray:batteryLevel ];
                break;
            }
                
                //            case  0xFFE1:
                //            {
                //                char keys;
                //                [characteristic.value getBytes:&keys length:TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN];
                //                //if (keys & 0x01) self.key1 = YES;
                //                //else self.key1 = NO;
                //                // if (keys & 0x02) self.key2 = YES;
                //                //else self.key2 = NO;
                //                // [[self delegate] keyValuesUpdated: keys];
                //                break;
                //            }
            case 0X2A06:
            {
                char xval;
                [characteristic.value getBytes:&xval length:TI_KEYFOB_ACCEL_READ_LEN];
                //self.x = xval;
                //[[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                
                break;
            }
            case 0xFFA4:
            {
                char yval;
                [characteristic.value getBytes:&yval length:TI_KEYFOB_ACCEL_READ_LEN];
                // self.y = yval;
                //[[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case 0xFFA5:
            {
                char zval;
                [characteristic.value getBytes:&zval length:TI_KEYFOB_ACCEL_READ_LEN];
                // self.z = zval;
                //[[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID://0x2A07:
            {
                
                
                //char TXLevel[20];
                //[characteristic.value getBytes:TXLevel length:20];
                //NSLog(@"value1=%s",TXLevel);
                //NSData *adata = [[NSData alloc] initWithBytes:TXLevel length:20];
                //if(TXLevel[0]=='T')
                //  [[self delegate] TXPwrLevelUpdat:adata];
                NSLog(@"dsf");
                break;
            }
            case 0xfff6:
            {
                NSLog(@"ffffffffffffttt");
                break;
            }
                
                
            case uart_tx_uuid:
            {
                Byte TXLevel[characteristic.value.length];
                [characteristic.value getBytes:TXLevel length:characteristic.value.length];
                NSData *data = characteristic.value;
                [ delegate rx_function_event:TXLevel :(int)data.length];
                break;
            }
            case uart_data_uuid_duart:
            case uart_data_uuid:
            {
                Byte TXLevel[characteristic.value.length];
                [characteristic.value getBytes:TXLevel length:characteristic.value.length];
                NSData *data = characteristic.value;
                [ delegate rx_data_event:TXLevel :(int)data.length];
                break;
            }
            default:
            {
                
            }
                
        }
    }
    else {
        NSLog(@"updateValueForCharacteristic failed !");
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

/*
-(NSString*)Read_DEV_UUID//:(CBPeripheral*)pheral
{
    NSString*strNSString = [[NSString alloc] initWithUTF8String:[self UUIDToString:[[self activePeripheral] UUID]]];
    return strNSString;
}
-(NSString*)Read_DEV_UUID:(CBPeripheral*)pheral
{
    NSString*strNSString = [[NSString alloc] initWithUTF8String:[self UUIDToString:[pheral UUID]]];
    return strNSString;
}


-(NSString*)Read_DEV_MAC{
    NSString*strNSString = [[NSString alloc] initWithUTF8String:[self UUIDToString:[[self activePeripheral] UUID]]];
    return [strNSString substringFromIndex:29];
}

-(NSString*)Read_DEV_MAC:(CBPeripheral*)pheral
{
    NSString*strNSString = [[NSString alloc] initWithUTF8String:[self UUIDToString:[pheral UUID]]];
    return [strNSString substringFromIndex:29];
}

*/

-(NSString*)Read_DEV_UUID:(CBPeripheral*)pheral
{
    //NSString*strNSString = [[NSString alloc] initWithUTF8String:[self UUIDToString:[pheral ]]];
    NSString *uuid = pheral.identifier.UUIDString;
    return uuid;
}

-(void)dss
{
    
}



@end
