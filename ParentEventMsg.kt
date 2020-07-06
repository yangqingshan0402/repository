package com.hongri.bluelight.ble

import com.blankj.utilcode.util.ConvertUtils
import com.blankj.utilcode.util.LogUtils
import okhttp3.internal.and
import kotlin.experimental.and

sealed class ParentEventMsg {
}


//==============================================================================
//==============================================================================
//==============================================================================
//==============================================================================
class BleEvent (var target:String,var cmd:Byte,var param1:Byte=-1,var param2:Short=-1,var param3:Byte=-1,var param4:Byte=-1,var param5:Byte=-1,var param6:Byte=-1):ParentEventMsg(){

    companion object{


        val START_1:Byte=0xAA.toByte()
        val START_2:Byte=0xFB.toByte()
        val PARAM_INVALIDATE:Byte=-1

        const val CMD_SET_CCT:Byte=0x41

        const val CMD_SET_HSI:Byte=0x42

        const val CMD_SET_SCENE:Byte=0x43

        const val CMD_SET_PROGRAM:Byte=0x44

        const val CMD_GET_NAME:Byte=0x68

        const val CMD_SET_DEVICE_NAME=0x69

        const val CMD_SET_FLASH_TIME:Byte=0x6E

        const val CMD_SET_LED_STATE:Byte=0X70

        const val CMD_GET_LED_STATE:Byte=0x71

        const val CMD_SET_COLOR_OFFSET_STATE:Byte=0X72

        const val CMD_GET_COLOR_OFFSET_STATE:Byte=0x73

        const val CMD_GET_DEVICE_FIRMWARE: Byte=0x6A

        const val CMD_GO_BOOT_MODE: Byte=0x6D



        //设备端返回的指令cmd
        const val RESULT_SET_CCT:Byte=0xC1.toByte()
        const val RESULT_SET_HSI:Byte=0xC2.toByte()
        const val RESULT_SET_SCENE:Byte=0xC3.toByte()
        const val RESULT_SET_PROGRAM:Byte=0xC4.toByte()

        const val RESULT_GET_NAME:Byte=0xE8.toByte()
        const val RESULT_SET_NAME:Byte=0xE9.toByte()

        const val RESULT_SET_LED_STATE: Byte=0xF0.toByte()
        const val RESULT_GET_LED_STATE: Byte=0xF1.toByte()

        const val RESULT_SET_COLOR_OFFSET_STATE: Byte=0xF2.toByte()
        const val RESULT_GET_COLOR_OFFSET_STATE: Byte=0xF3.toByte()

        const val RESULT_GET_DEVICE_FIRMWARE:Byte=0xEA.toByte()
        const val RESULT_GO_BOOT_MODE:Byte=0xED.toByte()







        /**
         * 获取设备的工作模式
         */
        const val COMMAND_GET_WORK_MODE: Byte=0x01





        //=================TX 通道的指令=========================
        const val COMMAND_HELLO: Byte=0x00
        const val RESULT_COMMAND_HELLO:Byte=0x80.toByte()


        const val COMMAND_START_UPGRADE: Byte=0x02
        const val COMMAND_SEND_UPGRADE_DATA: Byte=0x03

        const val COMMAND_END_UPGRADE: Byte=0x04
        const val RESULT_COMMAND_END_UPGRADE: Byte=0x84.toByte()

        const val COMMAND_SEND_KEY: Byte=0x06

        const val COMMAND_REBOOT: Byte=0x07
        const val RESULT_COMMAND_REBOOT: Byte=0x87.toByte()





        /**
         * 将收到的数据解析成BleEvent
         */
        /*fun parse(data: ByteArray): BleEvent {

            //收到的是16进制的byte[]

            LogUtils.e("BleEvent =====xgh=====,parse():str=${ConvertUtils.bytes2HexString(data)}");



            var start1=data[0]
            var start2=data[1]

            if (start1 != START_1 || start2 != START_2){
                return BleEvent("", 0, 0, 0, 0)

            }


            //target 2个byte
            var target=ConvertUtils.bytes2HexString(byteArrayOf(data[2],data[3]))

            var cmd=data[4]


            var param1=
                PARAM_INVALIDATE
            var param2:Short= PARAM_INVALIDATE.toShort()
            var param3=
                PARAM_INVALIDATE
            var param4=
                PARAM_INVALIDATE
            var param5=
                PARAM_INVALIDATE
            var param6=
                PARAM_INVALIDATE

            //根据不同的cmd 来区分参数
            when(cmd){
                CMD_MODE_CCT ->{//用的是byte(param1),byte(param3)
                    param1=data[5]
                    param3=data[6]

                  }
                CMD_MODE_HSI ->{//用的是byte(param1),short(param2),byte(param3)
                    param1=data[5]
                    param2=((data[6].toInt() shl(8) and 0xFFFF) or (data[7].toInt() and 0xFF)).toShort()
                    param3=data[8]

                  }
                CMD_MODE_SCENE ->{//用的是byte(param1),byte(param3)
                    param1=data[5]
                    param3=data[6]

                  }
                CMD_MODE_PROGRAM ->{//用的是byte,short,byte,byte,byte (参数1:行数, 参数2:色度, 参数3:亮度, 参数4:CCT, 参数5: 时间索引)


                }

            }


           // var param1=data[5]

           // var param2=data[6].toInt() shl(8) or (data[7].toInt())

           // var param3=data[8]


         return BleEvent(
             target,
             cmd,
             param1,
             param2,
             param3,
             param4,
             param5,
             param6
         )


        }*/

        /**
         * 从Mesh 数据中解析出真实的指令数据
         * F1 01 00 FF FF AA FB FF FF 01 20 19 00 00
         * 这里收到的是16进制的byte[],需要转换成10进制再使用
         */
        /* fun parseMeshData(justWrite: ByteArray): BleEvent {

             //这句话解析的格式: F1 01 00 FF FF AA FB FF FF 01 20 19 00 00
             var data=justWrite.slice(IntRange(5,justWrite.size-1)).toByteArray()
             LogUtils.e("BleEvent =====xgh=====,parseMeshData():mesh 解析后: ${Arrays.toString(data)}");
             return parse(data)

         }*/


        /**
         * Effect 模式
         */
        fun createCctEffectData(
            boost: Byte,
            light: Byte,
            cct: Short,
            offsetR: Byte,
            offsetG: Byte,
            offsetB: Byte
        ): ByteArray {

            var sbStr=StringBuilder()
            //添加Mesh 头

            //F10100FFFF
            sbStr.append("F10100")
            sbStr.append("0000")
            sbStr.append(String.format("%02X", CMD_SET_CCT))
            sbStr.append(String.format("%02X",boost))
            sbStr.append(String.format("%02X",light))

            //需要转换为低位在前
            var shortStr=String.format("%04X",cct)
            sbStr.append(shortStr.substring(2..3))
            sbStr.append(shortStr.substring(0..1))

            sbStr.append(String.format("%02X",offsetR))
            sbStr.append(String.format("%02X",offsetG))
            sbStr.append(String.format("%02X",offsetB))

            LogUtils.e("=====createCctEffectData(),str=${sbStr.toString()}")
            return  BLEService.getBytesByString(sbStr.toString())




        }


        /**
         * HSI模式
         */
        fun createHSIData( boost: Byte, valueI: Byte, editParam: Byte, valueH: Short, valueS: Byte): ByteArray {

            var sbStr=StringBuilder()
            //添加Mesh 头

            //F10100FFFF
            sbStr.append("F10100")
            sbStr.append("0000")
            sbStr.append(String.format("%02X", CMD_SET_HSI))
            sbStr.append(String.format("%02X",boost))
            sbStr.append(String.format("%02X",valueI))
            sbStr.append(String.format("%02X",editParam))

            //需要转换为低位在前
            var shortStr=String.format("%04X",valueH)
            sbStr.append(shortStr.substring(2..3))
            sbStr.append(shortStr.substring(0..1))

            sbStr.append(String.format("%02X",valueS))

            LogUtils.e("=====createCctEffectData(),str=${sbStr.toString()}")
            return  BLEService.getBytesByString(sbStr.toString())
        }





        /**
         * 编程模式
         */
        fun createProgramModeData( boost: Byte, valueI: Byte, rowIndex: Byte, valueH: Short, timeIndex: Byte,cct:Short): ByteArray {
            var sbStr=StringBuilder()
            //添加Mesh 头

            //F10100FFFF
            sbStr.append("F10100")
            sbStr.append("0000")
            sbStr.append(String.format("%02X", CMD_SET_PROGRAM))
            sbStr.append(String.format("%02X",boost))
            sbStr.append(String.format("%02X",valueI))
            sbStr.append(String.format("%02X",rowIndex))

            //需要转换为低位在前
            var shortStr=String.format("%04X",valueH)
            sbStr.append(shortStr.substring(2..3))
            sbStr.append(shortStr.substring(0..1))

            sbStr.append(String.format("%02X",timeIndex))

            //cct 2byte,需要转换低位在前, 高位在后
            var cctStr=String.format("%04X",cct)
            sbStr.append(cctStr.substring(2..3))
            sbStr.append(cctStr.substring(0..1))
//F10100 0000 44 00 64 00 7800 0A 8813

            LogUtils.e("=====createCctEffectData(),str=${sbStr.toString()}")
            return  BLEService.getBytesByString(sbStr.toString())
        }


        /**
         * 场景模式
         */
        fun createSceneModeData(boost: Byte, valueI: Byte, posIndex: Byte, subPosIndex: Byte): ByteArray {

            var sbStr=StringBuilder()
            //添加Mesh 头

            //F10100FFFF
            sbStr.append("F10100")
            sbStr.append("0000")
            sbStr.append(String.format("%02X", CMD_SET_SCENE))
            sbStr.append(String.format("%02X",boost))
            sbStr.append(String.format("%02X",valueI))
            sbStr.append(String.format("%02X",posIndex))

            //需要转换为低位在前
            /* var shortStr=String.format("%04X",valueH)
             sbStr.append(shortStr.substring(2..3))
             sbStr.append(shortStr.substring(0..1))*/

            sbStr.append(String.format("%02X",subPosIndex))

            LogUtils.e("=====createCctEffectData(),str=${sbStr.toString()}")
            return  BLEService.getBytesByString(sbStr.toString())

        }


        /**
         * 控制Led的状态 ON/OFF
         */
        fun createSetLedStateData(state:Boolean):ByteArray{

            var sbStr=StringBuilder()

            sbStr.append("F10100")
            sbStr.append("0000")
            sbStr.append(String.format("%02X", CMD_SET_LED_STATE))
            if (state){
                sbStr.append(String.format("%02X",1))

            }else{
                sbStr.append(String.format("%02X",0))

            }

            return  BLEService.getBytesByString(sbStr.toString())


        }


        /**
         * 读取led 状态
         */
        fun createGetLedStateData(shortAdd: String="0000"): ByteArray{

            var sbStr=java.lang.StringBuilder()
            sbStr.append("F10100")
            sbStr.append(shortAdd)
            sbStr.append(String.format("%02x", CMD_GET_LED_STATE))

            return BLEService.getBytesByString(sbStr.toString())
        }

        /**
         * 控制颜色补偿的On/off
         */
        fun createSetColorOffsetState(state:Boolean): ByteArray {

            var sbStr=StringBuilder()

            sbStr.append("F10100")
            sbStr.append("0000")
            sbStr.append(String.format("%02X", CMD_SET_COLOR_OFFSET_STATE))
            if (state){
                sbStr.append(String.format("%02X",1))

            }else{
                sbStr.append(String.format("%02X",0))

            }

            return  BLEService.getBytesByString(sbStr.toString())

        }


        /**
         * 读取颜色补偿 状态
         */
        fun createGetColorOffsetStateData(): ByteArray{

            var sbStr=java.lang.StringBuilder()
            sbStr.append("F10100")
            sbStr.append("0000")
            sbStr.append(String.format("%02x", CMD_GET_COLOR_OFFSET_STATE))

            return BLEService.getBytesByString(sbStr.toString())
        }


        /**
         * 设置SCENE模式的时间
         */
        fun createSetFlashTimeData(flashTime: Byte): ByteArray {

            var sbStr=StringBuilder()

            sbStr.append("F10100")
            sbStr.append("0000")
            sbStr.append(String.format("%02X",CMD_SET_FLASH_TIME))
            sbStr.append(String.format("%02X",flashTime))


            return  BLEService.getBytesByString(sbStr.toString())

        }


        /**
         * 扫描设备
         */
        fun createGetDevicesData(shortAdd: String,offset:Byte): ByteArray {
            var sbStr=StringBuilder()
            //添加Mesh 头

            //F10100FFFF
            sbStr.append("F10100")
            sbStr.append(shortAdd)
            sbStr.append(String.format("%02X",CMD_GET_NAME))
            sbStr.append(String.format("%02X",offset))
            LogUtils.e("=====createCctEffectData(),str=$sbStr")
            return  BLEService.getBytesByString(sbStr.toString())
        }

        /**
         * 根据设备名生成指令, 一条指令只能传输12个byte
         */
        fun createEditDeviceNameData(shortAdd:String,deviceName:String):MutableList<ByteArray>{
            var dataList= mutableListOf<ByteArray>()

            var byteNewName=deviceName.toByteArray()
            LogUtils.e("=====BleEvent, createEditDeviceNameData()===byteNewName.size=${byteNewName.size}")

            /*  if (byteNewName.size <= 9){

                  var sbStr=StringBuilder()
                  //添加Mesh 头
                  sbStr.append("F10100")
                  sbStr.append(shortAdd)
                  sbStr.append(String.format("%02X",0x69))
                  sbStr.append("00")//偏移位置,表示前一条指令发送了多少个字节的名称数据

                  var byteData=  BLEService.getBytesByString(sbStr.toString())

                  //设备名不能转成16进制
                  var byteName=deviceName.toByteArray()
                  var byteReal=ByteArray(byteData.size+byteName.size+1)

                  System.arraycopy(byteData,0,byteReal,0,byteData.size)
                  System.arraycopy(byteName,0,byteReal,byteData.size,byteName.size)
                  byteReal[byteReal.lastIndex]=0

                  dataList.add(byteReal)


              }else{




              }*/

            delevDeviceName(shortAdd,0,deviceName,dataList)
            LogUtils.e("=====BleEvent, createEditDeviceNameData()===dataList.size=${dataList.forEach {
                LogUtils.e("=====BleEvent, createEditDeviceNameData()===${ConvertUtils.bytes2HexString(it)}")
            }}")

            return dataList

        }





