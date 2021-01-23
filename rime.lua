-- 本文件中的日期代码由网友“镜中的迷离”倾情奉献。
-- Usage:
--  engine:
--    ...
--    translators:
--      ...
--      - lua_translator@lua_function3
--      - lua_translator@lua_function4
--      ...
--    filters:
--      ...
--      - lua_filter@lua_function1
--      - lua_filter@lua_function2
--      ...

cixuan = require("cixuan")
qinghouxuan = require("qinghouxuan")


function toNyear(year,mother,day) 
    --天干名称
    local cTianGan = {"甲","乙","丙","丁","戊","己","庚","辛","壬","癸"}
    --地支名称
    local cDiZhi = {"子","丑","寅","卯","辰","巳","午", "未","申","酉","戌","亥"}
    --属相名称
    local cShuXiang = {"鼠","牛","虎","兔","龙","蛇", "马","羊","猴","鸡","狗","猪"}
    --农历日期名
    local cDayName =
    {
        "*","初一","初二","初三","初四","初五",
        "初六","初七","初八","初九","初十",
        "十一","十二","十三","十四","十五",
        "十六","十七","十八","十九","二十",
        "廿一","廿二","廿三","廿四","廿五",
        "廿六","廿七","廿八","廿九","三十"
    }
    --农历月份名
    local cMonName = {"*","正","二","三","四","五","六", "七","八","九","十","十一","腊"}

    --公历每月前面的天数
    local wMonthAdd = {0,31,59,90,120,151,181,212,243,273,304,334}
    -- 农历数据
    local wNongliData = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
    ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
    ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
    ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
    ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
    ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
    ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
    ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
    ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
    ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877}

    local wCurYear,wCurMonth,wCurDay;
    local nTheDate,nIsEnd,m,k,n,i,nBit;
    local szNongli, szNongliDay,szShuXiang;
    ---取当前公历年、月、日---
    wCurYear = tonumber(year);
    wCurMonth = tonumber(mother);
    wCurDay = tonumber(day);
    ---计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)---
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth] - 38
    if (((wCurYear % 4) == 0) and (wCurMonth > 2)) then
        nTheDate = nTheDate + 1
    end
    
    --计算农历天干、地支、月、日---
    nIsEnd = 0;
    m = 0;
    while nIsEnd ~= 1 do
        if wNongliData[m+1] < 4095 then
            k = 11;
        else
            k = 12;
        end
        n = k;
        while n>=0 do
            --获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m+1];
            for i=1,n do
                nBit = math.floor(nBit/2);
            end
            nBit = nBit % 2;
            if nTheDate <= (29 + nBit) then
                nIsEnd = 1;
                break
            end
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        end
        if nIsEnd ~= 0 then
            break;
        end
        m = m + 1;
    end

    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if k == 12 then
        if wCurMonth == wNongliData[m+1] / 65536 + 1 then
            wCurMonth = 1 - wCurMonth;
        elseif wCurMonth > wNongliData[m+1] / 65536 + 1 then
            wCurMonth = wCurMonth - 1;
        end
    end
    wCurDay = math.floor(wCurDay)
    --print('农历', wCurYear, wCurMonth, wCurDay)
    --生成农历天干、地支、属相 ==> wNongli--
    szShuXiang = cShuXiang[(((wCurYear - 4) % 60) % 12) + 1]
    szShuXiang = cShuXiang[(((wCurYear - 4) % 60) % 12) + 1];
    szNongli = szShuXiang .. '(' .. cTianGan[(((wCurYear - 4) % 60) % 10)+1] .. cDiZhi[(((wCurYear - 4) % 60) % 12) + 1] .. ')年'
    --szNongli,"%s(%s%s)年",szShuXiang,cTianGan[((wCurYear - 4) % 60) % 10],cDiZhi[((wCurYear - 4) % 60) % 12]);

    --生成农历月、日 ==> wNongliDay--*/
    if wCurMonth < 1 then
        szNongliDay =  "闰" .. cMonName[(-1 * wCurMonth) + 1]
    else
        szNongliDay = cMonName[wCurMonth+1]
    end

    szNongliDay =  szNongliDay .. "月" .. cDayName[wCurDay+1]
    return szNongli .. szNongliDay
end



--- date/time translator
word=0  --单字优先模式参数

function date_translator(input, seg)
	  --普通日期1，类似2020年02月04日
      date1=os.date("%Y年%m月%d日")
	  date_y=os.date("%Y") --取年
	  date_m=os.date("%m") --取月
	  date_d=os.date("%d") --取日

	  --普通日期2，类似2020年2月4日
	  num_m=os.date("%m")+0
	  num_m1=math.modf(num_m)
	  num_d=os.date("%d")+0 
	  num_d1=math.modf(num_d)
	  date2=os.date("%Y年")..tostring(num_m1).."月"..tostring(num_d1).."日"

	  --报时，类似2020-06-06㊅06:06:06
	  date5=os.date("%Y-%m-%d")..os.date(day_w2)..os.date("%H:%M:%S")

	  --报时，类似2020年6月6日星期六6点6分6秒
	  date4=os.date(date2)..os.date(day_w1)..os.date("%H点%M分%S秒")

	  --报时，类似Sat Jun  6 06:06:06 2020
	  date7=os.date(ChineseDate)

	  --大写日期，类似二〇二〇年十一月二十六日
	 date_y=date_y:gsub("%d",{
       ["1"]="一",
       ["2"]="二",
       ["3"]="三",
       ["4"]="四",
       ["5"]="五",
       ["6"]="六",
       ["7"]="七",
       ["8"]="八",
       ["9"]="九",
       ["0"]="〇",
      })
	 date_y=date_y.."年"
	 
	 date_m=date_m:gsub("%d",{
       ["1"]="一",
       ["2"]="二",
       ["3"]="三",
       ["4"]="四",
       ["5"]="五",
       ["6"]="六",
       ["7"]="七",
       ["8"]="八",
       ["9"]="九",
       ["0"]="",
      })
	 date_m=date_m.."月"
	 if num_m1==10 then date_m="十月" end
	 if num_m1==11 then date_m="十一月" end
	 if num_m1==12 then date_m="十二月" end
	 
	 date_d=date_d:gsub("%d",{
       ["1"]="一",
       ["2"]="二",
       ["3"]="三",
       ["4"]="四",
       ["5"]="五",
       ["6"]="六",
       ["7"]="七",
       ["8"]="八",
       ["9"]="九",
       ["0"]="",
      })
	 date_d=date_d.."日"
	 date3=date_y..date_m..date_d
	 
	  --星期
	 day_w=os.date("%w")
	 day_w1=""
	if day_w=="0" then day_w1="星期日" end
	if day_w=="1" then day_w1="星期一" end
	if day_w=="2" then day_w1="星期二" end
	if day_w=="3" then day_w1="星期三" end
	if day_w=="4" then day_w1="星期四" end
	if day_w=="5" then day_w1="星期五" end
	if day_w=="6" then day_w1="星期六" end

	  --星期
	 day_w3=os.date("%w")
	 day_w2=""
	if day_w3=="0" then day_w2="㊐" end
	if day_w3=="1" then day_w2="㊀" end
	if day_w3=="2" then day_w2="㊁" end
	if day_w3=="3" then day_w2="㊂" end
	if day_w3=="4" then day_w2="㊃" end
	if day_w3=="5" then day_w2="㊄" end
	if day_w3=="6" then day_w2="㊅" end


   if (input == "oxz" or input == "oxz") then
      yield(Candidate("date", seg.start, seg._end, date5, ""))
      yield(Candidate("date", seg.start, seg._end, date4, ""))
   end
   if (input == "sj" or input == "osj") then
      yield(Candidate("time", seg.start, seg._end, os.date("%H:%M:%S"), ""))
      yield(Candidate("time", seg.start, seg._end, os.date("%H点%M分%S秒"), ""))
