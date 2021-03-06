import 'package:Surveyor/Services/Messages/Messages.dart';
import 'package:Surveyor/checkNeighborhood.dart';
import 'package:Surveyor/neighborhoodSurvey.dart';
import 'package:Surveyor/widgets/mainmenuwidgets.dart';
import 'package:flutter/material.dart';
import 'package:Surveyor/Services/Online/OnlineServices.dart';
import 'package:localstorage/localstorage.dart';

import 'assets/custom_icons_icons.dart';

class OutsideInsideNeighborhood extends StatefulWidget {
  final bool isNeighborhood;
  final bool isOutside;
  final bool isInside;
  final bool isStoreOperater;
  final String shopName;
  final String shopPhone;
  final String address;
  final String regOrAss;
  final passData;
  final question;
  final header;

  OutsideInsideNeighborhood(
      this.isNeighborhood,
      this.isOutside,
      this.isInside,
      this.isStoreOperater,
      this.shopName,
      this.shopPhone,
      this.address,
      this.regOrAss,
      this.passData,
      this.question,
      this.header);

  @override
  _OutsideInsideNeighborhoodState createState() =>
      _OutsideInsideNeighborhoodState();
}

class _OutsideInsideNeighborhoodState extends State<OutsideInsideNeighborhood> {
  var headerItems = [];
  LocalStorage storage = new LocalStorage('Surveyor');
  var allItem = 0;
  var answerItem = 0;
  bool continueStatus = false;
  var completeStatus;
  BoxDecoration flagDecoration(var flag) {
    if (flag == "1") {
      return BoxDecoration(
        border: Border.all(
          color: CustomIcons.appbarColor,
        ),
        borderRadius: BorderRadius.circular(5.0),
      );
    } else {
      return BoxDecoration();
    }
  }