        fun delevDeviceName(shortAdd:String,startIndex:Int,deviceName: String,cmdList:MutableList<ByteArray>){

            var byteDeviceName=deviceName.toByteArray()
            var temp=startIndex
            val maxLength=9

            if (temp +maxLength >= byteDeviceName.size){

                var sbStr=StringBuilder()
                //添加Mesh 头
                sbStr.append("F10100")
                sbStr.append(shortAdd)
                sbStr.append(String.format("%02X",CMD_SET_DEVICE_NAME))
                sbStr.append(String.format("%02X",temp))//偏移位置,表示前一条指令发送了多少个字节的名称数据

                var byteData=  BLEService.getBytesByString(sbStr.toString())

                //设备名不能转成16进制
                // var byteName=deviceName.toByteArray()
                var byteReal=ByteArray(byteData.size+byteDeviceName.size-temp+1)

                System.arraycopy(byteData,0,byteReal,0,byteData.size)
                System.arraycopy(byteDeviceName,temp,byteReal,byteData.size,byteDeviceName.size-temp)
                byteReal[byteReal.lastIndex]=0

                LogUtils.e("=====BleEvent, delevDeviceName()===递归结束")

                cmdList.add(byteReal)

            }else{

                var sbStr=StringBuilder()
                //添加Mesh 头
                sbStr.append("F10100")
                sbStr.append(shortAdd)
                sbStr.append(String.format("%02X",0x69))
                sbStr.append(String.format("%02X",temp))//偏移位置,表示前一条指令发送了多少个字节的名称数据

                var byteData=  BLEService.getBytesByString(sbStr.toString())

                //设备名不能转成16进制
                var byteName=deviceName.toByteArray()
                var byteReal=ByteArray(byteData.size+maxLength)

                System.arraycopy(byteData,0,byteReal,0,byteData.size)

                System.arraycopy(byteName,temp,byteReal,byteData.size,maxLength)
                cmdList.add(byteReal)


                temp+=9
                delevDeviceName(shortAdd,temp,deviceName,cmdList)
                LogUtils.e("=====BleEvent, delevDeviceName()===执行递归...")
            }


        }


