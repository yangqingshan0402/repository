package com.hongri.bluelight.ble;

import android.app.Application;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;

import com.blankj.utilcode.util.ConvertUtils;
import com.blankj.utilcode.util.LogUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.blankj.utilcode.util.Utils;
import com.clj.fastble.BleManager;
import com.clj.fastble.callback.BleGattCallback;
import com.clj.fastble.callback.BleMtuChangedCallback;
import com.clj.fastble.callback.BleNotifyCallback;
import com.clj.fastble.callback.BleScanCallback;
import com.clj.fastble.callback.BleWriteCallback;
import com.clj.fastble.data.BleDevice;
import com.clj.fastble.exception.BleException;
import com.clj.fastble.scan.BleScanRuleConfig;
import com.hongri.bluelight.R;
import com.hongri.testdrawlayout.MenuItem;

import org.greenrobot.eventbus.EventBus;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.BlockingDeque;
import java.util.concurrent.LinkedBlockingDeque;

import static com.clj.fastble.utils.HexUtil.charToByte;

public class BLEService {


    public static final String TAG="BLEService";

    boolean needDumpData =false;
    //boolean needDumpData =true;


    public static StringBuffer inputMSgBuild=new StringBuffer();
    public static StringBuffer outputMSgBuild=new StringBuffer();
    public static final String ACTION_UPDATE_LOG = "action_update_log";



    private BlockingDeque<DataWrap> blockingDeque=new LinkedBlockingDeque<>();

    public static final String ACTION_BLE_CONNECT_CHANGE = "action_ble_connect_change";
    public static final String EXTRA_BLE_CONNECT_STATE="extra_ble_connect_state";
    public static final int BLE_SCAN_STATE_START = 1;
    public static final int BLE_SCAN_STATE_SCANNING = 2;
    public static final int BLE_SCAN_STATE_FAIL = 3;
    public static final int BLE_SCAN_STATE_FINISH = 4;



    public static String uuidService = "0000ffe0-0000-1000-8000-00805f9b34fb";
    public static String uuidCharacteristicTX = "0000ffe1-0000-1000-8000-00805f9b34fb";//透传
    public static String uuidCharacteristicFUNCTION = "0000ffe2-0000-1000-8000-00805f9b34fb";//IO
    public static String uuidCharacteristicMESH = "0000ffe3-0000-1000-8000-00805f9b34fb";//MESH



    public static final String ACTION_BLE_SCAN_CHANGE = "action_ble_scan_change";
    public static final String EXTRA_BLE_SCAN_STATE="extra_ble_scan_state";
    public static final String EXTRA_BLE_SCAN_RESULT ="extra_ble_scan_result";


    private Context context;

    private BleDevice connectDevice;
    //private String uuid_service;
   // private String uuid_characteristic_write;
   // private String uuid_characteristic_read;
   // private String uuid_characteristic_notify;

    private boolean scanSuccess=false;
    public static String DEVICE_NAME = "FOSI";

    /**
     * 最大的Mtu值, 默认是23
     */
    public static int MAX_MTU=23;


    private int mState;


    // Constants that indicate the current connection state
    public static final int STATE_IDLE = 0;       // we're doing nothing
    public static final int STATE_SCANNING = 1;     // now listening for incoming connections
    public static final int STATE_CONNECTING = 2; // now initiating an outgoing connection
    public static final int STATE_CONNECTED = 3;  // now connected to a remote device

    private Handler mHandler;

    static BLEService service;
    public static BLEService getInstance(){

        if (service ==null){
            service=new BLEService(Utils.getApp());
        }
        return service;
    };


    private BLEService(Context ctx){

        context=ctx;
        mState = STATE_IDLE;
        mHandler=new Handler();

        new Thread(){
            @Override
            public void run() {

                writeData();


            }
        }.start();


    }

    /**
     * 是否等待回复的标记
     */
   volatile boolean isWriting=false;


    /**
     * 记录连续写入数据失败的次数
     */
    int writeErrorTime;

