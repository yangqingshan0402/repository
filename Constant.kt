package com.hongri.bluelight.util

class Constant {

    companion object{

        //SHI界面的默认12个颜色的hsl
        val DEFAULT_SHI_LIGHT: String="""[
            |{"pos":0,"h":14,"s":97,"l":100},
            |{"pos":1,"h":330,"s":100,"l":100},
            |{"pos":2,"h":55,"s":94,"l":100},
            |{"pos":3,"h":88,"s":74,"l":100},
            |{"pos":4,"h":166,"s":73,"l":100},
            |{"pos":5,"h":272,"s":98,"l":80},
            |{"pos":6,"h":225,"s":99,"l":90},
            |{"pos":7,"h":220,"s":100,"l":70},
            |{"pos":8,"h":215,"s":100,"l":80},
            |{"pos":9,"h":210,"s":100,"l":90},
            |{"pos":10,"h":205,"s":100,"l":80},
            |{"pos":11,"h":200,"s":100,"l":85}]""".trimMargin()

        val KEY_HSL_ITEM_STR: String="key_shi_light_json"


        //CCT 界面的亮度
        const  val DEFAULT_INT: String="""[{"pos":0,"value":25},{"pos":1,"value":50},{"pos":2,"value":75},{"pos":3,"value":100}]"""
        const val KEY_INT_JSON="key_int_json"


        //CCT界面的色值
         val DEFAULT_CCT: String="""[
            |{"pos":0,"value":32},
            |{"pos":1,"value":40},
            |{"pos":2,"value":50},
            |{"pos":3,"value":55},
            |{"pos":4,"value":60},
            |{"pos":5,"value":65}
            |]""".trimMargin()
        const val KEY_CCT_JSON="key_cct_json"



        //5000  5500 6000 6500
        //Effect界面的值
        val DEFAULT_EFFECT:String="""[
            |{"pos":0,"h":120,"hState":0,"cct":50,"cctState":0,"timeIndex":10},
            |{"pos":1,"h":240,"hState":1,"cct":55,"cctState":0,"timeIndex":10},
            |{"pos":2,"h":320,"hState":0,"cct":60,"cctState":1,"timeIndex":10},
            |{"pos":3,"h":360,"hState":1,"cct":65,"cctState":0,"timeIndex":10}
            |]""".trimMargin()

        val KEY_EFFECT_JOSN="key_effect_json"


        //传给设备的时候要乘以100
        const val CCT_MAX=65
        const val CCT_MIN=32


        /**
         * 随着app发布打包的设备端的固件的版本号, 固件文件放在src/main/assets/, 文件名固定是upgrade.bin
         */
        const val DEVICE_FIRMWARE_VERSION=10

    }


}