        /**
         * 根据传入的升级数据,组装成多条指令
         */
        fun generateUpgradeCmdList(startIndex: Int,payload2: ByteArray,cmdList: MutableList<ByteArray>){

            //自定义协议的字节占用数
            var customerSize=5
            //计算出每条指令的最大传输值
            var sizePerCmd=BLEService.MAX_MTU-customerSize

            var innerIndex=startIndex
            var payloadSize=payload2.size
            //协议头 A5,5A

            //协议尾: checksum

            while (innerIndex<=payloadSize){//0,20

                var endIndex=if (innerIndex + sizePerCmd >=payloadSize) payloadSize else innerIndex+sizePerCmd

                //LogUtils.e("=====BleEvent, generateUpgradeCmdList()===  innerIndex=$innerIndex,endIndex=$endIndex,payloadSize=$payloadSize")

                var payload=payload2.sliceArray(innerIndex until endIndex)
                var sbStr=StringBuilder()
                sbStr.append(String.format("%02X",0xA5))
                sbStr.append(String.format("%02X",0x5A))
                sbStr.append(String.format("%02X",COMMAND_SEND_UPGRADE_DATA))
                sbStr.append(String.format("%02X",payload.size))
                sbStr.append(ConvertUtils.bytes2HexString(payload))

                var checksum=generateChecksum(0xA5.toByte(),0x5A.toByte(),COMMAND_SEND_UPGRADE_DATA,payload.size.toByte(), payload)

                sbStr.append(String.format("%02X",checksum))
                var cmdData= BLEService.getBytesByString(sbStr.toString())
                cmdList.add(cmdData)
                // LogUtils.e("=====BleEvent, generateUpgradeCmdList()===cmdList=${cmdList.joinToString { ConvertUtils.bytes2HexString(it) }}")

                innerIndex+=sizePerCmd

            }

            //LogUtils.e("=====BleEvent, generateUpgradeCmdList()===cmdList=${ConvertUtils.bytes2HexString(cmdList.get(cmdList.size-2))}")
            //LogUtils.e("=====BleEvent, generateUpgradeCmdList()===cmdList=${ConvertUtils.bytes2HexString(cmdList.get(cmdList.size-1))}")



        }