    /**
     * 连续失败的最大次数
     */
    int MAX_WRITE_ERROR=3;
    /**
     * 记录当前在写入的data
     */
    DataWrap currentWriteData;


    private void writeData(){
        try {
        DataWrap data=null;
         while (isInit && (data= blockingDeque.take())!=null ){
             LogUtils.e("BLEService =====xgh=====,writeData():blockingDeque.size-="+blockingDeque.size());

             //Thread.sleep(100);

             while (isWriting){
                // LogUtils.e("BLEService =====xgh=====,writeData():isWriting="+isWriting+",待发送数据: ="+blockingDeque.size());
                 Thread.sleep(10);
             }

             //发送文件的上传进度
             UpgradeDataPackageEvent event=new UpgradeDataPackageEvent(blockingDeque.size());
             EventBus.getDefault().post(event);

             currentWriteData=data;
             isWriting=true;

             if (data.getSendType() == DataWrap.SEND_TYPE_MESH){ //Mesh传输

                 BleManager.getInstance().write(
                         connectDevice,
                         uuidService,
                         uuidCharacteristicMESH,
                         data.getData(),false,writeCallback );
                 Log.e(TAG, "writeData:, 通过MESH 发送 ");

             }else  if(data.getSendType() == DataWrap.SEND_TYPE_TX){//TX透传传输

                 BleManager.getInstance().write(
                         connectDevice,
                         uuidService,
                         uuidCharacteristicTX,
                         data.getData(),false,writeCallback );

                 Log.e(TAG, "writeData:, 通过TX 发送 data="+ Arrays.toString(data.getData()));

             }




        }

        } catch (InterruptedException e) {
            e.printStackTrace();
        }




    }



    private BleWriteCallback writeCallback=new BleWriteCallback() {
            @Override
            public void onWriteSuccess(int current, int total, byte[] justWrite) {



                String dataHex= ConvertUtils.bytes2HexString(justWrite);
                outputMSgBuild.append(dataHex);
                outputMSgBuild.append("\n");
                LogUtils.e(TAG, "=====xgh=====,onWriteSuccess: data="+dataHex+",isWriting="+isWriting);

                context.sendBroadcast(new Intent(ACTION_UPDATE_LOG));



              /*  if(needDumpData){

                    try {
                        BleEvent btMsgBean= BleEvent.Companion.parseMeshData(justWrite);

                        EventBus.getDefault().post(btMsgBean);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }*/

                writeErrorTime=0;



            }

            @Override
            public void onWriteFailure(BleException exception) {
                isWriting=false;

                if(writeErrorTime<MAX_WRITE_ERROR){
                    if (currentWriteData!=null){
                        sendMsg(currentWriteData,false,false);
                    }
                    writeErrorTime++;
                }else{
                    sendDeviceConnectStateCast(STATE_IDLE);

                    LogUtils.e(TAG, "=====xgh=====,onWriteFailure: exception="+exception+",isWriting="+isWriting);
                    currentWriteData=null;
                    blockingDeque.clear();
                    writeErrorTime=0;
                }


                outputMSgBuild.append(ConvertUtils.bytes2HexString(currentWriteData.getData())+",error");
                outputMSgBuild.append("\n");

                context.sendBroadcast(new Intent(ACTION_UPDATE_LOG));


            }
    };




    boolean  isInit=false;
    public  void init(Application context) {
        isInit=true;

        BleScanRuleConfig config=new BleScanRuleConfig.Builder()
                .setScanTimeOut(30*1000)
                .build();

        //初始化FastBle
        BleManager.getInstance().init(context);
        BleManager.getInstance()
                .enableLog(true)
                .setReConnectCount(1, 5000)
                .setConnectOverTime(10*1000)
                .setOperateTimeout(10*1000)
                .initScanRule(config);


    }


    public void setScanBleEventListener(ScanBleEventListener scanBleEventListener) {
        this.scanBleEventListener = scanBleEventListener;
    }

    private ScanBleEventListener scanBleEventListener;

    public boolean isScanning() {
        return  mState == STATE_SCANNING;
    }


    public interface ScanBleEventListener{

