package com.hongri.bluelight.activity

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.os.PersistableBundle
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.drawerlayout.widget.DrawerLayout
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.alibaba.fastjson.JSONObject
import com.blankj.utilcode.util.*
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.clj.fastble.data.BleDevice
import com.gyf.immersionbar.ImmersionBar
import com.hongri.bluelight.LocalApplication
import com.hongri.bluelight.R
import com.hongri.bluelight.ble.*
import com.hongri.bluelight.ui.FragmentCCT
import com.hongri.bluelight.ui.FragmentEffect
import com.hongri.bluelight.ui.FragmentHSL
import com.hongri.bluelight.ui.bean.CCTBean
import com.hongri.bluelight.ui.bean.HSLBean
import com.hongri.bluelight.ui.bean.ProgramBean
import com.hongri.bluelight.ui.bean.SceneBean
import com.hongri.bluelight.upgrade.Tag_UpgradeFileHeader
import com.hongri.bluelight.util.MyUtil.parseShortAddrByMac
import com.hongri.testdrawlayout.MenuItem
import com.shehuan.nicedialog.BaseNiceDialog
import com.shehuan.nicedialog.NiceDialog
import com.shehuan.nicedialog.ViewConvertListener
import com.shehuan.nicedialog.ViewHolder
import jp.wasabeef.blurry.Blurry
import kotlinx.android.synthetic.main.activity_main.*
import kotlinx.android.synthetic.main.content_main.*
import kotlinx.coroutines.*
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.io.File
import java.util.*
import kotlin.collections.ArrayList


class MainActivity : AppCompatActivity() {

    // private var ledOn: Boolean=false
    private var curIndex = 0
    internal var fragments = ArrayList<Fragment>()
    var bitmapBg1: Bitmap? = null
    var bitmapBg2: Bitmap? = null
    var bitmapBg3: Bitmap? = null
    var connectDevice: BleDevice? = null

    private var isNormalModel=true

    var mHandler: Handler = Handler(Handler.Callback {

        true
    })


    private lateinit var drawerLayout: DrawerLayout
    private lateinit var mAdapter: BaseQuickAdapter<MenuItem, BaseViewHolder>

    var selectMenus = ArrayList<MenuItem>()
    private var menuList = ArrayList<MenuItem>()

    lateinit var rv_menu: RecyclerView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        //透明状态栏和导航栏
        ImmersionBar.with(this).transparentBar().init()


        if (savedInstanceState != null) {
            curIndex = savedInstanceState.getInt("curIndex")
        }

        initView()


        BLEService.getInstance().setScanBleEventListener { scanState, bleDevice ->

            handScanEvent(scanState, bleDevice)
        }

        BLEService.getInstance().setConnectEventListener { flag, device ->

            LogUtils.e("=====MainActivity, onCreate()===connect device, flag=$flag, device=$device")
            connectDevice = device

            handConnectEvent(flag)
        }


        BLEService.getInstance().startScan()

        EventBus.getDefault().register(this)

        //加载blur对话框的位图
        //bitmap=BitmapFactory.decodeResource(resources,R.drawable.bg_blur_hsl)