        /**
         * 通过Mesh方式获取当前设备的工作模式
         *
         */
        fun createGetWorkModeData(shortAdd: String,magic1: Byte=0xA5.toByte(),magic2: Byte=0x5A.toByte(),command: Byte,payload: ByteArray): ByteArray {

            var sbStr=StringBuilder()
            //添加Mesh 头

            //F10100FFFF
            sbStr.append("F10100")
            sbStr.append(shortAdd)
            sbStr.append(String.format("%02X",magic1))
            sbStr.append(String.format("%02X",magic2))
            sbStr.append(String.format("%02X",command))
            sbStr.append(String.format("%02X",payload.size))

            var checksum=generateChecksum(magic1,magic2,command,payload.size.toByte(), payload)
            LogUtils.e("=====BleEvent, createGetWorkModeData()===checksum=$checksum")

            sbStr.append(String.format("%02X",checksum))
            LogUtils.e("=====createGetWorkModeData(),str=$sbStr")
            return  BLEService.getBytesByString(sbStr.toString())


        }


        /**
         * 根据内容计算出checksum
         */
        fun generateChecksumFromByteArray(payload: ByteArray):Byte{
            var checksum=0

            payload.forEach {
                checksum+=it
            }

            return checksum.toByte()
        }



        /**
         * 计算checksum
         */
        private fun generateChecksum(magic1: Byte, magic2: Byte, command: Byte, payloadSize:Byte, payloadData: ByteArray): Byte {
            var checksum=magic1 +magic2+command+payloadSize

            payloadData.forEach {
                checksum+=it
            }

            return checksum.toByte()
        }

