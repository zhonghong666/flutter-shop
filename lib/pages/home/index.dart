import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:async/async.dart';
import '../../service/serviceMethod.dart' as HttpMethod;

import './swiper.dart'; //轮播组件
import './navigator.dart'; //首页导航
import './adBanner.dart'; //广告图片
import './leaderPhone.dart'; //店长电话
import './recommend.dart'; //商品推荐
import './floorTitle.dart'; //floor标题
import './floorContent.dart'; //floor内容
import './hotTitle.dart'; //火爆专区标题
import './hotProduct.dart'; //火爆商品列表
import '../../util/dialog/progressDialog.dart'; //加载动画
import '../../util/animation/circle.dart';

class HomePage extends StatefulWidget {
  Map arguments; //定义接收的路由跳转参数map集合
  HomePage({this.arguments});
  _HomePageState createState() => _HomePageState(arguments: this.arguments);
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int page = 1;
  List<Map> hotGoodsList = [];
  final AsyncMemoizer _memoizer = AsyncMemoizer(); //记忆器对象
  bool _loading = true; //是否显示加载动画

  Map arguments; //路由跳转参数map集合
  _HomePageState({Map arguments}) {
    this.arguments = arguments;
    _getHotGoods();
  } //接收构造参数并赋值

  @override
  bool get wantKeepAlive => true;

  void _getHotGoods() {
    var formPage = {'page': page};
    HttpMethod.getHomePageBelowConten(params: formPage).then((val) {
      var data = json.decode(val.toString());
      if (data['data'] == null) {
        Fluttertoast.showToast(
          msg: "没有数据了",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Color.fromRGBO(104, 87, 229, 0.8),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
      List<Map> newGoodsList = (data['data'] as List).cast();
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
    });
  }

  Future _getHomePageContext() async {
    return _memoizer.runOnce(() async {
      return await HttpMethod.getHomePageContext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("斯贝儿"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _getHomePageContext(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _loading = false;
            var data = json.decode(snapshot.data.toString());
            List<Map> swiperDataList =
                (data['data']['slides'] as List).cast(); //轮播数据
            List<Map> navigatorList =
                (data['data']['category'] as List).cast(); //类别列表
            String advertesPicture =
                data['data']['advertesPicture']['PICTURE_ADDRESS']; //广告图片
            String leaderImage = data['data']['shopInfo']['leaderImage']; //店长图片
            String leaderPhone = data['data']['shopInfo']['leaderPhone']; //店长电话
            List<Map> recommendList =
                (data['data']['recommend'] as List).cast(); // 商品推荐
            String floor1Title =
                data['data']['floor1Pic']['PICTURE_ADDRESS']; //楼层1的标题图片
            String floor2Title =
                data['data']['floor2Pic']['PICTURE_ADDRESS']; //楼层1的标题图片
            String floor3Title =
                data['data']['floor3Pic']['PICTURE_ADDRESS']; //楼层1的标题图片
            List<Map> floor1 =
                (data['data']['floor1'] as List).cast(); //楼层1商品和图片
            List<Map> floor2 =
                (data['data']['floor2'] as List).cast(); //楼层1商品和图片
            List<Map> floor3 =
                (data['data']['floor3'] as List).cast(); //楼层1商品和图片
            return EasyRefresh(
              header: MaterialHeader(),
              footer: BezierBounceFooter(backgroundColor: Colors.blue),
              child: ListView(children: <Widget>[
                SwiperShow(swiperDataList: swiperDataList),
                TopNavigator(navigatorList: navigatorList),
                AdBanner(
                    advertesPicture: advertesPicture,
                    jumpAddress: 'http://blog.zhonghong520.com'),
                LeaderPhone(leaderImage: leaderImage, leaderPhone: leaderPhone),
                Recommend(recommendList: recommendList),
                FloorTitle(pictureAddress: floor1Title),
                FloorContent(floorGoodsList: floor1),
                FloorTitle(pictureAddress: floor2Title),
                FloorContent(floorGoodsList: floor2),
                FloorTitle(pictureAddress: floor3Title),
                FloorContent(floorGoodsList: floor3),
                HotTitle(),
                HotProduct(hotGoodsList)
              ]),
              onRefresh: () async {
                _getHomePageContext();
              },
              onLoad: () async {
                _getHotGoods();
              },
            );
          } else {
            return Container(
                child: ProgressDialog(
                  loading: _loading,
                  progress: Circle(
                    size: Size(100.0, 20.0),
                    color: Color(0xff41B5F1),
                ),
                alpha: 0,
            ));
          }
        },
      ),
    );
  }
}