        void onScanEvent(int scanState,BleDevice bleDevice );
    }


    public void setConnectEventListener(ConnectEventListener connectEventListener) {
        this.connectEventListener = connectEventListener;
    }

    private ConnectEventListener connectEventListener;



    public interface ConnectEventListener{

        void onConnectEvent(boolean success,BleDevice device);
    }



    public  synchronized void startScan(){

        scanSuccess=false;

        BleManager.getInstance().disconnectAllDevice();

        BleManager.getInstance().scan(new BleScanCallback() {
            @Override
            public void onScanStarted(boolean success) {
                mState = STATE_SCANNING;
                LogUtils.e(TAG, "=====xgh=====,onScanStarted: success="+success);

                if (scanBleEventListener!=null){
                    scanBleEventListener.onScanEvent(BLE_SCAN_STATE_START,null);
                }

                /*Intent it=new Intent(ACTION_BLE_SCAN_CHANGE);
                it.putExtra(EXTRA_BLE_SCAN_STATE,BLE_SCAN_STATE_START);
                context.sendBroadcast(it);*/

               // showScanDialog();
            }

            @Override
            public void onLeScan(BleDevice bleDevice) {
                //LogUtils.e(TAG, "=====xgh=====,onLeScan: bleDevice="+bleDevice.getName()+",mac="+bleDevice.getMac());

                if (scanBleEventListener!=null){
                    scanBleEventListener.onScanEvent(BLE_SCAN_STATE_SCANNING,bleDevice);
                }

              /*  Intent it=new Intent(ACTION_BLE_SCAN_CHANGE);
                it.putExtra(EXTRA_BLE_SCAN_STATE,BLE_SCAN_STATE_SCANNING);
                it.putExtra(EXTRA_BLE_SCAN_RESULT,bleDevice);
                context.sendBroadcast(it);*/

              /*  if(DEVICE_NAME.equalsIgnoreCase(bleDevice.getName())){
                    scanSuccess=true;
                    BLEService.getInstance().stopScan();
                }*/

               // LogUtils.e(TAG, "=====xgh=====,onLeScan: scanSuccess="+scanSuccess+",device_name="+DEVICE_NAME+",ble.name="+bleDevice.getName()+",boolean="+DEVICE_NAME.equalsIgnoreCase(bleDevice.getName()));
            }

            @Override
            public void onScanning(BleDevice bleDevice) {
            }

            @Override
            public void onScanFinished(List<BleDevice> scanResultList) {
                mState = STATE_IDLE;
                LogUtils.e(TAG, "=====xgh=====,onScanFinished: scanResultList="+scanResultList+",scanSuccess="+scanSuccess);

                if (scanBleEventListener!=null){
                    scanBleEventListener.onScanEvent(BLE_SCAN_STATE_FINISH,null);
                }
                /*if (!scanSuccess){

                   // showScanFailDialog();

                    Intent it=new Intent(ACTION_BLE_SCAN_CHANGE);
                    it.putExtra(EXTRA_BLE_SCAN_STATE, BLE_SCAN_STATE_FAIL);
                    context.sendBroadcast(it);
                }*/

            }
        });


    }

    public  synchronized void stopScan(){
        if (mState == STATE_SCANNING){
            BleManager.getInstance().cancelScan();
        }
        mState=STATE_IDLE;
    }

   /* public void setMtu(BleDevice bleDevice,int mtu){

        BleManager.getInstance().setMtu(bleDevice, mtu, new BleMtuChangedCallback() {
            @Override
            public void onSetMTUFailure(BleException exception) {
                Log.e(TAG, "====222xgh,onSetMTUFailure: exception="+exception);

            }

            @Override
            public void onMtuChanged(int mtu) {
                Log.e(TAG, "====222xgh,onMtuChanged: 修改Mtu: ="+mtu);

            }
        });

    }*/



