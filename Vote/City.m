//
//  City.m
//  Vote
//
//  Created by 丁 一 on 14-10-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "City.h"

@implementation City

- (id)init
{
    self = [super init];
    if (self) {
        self.cityMap = @{@"Anshan":@"鞍山",
                         @"Baoding":@"保定", @"Baoji":@"宝鸡", @"Baotou":@"包头", @"Beihai":@"北海", @"Beijing":@"北京", @"Benxi":@"本溪",
                         @"Cangzhou":@"沧州", @"Changzhi":@"长治", @"Changchun":@"长春", @"Changsha":@"长沙", @"Changzhou":@"常州", @"Chaozhou":@"潮州", @"Chengde":@"承德", @"Chengdu":@"成都", @"Chifeng":@"赤峰",
                         @"Dalian":@"大连", @"Daqing":@"大庆", @"Datong":@"大同", @"Dandong":@"丹东", @"Dezhou":@"德州", @"Dongguan":@"东莞",
                         @"Ordos":@"鄂尔多斯",
                         @"Foshan":@"佛山", @"Fushun":@"抚顺", @"Fuxin":@"阜新", @"Fuzhou":@"福州",
                         @"Guangzhou":@"广州", @"Guilin":@"桂林", @"Guiyang":@"贵阳",
                         @"Harbin":@"哈尔滨", @"Haikou":@"海口", @"Handan":@"邯郸", @"Hanzhong":@"汉中", @"Hangzhou":@"杭州", @"Hefei":@"合肥", @"Hengshui":@"衡水", @"Hengyang":@"衡阳", @"Honghe":@"红河", @"Hohhot":@"呼和浩特", @"Huludao":@"葫芦岛", @"Hulunber":@"呼伦贝尔", @"Huzhou":@"湖州", @"Huai'an":@"淮安", @"Huangshan":@"黄山", @"Huangshi":@"黄石",
                         @"Jilin":@"吉林", @"Jinan":@"济南", @"Jiaxing":@"嘉兴", @"Jiayuguan":@"嘉峪关", @"Jincheng":@"晋城", @"Jinzhong":@"晋中", @"Jinzhou":@"锦州", @"Jingzhou":@"荆州", @"Jingdezhen":@"景德镇", @"Jiujiang":@"九江",
                         @"Kaifeng":@"开封", @"Kunming":@"昆明",
                         @"Lhasa":@"拉萨", @"Lanzhou":@"兰州", @"Langfang":@"廊坊", @"Leshan":@"乐山", @"Lijiang":@"丽江", @"Lianyungang":@"连云港", @"Liaoyang":@"辽阳", @"Linfen":@"临汾", @"Liupanshui":@"六盘水", @"Luoyang":@"洛阳", @"Lvliang":@"吕梁",
                         @"Mianyang":@"绵阳",
                         @"Nanchang":@"南昌", @"Nanjing":@"南京", @"Nanning":@"南宁", @"Nantong":@"南通", @"Nanyang":@"南阳", @"Ningbo":@"宁波",
                         @"Panjin":@"盘锦", @"Panzhihua":@"攀枝花", @"Pu'er":@"普洱",
                         @"Qiqihar":@"齐齐哈尔", @"Qinhuangdao":@"秦皇岛", @"Qingdao":@"青岛",
                         @"Sanya":@"三亚", @"Shantou":@"汕头", @"Shanghai":@"上海", @"Shaoxing":@"绍兴", @"Shenyang":@"沈阳", @"Shenzhen":@"深圳", @"Shijiazhuang":@"石家庄", @"Shuozhou":@"朔州", @"Suzhou":@"苏州",
                         @"Taiyuan":@"太原", @"Taizhou":@{@"Zhejiang":@"台州", @"Jiangsu":@"泰州"}, @"Tangshan":@"唐山", @"Tianjin":@"天津", @"Tieling":@"铁岭", @"Tongliao":@"通辽", @"Turpan":@"吐鲁番",
                         @"Weihai":@"威海", @"Wenzhou":@"温州", @"Wuhai":@"乌海", @"Urumqi":@"乌鲁木齐", @"Wuhai":@"武汉", @"Wuxi":@"无锡",
                         @"Xi'an":@"西安", @"Xining":@"西宁", @"Xishuangbanna":@"西双版纳", @"Xiamen":@"厦门", @"Xianyang":@"咸阳", @"Xiangtan":@"湘潭", @"Xiangyang":@"襄阳", @"Xinzhou":@"忻州", @"Xingtai":@"邢台", @"Xuchang":@"许昌", @"Xuzhou":@"徐州",
                         @"Yan'an":@"延安", @"Yantai":@"烟台", @"Yangquan":@"阳泉", @"Yangzhou":@"扬州", @"Yichang":@"宜昌", @"Yichun":@"宜春", @"Yinchuan":@"银川", @"Yingkou":@"营口", @"Yulin":@"榆林", @"Yueyang":@"岳阳", @"Yuncheng":@"运城",
                         @"Zhangjiajie":@"张家界", @"Zhangjiakou":@"张家口", @"Zhenjiang":@"镇江", @"Zhengzhou":@"郑州", @"Zhongshan":@"中山", @"Zhoushan":@"舟山", @"Zhuhai":@"珠海", @"Zunyi":@"遵义"};
    }
    
    return self;
}

@end