        initDrawableLayout()


    }


    private fun initDrawableLayout() {
        drawerLayout = findViewById(R.id.drawer_layout)
        rv_menu = drawerLayout.findViewById(R.id.rv_menu)
        rv_menu.layoutManager = LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false)
        rv_menu.addItemDecoration(DividerItemDecoration(this, LinearLayout.VERTICAL))

        mAdapter =
            object : BaseQuickAdapter<MenuItem, BaseViewHolder>(R.layout.item_menu, menuList) {
                override fun convert(helper: BaseViewHolder, item: MenuItem) {

                    if (connectDevice != null && connectDevice!!.mac.endsWith(item.mac)) { //ble连接的设备
                        helper.setTextColor(R.id.text_label1, resources.getColor(R.color.text_red))
                        helper.setTextColor(R.id.text_label2, resources.getColor(R.color.text_red))

                        if (!selectMenus.contains(item)) {
                            selectMenus.add(item)

                            //更新选中设备记录
                            MenuItem.selectMenus.clear()
                            MenuItem.selectMenus.addAll(selectMenus)
                        }

                    } else {
                        helper.setTextColor(
                            R.id.text_label1,
                            resources.getColor(R.color.text_black)
                        )
                        helper.setTextColor(
                            R.id.text_label2,
                            resources.getColor(R.color.text_black)
                        )

                    }


                    helper.setText(R.id.text_label1, item.name)
                    helper.setText(R.id.text_label2, item.mac)

                    helper.setChecked(R.id.cb_menu, selectMenus.contains(item))

                }

            }

        mAdapter.setOnItemClickListener { adapter, view, position ->
            LogUtils.e("TAG", "=====setOnItemChildClickListener(), position=${position}")

            var menu = menuList[position]
            if (selectMenus.contains(menu)) {
                selectMenus.remove(menu)
            } else {
                selectMenus.add(menu)
            }

            LogUtils.e("=====MainActivity, initDrawableLayout()===selectMenus.size=${selectMenus.size}")

            //更新选中设备的集合
            MenuItem.selectMenus.clear()
            MenuItem.selectMenus.addAll(selectMenus)
            LogUtils.e("=====MainActivity, initDrawableLayout()===MenuItem.selectMenus.size=${MenuItem.selectMenus.size}")


            adapter.notifyItemChanged(position)

        }

        rv_menu.adapter = mAdapter
    }



    private fun handConnectEvent(connectState: Boolean) {
        //隐藏连接对话框
        dismissOperationDialog()

        if (connectState) {
            dismissDisConnectDialog()
            ToastUtils.showShort(R.string.connect_success)

            //连接上设备的时候需要判断是工作在normal模式还是upgrade模式

            //


            //延迟获取设备列表
            GlobalScope.launch(Dispatchers.Main) {
                if (isNormalModel) { //正常逻辑


                    delay(500)

                    //获取led 的开关状态
                    sendGetLedState()
                    delay(100)

                    //获取mesh在网的设备广播
                    sendGetDeviceListData()
                    delay(1000)

                    //获取设备的版本号
                    sendGetDeviceFirmwareVersion()
                    delay(1000)

                    //发送检测是否在Upgrade 模式
                     LogUtils.e("=====MainActivity, handConnectEvent()===连接时发送TX Hello")
                   // sendUpgradeHelloCMD()



                }else{ //透传


                    var file = File(getExternalFilesDir("firmware"), "upgrade_AA191115.bin")

                    var result = FileIOUtils.writeFileFromIS(
                        file,
                        assets.open("upgrade_AA191115.bin")
                    )
                    LogUtils.e("=====MainActivity, receiveEventMsg()===文件写到外部私有目录: $result, ${file.absoluteFile}")

                    upgradeData = FileIOUtils.readFile2BytesByChannel(file)


                    //模仿直接进入升级模式
                    var reply=ReplyMsgBean()
                    reply.cmd=BleEvent.RESULT_GO_BOOT_MODE
                    reply.result=1

                    receiveEventMsg(reply)

                }

            }


            //TODO...模拟收到GoBootMode 的消息

            /* GlobalScope.launch {
                 delay(2000)

                 var replyMsgBean=ReplyMsgBean(cmd = BleEvent.RESULT_GO_BOOT_MODE, result = 1)
                 receiveEventMsg(replyMsgBean)

             }*/


        } else {
            showDisconnectDialog()

        }

    }

    private fun sendGetDeviceFirmwareVersion() {
        var shortAdd = parseShortAddrByMac(connectDevice!!.mac)
        var data = BleEvent.createGetDeviceFirmwareData(shortAdd, payload = byteArrayOf())
        BLEService.getInstance().sendMsg(DataWrap(data), false)

    }


    /**
     * 获取led 状态
     */
    private fun sendGetLedState() {

        var shortAdd = parseShortAddrByMac(connectDevice!!.mac)
        var data = BleEvent.createGetLedStateData(shortAdd)
        BLEService.getInstance().sendMsg(DataWrap(data), false)

    }


    /**
     * 发送获取mesh 在网的设备广播, 设备收到后会回复设备名和短地址
     */
    private fun sendGetDeviceListData() {


        pb_device_name.visibility = View.VISIBLE
        tv_device_title.visibility = View.GONE

        if (connectDevice == null) {
            ToastUtils.showLong(R.string.tip_ble_disconnect)
            return
        }

        menuList.clear()
        var shortAddr = "FFFF"
        var data: ByteArray = BleEvent.createGetDevicesData(shortAddr, 0)
        BLEService.getInstance().sendMsg(DataWrap(data), false)

        mHandler.postDelayed({
            mAdapter.setNewData(menuList)
            pb_device_name.visibility = View.GONE
            tv_device_title.visibility = View.VISIBLE

        }, 1500)

    }


    private fun dismissDisConnectDialog() {
        showBlur(false)
        connectDialog?.dismissAllowingStateLoss()
        connectDialog = null
    }


    var connectDialog: BaseNiceDialog? = null
    private fun showDisconnectDialog() {
        showBlur(true)

        if (connectDialog?.isVisible == true) {
            connectDialog?.dismissAllowingStateLoss()
        }

        connectDialog = NiceDialog
            .init()
            .setLayoutId(R.layout.dialog_common_two_button)
            .setConvertListener(object : ViewConvertListener() {
                override fun convertView(holder: ViewHolder, dialog: BaseNiceDialog) {
                    holder.setText(R.id.tv_tips, R.string.tip_ble_disconnect)
                    holder.setOnClickListener(R.id.btn_left) {
                        dialog.dismissAllowingStateLoss()
                        showBlur(false)

                    }

                    holder.setOnClickListener(R.id.btn_right) {
                        dialog.dismissAllowingStateLoss()
                        showBlur(false)
                        showScanDeviceDialog()
                        startBleScan()
                    }


                }
            })
            .setWidth(-1)
            .setDimAmount(0.3f)
            .show(supportFragmentManager)

    }

    private fun startBleScan() {
        BLEService.getInstance().startScan()
    }

    //处理Ble 扫描的结果
    private fun handScanEvent(scanState: Int, bleDevice: BleDevice?) {
        when (scanState) {

            BLEService.BLE_SCAN_STATE_START -> { //开始扫描
                mHandler.post {

                    showScanDeviceDialog()
                }

            }
            BLEService.BLE_SCAN_STATE_SCANNING -> {// 收到扫描的结果
                /* if (bleDevice.name.isNullOrEmpty()){
                     return
                 }*/

                if (bleDevice == null) {
                    return
                }

                var exit = scanDeviceList.any {
                    it.mac == bleDevice.mac
                }

                if (!exit) {
                    LogUtils.e("MainActivity =====xgh=====,handScanEvent():结果集合中不包含bleDevice, ${bleDevice}");

                    scanDeviceList.add(bleDevice!!)
                    showScanDeviceDialog()
                }


            }
            BLEService.BLE_SCAN_STATE_FINISH -> {
                if (scanDeviceList.size == 0) {
                    if (scanResultDialog != null && scanResultDialog!!.isVisible) {
                        scanResultDialog!!.dismissAllowingStateLoss()
                    }

                    ToastUtils.showLong(R.string.no_ble_scan)
                }


                LogUtils.e("=====MainActivity, handScanEvent()===scan finish... scanDeviceList.size=${scanDeviceList.size}")

            }
        }


    }


    var scanDeviceList: ArrayList<BleDevice> = ArrayList()

    private var scanResultDialog: BaseNiceDialog? = null
    private fun showScanDeviceDialog() {

        showBlur(true)

        if (scanResultDialog == null) {
            scanResultDialog = NiceDialog
                .init()
                .setLayoutId(R.layout.dialog_scan_result)
                .setConvertListener(object : ViewConvertListener() {
                    override fun convertView(holder: ViewHolder, dialog: BaseNiceDialog) {


                        //弹出的Rv
                        var adapter: BaseQuickAdapter<BleDevice, BaseViewHolder> = object :
                            BaseQuickAdapter<BleDevice, BaseViewHolder>(
                                R.layout.item_scan_device,
                                scanDeviceList
                            ) {
                            override fun convert(helper: BaseViewHolder, item: BleDevice?) {
                                helper.setText(R.id.tv_device_name, "${item?.name},${item?.mac}")

                                //RV 的增加item 点击事件
                                helper.addOnClickListener(R.id.tv_device_name)

                            }

                        }

                        //Rv item 的点击
                        adapter.setOnItemChildClickListener { adapter, view, position ->
                            //showBlur(false)
                            dialog.dismissAllowingStateLoss()
                            showOperationDialog()
                            BLEService.getInstance().stopScan()
                            var device = scanDeviceList[position]


                            BLEService.getInstance().connectDevice(device)


                            LogUtils.e("MainActivity =====xgh=====,convertView():点击了item , ${scanDeviceList[position].name}");

                            scanResultDialog = null
                        }

                        var rvDevice = holder.getView<RecyclerView>(R.id.rv_scan_device)
                        rvDevice.layoutManager = LinearLayoutManager(
                            applicationContext,
                            LinearLayoutManager.VERTICAL,
                            false
                        )
                        rvDevice.adapter = adapter


                        //点击cancel
                        holder.setOnClickListener(R.id.btn_cancel) {
                            BLEService.getInstance().stopScan()
                            rvDevice.postDelayed({

                                dialog.dismissAllowingStateLoss()
                                showBlur(false)

                            }, 100)


                        }

                    }
                })
                .setWidth(-1)
                .setOutCancel(false)
                .setDimAmount(0.3f)
                .show(supportFragmentManager)
        }





        LogUtils.e("MainActivity =====xgh=====,showScanDeviceDialog():scanDeviceList.size=${scanDeviceList.size}");


        if (scanResultDialog?.isVisible == true) {
            var rvDevice = scanResultDialog?.view?.findViewById<RecyclerView>(R.id.rv_scan_device)
            if (rvDevice != null) {
                rvDevice.adapter?.notifyDataSetChanged()

            }

        }


    }

    private fun initView() {
        tabCct.isSelected = true


        fragments.add(FragmentCCT())
        fragments.add(FragmentHSL())
        fragments.add(FragmentEffect())


        FragmentUtils.add(
            supportFragmentManager,
            fragments,
            com.hongri.bluelight.R.id.root_fragment,
            arrayOf("FragmentCCT", "FragmentHSL", "FragmentEffect"),
            0
        )



    }

    override fun onSaveInstanceState(outState: Bundle, outPersistentState: PersistableBundle) {
        super.onSaveInstanceState(outState, outPersistentState)
        outState.putInt("curIndex", curIndex)
    }


    fun onClick(view: View) {
        tabCct.isSelected = false
        tabHsi.isSelected = false
        tabEffect.isSelected = false

        when (view.id) {
            R.id.tabCct -> {
                tabCct.isSelected = true
                FragmentUtils.showHide(0, fragments)
                (fragments[0] as FragmentCCT).sendData()

            }
            R.id.tabHsi -> {
                tabHsi.isSelected = true
                FragmentUtils.showHide(1, fragments)
                (fragments[1] as FragmentHSL).sendData()

            }
            R.id.tabEffect -> {
                tabEffect.isSelected = true
                FragmentUtils.showHide(2, fragments)

                //线程中执行, 避免阻塞
                GlobalScope.launch {
                    (fragments[2] as FragmentEffect).sendData(0)
                    delay(100)
                    (fragments[2] as FragmentEffect).sendData(1)
                    delay(100)
                    (fragments[2] as FragmentEffect).sendData(2)
                    delay(100)
                    (fragments[2] as FragmentEffect).sendData(3)

                }

                /*ThreadUtils.getCachedPool().execute {

                    (fragments[2] as FragmentEffect).sendData(0)
                    Thread.sleep(100)
                    (fragments[2] as FragmentEffect).sendData(1)
                    Thread.sleep(100)
                    (fragments[2] as FragmentEffect).sendData(2)
                    Thread.sleep(100)
                    (fragments[2] as FragmentEffect).sendData(3)

                }*/


            }
            R.id.tv_device_title -> {

                sendGetDeviceListData()

            }
            R.id.tv_settings -> {
                var intent = Intent(this, SettingActivity::class.java)
                intent.putExtra("data", JSONObject.toJSONString(menuList))
                startActivity(intent)

            }


        }


    }

    override fun onStop() {
        super.onStop()
        drawerLayout.closeDrawers()

    }


    override fun onDestroy() {
        super.onDestroy()
        EventBus.getDefault().unregister(this)
        BLEService.getInstance().deInit()
    }


    /**
     * 接收从BLEService 发送出来的消息
     * @param msg
     */
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun receiveEventMsg(msg: ParentEventMsg) {

        if (msg is ReplyMsgBean) { //设备从Mesh回复的消息
            //LogUtils.e("=====MainActivity, receiveEventMsg()===msg=${msg}")

            when (msg.cmd) {

                BleEvent.RESULT_GET_NAME -> {
                    LogUtils.e("=====MainActivity, receiveMsg()==RESULT_GET_NAME=msg=${msg}")

                    if (msg.isEnd) {//完整的设备名
                        var deviceName = String(msg.data)
                        var menuItem = MenuItem(deviceName, msg.shortAdd)

                        if (menuList.contains(menuItem)) {
                            menuList.remove(menuItem)
                        }

                        menuList.add(menuItem)
                        LogUtils.e("=====MainActivity, receiveEventMsg()==shortAdd=${msg.shortAdd}=deviceName=${deviceName}")

                    } else { //不完整的设备名, 再次获取

                        var data: ByteArray = BleEvent.createGetDevicesData(
                            msg.shortAdd.replace(":", ""),
                            msg.data.size.toByte()
                        )
                        BLEService.getInstance().sendMsg(DataWrap(data), false)

                    }


                }


                BleEvent.RESULT_GET_LED_STATE -> {
                    updateFragmentOnOffState(msg.result)

                }

                BleEvent.RESULT_GET_COLOR_OFFSET_STATE -> {

                }

                BleEvent.RESULT_GET_DEVICE_FIRMWARE -> { //获取设备的固件版本号

                    handUpgradeTip(msg)

                }

                BleEvent.RESULT_GO_BOOT_MODE -> { //根据升级流程, 开始发送升级数据, 显示对话框

                    ToastUtils.showShort(R.string.start_upgrade)

                    showOperationDialog()
                    sendUpgradeHello(msg)

                }

            }


        }else if(msg is TxReplyBean){ //设备从TX回复的消息

            when(msg.cmd.toByte()){
                BleEvent.RESULT_COMMAND_HELLO->{

                    startSendUpgradeData()
                }

                BleEvent.RESULT_COMMAND_REBOOT->{//升级数据发送完成, 隐藏对话框
                    dismissOperationDialog()
                    ToastUtils.showShort(R.string.upgrade_success)
                }
            }

        }else if(msg is UpgradeDataPackageEvent){//更新上传文件进度的消息

            if (upgradeTotalPackage ==0){
                return
            }
            var percent=(upgradeTotalPackage-msg.sendCount)*100/upgradeTotalPackage
            if (operationDialog!=null && operationDialog!!.isVisible){
                operationDialog?.view?.findViewById<TextView>(R.id.tv_dialog_msg)?.let {
                    it.text=String.format(getString(R.string.upgrade_percent),percent)
                }
            }

             LogUtils.e("=====MainActivity, receiveEventMsg()===percent=$percent")
        }


    }


    /**
     * 开始发送升级的数据
     */
    private fun startSendUpgradeData() {

        GlobalScope.launch(Dispatchers.Main) {

            withContext(Dispatchers.IO) {
                //代码块执行在DefaultDispatcher-worker线程

                var file = File(getExternalFilesDir("firmware"), "upgrade_AA191115.bin")

                var result = FileIOUtils.writeFileFromIS(
                    file,
                    assets.open("upgrade_AA191115.bin")
                )
                LogUtils.e("=====MainActivity, receiveEventMsg()===文件写到外部私有目录: $result, ${file.absoluteFile}")

                upgradeData = FileIOUtils.readFile2BytesByChannel(file)
                var upgradeHead =
                    Tag_UpgradeFileHeader(upgradeData.sliceArray(0..99))


                LogUtils.e("=====MainActivity, receiveEventMsg()===upgradeHead=$upgradeHead")

            }

            //4. 发送开始升级命令，里面包含 UpgradeElmentHeader 中的 size;,payload 为4字节的size, LSB(低位在前)
            var data  = BleEvent.createTXChannelData(
                command = BleEvent.COMMAND_START_UPGRADE,
                payload = upgradeData.sliceArray(24..27)
            )
            BLEService.getInstance()
                .sendMsg(DataWrap(data, sendType = DataWrap.SEND_TYPE_TX), false,false)

            delay(100)

            //回复: A55A 82 01 0082

            // return@launch

            //5. 发送 KEY 解密密钥命令，里面包含 UpgradeElmentHeader 中的 key;
            data = BleEvent.createTXChannelData(
                command = BleEvent.COMMAND_SEND_KEY,
                payload = upgradeData.sliceArray(32..47)
            )
            BLEService.getInstance()
                .sendMsg(DataWrap(data, sendType = DataWrap.SEND_TYPE_TX), false,false)

            delay(100)

            //回复: A55A 86 01 0187

            // return@launch

            //6. 发送升级数据
            var cmdList= mutableListOf<ByteArray>()
            BleEvent.generateUpgradeCmdList(0, upgradeData.sliceArray(48 until upgradeData.size),cmdList)
            LogUtils.e("=====MainActivity, handStartUpgrade()===cmdlist.size=${cmdList.size}, last=${ConvertUtils.bytes2HexString(cmdList[cmdList.size-1])}")

            upgradeTotalPackage=cmdList.size
            var count=0
            cmdList.forEach {
                count++
                BLEService.getInstance()
                    .sendMsg(DataWrap(it, sendType = DataWrap.SEND_TYPE_TX), false,false)
                LogUtils.e("=====MainActivity, handStartUpgrade()===count=$count,size=${cmdList.size}")
            }

            //回复:A55A 83 01 0184

            //return@launch
            //7. 发送结束升级命令;
            data = BleEvent.createTXChannelData(
                command = BleEvent.COMMAND_END_UPGRADE,
                payload = byteArrayOf(BleEvent.generateChecksumFromByteArray(upgradeData.sliceArray(48 until upgradeData.size)))
            )
            BLEService.getInstance()
                .sendMsg(DataWrap(data, sendType = DataWrap.SEND_TYPE_TX), false,false)

            delay(100)
            //return@launch

            //8. 发送重启命令;
            data = BleEvent.createTXChannelData(
                command = BleEvent.COMMAND_REBOOT,
                payload = byteArrayOf()
            )
            BLEService.getInstance()
                .sendMsg(DataWrap(data, sendType = DataWrap.SEND_TYPE_TX), false,false)

        }


    }


    /**
     * 记录升级的总包个数
     */
     var upgradeTotalPackage:Int=0


    private fun sendUpgradeHello(msg: ReplyMsgBean) {
        var result = msg.result
        LogUtils.e("=====MainActivity, receiveEventMsg()===发送升级的指令 result=$result")
        if (result.toInt() == 1) {//成功切换到Boot模式

            GlobalScope.launch {
                delay(2000)

                //切换到TX模式发送数据
                //发送hello, 确认在线
                // 3. 循环发送获取工作模式的命令，直到设备有回复则工作在 bootload 模式，则进入
                // 下一步。如果循环多次没有回复，则升级失败;
                sendUpgradeHelloCMD()

                //回复: A55A 80 010181


            }


        }
    }

    private suspend fun sendUpgradeHelloCMD() {
        var data = BleEvent.createTXChannelData(
            command = BleEvent.COMMAND_HELLO,
            payload = byteArrayOf()
        )
        BLEService.getInstance()
            .sendMsg(DataWrap(data, sendType = DataWrap.SEND_TYPE_TX), false, false)

        delay(100)
    }


    /**
     * 升级文件的数据
     */
    lateinit var upgradeData: ByteArray

    /**
     * 处理版本号的对比和提示
     */
    private fun handUpgradeTip(msg: ReplyMsgBean) {
        //版本号LSB 低位在前,反转后再和代码中的版本号对比
        var deviceVersion = ConvertUtils.bytes2HexString(msg.data.reversedArray()).toInt(16)
        var deviceId = "AA191115"

        var targetVersion = LocalApplication.deviceVersionMap[deviceId]

        LogUtils.e("=====MainActivity, receiveEventMsg()===deviceVersion=$deviceVersion,targetVersion=$targetVersion，msg.data=${Arrays.toString(msg.data)}")

        //如果设备的版本号小于app打包的升级文件的版本号, 就升级
        //1.将升级文件拷贝到私有外部目录
        if (targetVersion != null && deviceVersion < targetVersion) {

            LogUtils.e(
                "=====MainActivity, receiveEventMsg()===需要升级 ${ConvertUtils.bytes2HexString(
                    msg.data
                )}"
            )

            showUpgradeDialog {
                if (!it) return@showUpgradeDialog


                //点击了dialog 的确认

                //通知设备进入boot模式, 处理成功会收到  BleEvent.RESULT_GO_BOOT_MODE 的回复 //41542B4D455348001565EA01020D0A

                var shortAdd = parseShortAddrByMac(connectDevice!!.mac)
                var data = BleEvent.createGoBootModeData(shortAdd)
                BLEService.getInstance().sendMsg(DataWrap(data), false)

            }


        }
    }

    private fun showUpgradeDialog(callback: (Boolean) -> Unit = {}) {
        NiceDialog.init().setLayoutId(R.layout.dialog_common_two_button)
            .setConvertListener(object : ViewConvertListener() {
                override fun convertView(holder: ViewHolder, dialog: BaseNiceDialog) {
                    holder.setText(R.id.tv_tips, R.string.new_version)
                    holder.setOnClickListener(R.id.btn_left) {
                        dialog.dismissAllowingStateLoss()
                        callback.invoke(false)
                    }

                    holder.setOnClickListener(R.id.btn_right) {
                        dialog.dismissAllowingStateLoss()
                        ToastUtils.showLong(R.string.ready_upgrade)
                        callback.invoke(true)
                        //开始升级

                    }


                }

            })
            .setOutCancel(false)
            .setWidth(-1)
            .setDimAmount(0.3f)
            .show(supportFragmentManager)

    }


    private fun updateFragmentOnOffState(state: Byte) {

        LogUtils.e("=====MainActivity, updateFragmentOnOffState()===state=$state")
        //更新OnOff
        (fragments[0] as FragmentCCT).obOnOff.postValue(state == 1.toByte())
        (fragments[1] as FragmentHSL).obOnOff.postValue(state == 1.toByte())
        (fragments[2] as FragmentEffect).obOnOff.postValue(state == 1.toByte())


    }


    /**
     * 更新FragmentHSL界面
     */
    fun updateHSLViewModel(vm: HSLBean) {
        (fragments[1] as FragmentHSL).observableData.postValue(vm)

    }

    /**
     * 更新FragmentCCT界面
     */
    fun updateCCTViewModel(vm: CCTBean) {
        (fragments[0] as FragmentCCT).observableData.postValue(vm)

    }

    /**
     * 更新FragmentEffect_Program界面
     */
    fun updateEffectViewModel(vm: ProgramBean) {
        (fragments[2] as FragmentEffect).updateEffectBean(vm)

    }

    /**
     * 更新FragmentEffect_Scene界面
     */
    fun updateEffectSceneViewModel(vm: SceneBean) {
        (fragments[2] as FragmentEffect).updateSceneBean(vm)

    }


    fun showBlur(flag: Boolean, index: Int = 0) {
        if (flag) {
            dialog_blur.visibility = View.VISIBLE
            val bmp = Bitmap.createBitmap(
                root_main.getWidth(),
                root_main.getHeight(),
                Bitmap.Config.ARGB_8888
            )
            val c = Canvas(bmp)
            c.drawColor(Color.WHITE)
            root_main.draw(c)

            bitmapBg1 = bmp

            //root_main.buildDrawingCache()
            //val bitmap = root_main.getDrawingCache()

            // }
            Blurry.with(this).radius(10).sampling(10).from(bmp).into(dialog_blur)


            // Blurry.with(this).radius(10).sampling(10).from(bitmap).into(dialog_blur)
            //Blurry.with(this).radius(10).sampling(7).capture(root_main).into(dialog_blur)


            // Blurry.with(this)..capture(root_main).into(dialog_blur)
        } else {
            dialog_blur.visibility = View.GONE
        }

    }


    var operationDialog: BaseNiceDialog? = null
    private fun showOperationDialog() {
        dismissOperationDialog()

        showBlur(true)
        operationDialog = NiceDialog
            .init()
            .setLayoutId(R.layout.dialog_operation)
            .setWidth(-1)
            .setDimAmount(0.3f)
            //.setOutCancel(false)
            .show(supportFragmentManager)

        operationDialog?.isCancelable=true


    }

    private fun dismissOperationDialog() {
        if (operationDialog != null) {
            operationDialog!!.dismissAllowingStateLoss()
            operationDialog = null
        }

        showBlur(false)
    }


    override fun onBackPressed() {
        AppUtils.exitApp()
    }


    fun sendSetLedStateData(state: Boolean) {
        //ledOn=state

        var data = BleEvent.createSetLedStateData(state)
        BLEService.getInstance().sendMsg(DataWrap(data), true)

    }


}