    public  synchronized void connectDevice(BleDevice bleDevice){


        BleManager.getInstance().connect(bleDevice, new BleGattCallback() {
            @Override
            public void onStartConnect() {
                mState = STATE_CONNECTING;
                LogUtils.e(TAG, "=====xgh=====,onStartConnect: ");

            }

            @Override
            public void onConnectFail(BleDevice bleDevice, BleException exception) {
                mState = STATE_IDLE;

                if (connectEventListener!=null){
                    connectEventListener.onConnectEvent(false,bleDevice);
                }
            }

            //Discover成功回调
            @Override
            public void onConnectSuccess(final BleDevice bleDevice, final BluetoothGatt gatt, final int status) {

               // gatt.requestConnectionPriority(BluetoothGatt.CONNECTION_PRIORITY_HIGH);
               // Logger.d("设置mtu结果 : ${gatt.requestMtu(BlePara.mtu)}"
               // gatt.requestMtu(512);


                BleManager.getInstance().setMtu(bleDevice, 512, new BleMtuChangedCallback() {
                    @Override
                    public void onSetMTUFailure(BleException exception) {
                        Log.e(TAG, "====222xgh,onSetMTUFailure: exception="+exception);

                    }

                    @Override
                    public void onMtuChanged(int mtu) {
                        Log.e(TAG, "====222xgh,onMtuChanged: 修改Mtu: ="+mtu);
                        //默认值是23, 有3个字节是系统协议使用的
                        MAX_MTU=mtu-3;


                        initServiceAndChara(gatt);

                        BleManager.getInstance().notify(
                                bleDevice,
                                uuidService,
                                uuidCharacteristicTX,
                                new BleNotifyCallback() {
                                    @Override
                                    public void onNotifySuccess() {
                                        LogUtils.e(TAG, "=====xgh=====,onNotifySuccess: ");

                                    }

                                    @Override
                                    public void onNotifyFailure(BleException exception) {
                                        if (connectEventListener!=null){
                                            connectEventListener.onConnectEvent(false,null);
                                        }
                                        LogUtils.e(TAG, "=====xgh=====,onNotifyFailure: exception="+exception);
                                    }

                                    @Override
                                    public void onCharacteristicChanged(byte[] data) {
                                        isWriting=false;

                                        try {

                                            //按照Mesh协议解析
                                            ParentEventMsg btMsgBean= ReplyMsgBean.Companion.parse(data);
                                            LogUtils.e(TAG, "=====xgh=====,收到Mesh数据: data="+ ConvertUtils.bytes2HexString(data)+",待发送数据: "+blockingDeque.size());
                                            EventBus.getDefault().post(btMsgBean);


                                        } catch (Exception e) {

                                            try {
                                                //按照TX协议解析
                                                TxReplyBean txReplyBean=TxReplyBean.Companion.parseTxReply(data);
                                                EventBus.getDefault().post(txReplyBean);
                                                Log.e(TAG, "onCharacteristicChanged:  收到TX通数据... "+txReplyBean);
                                            } catch (Exception ex) {
                                                ex.printStackTrace();
                                            }

                                        }




                                        inputMSgBuild.append(ConvertUtils.bytes2HexString(data));
                                        inputMSgBuild.append("\n");

                                        context.sendBroadcast(new Intent(ACTION_UPDATE_LOG));

                                    }
                                });



                        if (connectEventListener!=null){
                            connectEventListener.onConnectEvent(true,bleDevice);
                        }

                        LogUtils.e(TAG, "=====xgh=====,onConnectSuccess: bleDevice="+bleDevice+",status="+status);
                        mState = STATE_CONNECTED;
                        connectDevice=bleDevice;


                    }
                });


                sendDeviceConnectStateCast(STATE_CONNECTED);


            }

            @Override
            public void onDisConnected(boolean isActiveDisConnected, BleDevice bleDevice, BluetoothGatt gatt, int status) {

                mState = STATE_IDLE;
                connectDevice=null;
                LogUtils.e(TAG, "=====xgh=====,onDisConnected: ");

                sendDeviceConnectStateCast(STATE_IDLE);

                if (connectEventListener!=null){
                    connectEventListener.onConnectEvent(false,bleDevice);
                }


            }

            @Override
            public void onMtuChanged(BluetoothGatt gatt, int mtu, int status) {
                super.onMtuChanged(gatt, mtu, status);
            }
        });





    }

