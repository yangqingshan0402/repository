
//
//  Created by JDY on 14-8-8.
//  Copyright (c) 2014年 JDY. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "MsgPlaySound.h"

#import "JDY_BLE.h"


#import "sys/utsname.h"
//#import "RefreshHeaderAndFooterView.h"

//#import "ODRefreshControl.h"
#import "SimpleTableViewCell.h"
@interface jdy_scan_ble_ViewController : UIViewController //UITableViewController//UIViewController
<
UITextFieldDelegate,UITabBarDelegate
,UITableViewDelegate,UITableViewDataSource ,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UITableViewDelegate,UIWebViewDelegate>
{
    JDY_BLE*t;
    //UILabel *lab3;
    UIAlertView *alert;
    UITableView *tab;
    int cont_status;
    int dfg;
    
   
    Byte viewData[9];
    //UIImageView*image8;
    int select_row;
    
    NSTimer *timer8,*time_11;
    CBPeripheral	*aPeripheral8;
    UIBarButtonItem *editButton,*editButton1;
    
    int tt6,bmmn;
    //v1 *vvv1;
 
    int ivt;
    int dly;
//    NSTimer *timer;
    
    //ODRefreshControl *refreshControl;
    //UIView *contentView;
    //UIScrollView *myScrollView;
    int hb;
    int hbn;
    // RefreshHeaderAndFooterView * refreshHeaderAndFooterView;
    //BOOL reloading;
}

//@property (nonatomic,retain)ODRefreshControl *refreshControl;




@property int coutn_image;

@property int conect_status;
@property int select_st;


- (void) batteryIndicatorTimer:(NSTimer *)timer;
- (void) connectionTimer:(NSTimer *)timer;



@end