--      yield(Candidate("time", seg.start, seg._end, os.date("%H:%M"), ""))
--      yield(Candidate("time", seg.start, seg._end, os.date("%H点%M分"), ""))
   end
   if (input == "rq" or input == "orq") then
      yield(Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d "), ""))
--      yield(Candidate("date", seg.start, seg._end, os.date("%Y/%m/%d"), ""))
--      yield(Candidate("date", seg.start, seg._end, os.date("%Y%m%d"), ""))
--      yield(Candidate("date", seg.start, seg._end, date1, ""))   #这种单位数日期前面添加前缀0的格式为国家公文标准明令禁止的，不建议使用
      yield(Candidate("date", seg.start, seg._end, date2, ""))
--      yield(Candidate("date", seg.start, seg._end, date3, ""))
   end
   if (input == "xq" or input == "oxq") then
      yield(Candidate("date", seg.start, seg._end, day_w1, ""))
   end
   if (input == "now") then
      yield(Candidate("date", seg.start, seg._end, date7, ""))
   end
   if (input == "/qwer") then
      -- Candidate(type, start, end, text, comment)
	   if (word == 0) then
	    word=1
        yield(Candidate("date", seg.start, seg._end, "单字优先模式启用", " 配置"))
	   else
	    word=0
        yield(Candidate("date", seg.start, seg._end, "单字优先模式关闭", " 配置"))
	    end
   end
end


function Lunar_calendar_translator(input, seg)
	  --农历
	 Lunar_calendar=toNyear(os.date("%Y"),os.date("%m"),os.date("%d"))
	 Lunar_calendar=Lunar_calendar:gsub("年","农历年")
   if (input == "onl" or input == "onl") then
      yield(Candidate("date", seg.start, seg._end, Lunar_calendar, ""))
   end
end

--[[
function time_translator(input, seg)
   if (input == "/time") then
      yield(Candidate("time", seg.start, seg._end, os.date("%H:%M:%S"), " 时间"))
   end
end
]]

--[[
--- charset filter
charset = {
   ["GBK"] = { first = 0x4e00, last = 0x9fff },
   ["CJK-A"] = { first = 0x3400, last = 0x4dbf },
   ["CJK-B"] = { first = 0x20000, last = 0x2a6dd },
   ["CJK-C"] = { first = 0x2a700, last = 0x2b734 },
   ["CJK-D"] = { first = 0x2b740, last = 0x2b81d },
   ["CJK-E"] = { first = 0x2b820, last = 0x2cea1 },
   ["CJK-F"] = { first = 0x2ceb0, last = 0x2ebe0 },
   ["CJK-G"] = { first = 0x30000, last = 0x3134a },
   ["拉丁补"] = { first = 0x0080, last = 0x00ff },
   ["拉丁语"] = { first = 0x0000, last = 0x007f },
   ["私用区"] = { first = 0xe000, last = 0xf8ff },
   ["私用补"] = { first = 0x100000, last = 0x10ffff },
   ["符号和象形文字扩展-A"] = { first = 0x1fa70, last = 0x1faff },
   ["中日韩兼容表意文字增补"] = { first = 0x2f800, last = 0x2fa1f },
   ["楔形文字数字和标点符号"] = { first = 0x12400, last = 0x1247f },
   ["高加索阿尔巴尼亚语言"] = { first = 0x10530, last = 0x1056f },
   ["统一加拿大原住民音节扩展"] = { first = 0x18b0, last = 0x18ff },
   ["补私用-A"] = { first = 0xf0000, last = 0xffff },
   ["补充符号和象形文字"] = { first = 0x1f900, last = 0x1f9ff },
   ["阿拉伯字母数字符号"] = { first = 0x1ee00, last = 0x1eeff },
   ["杂项符号和象形文字"] = { first = 0x1f300, last = 0x1f5ff },
   ["日文假名扩展-A"] = { first = 0x1b100, last = 0x1b12f },
   ["安纳托利亚象形文字"] = { first = 0x14400, last = 0x1467f },
   ["表意符号和标点符号"] = { first = 0x16fe0, last = 0x16fff },
   ["线形文字B表意文字"] = { first = 0x10080, last = 0x100ff },
   ["阿拉伯语表现形式-A"] = { first = 0xfb50, last = 0xfdff },
   ["方框绘制字符(制表符)"] = { first = 0x2500, last = 0x257f },
   ["札那巴札尔方形字母"] = { first = 0x11a00, last = 0x11a4f },
   ["阿拉伯语表现形式-B"] = { first = 0xfe70, last = 0xfeff },
   ["斐斯托斯圆盘古文字"] = { first = 0x101d0, last = 0x101ff },
   ["埃及圣书体格式控制"] = { first = 0x13430, last = 0x1343f },
   ["奥斯曼西亚克数字"] = { first = 0x1ed00, last = 0x1ed4f },
   ["小型日文假名扩展"] = { first = 0x1b130, last = 0x1b16f },
   ["带圈表意文字补充"] = { first = 0x1f200, last = 0x1f2ff },
   ["带圈字母数字补充"] = { first = 0x1f100, last = 0x1f1ff },
   ["格拉哥里字母增补"] = { first = 0x1e000, last = 0x1e02f },
   ["尼亚坑普阿绰苗文"] = { first = 0x1e100, last = 0x1e14f },
   ["统一加拿大原住民音节"] = { first = 0x1400, last = 0x167f },
   ["中日韩带圈字符及月份"] = { first = 0x3200, last = 0x32ff },
   ["哈乃斐罗兴亚文字"] = { first = 0x10d00, last = 0x10d3f },
   ["中日韩符号和标点符号"] = { first = 0x3000, last = 0x303f },
   ["阿姆哈拉语扩展-A"] = { first = 0xab00, last = 0xab2f },
   ["马萨拉姆贡德文字"] = { first = 0x11d00, last = 0x11d5f },
   ["变化选择器补充"] = { first = 0xe0100, last = 0xe01ef },
   ["速记格式控制符"] = { first = 0x1bca0, last = 0x1bcaf },
   ["追加箭头-C"] = { first = 0x1f800, last = 0x1f8ff },
   ["拜占庭音乐符号"] = { first = 0x1d000, last = 0x1d0ff },
   ["交通和地图符号"] = { first = 0x1f680, last = 0x1f6ff },
   ["古希腊音乐记号"] = { first = 0x1d200, last = 0x1d24f },
   ["字母和数字符号"] = { first = 0x1d400, last = 0x1d7ff },
   ["印度西亚格数字"] = { first = 0x1ec70, last = 0x1ecbf },
   ["结合符号的变音符号"] = { first = 0x20d0, last = 0x20ff },
   ["中日韩汉字部首补充"] = { first = 0x2e80, last = 0x2eff },
   ["古北部阿拉伯语"] = { first = 0x10a80, last = 0x10a9f },
   ["古南部阿拉伯语"] = { first = 0x10a60, last = 0x10a7f },
   ["麦罗埃文草体字"] = { first = 0x109a0, last = 0x109ff },
   ["奥斯曼亚字母"] = { first = 0x10480, last = 0x104af },
   ["塞浦路斯语音节"] = { first = 0x10800, last = 0x1083f },
   ["爱尔巴桑字母"] = { first = 0x10500, last = 0x1052f },
   ["德瑟雷特字母"] = { first = 0x10400, last = 0x1044f },
   ["杂项数学符号-A"] = { first = 0x27c0, last = 0x27ef },
   ["杂项数学符号-B"] = { first = 0x2980, last = 0x29ff },
   ["科普特闰余数字"] = { first = 0x102e0, last = 0x102ff },
   ["西里尔文扩展-B"] = { first = 0xa640, last = 0xa69f },
   ["西里尔文扩展-A"] = { first = 0x2de0, last = 0x2dff },
   ["韩文字母扩展-A"] = { first = 0xa960, last = 0xa97f },
   ["中日韩兼容表意文字"] = { first = 0xf900, last = 0xfaff },
   ["韩文字母扩展-B"] = { first = 0xd7b0, last = 0xd7ff },
   ["梅德法伊德林文"] = { first = 0x16e40, last = 0x16e9f },
   ["线形文字B音节"] = { first = 0x10000, last = 0x1007f },
   ["巴姆穆文字增补"] = { first = 0x16800, last = 0x16a3f },
   ["𑙠蒙古语增补"] = { first = 0x11660, last = 0x1167f },
   ["古僧伽罗文数字"] = { first = 0x111e0, last = 0x111ff },
   ["西里尔文扩展-C"] = { first = 0x1c80, last = 0x1c8f },
   ["麦罗埃象形文字"] = { first = 0x10980, last = 0x1099f },
   ["日文假名补充"] = { first = 0x1b000, last = 0x1b0ff },
   ["阿德拉姆字母"] = { first = 0x1e900, last = 0x1e95f },
   ["门德基卡库文"] = { first = 0x1e800, last = 0x1e8df },
   ["萨顿书写符号"] = { first = 0x1d800, last = 0x1daaf },
   ["几何图形扩展"] = { first = 0x1f780, last = 0x1f7ff },
   ["表意文字描述字符"] = { first = 0x2ff0, last = 0x2fff },
   ["巴尔米拉字母"] = { first = 0x10860, last = 0x1087f },
   ["拉丁语扩展-A"] = { first = 0x0100, last = 0x017f },
   ["乌加里特语"] = { first = 0x10380, last = 0x1039f },
   ["古代楔形文字"] = { first = 0x12480, last = 0x1254f },
   ["易经六十四卦符号"] = { first = 0x4dc0, last = 0x4dff },
   ["萧伯纳字母"] = { first = 0x10450, last = 0x1047f },
   ["泰米尔文增补"] = { first = 0x11fc0, last = 0x11fff },
   ["贡贾拉贡德文"] = { first = 0x11d60, last = 0x11daf },
   ["拉丁语扩展-B"] = { first = 0x0180, last = 0x024f },
   ["欧塞奇字母"] = { first = 0x104b0, last = 0x104ff },
   ["拉丁语扩展-D"] = { first = 0xa720, last = 0xa7ff },
   ["希腊语和科普特语"] = { first = 0x0370, last = 0x03ff },
   ["结合变音符号扩展"] = { first = 0x1ab0, last = 0x1aff },
   ["缅甸语扩展-B"] = { first = 0xa9e0, last = 0xa9ff },
   ["索拉僧平文字"] = { first = 0x110d0, last = 0x110ff },
   ["鲁米数字符号"] = { first = 0x10e60, last = 0x10e7f },
   ["线性文字A"] = { first = 0x10600, last = 0x1077f },
   ["古匈牙利字母"] = { first = 0x10c80, last = 0x10cff },
   ["阿拉伯语扩展-A"] = { first = 0x08a0, last = 0x08ff },
   ["常用印度数字形式"] = { first = 0xa830, last = 0xa83f },
   ["诗篇巴列维文"] = { first = 0x10b80, last = 0x10baf },
   ["碑刻巴列维文"] = { first = 0x10b60, last = 0x10b7f },
   ["碑刻帕提亚文"] = { first = 0x10b40, last = 0x10b5f },
   ["阿维斯陀字母"] = { first = 0x10b00, last = 0x10b3f },
   ["结合变音标记增补"] = { first = 0x1dc0, last = 0x1dff },
   ["帝国阿拉姆語"] = { first = 0x10840, last = 0x1085f },
   ["古意大利字母"] = { first = 0x10300, last = 0x1032f },
   ["拉丁语扩展-C"] = { first = 0x2c60, last = 0x2c7f },
   ["缅甸语扩展-A"] = { first = 0xaa60, last = 0xaa7f },
   ["拉丁文扩展-E"] = { first = 0xab30, last = 0xab6f },
   ["多米诺骨牌"] = { first = 0x1f030, last = 0x1f09f },
   ["太玄经符号"] = { first = 0x1d300, last = 0x1d35f },
   ["炼金术符号"] = { first = 0x1f700, last = 0x1f77f },
   ["杜普雷速记"] = { first = 0x1bc00, last = 0x1bc9f },
   ["西夏文部首"] = { first = 0x18800, last = 0x18aff },
   ["拉丁语扩展附加"] = { first = 0x1e00, last = 0x1eff },
   ["封闭式字母数字"] = { first = 0x2460, last = 0x24ff },
   ["补充箭头-A"] = { first = 0x27f0, last = 0x27ff },
   ["国际音标扩展"] = { first = 0x0250, last = 0x02af },
   ["间距修饰字符"] = { first = 0x02b0, last = 0x02ff },
   ["组合变音标记"] = { first = 0x0300, last = 0x036f },
   ["补充箭头-B"] = { first = 0x2900, last = 0x297f },
   ["补充数学运算符"] = { first = 0x2a00, last = 0x2aff },
   ["其他符号和箭头"] = { first = 0x2b00, last = 0x2bff },
   ["格鲁吉亚文增补"] = { first = 0x2d00, last = 0x2d2f },
   ["阿姆哈拉语扩展"] = { first = 0x2d80, last = 0x2ddf },
   ["中日韩汉语笔画"] = { first = 0x31c0, last = 0x31ef },
   ["腓尼基字母"] = { first = 0x10900, last = 0x1091f },
   ["曼尼普尔语扩展"] = { first = 0xaae0, last = 0xaaff },
   ["全角和半角字符"] = { first = 0xff00, last = 0xffef },
   ["爱琴海数字"] = { first = 0x10100, last = 0x1013f },
   ["古希腊数字"] = { first = 0x10140, last = 0x1018f },
   ["古罗马符号"] = { first = 0x10190, last = 0x101cf },
   ["卡里亚字母"] = { first = 0x102a0, last = 0x102df },
   ["古彼尔姆文"] = { first = 0x10350, last = 0x1037f },
   ["古波斯语"] = { first = 0x103a0, last = 0x103df },
   ["纳巴泰字母"] = { first = 0x10880, last = 0x108af },
   ["中日韩兼容形式"] = { first = 0xfe30, last = 0xfe4f },
   ["哈特兰字母"] = { first = 0x108e0, last = 0x108ff },
   ["古代突厥語"] = { first = 0x10c00, last = 0x10c4f },
   ["古粟特字母"] = { first = 0x10f00, last = 0x10f2f },
   ["以利买字母"] = { first = 0x10fe0, last = 0x10fff },
   ["马哈雅尼文"] = { first = 0x11150, last = 0x1117f },
   ["库达瓦迪文"] = { first = 0x112b0, last = 0x112ff },
   ["瓦兰齐地文"] = { first = 0x118a0, last = 0x118ff },
   ["索永布字母"] = { first = 0x11a50, last = 0x11aaf },
   ["拜克舒基文"] = { first = 0x11c00, last = 0x11c6f },
   ["埃及圣书体"] = { first = 0x13000, last = 0x1342f },
   ["巴萨哇文字"] = { first = 0x16ad0, last = 0x16aff },
   ["柏格理苗文"] = { first = 0x16f00, last = 0x16f9f },
   ["阿姆哈拉语增补"] = { first = 0x1380, last = 0x139f },
   ["提尔胡塔文"] = { first = 0x11480, last = 0x114df },
   ["格鲁吉亚文扩展"] = { first = 0x1c90, last = 0x1cbf },
   ["表情符号"] = { first = 0x1f600, last = 0x1f64f },
   ["玛雅数字"] = { first = 0x1d2e0, last = 0x1d2ff },
   ["装饰符号"] = { first = 0x1f650, last = 0x1f67f },
   ["音乐符号"] = { first = 0x1d100, last = 0x1d1ff },
   ["象棋符号"] = { first = 0x1fa00, last = 0x1fa6f },
   ["文乔字母"] = { first = 0x1e2c0, last = 0x1e2ff },
   ["杂项技术符号"] = { first = 0x2300, last = 0x23ff },
   ["数字形式符号"] = { first = 0x2150, last = 0x218f },
   ["悉昙文字"] = { first = 0x11580, last = 0x115ff },
   ["切罗基语增补"] = { first = 0xab70, last = 0xabbf },
   ["西里尔文增补"] = { first = 0x0500, last = 0x052f },
   ["塔克里文"] = { first = 0x11680, last = 0x116cf },
   ["补充标点符号"] = { first = 0x2e00, last = 0x2e7f },
   ["阿洪姆语"] = { first = 0x11700, last = 0x1173f },
   ["小型变体形式"] = { first = 0xfe50, last = 0xfe6f },
   ["阿拉伯语增补"] = { first = 0x0750, last = 0x077f },
   ["索拉什特拉语"] = { first = 0xa880, last = 0xa8df },
   ["西非书面文字"] = { first = 0x07c0, last = 0x07ff },
   ["撒玛利亚字母"] = { first = 0x0800, last = 0x083f },
   ["婆罗米文"] = { first = 0x11000, last = 0x1107f },
   ["叙利亚文增补"] = { first = 0x0860, last = 0x086f },
   ["粟特字母"] = { first = 0x10f30, last = 0x10f6f },
   ["多格拉语"] = { first = 0x11800, last = 0x1184f },
   ["桑塔利语字母"] = { first = 0x1c50, last = 0x1c7f },
   ["南迪城文"] = { first = 0x119a0, last = 0x119ff },
   ["吕基亚语"] = { first = 0x10280, last = 0x1029f },
   ["包钦豪文"] = { first = 0x11ac0, last = 0x11aff },
   ["光学字符识别"] = { first = 0x2440, last = 0x245f },
   ["马拉雅拉姆语"] = { first = 0x0d00, last = 0x0d7f },
   ["吕底亚语"] = { first = 0x10920, last = 0x1093f },
   ["望加锡文"] = { first = 0x11ee0, last = 0x11eff },
   ["国际音标扩展"] = { first = 0x1d00, last = 0x1d7f },
   ["国际音标增补"] = { first = 0x1d80, last = 0x1dbf },
   ["摩尼字母"] = { first = 0x10ac0, last = 0x10aff },
   ["楔形文字"] = { first = 0x12000, last = 0x123ff },
   ["格拉哥里字母"] = { first = 0x2c00, last = 0x2c5f },
   ["塔格巴努亚文"] = { first = 0x1760, last = 0x177f },
   ["哥特字母"] = { first = 0x10330, last = 0x1034f },
   ["帕哈苗文"] = { first = 0x16b00, last = 0x16b8f },
   ["一般标点符号"] = { first = 0x2000, last = 0x206f },
   ["注音符号扩展"] = { first = 0x31a0, last = 0x31bf },
   ["韩文兼容字母"] = { first = 0x3130, last = 0x318f },
   ["字母连写形式"] = { first = 0xfb00, last = 0xfb4f },
   ["组合用半符号"] = { first = 0xfe20, last = 0xfe2f },
   ["查克马语"] = { first = 0x11100, last = 0x1114f },
   ["夏拉达文"] = { first = 0x11180, last = 0x111df },
   ["木尔坦文"] = { first = 0x11280, last = 0x112af },
   ["古兰塔文"] = { first = 0x11300, last = 0x1137f },
   ["尼瓦尔语"] = { first = 0x11400, last = 0x1147f },
   ["扑克牌"] = { first = 0x1f0a0, last = 0x1f0ff },
   ["麻将牌"] = { first = 0x1f000, last = 0x1f02f },
   ["凯提文"] = { first = 0x11080, last = 0x110cf },
   ["日文平假名"] = { first = 0x3040, last = 0x309f },
   ["亚美尼亚语"] = { first = 0x0530, last = 0x058f },
   ["上标和下标"] = { first = 0x2070, last = 0x209f },
   ["提非纳字母"] = { first = 0x2d30, last = 0x2d7f },
   ["古吉拉特語"] = { first = 0x0a80, last = 0x0aff },
   ["天城文扩展"] = { first = 0xa8e0, last = 0xa8ff },
   ["巽他文增补"] = { first = 0x1cc0, last = 0x1ccf },
   ["格鲁吉亚语"] = { first = 0x10a0, last = 0x10ff },
   ["阿姆哈拉语"] = { first = 0x1200, last = 0x137f },
   ["希腊语扩展"] = { first = 0x1f00, last = 0x1fff },
   ["类字母符号"] = { first = 0x2100, last = 0x214f },
   ["和卓文"] = { first = 0x11200, last = 0x1124f },
   ["中日韩兼容"] = { first = 0x3300, last = 0x33ff },
   ["佉卢文"] = { first = 0x10a00, last = 0x10a5f },
   ["片假名扩展"] = { first = 0x31f0, last = 0x31ff },
   ["声调修饰符"] = { first = 0xa700, last = 0xa71f },
   ["西夏文"] = { first = 0x17000, last = 0x187ff },
   ["玛钦文"] = { first = 0x11c70, last = 0x11cbf },
   ["数学运算符"] = { first = 0x2200, last = 0x22ff },
   ["日文片假名"] = { first = 0x30a0, last = 0x30ff },
   ["曼尼普尔语"] = { first = 0xabc0, last = 0xabff },
   ["锡尔赫特文"] = { first = 0xa800, last = 0xa82f },
   ["默禄文"] = { first = 0x16a40, last = 0x16a6f },
   ["变体选择器"] = { first = 0xfe00, last = 0xfe0f },
   ["莫迪文"] = { first = 0x11600, last = 0x1165f },
   ["算筹"] = { first = 0x1d360, last = 0x1d37f },
   ["女书"] = { first = 0x1b170, last = 0x1b2ff },
   ["标签"] = { first = 0xe0000, last = 0xe007f },
   ["古木基文"] = { first = 0x0a00, last = 0x0a7f },
   ["货币符号"] = { first = 0x20a0, last = 0x20cf },
   ["吠陀扩展"] = { first = 0x1cd0, last = 0x1cff },
   ["彝族部首"] = { first = 0xa490, last = 0xa4cf },
   ["箭头符号"] = { first = 0x2190, last = 0x21ff },
   ["巴塔克语"] = { first = 0x1bc0, last = 0x1bff },
   ["彝族音节"] = { first = 0xa000, last = 0xa48f },
   ["康熙部首"] = { first = 0x2f00, last = 0x2fdf },
   ["西里尔文"] = { first = 0x0400, last = 0x04ff },
   ["希伯来语"] = { first = 0x0590, last = 0x05ff },
   ["阿拉伯语"] = { first = 0x0600, last = 0x06ff },
   ["巴姆穆语"] = { first = 0xa6a0, last = 0xa6ff },
   ["叙利亚文"] = { first = 0x0700, last = 0x074f },
   ["它拿字母"] = { first = 0x0780, last = 0x07bf },
   ["奥里亚语"] = { first = 0x0b00, last = 0x0b7f },
   ["孟加拉语"] = { first = 0x0980, last = 0x09ff },
   ["泰米尔语"] = { first = 0x0b80, last = 0x0bff },
   ["泰卢固语"] = { first = 0x0c00, last = 0x0c7f },
   ["卡纳达语"] = { first = 0x0c80, last = 0x0cff },
   ["僧伽罗语"] = { first = 0x0d80, last = 0x0dff },
   ["韩文字母"] = { first = 0x1100, last = 0x11ff },
   ["切罗基语"] = { first = 0x13a0, last = 0x13ff },
   ["高棉符号"] = { first = 0x19e0, last = 0x19ff },
   ["汉文训读"] = { first = 0x3190, last = 0x319f },
   ["竖排形式"] = { first = 0xfe10, last = 0xfe1f },
   ["特殊字符"] = { first = 0xfff0, last = 0xffff },
   ["八思巴字"] = { first = 0xa840, last = 0xa87f },
   ["德宏傣文"] = { first = 0x1950, last = 0x197f },
   ["科普特文"] = { first = 0x2c80, last = 0x2cff },
   ["克耶字母"] = { first = 0xa900, last = 0xa92f },
   ["装饰符号"] = { first = 0x2700, last = 0x27bf },
   ["杂项符号"] = { first = 0x2600, last = 0x26ff },
   ["布希德文"] = { first = 0x1740, last = 0x175f },
   ["哈努诺文"] = { first = 0x1720, last = 0x173f },
   ["几何形状"] = { first = 0x25a0, last = 0x25ff },
   ["韩文音节"] = { first = 0xac00, last = 0xd7af },
   ["方块元素"] = { first = 0x2580, last = 0x259f },
   ["他加禄语"] = { first = 0x1700, last = 0x171f },
   ["卢恩字母"] = { first = 0x16a0, last = 0x16ff },
   ["控制图片"] = { first = 0x2400, last = 0x243f },
   ["欧甘字母"] = { first = 0x1680, last = 0x169f },
   ["绒巴文"] = { first = 0x1c00, last = 0x1c4f },
   ["拉让语"] = { first = 0xa930, last = 0xa95f },
   ["曼达文"] = { first = 0x0840, last = 0x085f },
   ["巽他语"] = { first = 0x1b80, last = 0x1bbf },
   ["瓦伊语"] = { first = 0xa500, last = 0xa63f },
   ["傣仂语"] = { first = 0x1980, last = 0x19df },
   ["林布语"] = { first = 0x1900, last = 0x194f },
   ["巴厘语"] = { first = 0x1b00, last = 0x1b7f },
   ["蒙古语"] = { first = 0x1800, last = 0x18af },
   ["高棉语"] = { first = 0x1780, last = 0x17ff },
   ["老傣文"] = { first = 0x1a20, last = 0x1aaf },
   ["缅甸语"] = { first = 0x1000, last = 0x109f },
   ["老挝语"] = { first = 0x0e80, last = 0x0eff },
   ["傈僳语"] = { first = 0xa4d0, last = 0xa4ff },
   ["爪哇语"] = { first = 0xa980, last = 0xa9df },
   ["布吉语"] = { first = 0x1a00, last = 0x1a1f },
   ["占语"] = { first = 0xaa00, last = 0xaa5f },
   ["梵文"] = { first = 0x0900, last = 0x097f },
   ["傣文"] = { first = 0xaa80, last = 0xaadf },
   ["注音"] = { first = 0x3100, last = 0x312f },
   ["高位专用替代"] = { first = 0xdb80, last = 0xdbff },
   ["藏文"] = { first = 0x0f00, last = 0x0fff },
   ["泰语"] = { first = 0x0e00, last = 0x0e7f },
   ["盲文"] = { first = 0x2800, last = 0x28ff },
   ["低位替代区"] = { first = 0xdc00, last = 0xdfff },
   ["高位替代区"] = { first = 0xd800, last = 0xdb7f },
   ["Compat"] = { first = 0x2F800, last = 0x2FA1F } }

function exists(single_filter, text)
  for i in utf8.codes(text) do
     local c = utf8.codepoint(text, i)
     if (not single_filter(c)) then
	return false
     end
  end
  return true
end

function is_charset(s)
   return function (c)
      return c >= charset[s].first and c <= charset[s].last
   end
end

function is_cjk_ext(c)
   return is_charset("CJK-A")(c) or is_charset("CJK-B")(c) or
      is_charset("CJK-C")(c) or is_charset("CJK-D")(c) or
      is_charset("CJK-E")(c) or is_charset("CJK-F")(c) or
      is_charset("CJK-G")(c) or is_charset("拉丁补")(c) or
      is_charset("拉丁语")(c) or is_charset("私用区")(c) or
      is_charset("私用补")(c) or is_charset("符号和象形文字扩展-A")(c) or
      is_charset("中日韩兼容表意文字增补")(c) or is_charset("楔形文字数字和标点符号")(c) or
      is_charset("高加索阿尔巴尼亚语言")(c) or is_charset("统一加拿大原住民音节扩展")(c) or
      is_charset("补私用-A")(c) or is_charset("补充符号和象形文字")(c) or
      is_charset("阿拉伯字母数字符号")(c) or is_charset("杂项符号和象形文字")(c) or
      is_charset("日文假名扩展-A")(c) or is_charset("安纳托利亚象形文字")(c) or
      is_charset("表意符号和标点符号")(c) or is_charset("线形文字B表意文字")(c) or
      is_charset("阿拉伯语表现形式-A")(c) or is_charset("方框绘制字符(制表符)")(c) or
      is_charset("札那巴札尔方形字母")(c) or is_charset("阿拉伯语表现形式-B")(c) or
      is_charset("斐斯托斯圆盘古文字")(c) or is_charset("埃及圣书体格式控制")(c) or
      is_charset("奥斯曼西亚克数字")(c) or is_charset("小型日文假名扩展")(c) or
      is_charset("带圈表意文字补充")(c) or is_charset("带圈字母数字补充")(c) or
      is_charset("格拉哥里字母增补")(c) or is_charset("尼亚坑普阿绰苗文")(c) or
      is_charset("统一加拿大原住民音节")(c) or is_charset("中日韩带圈字符及月份")(c) or
      is_charset("哈乃斐罗兴亚文字")(c) or is_charset("中日韩符号和标点符号")(c) or
      is_charset("阿姆哈拉语扩展-A")(c) or is_charset("马萨拉姆贡德文字")(c) or
      is_charset("变化选择器补充")(c) or is_charset("速记格式控制符")(c) or
      is_charset("追加箭头-C")(c) or is_charset("拜占庭音乐符号")(c) or
      is_charset("交通和地图符号")(c) or is_charset("古希腊音乐记号")(c) or
      is_charset("字母和数字符号")(c) or is_charset("印度西亚格数字")(c) or
      is_charset("结合符号的变音符号")(c) or is_charset("中日韩汉字部首补充")(c) or
      is_charset("古北部阿拉伯语")(c) or is_charset("古南部阿拉伯语")(c) or
      is_charset("麦罗埃文草体字")(c) or is_charset("奥斯曼亚字母")(c) or
      is_charset("塞浦路斯语音节")(c) or is_charset("爱尔巴桑字母")(c) or
      is_charset("德瑟雷特字母")(c) or is_charset("杂项数学符号-A")(c) or
      is_charset("杂项数学符号-B")(c) or is_charset("科普特闰余数字")(c) or
      is_charset("西里尔文扩展-B")(c) or is_charset("西里尔文扩展-A")(c) or
      is_charset("韩文字母扩展-A")(c) or is_charset("中日韩兼容表意文字")(c) or
      is_charset("韩文字母扩展-B")(c) or is_charset("梅德法伊德林文")(c) or
      is_charset("线形文字B音节")(c) or is_charset("巴姆穆文字增补")(c) or
      is_charset("𑙠蒙古语增补")(c) or is_charset("古僧伽罗文数字")(c) or
      is_charset("西里尔文扩展-C")(c) or is_charset("麦罗埃象形文字")(c) or
      is_charset("日文假名补充")(c) or is_charset("阿德拉姆字母")(c) or
      is_charset("门德基卡库文")(c) or is_charset("萨顿书写符号")(c) or
      is_charset("几何图形扩展")(c) or is_charset("表意文字描述字符")(c) or
      is_charset("巴尔米拉字母")(c) or is_charset("拉丁语扩展-A")(c) or
      is_charset("乌加里特语")(c) or is_charset("古代楔形文字")(c) or
      is_charset("易经六十四卦符号")(c) or is_charset("萧伯纳字母")(c) or
      is_charset("泰米尔文增补")(c) or is_charset("贡贾拉贡德文")(c) or
      is_charset("拉丁语扩展-B")(c) or is_charset("欧塞奇字母")(c) or
      is_charset("拉丁语扩展-D")(c) or is_charset("希腊语和科普特语")(c) or
      is_charset("结合变音符号扩展")(c) or is_charset("缅甸语扩展-B")(c) or
      is_charset("索拉僧平文字")(c) or is_charset("鲁米数字符号")(c) or
      is_charset("线性文字A")(c) or is_charset("古匈牙利字母")(c) or
      is_charset("阿拉伯语扩展-A")(c) or is_charset("常用印度数字形式")(c) or
      is_charset("诗篇巴列维文")(c) or is_charset("碑刻巴列维文")(c) or
      is_charset("碑刻帕提亚文")(c) or is_charset("阿维斯陀字母")(c) or
      is_charset("结合变音标记增补")(c) or is_charset("帝国阿拉姆語")(c) or
      is_charset("古意大利字母")(c) or is_charset("拉丁语扩展-C")(c) or
      is_charset("缅甸语扩展-A")(c) or is_charset("拉丁文扩展-E")(c) or
      is_charset("多米诺骨牌")(c) or is_charset("太玄经符号")(c) or
      is_charset("炼金术符号")(c) or is_charset("杜普雷速记")(c) or
      is_charset("西夏文部首")(c) or is_charset("拉丁语扩展附加")(c) or
      is_charset("封闭式字母数字")(c) or is_charset("补充箭头-A")(c) or
      is_charset("国际音标扩展")(c) or is_charset("间距修饰字符")(c) or
      is_charset("组合变音标记")(c) or is_charset("补充箭头-B")(c) or
      is_charset("补充数学运算符")(c) or is_charset("其他符号和箭头")(c) or
      is_charset("格鲁吉亚文增补")(c) or is_charset("阿姆哈拉语扩展")(c) or
      is_charset("中日韩汉语笔画")(c) or is_charset("腓尼基字母")(c) or
      is_charset("曼尼普尔语扩展")(c) or is_charset("全角和半角字符")(c) or
      is_charset("爱琴海数字")(c) or is_charset("古希腊数字")(c) or
      is_charset("古罗马符号")(c) or is_charset("卡里亚字母")(c) or
      is_charset("古彼尔姆文")(c) or is_charset("古波斯语")(c) or
      is_charset("纳巴泰字母")(c) or is_charset("中日韩兼容形式")(c) or
      is_charset("哈特兰字母")(c) or is_charset("古代突厥語")(c) or
      is_charset("古粟特字母")(c) or is_charset("以利买字母")(c) or
      is_charset("马哈雅尼文")(c) or is_charset("库达瓦迪文")(c) or
      is_charset("瓦兰齐地文")(c) or is_charset("索永布字母")(c) or
      is_charset("拜克舒基文")(c) or is_charset("埃及圣书体")(c) or
      is_charset("巴萨哇文字")(c) or is_charset("柏格理苗文")(c) or
      is_charset("阿姆哈拉语增补")(c) or is_charset("提尔胡塔文")(c) or
      is_charset("格鲁吉亚文扩展")(c) or is_charset("表情符号")(c) or
      is_charset("玛雅数字")(c) or is_charset("装饰符号")(c) or
      is_charset("音乐符号")(c) or is_charset("象棋符号")(c) or
      is_charset("文乔字母")(c) or is_charset("杂项技术符号")(c) or
      is_charset("数字形式符号")(c) or is_charset("悉昙文字")(c) or
      is_charset("切罗基语增补")(c) or is_charset("西里尔文增补")(c) or
      is_charset("塔克里文")(c) or is_charset("补充标点符号")(c) or
      is_charset("阿洪姆语")(c) or is_charset("小型变体形式")(c) or
      is_charset("阿拉伯语增补")(c) or is_charset("索拉什特拉语")(c) or
      is_charset("西非书面文字")(c) or is_charset("撒玛利亚字母")(c) or
      is_charset("婆罗米文")(c) or is_charset("叙利亚文增补")(c) or
      is_charset("粟特字母")(c) or is_charset("多格拉语")(c) or
      is_charset("桑塔利语字母")(c) or is_charset("南迪城文")(c) or
      is_charset("吕基亚语")(c) or is_charset("包钦豪文")(c) or
      is_charset("光学字符识别")(c) or is_charset("马拉雅拉姆语")(c) or
      is_charset("吕底亚语")(c) or is_charset("望加锡文")(c) or
      is_charset("国际音标扩展")(c) or is_charset("国际音标增补")(c) or
      is_charset("摩尼字母")(c) or is_charset("楔形文字")(c) or
      is_charset("格拉哥里字母")(c) or is_charset("塔格巴努亚文")(c) or
      is_charset("哥特字母")(c) or is_charset("帕哈苗文")(c) or
      is_charset("一般标点符号")(c) or is_charset("注音符号扩展")(c) or
      is_charset("韩文兼容字母")(c) or is_charset("字母连写形式")(c) or
      is_charset("组合用半符号")(c) or is_charset("查克马语")(c) or
      is_charset("夏拉达文")(c) or is_charset("木尔坦文")(c) or
      is_charset("古兰塔文")(c) or is_charset("尼瓦尔语")(c) or
      is_charset("扑克牌")(c) or is_charset("麻将牌")(c) or
      is_charset("凯提文")(c) or is_charset("日文平假名")(c) or
      is_charset("亚美尼亚语")(c) or is_charset("上标和下标")(c) or
      is_charset("提非纳字母")(c) or is_charset("古吉拉特語")(c) or
      is_charset("天城文扩展")(c) or is_charset("巽他文增补")(c) or
      is_charset("格鲁吉亚语")(c) or is_charset("阿姆哈拉语")(c) or
      is_charset("希腊语扩展")(c) or is_charset("类字母符号")(c) or
      is_charset("和卓文")(c) or is_charset("中日韩兼容")(c) or
      is_charset("佉卢文")(c) or is_charset("片假名扩展")(c) or
      is_charset("声调修饰符")(c) or is_charset("西夏文")(c) or
      is_charset("玛钦文")(c) or is_charset("数学运算符")(c) or
      is_charset("日文片假名")(c) or is_charset("曼尼普尔语")(c) or
      is_charset("锡尔赫特文")(c) or is_charset("默禄文")(c) or
      is_charset("变体选择器")(c) or is_charset("莫迪文")(c) or
      is_charset("算筹")(c) or is_charset("女书")(c) or
      is_charset("标签")(c) or is_charset("古木基文")(c) or
      is_charset("货币符号")(c) or is_charset("吠陀扩展")(c) or
      is_charset("彝族部首")(c) or is_charset("箭头符号")(c) or
      is_charset("巴塔克语")(c) or is_charset("彝族音节")(c) or
      is_charset("康熙部首")(c) or is_charset("西里尔文")(c) or
      is_charset("希伯来语")(c) or is_charset("阿拉伯语")(c) or
      is_charset("巴姆穆语")(c) or is_charset("叙利亚文")(c) or
      is_charset("它拿字母")(c) or is_charset("奥里亚语")(c) or
      is_charset("孟加拉语")(c) or is_charset("泰米尔语")(c) or
      is_charset("泰卢固语")(c) or is_charset("卡纳达语")(c) or
      is_charset("僧伽罗语")(c) or is_charset("韩文字母")(c) or
      is_charset("切罗基语")(c) or is_charset("高棉符号")(c) or
      is_charset("汉文训读")(c) or is_charset("竖排形式")(c) or
      is_charset("特殊字符")(c) or is_charset("八思巴字")(c) or
      is_charset("德宏傣文")(c) or is_charset("科普特文")(c) or
      is_charset("克耶字母")(c) or is_charset("装饰符号")(c) or
      is_charset("杂项符号")(c) or is_charset("布希德文")(c) or
      is_charset("哈努诺文")(c) or is_charset("几何形状")(c) or
      is_charset("韩文音节")(c) or is_charset("方块元素")(c) or
      is_charset("他加禄语")(c) or is_charset("卢恩字母")(c) or
      is_charset("控制图片")(c) or is_charset("欧甘字母")(c) or
      is_charset("绒巴文")(c) or is_charset("拉让语")(c) or
      is_charset("曼达文")(c) or is_charset("巽他语")(c) or
      is_charset("瓦伊语")(c) or is_charset("傣仂语")(c) or
      is_charset("林布语")(c) or is_charset("巴厘语")(c) or
      is_charset("蒙古语")(c) or is_charset("高棉语")(c) or
      is_charset("老傣文")(c) or is_charset("缅甸语")(c) or
      is_charset("老挝语")(c) or is_charset("傈僳语")(c) or
      is_charset("爪哇语")(c) or is_charset("布吉语")(c) or
      is_charset("占语")(c) or is_charset("梵文")(c) or
      is_charset("傣文")(c) or is_charset("注音")(c) or
      is_charset("高位专用替代")(c) or is_charset("藏文")(c) or
      is_charset("泰语")(c) or is_charset("盲文")(c) or
      is_charset("低位替代区")(c) or is_charset("高位替代区")(c) or
      is_charset("Compat")(c)
end

function charset_filter(input)
   for cand in input:iter() do
      if (not exists(is_cjk_ext, cand.text))
      then
	 yield(cand)
      end
   end
end


--- charset comment filter
function charset_comment_filter(input)
   for cand in input:iter() do
      for s, r in pairs(charset) do
	 if (exists(is_charset(s), cand.text)) then
	    cand:get_genuine().comment = cand.comment .. " " .. s
	    break
	 end
      end
      yield(cand)
   end
end
]]

--- single_char_filter,单字优先模式
function single_char_filter(input)
   if (word == 1) then
    local L = {}
    for cand in input:iter() do
       if (utf8.len(cand.text) == 1) then
	  yield(cand)
       else
	  table.insert(L, cand)
       end
    end
    for i, cand in ipairs(L) do
      yield(cand)
    end
   else
	local L = {}
    for cand in input:iter() do
	  yield(cand)
    end
    
   end
end


--[[
--- single_pick_filter,转换候选中的空格
function single_pick_filter(input)
local L = {}
	for cand in input:iter() do
	local mt = cand.text
	mt=string.gsub (mt, "&nbsp"," ")
	cand.text= mt 
	yield(cand)
	end

end
]]

--[[
--- single_pick_translator,转换候选中的空格
function single_pick_translator(input)
local L = {}
	for cand in input:iter() do
	local mt = cand.text
	mt=string.gsub (mt, "一","/")
	cand.text= mt 
	yield(cand)
	end

end
]]


--[[
--- reverse_lookup_filter
pydb = ReverseDb("build/terra_pinyin.reverse.bin")

function xform_py(inp)
   if inp == "" then return "" end
   inp = string.gsub(inp, "([aeiou])(ng?)([1234])", "%1%3%2")
   inp = string.gsub(inp, "([aeiou])(r)([1234])", "%1%3%2")
   inp = string.gsub(inp, "([aeo])([iuo])([1234])", "%1%3%2")
   inp = string.gsub(inp, "a1", "ā")
   inp = string.gsub(inp, "a2", "á")
   inp = string.gsub(inp, "a3", "ǎ")
   inp = string.gsub(inp, "a4", "à")
   inp = string.gsub(inp, "e1", "ē")
   inp = string.gsub(inp, "e2", "é")
   inp = string.gsub(inp, "e3", "ě")
   inp = string.gsub(inp, "e4", "è")
   inp = string.gsub(inp, "o1", "ō")
   inp = string.gsub(inp, "o2", "ó")
   inp = string.gsub(inp, "o3", "ǒ")
   inp = string.gsub(inp, "o4", "ò")
   inp = string.gsub(inp, "i1", "ī")
   inp = string.gsub(inp, "i2", "í")
   inp = string.gsub(inp, "i3", "ǐ")
   inp = string.gsub(inp, "i4", "ì")
   inp = string.gsub(inp, "u1", "ū")
   inp = string.gsub(inp, "u2", "ú")
   inp = string.gsub(inp, "u3", "ǔ")
   inp = string.gsub(inp, "u4", "ù")
   inp = string.gsub(inp, "v1", "ǖ")
   inp = string.gsub(inp, "v2", "ǘ")
   inp = string.gsub(inp, "v3", "ǚ")
   inp = string.gsub(inp, "v4", "ǜ")
   inp = string.gsub(inp, "([nljqxy])v", "%1ü")
   inp = string.gsub(inp, "eh[0-5]?", "ê")
   return "(" .. inp .. ")"
end

function reverse_lookup_filter(input)
   for cand in input:iter() do
      cand:get_genuine().comment = cand.comment .. " " .. xform_py(pydb:lookup(cand.text))
      yield(cand)
   end
end
]]


--[[
number_translator: 将 `/` + 阿拉伯数字 翻译为大小写汉字
]]

local confs = {
   {
      comment = " 大写",
      number = { [0] = "零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" },
      suffix = { [0] = "", "拾", "佰", "仟" },
      suffix2 = { [0] = "", "万", "亿", "万亿", "亿亿" }
   },
   {
      comment = " 小写",
      number = { [0] = "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" },
      suffix = { [0] = "", "十", "百", "千" },
      suffix2 = { [0] = "", "万", "亿", "万亿", "亿亿" }
   },
   {
      comment = " 大寫",
      number = { [0] = "零", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖" },
      suffix = { [0] = "", "拾", "佰", "仟" },
      suffix2 = { [0] = "", "萬", "億", "萬億", "億億" }
   },
   {
      comment = " 小寫",
      number = { [0] = "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" },
      suffix = { [0] = "", "十", "百", "千" },
      suffix2 = { [0] = "", "萬", "億", "萬億", "億億" }
   },
}

local function read_seg(conf, n)
   local s = ""
   local i = 0
   local zf = true

   while string.len(n) > 0 do
      local d = tonumber(string.sub(n, -1, -1))
      if d ~= 0 then
	 s = conf.number[d] .. conf.suffix[i] .. s
	 zf = false
      else
	 if not zf then
	    s = conf.number[0] .. s
	 end
	 zf = true
      end
      i = i + 1
      n = string.sub(n, 1, -2)
   end

   return i < 4, s
end

local function read_number(conf, n)
   local s = ""
   local i = 0
   local zf = false

   n = string.gsub(n, "^0+", "")

   if n == "" then
      return conf.number[0]
   end

   while string.len(n) > 0 do
      local zf2, r = read_seg(conf, string.sub(n, -4, -1))
      if r ~= "" then
	 if zf and s ~= "" then
	    s = r .. conf.suffix2[i] .. conf.number[0] .. s
	 else
	    s = r .. conf.suffix2[i] .. s
	 end
      end
      zf = zf2
      i = i + 1
      n = string.sub(n, 1, -5)
   end
   return s
end

function number_translator(input, seg)
   if string.sub(input, 1, 1) == "=" then
      local n = string.sub(input, 2)
      if tonumber(n) ~= nil then
	 for _, conf in ipairs(confs) do
	    local r = read_number(conf, n)
	    yield(Candidate("number", seg.start, seg._end, r, conf.comment))
	 end
      end
   end
end


--[[
--- Scc,补次选
function Scc(input, env)
local count = 0
for cand in input:iter() do
yield(cand) -- 生成这个候选
count = count + 1
end
if count == 1 then
local _end = env.engine.context.input:len()
local cand = Candidate('补次选（随便写）', 0, _end, '', '')
yield(cand)
end
end
]]


--- composition
function myfilter(input)
   local input2 = Translation(charset_comment_filter, input)
   reverse_lookup_filter(input2)
end

function mytranslator(input, seg)
   date_translator(input, seg)
   time_translator(input, seg)
   number_translator(input, seg)
end