    /**
     * 发送设备连接状态改变的广播
     * @param state
     */
    private void sendDeviceConnectStateCast(int state){

        if (state == STATE_IDLE){
            isWriting=false;
        }


        Intent it=new Intent(ACTION_BLE_CONNECT_CHANGE);
        it.putExtra(EXTRA_BLE_CONNECT_STATE,state);
        context.sendBroadcast(it);

        if (state ==STATE_IDLE){
            ToastUtils.showLong(R.string.tip_ble_disconnect);
           // showConnectFailDialog();
        }


    }



    public  synchronized void deInit( ){
        isInit=false;
        connectDevice=null;
        mState = STATE_IDLE;
        BleManager.getInstance().disconnectAllDevice();
        BleManager.getInstance().destroy();
    }



    private synchronized void initServiceAndChara(BluetoothGatt gatt){
        if (gatt.getServices()== null ){
            return;
        }

        mBluetoothGatt=gatt;

        Delay_ms(400);
        enable_JDY_ble(0,gatt);//使能JDY透传智能
        Delay_ms(400);
        enable_JDY_ble(2,gatt);//使能JDY MESH通知
        Delay_ms(100);


    }


    public void Delay_ms(int ms) {
        try {
            Thread.currentThread();
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }


    public void enable_JDY_ble( int p,BluetoothGatt gatt )
    {
        try {
            //if( p )
            {
                BluetoothGattService service =gatt.getService(UUID.fromString(uuidService));
                if (service == null){
                    return;
                }

                BluetoothGattCharacteristic ale;// =service.getCharacteristic(UUID.fromString(uuidCharacteristicTX));
                switch( p )
                {
                    case 0://0xFFE1 //透传
                    {
                        ale =service.getCharacteristic(UUID.fromString(uuidCharacteristicTX));//智能透传通知
                    }break;
                    case 1:// 0xFFE2 //iBeacon_UUID
                    {
                        ale =service.getCharacteristic(UUID.fromString(uuidCharacteristicFUNCTION));
                    }break;
                    case 2:// 0XFFE3
                    {
                        ale =service.getCharacteristic(UUID.fromString(uuidCharacteristicMESH));//使能MESH的通知
                        break;
                    }
                    default:
                        ale =service.getCharacteristic(UUID.fromString(uuidCharacteristicMESH));
                        break;
                }
                boolean set = gatt.setCharacteristicNotification(ale, true);
                //Log.d(TAG," setnotification = " + set);
                BluetoothGattDescriptor dsc =ale.getDescriptor(UUID.fromString(  "00002902-0000-1000-8000-00805f9b34fb"));
                byte[]bytes = {0x01,0x00};
                dsc.setValue(bytes);
                boolean success =gatt.writeDescriptor(dsc);
                Log.e(TAG, "enable_JDY_ble: success:$success");
                //Log.d(TAG, "writing enabledescriptor:" + success);
            }
//	    else
//	    {
//		   BluetoothGattService service =mBluetoothGatt.getService(UUID.fromString("49535343-fe7d-4ae5-8fa9-9fafd205e455"));
//		   BluetoothGattCharacteristic ale =service.getCharacteristic(UUID.fromString(uuidService));
//		   boolean set = mBluetoothGatt.setCharacteristicNotification(ale, false);
//		   Log.d(TAG," setnotification = " + set);
//		   BluetoothGattDescriptor dsc =ale.getDescriptor(UUID.fromString(uuidCharacteristicTX));
//		   byte[]bytes = {0x00, 0x00};
//		   dsc.setValue(bytes);
//		   boolean success =mBluetoothGatt.writeDescriptor(dsc);
//		   Log.d(TAG, "writing enabledescriptor:" + success);
//	    }


//        	jdy=mBluetoothGatt.getService(UUID.fromString(uuidService)).getCharacteristic(UUID.fromString(uuidCharacteristicFUNCTION));
//        	mBluetoothGatt.setCharacteristicNotification(jdy, p);
        } catch (Exception e) {
            e.printStackTrace();

        }
    }




    private BluetoothGatt mBluetoothGatt;



    public  void sendMsg(DataWrap data,boolean isMultiSend){
        sendMsg(data,isMultiSend,true);
    }



    /**
     * 给设备发送指令
     */
    public  void sendMsg(DataWrap wrapper,boolean isMultiSend,boolean clearQueue){


        LogUtils.e("BLEService =====xgh=====,sendMsg():wrapper="+ConvertUtils.bytes2HexString(wrapper.getData()));

        if (connectDevice==null || (!BleManager.getInstance().isConnected(connectDevice))){
            ToastUtils.showLong(R.string.tip_ble_disconnect);

            sendDeviceConnectStateCast(STATE_IDLE);
            return;
        }

        if (clearQueue){
            synchronized (this){
                blockingDeque.clear();
            }
        }


        try {
            //F10100FFFF

           // LogUtils.e("============ BLEService sendMsg()===MenuItem.Companion.getSelectMenus().size()"+MenuItem.Companion.getSelectMenus());

            if (isMultiSend){
                if (MenuItem.Companion.getSelectMenus().size() ==0 ){
                    //广播指令不处理
                    byte[] shortAdd=new byte[2];
                    System.arraycopy(wrapper.getData(),3,shortAdd,0,2);


                    if (!ConvertUtils.bytes2HexString(shortAdd).equals("FFFF")){
                        ToastUtils.showLong(R.string.tip_select_device);
                        return;
                    }


                    blockingDeque.put(wrapper);

                }else{
                    //循环发送给选中的设备
                    for(MenuItem item : MenuItem.Companion.getSelectMenus()){
                        //替换指令的 shortAdd

                        String shortAdd= item.getMac().replace(":","");
                        LogUtils.e("============ BLEService sendMsg()===shortAdd="+shortAdd);

                        byte[] tempData= BLEService.getBytesByString(shortAdd);

                        byte[] newData=new byte[wrapper.getData().length];
                        System.arraycopy(wrapper.getData(),0,newData,0,wrapper.getData().length);

                        newData[3]=tempData[0];
                        newData[4]=tempData[1];

                        blockingDeque.put(new DataWrap(newData,wrapper.getSendType()));


                    }

                }


            }else{

                blockingDeque.put(wrapper);

            }

           // LogUtils.e("BLEService =====xgh=====,sendMsg():blockingDeque.size-="+blockingDeque.size());
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    /**
     * 把10进制的String字符转变为16进制的byte[]
     */
    public static byte[] getBytesByString(String data) {
        byte[] bytes = null;
        if (data != null) {
            data = data.toUpperCase();
            int length = data.length() / 2;
            char[] dataChars = data.toCharArray();
            bytes = new byte[length];
            for (int i = 0; i < length; i++) {
                int pos = i * 2;
                bytes[i] = (byte) (charToByte(dataChars[pos]) << 4 | charToByte(dataChars[pos + 1]));
            }
        }
        return bytes;
    }


    /**
     * 16进制的byte[] 转10进制的byte[]
     * @param b
     * @return
     */
    public static   byte[] hex2byte(byte[] b) {
        if ((b.length % 2) != 0) {
            throw new IllegalArgumentException("长度不是偶数");
        }
        byte[] b2 = new byte[b.length / 2];
        for (int n = 0; n < b.length; n += 2) {
            String item = new String(b, n, 2);
            // 两位一组，表示一个字节,把这样表示的16进制字符串，还原成一个进制字节
            b2[n / 2] = (byte) Integer.parseInt(item, 16);
        }
        b = null;
        return b2;
    }




    /**
     * 获取speed 数据
     */
    public void loadSpeedData() {


    }


    public boolean isConnected() {
        //LogUtils.e(TAG, "=====xgh=====,isConnected: connectDevice="+connectDevice+",isConnected="+BleManager.getInstance().isConnected(connectDevice));
        if (connectDevice !=null && BleManager.getInstance().isConnected(connectDevice)){
            return  true;
        }
      return   false;
    }
}
