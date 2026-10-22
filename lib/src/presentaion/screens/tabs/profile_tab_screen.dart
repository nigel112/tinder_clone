import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zimdate/src/presentaion/states/user_state.dart';

import '../../../../common/utils/coloors.dart';
import '../../../../common/utils/utils.dart';
import '../match_screen.dart';
import '../tags_screen.dart';
import '../user_info_screen.dart';

class ProfileTabScreen extends ConsumerStatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  ConsumerState<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends ConsumerState<ProfileTabScreen> {

  @override
  Widget build(BuildContext context) {
    var data = ref.watch(userStateProvider);
    return Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey.shade100,
              ),
              ClipPath(
                clipBehavior: Clip.antiAlias,
                clipper: MyClipper(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1.0, 10.0),
                        blurRadius: 10.0)
                  ]),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 30.h),
                            CircleAvatar(
                              radius: 60.0,
                              foregroundImage:
                                  NetworkImage(data!.avatar),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              "${data.name}, ${getAge(data.age['year'])}",
                              style: TextStyle(
                                  letterSpacing: 1.1,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                            Expanded(
                                child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.pushNamed(context, TagsScreen.routeName, arguments: data.tags);
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 40.w,
                                          height: 35.h,
                                          decoration: BoxDecoration(
                                              color: Colors.blueGrey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(100.0)),
                                          child: Icon(
                                            Icons.tag_rounded,
                                            size: 25.sp,
                                            color: Colors.blueGrey.shade200,
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        Text(
                                          "tags".tr(),
                                          style: TextStyle(
                                              color: Colors.blueGrey.shade200,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child:GestureDetector(
                                      onTap: (){
                                        Navigator.pushNamed(context, MatchScreen.routeName);
                                      },
                                      child: Stack(
                                  children: <Widget>[
                                    Container(
                                      color: Colors.white,
                                    ),
                                    Positioned(
                                      right: 1.0,
                                      bottom: 0.0,
                                      left: 1.0,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            width: 50.h,
                                            height: 50.h,
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                    colors: [
                                                      Coloors.accentColor,
                                                      Coloors.secondaryHeaderColor,
                                                      Coloors.primaryColor
                                                    ],
                                                    begin: Alignment.topRight,
                                                    end:
                                                        Alignment.bottomRight,
                                                    stops: [0.0, 0.35, 1.0]),
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        150.0)),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 32.sp,
                                            ),
                                          ),
                                          SizedBox(height: 5.h),
                                          Text(
                                            "suggestions".tr(),
                                            style: TextStyle(
                                                color:
                                                    Colors.blueGrey.shade200,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 40.w,
                                      bottom: 31.w,
                                      child: Container(
                                        width: 15.w,
                                        height: 15.h,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset: Offset(2.0, 3.0),
                                                blurRadius: 5.0,
                                              )
                                            ],
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Center(
                                          child: Icon(
                                            Icons.add,
                                            color:
                                                Coloors.accentColor,
                                            size: 15.sp,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ))),
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(context, UserInfoScreen.routeName, arguments: {
                                      'name': data.name,
                                      'age': "${data.age['day']}.${data.age['month']}.${data.age['year']}",
                                      'sex': data.sex,
                                      'city': data.city,
                                      'bio': data.bio,
                                      'sexFind': data.sexFind, 
                                      'avatar' : data.avatar,
                                      'fromProfile': true
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: 40.w,
                                        height: 35.h,
                                        decoration: BoxDecoration(
                                            color: Colors.blueGrey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(100.0)),
                                        child: Icon(
                                          Icons.edit,
                                          size: 25.sp,
                                          color: Colors.blueGrey.shade200,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(
                                        "edit_info".tr(),
                                        style: TextStyle(
                                            color: Colors.blueGrey.shade200,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                )),
                              ],
                            ))
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Container())
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}


class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(0, size.height - 100.h);
    Offset controlPoint = Offset(size.width / 2, size.height);
    p.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, size.width, size.height - 100.h);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