        /**
         * 通过mesh 获取设备的固件版本号
         */
        fun createGetDeviceFirmwareData(shortAdd: String, payload: ByteArray): ByteArray {
            var sbStr=StringBuilder()
            //添加Mesh 头

            //F10100FFFF
            sbStr.append("F10100")
            sbStr.append(shortAdd)
            sbStr.append(String.format("%02X",CMD_GET_DEVICE_FIRMWARE))

            LogUtils.e("=====createGetWorkModeData(),str=$sbStr")
            return  BLEService.getBytesByString(sbStr.toString())

        }


        /**
         * 通知设备切换到Boot模式
         */
        fun createGoBootModeData(shortAdd: String):ByteArray {
            var sbStr=java.lang.StringBuilder()

            sbStr.append("F10100")
            sbStr.append(shortAdd)
            sbStr.append(String.format("%02X",CMD_GO_BOOT_MODE))

            LogUtils.e("=====createGetWorkModeData(),str=$sbStr")
            return  BLEService.getBytesByString(sbStr.toString())
        }


        /**
         * 组装通过TX发送的数据
         */
        fun createTXChannelData(magic1: Byte=0xA5.toByte(),magic2: Byte=0x5A.toByte(),command: Byte,payload: ByteArray,sendPayload:Boolean=true):ByteArray {

            var sbStr=StringBuilder()

            sbStr.append(String.format("%02X",magic1))
            sbStr.append(String.format("%02X",magic2))
            sbStr.append(String.format("%02X",command))

            //发送升级完成指令不需要payload
            if (sendPayload){
                sbStr.append(String.format("%02X",payload.size))
                sbStr.append(ConvertUtils.bytes2HexString(payload))
            }

            var checksum=generateChecksum(magic1,magic2,command,payload.size.toByte(), payload)

            sbStr.append(String.format("%02X",checksum))
            return  BLEService.getBytesByString(sbStr.toString())

        }



