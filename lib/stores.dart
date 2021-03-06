import 'package:Surveyor/Services/GeneralUse/Geolocation.dart';
import 'package:Surveyor/Services/Loading/LoadingServices.dart';
import 'package:Surveyor/Services/Messages/Messages.dart';
import 'package:Surveyor/Services/Online/OnlineServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:load/load.dart';
import 'package:localstorage/localstorage.dart';

import 'Map/map.dart';
import 'assets/custom_icons_icons.dart';
import 'stores_details.dart';
import 'widgets/mainmenuwidgets.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final LocalStorage storage = new LocalStorage('Surveyor');
  var storeData;
  var assignStores = [];
  var storeRegistration = [];
  var count = "0";

  bool showAssignStore = false;
  bool showRegisterStore = false;
  bool showSearch = false;
  bool isLoad = false;

  String query = '';
  TextEditingController tc;

  var performType, performTypearray;
  OnlineSerives onlineSerives = new OnlineSerives();
  Geolocator geolocator = Geolocator();

  RoundedRectangleBorder buttonShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: BorderSide(color: CustomIcons.dropDownHeader),
    );
  }

  RoundedRectangleBorder alertButtonShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
      side: BorderSide(color: CustomIcons.appbarColor),
    );
  }

  List<String> _chooseList = ["Check In", "Store Closed"];
  var _checkInType;

  var rating = "";
  TextEditingController reason = new TextEditingController();
  var _reasonText;
  List<String> _storeClosed = ["Permanent Close", "Temporary Close"];
  var _selectType;
  var _checkClosed;

  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('dd/MM/yyyy-h:m a');
  final String formatted = formatter.format(now);

  Widget buildStatusText(status) {
    // var status;
    Color textColor;
    if (status == "In Progress") {
      textColor = Color(0xFFe0ac08);
    } else if (status == "Not Started") {
      textColor = Colors.blue;
    } else if (status == "Check Out") {
      textColor = Colors.green;
    } else if (status == "Permanent Close") {
      textColor = Colors.red;
    } else {
      textColor = Colors.deepOrange;
    }
    return Text(
      status,
      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
    );
  }

  Widget assignStoreWidget(var data, var index) {
    var townshipID = data["townshipId"].toString();
    print("1234-->" + data.toString());
    return Container(
      // margin: EdgeInsets.all(5),
      margin: EdgeInsets.only(top: 5, bottom: 10, left: 5, right: 5),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {
                  setState(() {
                    data["show"] = !data["show"];
                  });
                },
                child: Row(
                  children: <Widget>[
                    Text(
                      data["regionName"].toString(),
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              trailing: Wrap(
                spacing: 12, // space between two icons
                children: <Widget>[
                  // icon-1
                  IconButton(
                    color: Colors.black,
                    icon: data["show"] == true
                        ? Icon(Icons.keyboard_arrow_down)
                        : Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        data["show"] = !data["show"];
                      });
                    },
                  ) // icon-2
                ],
              ),
              onTap: () {
                setState(() {
                  data["show"] = !data["show"];
                });
              },
            ),
          ),
          Container(
              child: data["show"] == true
                  ? Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.grey[300],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          // if (data["existingStore"]["storeList"].length > 0)
                          Container(
                            color: CustomIcons.dropDownHeader,
                            child: ListTile(
                              title: InkWell(
                                onTap: () {
                                  setState(() {
                                    data["existItem"] = !data["existItem"];
                                  });
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "Existing Store",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "0" +
                                          "/" +
                                          data["existingStore"]["storeList"]
                                              .length
                                              .toString(),
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                              trailing: Wrap(
                                spacing: 12, // space between two icons
                                children: <Widget>[
                                  // icon-1
                                  IconButton(
                                    color: Colors.black,
                                    icon: data["existItem"] == true
                                        ? Icon(Icons.keyboard_arrow_down)
                                        : Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        print("sdfs-->" +
                                            data["existingStore"]["storeList"]
                                                .length
                                                .toString());
                                        // data["show"] = !data["show"];
                                        data["existItem"] = !data["existItem"];
                                      });
                                    },
                                  ) // icon-2
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  data["existItem"] = !data["existItem"];
                                });
                              },
                            ),
                          ),
                          Column(
                            children: [
                              //Build Search Box Widget
                              if (data["existItem"] == true)
                                _buildSearchWidget(index),

                              if (data["existItem"] == true)
                                if (data["existingStore"]["storeList"].length ==
                                        0 &&
                                    data["existItem"] == true)
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: Text(
                                              "No Data",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                              if (data["existingStore"]["storeList"].length >
                                      0 &&
                                  data["existItem"] == true &&
                                  isLoad == false)
                                for (var ii = 0;
                                    ii <
                                        data["existingStore"]["storeList"]
                                            .length;
                                    ii++)
                                  buildAssignItem(
                                      data["existingStore"]["storeList"][ii],
                                      data["existingStore"]["surDetail"],
                                      data["userDetail"],
                                      townshipID),
                            ],
                          ),

                          // if (data["existingStore"]["storeList"].length > 0)
                          SizedBox(
                            height: 10,
                          ),
                          if (data["flagStore"]["storeList"].length > 0)
                            Container(
                              color: CustomIcons.dropDownHeader,
                              child: ListTile(
                                title: InkWell(
                                  onTap: () {
                                    setState(() {
                                      data["flagItem"] = !data["flagItem"];
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "Flag Store",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "0" +
                                            "/" +
                                            data["flagStore"]["storeList"]
                                                .length
                                                .toString(),
                                        style: TextStyle(color: Colors.black),
                                      )
                                    ],
                                  ),
                                ),
                                trailing: Wrap(
                                  spacing: 12, // space between two icons
                                  children: <Widget>[
                                    // icon-1
                                    IconButton(
                                      color: Colors.black,
                                      icon: data["flagItem"] == true
                                          ? Icon(Icons.keyboard_arrow_down)
                                          : Icon(Icons.chevron_right),
                                      onPressed: () {
                                        setState(() {
                                          // data["show"] = !data["show"];
                                          data["flagItem"] = !data["flagItem"];
                                        });
                                      },
                                    ) // icon-2
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    data["flagItem"] = !data["flagItem"];
                                  });
                                },
                              ),
                            ),
                          if (data["flagItem"] == true)
                            if (data["flagStore"]["storeList"].length == 0 &&
                                data["flagItem"] == true)
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Text(
                                          "No Data",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                          if (data["flagStore"]["storeList"].length > 0 &&
                              data["flagItem"] == true)
                            for (var ii = 0;
                                ii < data["flagStore"]["storeList"].length;
                                ii++)
                              buildAssignItem(
                                  data["flagStore"]["storeList"][ii],
                                  data["flagStore"]["surDetail"],
                                  data["userDetail"],
                                  townshipID),
                          if (data["flagStore"]["storeList"].length > 0)
                            SizedBox(
                              height: 10,
                            ),
                          // if (data["newStore"])
                          if (data["newStore"] == true)
                            Container(
                              color: CustomIcons.dropDownHeader,
                              child: ListTile(
                                title: InkWell(
                                  onTap: () {
                                    setState(() {
                                      data["storeItem"] = !data["storeItem"];
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "New Store",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Wrap(
                                  spacing: 12, // space between two icons
                                  children: <Widget>[
                                    // icon-1
                                    IconButton(
                                      color: Colors.black,
                                      icon: data["storeItem"] == true
                                          ? Icon(Icons.keyboard_arrow_down)
                                          : Icon(Icons.chevron_right),
                                      onPressed: () {
                                        setState(() {
                                          // data["show"] = !data["show"];
                                          data["storeItem"] =
                                              !data["storeItem"];
                                        });
                                      },
                                    ) // icon-2
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    data["storeItem"] = !data["storeItem"];
                                  });
                                },
                              ),
                            ),
                          if (data["storeItem"] == true)
                            Container(
                              child: Column(
                                children: <Widget>[
                                  if (data["newStoresList"].length == 0)
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Text(
                                                "No Data",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  if (data["newStoresList"].length > 0 &&
                                      data["storeItem"] == true)
                                    for (var a = 0;
                                        a < data["newStoresList"].length;
                                        a++)
                                      buildNewStoreItem(
                                          data["newStoresList"][a],
                                          data["newSurdetail"],
                                          data["userDetail"],
                                          townshipID),
                                  // if(data["newStoresList"].length == 0)
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(),
                                        ),
                                        Expanded(
                                          child: RaisedButton(
                                            color: Colors.white,
                                            shape: buttonShape(),
                                            onPressed: () {
                                              getGPSstatus().then((status) => {
                                                    if (status == true)
                                                      {
                                                        this.storage.setItem(
                                                            "Category", []),
                                                        this.setSurDetail(
                                                          data["newSurdetail"],
                                                        ),
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                StoresDetailsScreen(
                                                                    [],
                                                                    false,
                                                                    "newStore",
                                                                    "null",
                                                                    "Not Started",
                                                                    townshipID),
                                                          ),
                                                        ),
                                                      }
                                                    else
                                                      {
                                                        ShowToast(
                                                            "Please open GPS")
                                                      }
                                                  });
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.add_box,
                                                  color: Colors.black,
                                                ),
                                                Text(" Add New Store",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ))
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    )
                  : new Container())
        ],
      ),
    );
  }

  BoxDecoration flagDecoration(var check) {
    if (check != "0" && check != "0.0") {
      return BoxDecoration(
        border: Border.all(
          color: CustomIcons.appbarColor,
        ),
        borderRadius: BorderRadius.circular(0.0),
      );
    } else {
      return BoxDecoration();
    }
  }

  // Widget storeRegWIdget(var data) {
  //   return Container(
  //     margin: EdgeInsets.all(5),
  //     child: Column(
  //       children: <Widget>[
  //         Container(
  //           color: CustomIcons.dropDownHeader,
  //           child: ListTile(
  //             title: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   data["show"] = !data["show"];
  //                 });
  //               },
  //               child: Text(
  //                 data["townshipname"],
  //                 style: TextStyle(color: Colors.black),
  //               ),
  //             ),
  //             onTap: () {
  //               setState(() {
  //                 data["show"] = !data["show"];
  //               });
  //             },
  //             trailing: Wrap(
  //               spacing: 12, // space between two icons
  //               children: <Widget>[
  //                 // icon-1
  //                 IconButton(
  //                   color: Colors.black,
  //                   icon: data["show"] == true
  //                       ? Icon(Icons.keyboard_arrow_down)
  //                       : Icon(Icons.chevron_right),
  //                   onPressed: () {
  //                     setState(() {
  //                       data["show"] = !data["show"];
  //                     });
  //                   },
  //                 ) // icon-2
  //               ],
  //             ),
  //           ),
  //         ),
  //         Container(
  //             child: data["show"] == true
  //                 ? Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: <Widget>[
  //                       this.storeRegistration.length == 0
  //                           ? Row(
  //                               children: <Widget>[
  //                                 Expanded(
  //                                   child: Container(
  //                                     height: 50,
  //                                     color: Colors.grey[200],
  //                                     child: Center(
  //                                       child: Text(
  //                                         "No Data",
  //                                         textAlign: TextAlign.center,
  //                                         style: TextStyle(
  //                                           color: Colors.black,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 )
  //                               ],
  //                             )
  //                           : Column(
  //                               children: <Widget>[
  //                                 for (var i = 0;
  //                                     i < data["childData"].length;
  //                                     i++)
  //                                   buildRegisterItem(
  //                                       data["childData"][i]["name"]
  //                                               .toString() +
  //                                           "( " +
  //                                           data["childData"][i]["mmName"]
  //                                               .toString() +
  //                                           " )",
  //                                       data["childData"][i]["phoneNumber"]
  //                                           .toString(),
  //                                       data["childData"][i]["address"]
  //                                           .toString(),
  //                                       data["childData"][i])
  //                               ],
  //                             ),
  //                     ],
  //                   )
  //                 : new Container())
  //       ],
  //     ),
  //   );
  // }

  _showDialog(data, surDetail, userDetail, townshipId) {
    var shopData = [data];
    var param;
    var params;
    var loginUser;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: new Text("Check In"),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.store,
                            color: CustomIcons.iconColor,
                            size: 27,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              data["shopname"] + "(" + data["shopnamemm"] + ")",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.timelapse,
                            color: CustomIcons.iconColor,
                            size: 27,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              "${this.formatted}",
                              style: TextStyle(fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: CustomIcons.iconColor,
                            size: 27,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              data["lat"] + " " + "/" + " " + data["long"],
                              style: TextStyle(color: Colors.red, fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.select_all,
                            color: CustomIcons.iconColor,
                            size: 27,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Container(
                              width: 200,
                              child: DropdownButtonFormField<String>(
                                value: _checkInType,
                                items: _chooseList
                                    .map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                decoration:
                                    InputDecoration.collapsed(hintText: ''),
                                hint: Row(
                                  children: <Widget>[
                                    Text('Select Type'),
                                  ],
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _checkInType = value;
                                    _selectType = null;
                                    if (_checkInType == "Store Closed" ||
                                        _checkInType == "STORECLOSED")
                                      _checkClosed = "1";
                                    else
                                      _checkClosed = "2";
                                    _selectType = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (this._checkClosed == "1")
                      SizedBox(
                        height: 10,
                      ),
                    if (this._checkClosed == "1")
                      Container(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.nfc,
                              color: CustomIcons.iconColor,
                              size: 27,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 200,
                              child: Container(
                                child: DropdownButtonFormField<String>(
                                  value: _selectType,
                                  items: _storeClosed
                                      .map<DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  decoration:
                                      InputDecoration.collapsed(hintText: ''),
                                  hint: Row(
                                    children: <Widget>[
                                      Text('Select Type'),
                                    ],
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectType = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (this._checkClosed == "1")
                      SizedBox(
                        height: 10,
                      ),
                    if (this._checkClosed == "1")
                      Container(
                        height: 10 * 20.0,
                        child: TextField(
                          controller: reason,
                          maxLines: 10,
                          onChanged: (value) {
                            this._reasonText = value.toString();
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Reason",
                            fillColor: Colors.grey[50],
                            filled: true,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.map,
                            color: CustomIcons.iconColor,
                            size: 27,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              data["address"],
                              style: TextStyle(fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: RaisedButton(
                                color: Colors.white,
                                shape: alertButtonShape(),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
//                                        buildStatusText(this.performTypearray)
                                      Text("Cancel")
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              child: RaisedButton(
                                color: Colors.white,
                                shape: alertButtonShape(),
                                onPressed: () {
                                  getGPSstatus().then((status) => {
                                        if (status == true)
                                          {
                                            if (_checkInType == "CHECKIN" ||
                                                _checkInType == "Check In")
                                              {
                                                loginUser = this
                                                    .storage
                                                    .getItem("loginData"),
                                                params = {
                                                  "lat": data["lat"],
                                                  "lon": data["long"],
                                                  "address": data["address"],
                                                  "shopsyskey":
                                                      data["shopsyskey"],
                                                  "usersyskey":
                                                      loginUser['syskey'],
                                                  if (data["status"]
                                                          ["currentType"] ==
                                                      "CHECKIN")
                                                    "checkInType":
                                                        "TEMPCHECKOUT"
                                                  else
                                                    "checkInType": "CHECKIN",
                                                  "register": true,
                                                  "reason": this
                                                      ._reasonText
                                                      .toString(),
                                                  "task": "INCOMPLETE",
                                                },
                                                this
                                                    .onlineSerives
                                                    .getSurveyor(params)
                                                    .then(
                                                      (value) => {
                                                        if (value["status"] ==
                                                            true)
                                                          {
                                                            param = {
                                                              "shopsyskey":
                                                                  shopData[0][
                                                                      "shopsyskey"]
                                                            },
                                                            this
                                                                .onlineSerives
                                                                .getCategory(
                                                                    param)
                                                                .then(
                                                                    (value) => {
                                                                          if (value ==
                                                                              true)
                                                                            {
                                                                              this.setSurDetail(surDetail),
                                                                              Navigator.of(context, rootNavigator: true).pop(),
                                                                              Navigator.of(context).pushReplacement(
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => StoresDetailsScreen(shopData, false, "assign", "null", "CHECKIN", townshipId),
                                                                                ),
                                                                              ),
                                                                            }
                                                                          else
                                                                            {
                                                                              hideLoadingDialog(),
                                                                            },
                                                                        }),
                                                          }
                                                        else
                                                          {}
                                                      },
                                                    ),
                                              }
                                            else if ((_checkInType ==
                                                        "STORECLOSED" ||
                                                    _checkInType ==
                                                        "Store Closed") &&
                                                _selectType != null)
                                              {
                                                print("adf-->" +
                                                    _selectType.toString()),
                                                //     loginUser = this
                                                //         .storage
                                                //         .getItem("loginData"),
                                                //     params = {
                                                //       "lat": data["lat"],
                                                //       "lon": data["long"],
                                                //       "address": data["address"],
                                                //       "shopsyskey":
                                                //           data["shopsyskey"],
                                                //       "usersyskey":
                                                //           loginUser['syskey'],
                                                //         "checkInType": "STORECLOSED",
                                                //       "register": true,
                                                //       "reason": this
                                                //           ._reasonText
                                                //           .toString(),
                                                //       "task": "INCOMPLETE",
                                                //     },
                                                //     this
                                                //         .onlineSerives
                                                //         .getSurveyor(params)
                                                //         .then(
                                                //           (value) => {
                                                //             if (value["status"] ==
                                                //                 true)
                                                //               {

                                                //               }
                                                //             else
                                                //               {}
                                                //           },
                                                //         ),
                                                //   }
                                                // else
                                                //   {
                                                //     ShowToast("Please Select Type"),
                                                //   }
                                              }
                                          }
                                        else
                                          {ShowToast("Please open GPS")}
                                      });
                                },
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
//                                        buildStatusText(this.performTypearray)
                                      Text("Next")
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildAssignItem(data, surDetail, userDetail, townshipId) {
    // print("123--->" + data.toString());
    var shopData = [data];
    var checkStatus;
    bool start = true;

    print("surveydetail->");
    print(surDetail);

    if (data["status"]["currentType"] == "") {
      checkStatus = "Not Started";
    } else if (data["status"]["currentType"] == "CHECKIN") {
      checkStatus = "In Progress";
    } else if (data["status"]["currentType"] == "CHECKOUT") {
      checkStatus = "Check Out";
    } else if (data["status"]["currentType"] == "TEMPCHECKOUT") {
      checkStatus = "In Progress";
    } else if (data["status"]["currentType"] == "PERMANENT_CLOSE") {
      checkStatus = "Permanent Close";
      start = false;
    } else if (data["status"]["currentType"] == "TEMPORARY_CLOSE") {
      checkStatus = "Temporary Close";
    } else if (data["status"]["currentType"] == "STORECLOSED") {
      checkStatus = "Temporary Close";
    }

    return Container(
      color: Colors.grey[200],
      child: Card(
        child: Container(
          decoration: flagDecoration(data["FlagCount"].toString()),
          child: Column(
            children: <Widget>[
              ListTile(
                  title: Text(
                    data["shopname"] + " ( " + data["shopnamemm"] + " )",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      ),
                      Text(
                        data["phoneno"],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      ),
                      Text(
                        data["address"],
                        style: TextStyle(height: 1.3),
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: RaisedButton(
                                  color: Colors.white,
                                  shape: buttonShape(),
                                  onPressed: () {},
                                  child: Center(
                                    child: Column(
                                      children: <Widget>[
                                        buildStatusText(checkStatus)
                                        // Text(checkStatus.toString())
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (start)
                              Expanded(
                                child: Container(
                                  child: RaisedButton(
                                    color: Colors.white,
                                    shape: buttonShape(),
                                    onPressed: () {
                                      if (checkStatus == "Check Out") {
                                        this.storage.setItem(
                                            "completeStatus", "Complete");
                                        this.setSurDetail(surDetail);
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StoresDetailsScreen(
                                                    shopData,
                                                    false,
                                                    "assign",
                                                    "null",
                                                    checkStatus,
                                                    townshipId),
                                          ),
                                        );
                                      } else {
                                        this.storage.setItem(
                                            "completeStatus", "inComplete");
                                        _showDialog(data, surDetail, townshipId,
                                            userDetail);
                                      }
                                      _checkInType = null;
                                      _checkClosed = "2";
                                      _selectType = null;
                                      reason = null;
                                    },
                                    child: Center(
                                      child: Text(
                                        "Start",
                                        style: TextStyle(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNewStoreItem(data, surDetail, userDetail, townshipId) {
    var checkStatus = "Not Started";
    data["address"] = data["locationData"]["address"];
    bool start = true;

    print("datas->" + data.toString());
    if (data["routeStatus"]["currentType"] == "") {
      checkStatus = "Not Started";
    } else if (data["routeStatus"]["currentType"] == "CHECKIN") {
      checkStatus = "In Progress";
    } else if (data["routeStatus"]["currentType"] == "CHECKOUT") {
      checkStatus = "Check Out";
    } else if (data["routeStatus"]["currentType"] == "TEMPCHECKOUT") {
      checkStatus = "In Progress";
    } else if (data["routeStatus"]["currentType"] == "PERMANENT_CLOSE") {
      checkStatus = "Permanent Close";
      start = false;
    } else if (data["routeStatus"]["currentType"] == "TEMPORARY_CLOSE") {
      checkStatus = "Temporary Close";
    }

    return Container(
      color: Colors.grey[200],
      child: Card(
        child: Container(
          child: Column(
            children: <Widget>[
              ListTile(
                  title: Text(
                    data["name"] + " ( " + data["mmName"] + " )",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      ),
                      Text(
                        data["phoneNumber"],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      ),
                      Text(
                        data["locationData"]["address"],
                        style: TextStyle(height: 1.3),
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: RaisedButton(
                                  color: Colors.white,
                                  shape: buttonShape(),
                                  onPressed: () {},
                                  child: Center(
                                    child: Column(
                                      children: <Widget>[
                                        buildStatusText(checkStatus)
                                        // Text(checkStatus.toString())
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (start)
                              Expanded(
                                child: Container(
                                  child: RaisedButton(
                                    color: Colors.white,
                                    shape: buttonShape(),
                                    onPressed: () {
                                      getGPSstatus().then((status) => {
                                            if (status == true)
                                              {
                                                if (checkStatus == "Check Out")
                                                  {
                                                    this.storage.setItem(
                                                        "completeStatus",
                                                        "Complete"),
                                                  }
                                                else
                                                  {
                                                    this.storage.setItem(
                                                        "completeStatus",
                                                        "inComplete"),
                                                  },
                                                this.setSurDetail(surDetail),
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StoresDetailsScreen(
                                                            [data],
                                                            false,
                                                            "register",
                                                            "null",
                                                            checkStatus,
                                                            townshipId),
                                                  ),
                                                ),
                                              }
                                            else
                                              {ShowToast("Please open GPS")}
                                          });
                                    },
                                    child: Center(
                                      child: Text(
                                        "Start",
                                        style: TextStyle(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // Widget buildRegisterItem(
  //     String storeName, String phone, String address, data) {
  //   var params;
  //   return Container(
  //     color: Colors.grey[200],
  //     padding: EdgeInsets.all(1),
  //     child: Card(
  //       child: Container(
  //         decoration: flagDecoration(data["FlagCount"].toString()),
  //         padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
  //         child: Column(
  //           children: <Widget>[
  //             ListTile(
  //                 title: Text(
  //                   storeName,
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.w700,
  //                   ),
  //                 ),
  //                 subtitle: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: <Widget>[
  //                     Container(
  //                       margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
  //                     ),
  //                     Text(
  //                       phone,
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         height: 1.0,
  //                       ),
  //                     ),
  //                     Container(
  //                       margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
  //                     ),
  //                     Text(
  //                       address,
  //                       style: TextStyle(height: 1.3),
  //                     ),
  //                     Container(
  //                       margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
  //                       child: Row(
  //                         children: <Widget>[
  //                           Expanded(
  //                             child: Container(
  //                               child: RaisedButton(
  //                                 color: Colors.white,
  //                                 shape: buttonShape(),
  //                                 onPressed: () {},
  //                                 child: Center(
  //                                   child: Text(
  //                                     "Status",
  //                                     style: TextStyle(),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Container(
  //                               child: RaisedButton(
  //                                 color: Colors.white,
  //                                 shape: buttonShape(),
  //                                 onPressed: () {
  //                                   getGPSstatus().then((status) => {
  //                                         if (status == true)
  //                                           {
  //                                             params = {
  //                                               "shopsyskey": data["id"]
  //                                             },
  //                                             this
  //                                                 .onlineSerives
  //                                                 .getCategory(params)
  //                                                 .then((value) => {
  //                                                       if (value == true)
  //                                                         {
  //                                                           Navigator.of(
  //                                                                   context)
  //                                                               .pushReplacement(
  //                                                             MaterialPageRoute(
  //                                                               builder: (context) =>
  //                                                                   StoresDetailsScreen(
  //                                                                       [data],
  //                                                                       false,
  //                                                                       "register",
  //                                                                       "null"),
  //                                                             ),
  //                                                           ),
  //                                                         }
  //                                                       else
  //                                                         {
  //                                                           hideLoadingDialog(),
  //                                                         }
  //                                                     }),
  //                                           }
  //                                         else
  //                                           {
  //                                             {ShowToast("Please open GPS")}
  //                                           }
  //                                       });
  //                                 },
  //                                 child: Center(
  //                                   child: Text(
  //                                     "Continue",
  //                                     style: TextStyle(),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 )),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  var allData = [];
  var storeallData = [];

  allDataFunction() {
    allData = [];
    storeallData = [];
    var storeDatas = this.storage.getItem("storeData");
    print("shops-->" + storeDatas.length.toString());
    if (storeDatas.length == 0) {
      ShowToast("No Data!");
      hideLoadingDialog();
    } else {
      sortArray(storeDatas);
    }
  }

  sortArray(storeDatas) async {
    for (var i = 0; i < storeDatas.length; i++) {
      var objData = {};
      objData["show"] = false;
      objData["regionId"] = storeDatas[i]["regionId"].toString();
      objData["existingStore"] = storeDatas[i]["existingStore"];
      objData["existItem"] = false;
      objData["flagStore"] = storeDatas[i]["flagStore"];
      objData["flagItem"] = false;
      objData["storeItem"] = false;
      objData["newStore"] = storeDatas[i]["containNewStore"];
      objData["newSurdetail"] = storeDatas[i]["newStore"]["surDetail"];
      print("status" + storeDatas[i]["containNewStore"].toString());
      var newStores;
      var newStoresList;

      if (storeDatas[i]["containNewStore"] == true) {
        var params = {
          "usersyskey": this.loginData["syskey"].toString(),
          "regionsyskey": storeDatas[i]["regionId"].toString(),
        };
        print("param-->" + storeDatas[i]["regionId"].toString());
        newStores = await this.onlineSerives.getNewStore(params);
        print("newStroe-->" + newStores.toString());
        if (newStores != null) {
          if (newStores["status"]) {
            print("true-->" + newStores["status"].toString());
            newStoresList = newStores["data"];
          } else {
            print("false-->" + newStores["status"].toString());
            newStoresList = [];
          }
        }
      } else {
        newStoresList = [];
      }
      objData["newStoresList"] = newStoresList;
      print("--->>" + newStoresList.toString());
      var paramforTownshipName = {
        "id": storeDatas[i]["regionId"].toString(),
        "code": "",
        "description": "",
        "parentid": "",
        "n2": ""
      };

      this.onlineSerives.getTownship(paramforTownshipName).then((value) => {
            if (value["status"] == true)
              {
                objData["regionName"] = value["data"][0]["description"],
                objData["townshipId"] = value["data"][0]["id"],
                // setState(() {
                storeallData.add(objData),
                print("check->>" +
                    storeallData.length.toString() +
                    "__" +
                    storeDatas.length.toString()),
                if (storeallData.length == storeDatas.length)
                  {
                    storeallData.sort(
                        (a, b) => a["regionName"].compareTo(b["regionName"])),
                  },
                // }),
                if ((storeDatas.length - 1) == i)
                  {
                    setState(() {
                      this.count = this.assignStores.length.toString();
                      // allData = storeallData;
                      allData = json.decode(json.encode(storeallData));
                    })
                  }
              }
          });
    }
  }

  Widget _buildSearchWidget(var index) {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          controller: tc,
          decoration: InputDecoration(hintText: 'Search...'),
          textInputAction: TextInputAction.search,
          onSubmitted: (v) {
            setState(() {
              isLoad = true;
              allData[index]["existingStore"]["storeList"] = [];
              query = v;
              print("Query:" + query);
              setResults(query, index);
            });
          },
        ),
      ),
    );
  }

  void setResults(query, var index) {
    print("Index: " + index.toString());

    allData[index]["existingStore"]["storeList"] = json
        .decode(json.encode(storeallData[index]["existingStore"]["storeList"]));

    allData[index]["existingStore"]["storeList"] = allData[index]
            ["existingStore"]["storeList"]
        .where((element) => element["shopname"]
            .toString()
            .toLowerCase()
            .contains(query.toString().toLowerCase()))
        .toList();

    allData[index]["show"] = true;
    allData[index]["existItem"] = true;
    isLoad = false;
  }

  void setSurDetail(surDetail) {
    this.storage.deleteItem('Maplatlong');
    this.storage.setItem("surDetail", surDetail);
  }

  var loginData, newParam;
  @override
  void initState() {
    print("aa-->");
    super.initState();

    try {
      var shopParam = {
        "spsyskey": "",
        "teamsyskey": "",
        "usertype": "",
        "date": ""
      };

      this.loginData = this.storage.getItem("loginData");
      newParam = {"usersyskey": this.loginData["syskey"].toString()};
      shopParam["spsyskey"] = this.loginData["syskey"];
      shopParam["teamsyskey"] = this.loginData["teamSyskey"];
      shopParam["usertype"] = this.loginData["userType"];
      shopParam["date"] = "";

      Future.delayed(const Duration(milliseconds: 900), () {
        showLoading();
        this
            .onlineSerives
            .getStores(shopParam)
            .then((result) => {
                  if (result == true)
                    {
                      this.assignStores = this.storage.getItem("storeData"),
                      allDataFunction(),
                    }
                  else
                    {
                      this.storeRegistration = [],
                      this.assignStores = [],
                      hideLoadingDialog(),
                    }
                })
            .catchError((onError) => {print(onError), hideLoadingDialog()});
      });
    } catch (e) {
      ShowToast(e);
    }
  }

  List data;

  Future<void> localJsonData() async {
    var jsonText = await rootBundle.loadString("assets/township.json");
    setState(() {
      data = json.decode(jsonText);
    });
  }

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LoadingProvider(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Color(0xFFF8F8FF),
            drawer: MainMenuWidget(),
            appBar: AppBar(
              title: Text("Surveyor"),
              backgroundColor: CustomIcons.appbarColor,
              actions: <Widget>[
                // IconButton(
                //     icon: Icon(Icons.search),
                //     onPressed: () {
                //       setState(() {
                //         showSearch = !showSearch;
                //       });
                //     }),
                IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () {
                    getGPSstatus().then((status) => {
                          if (status == true)
                            {
                              showLoading(),
                              _getLocation().then((value) async {
//                                setState(() {
                                if (value == null) {
                                } else {
//                                    _getAddress(value).then((val) async {
                                  if (value.latitude != null &&
                                      value.longitude != null) {
                                    var param = {
                                      {
                                        "usersyskey":
                                            loginData["syskey"].toString(),
                                        "regionsyskey": ""
                                      }
                                    };
                                    this
                                        .onlineSerives
                                        .getNewStore(param)
                                        .then((value) => {});
                                    localJsonData().then((val) {
                                      // hideLoadingDialog();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => GmapS(
                                            lati: value.latitude,
                                            long: value.longitude,
                                            regass: 'Map',
                                            passLength: null,
                                            updateStatus: false,
                                            data: data,
                                            shopkey: value,
                                          ),
                                        ),
                                      );
                                    });
                                  } else {}
//                                    }).catchError((error) {
//                                    });
                                }
//                                });
                              }).catchError((error) {}),
                            }
                          else
                            {ShowToast("Please open GPS")}
                        });
                  },
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Column(children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          // color: CustomIcons.iconColor,
                          child: Column(
                            children: <Widget>[
                              if (allData.length > 0)
                                for (var i = 0; i < allData.length; i++)
                                  assignStoreWidget(allData[i], i),
                              // RaisedButton(
                              //   onPressed: () {
                              //     allDataFunction();
                              //   },
                              //   child: Text("text data"),
                              // )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[300],
                        )
                      ],
                    ),
                  ),
                  // Container(
                  //   child: Row(
                  //     children: <Widget>[
                  //       Expanded(
                  //         child: Container(),
                  //       ),
                  //       Expanded(
                  //         child: RaisedButton(
                  //           color: Colors.white,
                  //           shape: buttonShape(),
                  //           onPressed: () {
                  //             getGPSstatus().then((status) => {
                  //                   if (status == true)
                  //                     {
                  //                       Navigator.of(context).pushReplacement(
                  //                         MaterialPageRoute(
                  //                           builder: (context) =>
                  //                               StoresDetailsScreen([], false,
                  //                                   "newStore", "null"),
                  //                         ),
                  //                       ),
                  //                     }
                  //                   else
                  //                     {ShowToast("Please open GPS")}
                  //                 });
                  //           },
                  //           child: Row(
                  //             children: <Widget>[
                  //               Icon(
                  //                 Icons.add_box,
                  //                 color: Colors.black,
                  //               ),
                  //
                  //                   style: TextStyle(
                  //                     color: Colors.black,
                  //                   ))
                  //             ],
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // )
                ]),
              ),
            )),
      ),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<String> _getAddress(Position pos) async {
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      final Placemark pos = placemarks[0];
      return pos.thoroughfare + ', ' + pos.locality;
    }
    return "";
  }
}