  Widget sectionList(var passSection, var item) {
    return Container(
      child: Card(
        child: Container(
          decoration: flagDecoration(item["flag"]),
          child: Column(
            children: <Widget>[
              ListTile(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => NeighborhoodSurveyScreen(
                            this.widget.isNeighborhood,
                            this.widget.isOutside,
                            this.widget.isInside,
                            this.widget.isStoreOperater,
                            this.widget.shopName,
                            this.widget.shopPhone,
                            this.widget.address,
                            "This is text for the instruciotns",
                            passSection["sectionDescription"],
                            this.widget.regOrAss,
                            this.widget.passData,
                            passSection,
                            this.widget.header,
                            this.widget.header["sections"],
                            this.headerShopSyskey),
                      ),
                    );
                  },
                  title: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        passSection["sectionDescription"],
                        style: cardHeader(),
                      )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: <Widget>[
                            if (item["total"] > 0)
                              Expanded(
                                child: _statusButton("Status", item["remain"]),
                              ),
                            if (item["total"] > 0)
                              Expanded(
                                  child: _remainButton(
                                      item["remain"].toString() +
                                          " Items remaining",
                                      item["remain"])),
                            if (item["total"] == 0)
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
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String serveytype;
  OnlineSerives onlineSerives = new OnlineSerives();

  TextStyle cardHeader() {
    return TextStyle(
      height: 1.2,
      letterSpacing: 2.0,
      fontSize: 30,
      fontWeight: FontWeight.w600,
      shadows: <Shadow>[
        Shadow(
          offset: Offset(1.0, 0.0),
          blurRadius: 0.0,
          color: Colors.black,
        ),
        Shadow(
          offset: Offset(1.0, 2.0),
          blurRadius: 2.0,
          color: Colors.black45,
        ),
      ],
    );
  }

  var headerShopSyskey = "";
  var flag;
  @override
  void initState() {
    super.initState();
    print("s->" + this.widget.question.toString());

    // var svrhdrSyskey = this.storage.getItem("allsectionHeadersyskey");
    // this.storage.setItem("allsectionHeadersyskey", svrhdrSyskey);
    // print("098-->" + svrhdrSyskey);
    completeStatus = this.storage.getItem("completeStatus");
    var _pssOject;
    if (this.widget.passData[0]["shopsyskey"] == null) {
      _pssOject = this.widget.passData[0]["id"];
    } else {
      _pssOject = this.widget.passData[0]["shopsyskey"];
    }

    var param = {
      "HeaderShopSyskey": "",
      "ShopTransSyskey": "",
      "SectionSyskey": "",
      "HeaderSyskey": this.widget.header["headerSyskey"].toString(),
      "ShopSyskey": _pssOject.toString(),
    };

    var data;
    var sinpleData = {};
    var totalCount;
    var answeredCount;
    var sections = this.widget.header["sections"];

    print("allsection->");
    print(param);

    this.onlineSerives.getQuestions(param, "allsection").then((value) => {
          data = value["data"],
          print("--data>>" + sections.toString()),
          for (var i = 0; i < sections.length; i++)
            {
              flag = false,
              sinpleData = {},
              totalCount = 0,
              answeredCount = 0,
              sinpleData["desc"] = sections[i]["sectionDescription"],
              for (var ii = 0; ii < data.length; ii++)
                {
                  if (data[ii]["SectionDesc"] ==
                      sections[i]["sectionDescription"])
                    {
                      if (data[ii]["Flag"].toString() == "1")
                        {
                          sinpleData["flag"] = "1",
                        },
                      this.allItem++,
                      totalCount++,
                      print("1ss-->" + data[ii]["TypeDesc"].toString()),
                      if (data[ii]["TypeDesc"] == "Fill in the Blank")
                        {
                          if (data[ii]["AnswerShopPhoto"].length > 0)
                            {
                              if (data[ii]["AnswerShopPhoto"][0]
                                      ["AnswerDesc1"] !=
                                  "")
                                {
                                  answeredCount++,
                                  answerItem++,
                                }
                            },
                        }
                      else if (data[ii]["TypeDesc"] == "Date")
                        {
                          if (data[ii]["AnswerShopPhoto"].length > 0)
                            {
                              if (data[ii]["AnswerShopPhoto"][0]
                                      ["AnswerDesc1"] !=
                                  "")
                                {
                                  answeredCount++,
                                  answerItem++,
                                }
                            },
                        }
                      else if (data[ii]["TypeDesc"] == "Rating 0-10")
                        {
                          if (data[ii]["AnswerShopPhoto"].length > 0)
                            {
                              if (data[ii]["AnswerShopPhoto"][0]
                                      ["AnswerDesc1"] !=
                                  "")
                                {
                                  answeredCount++,
                                  answerItem++,
                                }
                            },
                        }
                      else if (data[ii]["TypeDesc"] == "Number Range")
                        {
                          if (data[ii]["AnswerShopPhoto"].length > 0)
                            {
                              if (data[ii]["AnswerShopPhoto"][0]
                                          ["AnswerDesc1"] !=
                                      "" ||
                                  data[ii]["AnswerShopPhoto"][0]
                                          ["AnswerDesc2"] !=
                                      "")
                                {
                                  answeredCount++,
                                  answerItem++,
                                }
                            },
                        }
                      else if (data[ii]["TypeDesc"] == "Attach Photograph")
                        {
                          if (data[ii]["AnswerShopPhoto"].length > 0)
                            {
                              answeredCount++,
                              answerItem++,
                            },
                        }
                      else if (data[ii]["TypeDesc"] == "Checkbox")
                        {
                          if (data[ii]["AnswerShopPhoto"].length > 0)
                            {
                              if (data[ii]["AnswerShopPhoto"][0]
                                      ["AnswerDesc1"] !=
                                  "")
                                {
                                  answeredCount++,
                                  answerItem++,
                                }
                            },
                        }
                      else if (data[ii]["TypeDesc"] == "Multiple Choice")
                        {
                          if (data[ii]["AnswerShopPhoto"].length > 0)
                            {
                              if (data[ii]["AnswerShopPhoto"][0]
                                      ["AnswerDesc1"] !=
                                  "")
                                {
                                  answeredCount++,
                                  answerItem++,
                                }
                            },
                        }
                      else if (data[ii]["TypeDesc"] == "Time Range")
                        {
                          if (data[ii]["AnswerShopPhoto"].length > 0)
                            {
                              if (data[ii]["AnswerShopPhoto"][0]
                                      ["AnswerDesc1"] !=
                                  "")
                                {
                                  answeredCount++,
                                  answerItem++,
                                }
                            },
                        },
                    },
                  if (data[ii]["HeaderShopSyskey"].toString() != "")
                    {
                      headerShopSyskey = "",
                      headerShopSyskey =
                          data[ii]["HeaderShopSyskey"].toString(),
                    }
                },
              sinpleData["answered"] = answeredCount,
              sinpleData["total"] = totalCount,
              sinpleData["remain"] = totalCount - answeredCount,
              setState(() => {
                    headerItems.add(sinpleData),
                  }),
            },
          setState(() => {
                if (sections.length == 0)
                  {
                    continueStatus = false,
                  }
                else
                  {
                    if (allItem == answerItem)
                      {
                        continueStatus = true,
                      }
                  }
              }),
          print("questions-->" +
              this.headerItems.toString() +
              "--> " +
              this.widget.question.toString()),
        });
  }

  clickComplete() {
    var param = {"RespHdrSyskey": this.headerShopSyskey.toString()};
    this.onlineSerives.saveComplete(param).then((value) => {
          if (value == true)
            {
              ShowToast("Completed successfully"),
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => CheckNeighborhoodScreen(
                        this.widget.shopName,
                        this.widget.shopPhone,
                        this.widget.address,
                        this.widget.regOrAss,
                        this.widget.passData)),
              ),
            }
        });
  }

  Widget _statusButton(String text, var item) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(9),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Color(0XFFE0E0E0)),
        ),
        child: Center(
            child: item == 0
                ? Text(
                    "Complete",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  )
                : Text(
                    "Pending",
                    style: TextStyle(
                        color: Color(0xFFe0ac08), fontWeight: FontWeight.bold),
                  )),
      ),
    );
  }

  Widget _remainButton(text, var item) {
    if (item > 1) {
      text = item.toString() + " Items remaining";
    } else {
      text = item.toString() + " Item remaining";
    }
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(9),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Color(0XFFE0E0E0),
              width: 1.0,
            ),
            top: BorderSide(
              color: Color(0XFFE0E0E0),
              width: 1.0,
            ),
            bottom: BorderSide(
              color: Color(0XFFE0E0E0),
              width: 1.0,
            ),
          ),
        ),
        child: Center(
            child: item == 0
                ? Text(
                    text,
                    style: TextStyle(
                        color: Colors.red[200], fontWeight: FontWeight.bold),
                  )
                : Text(
                    text,
                    style: TextStyle(
                        color: CustomIcons.appbarColor,
                        fontWeight: FontWeight.bold),
                  )),
      ),
    );
  }

  RoundedRectangleBorder buttonShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: BorderSide(color: CustomIcons.dropDownHeader),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color(0xFFF8F8FF),
        drawer: MainMenuWidget(),
        appBar: AppBar(
          backgroundColor: CustomIcons.appbarColor,
          title: Text("Sections"),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 700,
                  color: Colors.grey[200],
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          this.widget.shopName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          this.widget.shopPhone,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          this.widget.address,
                          style: TextStyle(height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
                // error widget
                if (this.headerItems.length.toString() ==
                    this.widget.question.length.toString())
                  for (var x = 0; x < this.widget.question.length; x++)
                    sectionList(this.widget.question[x], this.headerItems[x])
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: CustomIcons.appbarColor,
          height: 50.0,
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => CheckNeighborhoodScreen(
                              this.widget.shopName,
                              this.widget.shopPhone,
                              this.widget.address,
                              this.widget.regOrAss,
                              this.widget.passData)),
                    );
                  },
                  child: Container(
                    height: 40,
                    width: 300,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Center(
                      child: new Text(
                        "Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (completeStatus != "Complete") {
                      if (continueStatus == true) {
                        this.clickComplete();
                      }
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 300,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Center(
                      child:
                          completeStatus == "Complete" || continueStatus != true
                              ? Text(
                                  "Complete",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white38,
                                      fontSize: 15),
                                )
                              : Text(
                                  "Complete",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