        /**
         * 组装通过TX发送的数据
         */
        /*  fun createTXEndUpgradeData(magic1: Byte=0xA5.toByte(),magic2: Byte=0x5A.toByte(),command: Byte):ByteArray {

              var sbStr=StringBuilder()

              sbStr.append(String.format("%02X",magic1))
              sbStr.append(String.format("%02X",magic2))
              sbStr.append(String.format("%02X",command))

              //发送升级完成指令不需要payload
                  sbStr.append(String.format("%02X",1))

              var checksum=generateChecksum(magic1,magic2,command,payload.size.toByte(), payload)

              sbStr.append(String.format("%02X",checksum))
              return  BLEService.getBytesByString(sbStr.toString())

          }*/



    }


    constructor():this("",0){

    }



    override fun toString(): String {
        return "BleEvent(target='$target', cmd=$cmd, param1=$param1, param2=$param2, param3=$param3, param4=$param4, param5=$param5, param6=$param6)"
    }


}


//==============================================================================
//==============================================================================
//==============================================================================
//==============================================================================

class ReplyMsgBean(var shortAdd:String="", var cmd:Byte=0, var result:Byte=0, var data:ByteArray= byteArrayOf(), var isEnd:Boolean=true) :ParentEventMsg(){



    companion object{

        //用来记录设备名称的临时数据
        private var tempDataMap:HashMap<String,ArrayList<Byte>> = HashMap(10)

        fun parse(data: ByteArray): ParentEventMsg {
            var receiveMsgBean:ParentEventMsg?=null

            //设置CCT	    41542B4D45534800([0-7]字节) 1584([8-9]字节) C1([10]) 01([11]) 0D0A
            //设置HSI	    41542B4D45534800 1584 C2 01 0D0A
            //设置Scence:	41542B4D45534800 1584 C3 01 0D0A
            //设置Program	41542B4D45534800 1584 C4 01 0D0A
            //获取设备名称： 41542B4D45534800 1584 E8 00 4C45442D363500 0D0A  41542B4D455348001565E8004C45442D3635000D0A

            //解析出短地址
            var sb=StringBuilder()
            sb.append(String.format("%02X",data[8]))
            sb.append(":")
            sb.append(String.format("%02X",data[9]))
            var shortAdd=sb.toString()

            //指令
            var  cmd:Byte=data[10]

            //结果
            var result:Byte=data[11]

            //按照Upgrade方式解析==========================
            //第10字节和第11字节如果是0xA5和0x5A,就是升级的指令,按照升级的解析方式
            if ((cmd.and(0xFF.toByte())) == 0xA5.toByte() && result.and(0xFF.toByte()) == 0xA5.toByte()){
                receiveMsgBean= UpgradeMsgBean(0xA5.toByte(),0x5A.toByte(),0.toByte(), byteArrayOf())

                return receiveMsgBean
            }



            //按照标准的方法解析============================
            when(cmd and 0xFF.toByte()){
                BleEvent.RESULT_SET_CCT->{
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)

                }
                BleEvent.RESULT_SET_HSI->{
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)
                }
                BleEvent.RESULT_SET_SCENE->{
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)
                }
                BleEvent.RESULT_SET_PROGRAM->{
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)
                }
                BleEvent.RESULT_GET_NAME->{ //获取名称
                    //41 54 2B 4D 45 53 48 00 15 84 E8 00 4C 45 44 2D 39 36 00 0D 0A


                    var isEnd=true
                    //获取数据偏移值
                    var offset:Byte=data[11]
                    if (offset == 0.toByte()){ //一个新的开始

                        tempDataMap.remove(shortAdd)
                        var tempDeviceNameData:ArrayList<Byte> = ArrayList()
                        isEnd= getDeviceNameData(data,tempDeviceNameData)

                        tempDataMap[shortAdd] = tempDeviceNameData

                    }else{//添加到前面的数据中

                        var tempDeviceNameData= tempDataMap[shortAdd]!!
                        isEnd= getDeviceNameData(data,tempDeviceNameData)

                    }


                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result,  tempDataMap[shortAdd]!!.toByteArray(),isEnd)


                }

                BleEvent.RESULT_SET_NAME->{ //修改名称

                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, data[12], byteArrayOf())

                }

                BleEvent.RESULT_SET_LED_STATE->{ //设置LED状态
                    //如果设置成功, 再读取一次Led状态, 用于更新UI
                    if (result == 1.toByte()){ //修改成功
                        LogUtils.e("=====ReplyMsgBean, parse()===设置led 状态成功")
                        var data=BleEvent.createGetLedStateData()
                        BLEService.getInstance().sendMsg(DataWrap(data),true)
                    }else{

                    }

                }


                BleEvent.RESULT_GET_LED_STATE->{//获取LED状态
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)
                }

                BleEvent.RESULT_SET_COLOR_OFFSET_STATE->{ //设置colorOffset
                    //如果设置成功, 再读取一次colorOffset状态, 用于更新UI
                    if (result == 1.toByte()){ //修改成功
                        LogUtils.e("=====ReplyMsgBean, parse()===设置colorOffset 状态成功")
                        var data=BleEvent.createGetColorOffsetStateData()
                        BLEService.getInstance().sendMsg(DataWrap(data),true)
                    }else{

                    }
                }

                BleEvent.RESULT_GET_COLOR_OFFSET_STATE->{ //读取colorOffset状态
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)
                }

                BleEvent.RESULT_GET_DEVICE_FIRMWARE->{ //获取设备的固件版本

                    //用2个字节来表示版本号[10],[11], 低位在前, 比如 v1.2: 返回0201

                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, 0, data.sliceArray(11..12).reversedArray(),true)


                }

                BleEvent.RESULT_GO_BOOT_MODE->{
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)
                }

                BleEvent.RESULT_COMMAND_END_UPGRADE->{
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)
                }

                BleEvent.RESULT_COMMAND_REBOOT->{
                    receiveMsgBean= ReplyMsgBean(shortAdd,cmd, result, byteArrayOf(),true)
                }

            }


            LogUtils.e("=====ReceiveMsgBean, parse()===receiveMsgBean:${receiveMsgBean}")

            return receiveMsgBean!!
        }



        private fun getDeviceNameData(data: ByteArray,deviceNameData:ArrayList<Byte>):Boolean{
            //从byte数组中解析出设备名称
            //41542B4D455348001565E8 00 31 32 33 34 35 36 37 38 39 00 0D0A

            //  var offset=data[11].toInt()
            var end=0

            for (i in 12 until data.size-2){// [12,data.size-2)

                if (data[i]==0.toByte()){
                    end=i
                    break
                }
                deviceNameData.add(data[i])

            }

            LogUtils.e("=====ReplyMsgBean, getDeviceNameData()===解析的结果: ${String(deviceNameData.toByteArray())}")

            return end >0
            /*if (String.format("%02X",data[10]) == "E8"){
            }else{
                return  false
            }*/

        }


        fun parseByTx(data: ByteArray): ParentEventMsg? {
            var receiveMsgBean:ParentEventMsg?=null

            //TX协议返回的格式: A55A 83 01 01 84


            //解析出短地址
            var sb=StringBuilder()
            sb.append(String.format("%02X",data[8]))
            sb.append(":")
            sb.append(String.format("%02X",data[9]))
            var shortAdd=sb.toString()

            //指令
            var  cmd:Byte=data[10]

            //结果
            var result:Byte=data[11]

            return receiveMsgBean


        }
    }

    override fun toString(): String {
        return "ReceiveMsgBean(shortAdd='$shortAdd', cmd=$cmd, result=$result, data=${data.contentToString()}, isEnd=$isEnd)"
    }


}



//==============================================================================
//==============================================================================
//==============================================================================
//==============================================================================

class UpgradeMsgBean(var magic1:Byte,var magic2:Byte,var command:Byte,var payload:ByteArray):ParentEventMsg() {


}


class TxReplyBean(var cmd:UByte,var data: ByteArray):ParentEventMsg(){

    val result:String
    get() {

        return ConvertUtils.bytes2HexString(data)
    }


    companion object{
        //A55A80010181
        const val RESULT_COMMAND_HELLO=0x80.toByte()

        //A55A82010082
        const val RESULT_COMMAND_START_UPGRADE=0x82.toByte()

        //A55A86010187

        const val RESULT_COMMAND_SEND_KEY=0x86.toByte()

        //A55A83010187
        const val RESULT_COMMAND_SEND_UPGRADE_DATA=0x83.toByte()


        fun parseTxReply(data:ByteArray):TxReplyBean{

            var start1:UByte= data[0].and(0xFF).toUByte()
            var start2:Byte= data[1].and(0xFF).toByte()

            var cmd:UByte= data[2].and(0xFF).toUByte()
            var payloadSize=data[3].and(0xFF)
            var payload=data.sliceArray(4 until 4+payloadSize)

            return TxReplyBean(cmd,payload)

        }



    }

    override fun toString(): String {
        return "TxReplyBean(cmd=${cmd.toString(16)}, data=${data.contentToString()})"
    }






}

//=============================================
//
//升级包发送的进度
//
//=============================================

data class UpgradeDataPackageEvent(var sendCount:Int):ParentEventMsg(){

}


