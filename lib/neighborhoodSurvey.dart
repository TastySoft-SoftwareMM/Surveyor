import 'dart:io';
import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_material_pickers/helpers/show_date_picker.dart';
import 'package:http/http.dart' as http;
import 'package:Surveyor/Services/Messages/Messages.dart';
import 'package:Surveyor/outsideInsideNeighborhood.dart';
import 'package:Surveyor/widgets/mainmenuwidgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:load/load.dart';
import 'package:localstorage/localstorage.dart';
import 'Services/Loading/LoadingServices.dart';
import 'assets/custom_icons_icons.dart';
import 'package:Surveyor/Services/Online/OnlineServices.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

// ignore: must_be_immutable
class NeighborhoodSurveyScreen extends StatefulWidget {
  final bool isNeighborhood;
  final bool isOutside;
  final bool isInside;
  final bool isStoreOperater;
  final String storeName;
  final String storeNumber;
  final String address;
  final String surveyStage;
  final String surveyType;
  final String regOrAss;
  final passData;
  final question;
  final header;
  final allsection;
  final String headershopKey;

  NeighborhoodSurveyScreen(
    this.isNeighborhood,
    this.isOutside,
    this.isInside,
    this.isStoreOperater,
    this.storeName,
    this.storeNumber,
    this.address,
    this.surveyStage,
    this.surveyType,
    this.regOrAss,
    this.passData,
    this.question,
    this.header,
    this.allsection,
    this.headershopKey,
  );

  @override
  _NeighborhoodSurveyScreenState createState() =>
      _NeighborhoodSurveyScreenState();
}

class ImageUploadModel {
  bool isUploaded;
  bool uploading;
  File imageFile;
  String imageUrl;

  ImageUploadModel({
    this.isUploaded,
    this.uploading,
    this.imageFile,
    this.imageUrl,
  });
}

class _NeighborhoodSurveyScreenState extends State<NeighborhoodSurveyScreen> {
  bool check1 = false;
  bool check2 = false;
  bool check3 = false;
  bool check4 = false;
  OnlineSerives onlineSerives = new OnlineSerives();
  LocalStorage storage = new LocalStorage('Surveyor');
  List questions = [];
  List imageList = [];
  var questionNature;
  bool _status = true;
  var groupId2 = "";
  var newQuestionarray = [];
  var _allData = {};
  var imageName;
  var _consoleLable = "";
  var svr9DataList = [];
  var fillAnswerArray = [];
  var _primaryData = [];
  var _checkSaveorupdate;
  var url;
  var saveCondition = "1";
  var file;
  var completeStatus;
  var svrhdrSyskey = "";
  var userSyseky = "";

  Future<File> urlToFile(String imageUrl) async {
// generate random number.
    var rng = new Random();
// get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(imageUrl);
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    print("2");
    return file;
  }

  _clickDoneAssignStore() async {
    print("saveCondition->" + saveCondition.toString());
    var checkPHoto = "sinple";
    var sectionCompletestatus = "0";
    print("sdfd-->" + this.widget.header["status"].toString());
    if (this.widget.header["status"].toString() == "1.0") {
      sectionCompletestatus = "1";
    } else {
      sectionCompletestatus = "0";
    }
    for (var i = 0; i < this.questions.length; i++) {
      var loopdata = questions[i];
      var loopPrimary = _primaryData[i];
      if (loopdata["TypeDesc"] == "Attach Photograph") {
        checkPHoto = "have";
        if (loopPrimary["images"].length > 0) {
          checkPHoto = "answered";
          break;
        }
      }
    }

    if (checkPHoto == "have") {
      ShowToast("Please answer  the photo questions at least one");
      hideLoadingDialog();
    } else {
      Future.delayed(const Duration(milliseconds: 200), () async {
        await showLoading();
      });
      var _question = this.widget.question;
      var pssOject = this.widget.passData[0];

      print("pssObject");
      print(pssOject);
      // if (this.widget.regOrAss == "assign") {
      if (pssOject["shopsyskey"] == null) {
        _allData["id"] = pssOject["id"];
        _allData["saveCondition"] = saveCondition;
        _allData["active"] = true;
        _allData["name"] = pssOject["name"];
        _allData["mmName"] = pssOject["mmName"];
        _allData["personName"] = pssOject["personName"];
        _allData["personPhoneNumber"] = pssOject["personPhoneNumber"];
        _allData["phoneNumber"] = pssOject["phoneNumber"];
        _allData["stateId"] = pssOject["stateId"];
        _allData["districtId"] = pssOject["districtId"];
        _allData["townshipId"] = pssOject["townshipId"];
        _allData["townId"] = pssOject["townId"];
        _allData["wardId"] = pssOject["wardId"];
        _allData["address"] = pssOject["address"];
        _allData["street"] = pssOject["street"];
        _allData["t12"] = "";
        _allData["t14"] = "";
        var _syskey = "";
        _syskey = svrhdrSyskey;
        print("syskey1=>" + _syskey);
        _allData["svrHdrData"] = {
          "userSyskey": userSyseky.toString(),
          "syskey": _syskey,
          "n1": sectionCompletestatus,
          "n2": pssOject["id"].toString(),
          "n3": this.widget.header["headerSyskey"].toString()
        };

        _allData["locationData"] = {
          "latitude": pssOject["locationData"]["latitude"],
          "longitude": pssOject["locationData"]["longitude"],
          "plusCode": pssOject["locationData"]["plusCode"],
          "minuCode": pssOject["locationData"]["minuCode"]
        };
      } else {
        _allData["id"] = pssOject["shopsyskey"];
        _allData["saveCondition"] = saveCondition;
        _allData["active"] = true;
        _allData["name"] = pssOject["shopname"];
        _allData["mmName"] = pssOject["shopnamemm"];
        _allData["personName"] = pssOject["personname"];
        _allData["personPhoneNumber"] = pssOject["personph"];
        _allData["phoneNumber"] = pssOject["phoneno"];
        _allData["stateId"] = pssOject["stateid"];
        _allData["districtId"] = pssOject["districtid"];
        _allData["townshipId"] = pssOject["townshipid"];
        _allData["townId"] = pssOject["townid"];
        _allData["wardId"] = pssOject["wardid"];
        _allData["address"] = pssOject["address"];
        _allData["street"] = pssOject["street"];
        _allData["t12"] = "";
        _allData["t14"] = "";
        var _syskey = "";
        _syskey = svrhdrSyskey;

        _allData["svrHdrData"] = {
          "userSyskey": userSyseky.toString(),
          "syskey": _syskey,
          "n1": sectionCompletestatus,
          "n2": pssOject["shopsyskey"].toString(),
          "n3": this.widget.header["headerSyskey"].toString()
        };

        _allData["locationData"] = {
          "latitude": pssOject["lat"],
          "longitude": pssOject["long"],
          "plusCode": pssOject["pluscode"],
          "minuCode": pssOject["mimu"]
        };
      }
      // } else {}

      var questionAndAnswer = [];

      for (var i = 0; i < this.questions.length; i++) {
        var loopData = this.questions[i];
        var loopPrimary = {};
        loopPrimary = this._primaryData[i];

        if (loopData["TypeDesc"] == "Fill in the Blank") {
          var _value = {};
          _value["id"] = loopData["QuestionShopSyskey"];
          _value["questionTypeId"] = loopData["TypeSK"].toString();
          _value["questionNatureId"] = _question["sectionSyskey"].toString();
          _value["questionId"] = loopData["QuestionSyskey"].toString();
          _value["answerId"] = "0";
          _value["remark"] = "";
          _value["desc"] =
              loopData["QuestionDescription"]; //QuestionDescription
          _value["instruction"] = loopData["Instruction"];
          if (loopData["Comment"] == "") {
            _value["t4"] = "";
          } else {
            _value["t4"] = loopData["Comment"];
          }
          _value["t5"] = "";
          _value["n8"] = "0";
          if (loopData["Flag"] == "") {
            _value["n9"] = "0";
          } else {
            _value["n9"] = loopData["Flag"];
          }
          if (loopData["ApprovedFlag"] == "" ||
              loopData["ApprovedFlag"] == null) {
            _value["n10"] = "0";
          } else {
            _value["n10"] = loopData["ApprovedFlag"];
          }
          _value["svr9DataList"] = [
            {
              "recordStatus": 1,
              "t1": "",
              "t2": "",
              "t3": loopPrimary["AnswerDesc"],
              "t4": "",
              "n2": "",
            }
          ];
          questionAndAnswer.add(_value);
        } else if (loopData["TypeDesc"] == "Date") {
          var _value = {};
          _value["id"] = loopData["QuestionShopSyskey"];
          _value["questionTypeId"] = loopData["TypeSK"].toString();
          _value["questionNatureId"] = _question["sectionSyskey"].toString();
          _value["questionId"] = loopData["QuestionSyskey"].toString();
          _value["answerId"] = "0";
          _value["remark"] = "";
          _value["desc"] = loopData["QuestionDescription"];
          _value["instruction"] = loopData["Instruction"];
          if (loopData["Comment"] == null) {
            _value["t4"] = "";
          } else {
            _value["t4"] = loopData["Comment"];
          }
          _value["t5"] = "";
          _value["n8"] = "0";
          if (loopData["Flag"] == null) {
            _value["n9"] = "0";
          } else {
            _value["n9"] = loopData["Flag"];
          }
          if (loopData["ApprovedFlag"] == null) {
            _value["n10"] = "0";
          } else {
            _value["n10"] = loopData["ApprovedFlag"];
          }
          _value["svr9DataList"] = [
            {
              "recordStatus": 1,
              "t1": "",
              "t2": "",
              "t3": loopPrimary["servicedate"],
              "t4": "",
              "n2": "",
            }
          ];
          questionAndAnswer.add(_value);
        } else if (loopData["TypeDesc"] == "Rating 0-10") {
          var _value = {};
          _value["id"] = loopData["QuestionShopSyskey"];
          _value["questionTypeId"] = loopData["TypeSK"].toString();
          _value["questionNatureId"] = _question["sectionSyskey"].toString();
          _value["questionId"] = loopData["QuestionSyskey"].toString();
          _value["answerId"] = "0";
          _value["remark"] = "";
          _value["desc"] = loopData["QuestionDescription"];
          _value["instruction"] = loopData["Instruction"];
          if (loopData["Comment"] == null) {
            _value["t4"] = "";
          } else {
            _value["t4"] = loopData["Comment"];
          }
          _value["t5"] = "";
          _value["n8"] = "0";
          if (loopData["Flag"] == null) {
            _value["n9"] = "0";
          } else {
            _value["n9"] = loopData["Flag"];
          }
          if (loopData["ApprovedFlag"] == null) {
            _value["n10"] = "0";
          } else {
            _value["n10"] = loopData["ApprovedFlag"];
          }
          _value["svr9DataList"] = [
            {
              "recordStatus": 1,
              "t1": "",
              "t2": "",
              "t3": loopPrimary["rating"],
              "t4": "",
              "n2": "",
            }
          ];
          questionAndAnswer.add(_value);
        } else if (loopData["TypeDesc"] == "Number Range") {
          var _value = {};
          _value["id"] = loopData["QuestionShopSyskey"];
          _value["questionTypeId"] = loopData["TypeSK"].toString();
          _value["questionNatureId"] = _question["sectionSyskey"].toString();
          _value["questionId"] = loopData["QuestionSyskey"].toString();
          _value["answerId"] = "0";
          _value["remark"] = "";
          _value["desc"] = loopData["QuestionDescription"];
          _value["instruction"] = loopData["Instruction"];
          if (loopData["Comment"] == null) {
            _value["t4"] = "";
          } else {
            _value["t4"] = loopData["Comment"];
          }
          _value["t5"] = "";
          _value["n8"] = "0";
          if (loopData["Flag"] == null) {
            _value["n9"] = "0";
          } else {
            _value["n9"] = loopData["Flag"];
          }
          if (loopData["ApprovedFlag"] == null) {
            _value["n10"] = "0";
          } else {
            _value["n10"] = loopData["ApprovedFlag"];
          }
          _value["svr9DataList"] = [
            {
              "recordStatus": 1,
              "t1": "",
              "t2": "",
              "t3": loopPrimary["AnswerDesc1"],
              "t4": loopPrimary["AnswerDesc2"],
              "n2": "",
            }
            //  questions[ss]["AnswerShopPhoto"][0]["AnswerDesc1"];
            //             _data["AnswerDesc2"] =  questions[ss]["AnswerShopPhoto"][0]["AnswerDesc2"];
          ];
          questionAndAnswer.add(_value);
        } else if (loopData["TypeDesc"] == "Time Range") {
          var _value = {};
          _value["id"] = loopData["QuestionShopSyskey"];
          _value["questionTypeId"] = loopData["TypeSK"].toString();
          _value["questionNatureId"] = _question["sectionSyskey"].toString();
          _value["questionId"] = loopData["QuestionSyskey"].toString();
          _value["answerId"] = "0";
          _value["remark"] = "";
          _value["desc"] = loopData["QuestionDescription"];
          _value["instruction"] = loopData["Instruction"];
          if (loopData["Comment"] == null) {
            _value["t4"] = "";
          } else {
            _value["t4"] = loopData["Comment"];
          }
          _value["t5"] = "";
          _value["n8"] = "0";
          if (loopData["Flag"] == null) {
            _value["n9"] = "0";
          } else {
            _value["n9"] = loopData["Flag"];
          }
          if (loopData["ApprovedFlag"] == null) {
            _value["n10"] = "0";
          } else {
            _value["n10"] = loopData["ApprovedFlag"];
          }
          _value["svr9DataList"] = [
            {
              "recordStatus": 1,
              "t1": "",
              "t2": "",
              "t3": loopPrimary["AnswerDesc1"],
              "t4": loopPrimary["AnswerDesc2"],
              "n2": "",
            }
          ];
          questionAndAnswer.add(_value);
        } else if (loopData["TypeDesc"] == "Checkbox") {
          var _value = {};
          _value["id"] = loopData["QuestionShopSyskey"];
          _value["questionTypeId"] = loopData["TypeSK"].toString();
          _value["questionNatureId"] = _question["sectionSyskey"].toString();
          _value["questionId"] = loopData["QuestionSyskey"].toString();

          _value["remark"] = "";
          _value["desc"] = loopData["QuestionDescription"];
          _value["instruction"] = loopData["Instruction"];
          if (loopData["Comment"] == null) {
            _value["t4"] = "";
          } else {
            _value["t4"] = loopData["Comment"];
          }
          _value["t5"] = "";
          _value["n8"] = "0";
          if (loopData["Flag"] == null) {
            _value["n9"] = "0";
          } else {
            _value["n9"] = loopData["Flag"];
          }
          if (loopData["ApprovedFlag"] == null) {
            _value["n10"] = "0";
          } else {
            _value["n10"] = loopData["ApprovedFlag"];
          }
          if (loopPrimary["checkDatas"].length > 0) {
            var datalist = [];
            for (var x = 0; x < loopPrimary["checkDatas"].length; x++) {
              var data = {};
              if (loopPrimary["checkDatas"][x]["check"] == true) {
                data["recordStatus"] = 1;
                data["t1"] = "";
                data["t2"] = "";
                data["t3"] = loopPrimary["checkDatas"][x]["text"];
                data["t4"] = "";
                data["n2"] = loopPrimary["checkDatas"][x]["syskey"];
                datalist.add(data);
              }
            }

            _value["svr9DataList"] = datalist;
          } else {
            var datalist = [];

            _value["svr9DataList"] = datalist;
          }
          questionAndAnswer.add(_value);
        } else if (loopData["TypeDesc"] == "Attach Photograph") {
          var _value = {};
          _value["id"] = loopData["QuestionShopSyskey"];
          _value["questionTypeId"] = loopData["TypeSK"].toString();
          _value["questionNatureId"] = _question["sectionSyskey"].toString();
          _value["questionId"] = loopData["QuestionSyskey"].toString();
          _value["answerId"] = "0";
          _value["remark"] = "";
          _value["desc"] = loopData["QuestionDescription"];
          _value["instruction"] = loopData["Instruction"];
          if (loopData["Comment"] == null) {
            _value["t4"] = "";
          } else {
            _value["t4"] = loopData["Comment"];
          }
          _value["t5"] = "";
          _value["n8"] = "0";
          if (loopData["Flag"] == null) {
            _value["n9"] = "0";
          } else {
            _value["n9"] = loopData["Flag"];
          }
          if (loopData["ApprovedFlag"] == null) {
            _value["n10"] = "0";
          } else {
            _value["n10"] = loopData["ApprovedFlag"];
          }
          if (loopPrimary["images"].length > 0) {
            var datalist = [];
            for (var x = 0; x < loopPrimary["images"].length; x++) {
              var loopObj = loopPrimary["images"][x];

              var data = {};
              data["recordStatus"] = 1;
              if (loopObj["type"] == "online") {
                data["t1"] = loopObj["base64"].toString();
              } else {
                data["t1"] = loopObj["base64"].toString();
              }
              data["t2"] = loopObj["name"].toString();
              data["t3"] = "";
              data["t4"] = "";
              data["n2"] = "";
              datalist.add(data);
            }
            _value["svr9DataList"] = datalist;
            questionAndAnswer.add(_value);
          } else {
            var datalist = [];
            _value["svr9DataList"] = datalist;
            questionAndAnswer.add(_value);
          }
        } else if (loopData["TypeDesc"] == "Multiple Choice") {
          for (var ss = 0; ss < this.newQuestionarray.length; ss++) {
            if (this.newQuestionarray[ss]["questionSyskey"].toString() ==
                loopData["QuestionSyskey"].toString()) {
              var _value = {};
              _value["id"] = loopData["QuestionShopSyskey"];
              _value["questionTypeId"] = loopData["TypeSK"].toString();
              _value["questionNatureId"] =
                  _question["sectionSyskey"].toString();
              _value["questionId"] = loopData["QuestionSyskey"].toString();
              _value["answerId"] = "0";

              _value["remark"] = "";
              _value["desc"] = loopData["QuestionDescription"];
              _value["instruction"] = loopData["Instruction"];
              if (loopData["Comment"] == null) {
                _value["t4"] = "";
              } else {
                _value["t4"] = loopData["Comment"];
              }
              _value["t5"] = "";
              _value["n8"] = "0";
              if (loopData["Flag"] == null) {
                _value["n9"] = "0";
              } else {
                _value["n9"] = loopData["Flag"];
              }
              if (loopData["ApprovedFlag"] == null) {
                _value["n10"] = "0";
              } else {
                _value["n10"] = loopData["ApprovedFlag"];
              }
              _value["svr9DataList"] = [
                {
                  "t1": "",
                  "t2": "",
                  "t3": this.newQuestionarray[ss]["answerDesc"].toString(),
                  "t4": "",
                  "n2": this.newQuestionarray[ss]["answerSyskey"].toString(),
                }
              ];
              questionAndAnswer.add(_value);
            }
          }
        }
      }
      _allData["quesAndAns"] = questionAndAnswer;

      // setState(() {
      //   _consoleLable = _allData.toString();
      //   hideLoadingDialog();
      // });
      var aa;
      this.onlineSerives.createStore(_allData).then((reslut) => {
            hideLoadingDialog(),
            // aa = reslut["data"]["respHdrSyskey"].toString(),
            // setState((){
            //   this.storage.setItem("allsectionHeadersyskey", aa);
            // }),

            if (reslut["status"] == true)
              {
                this.storage.setItem("allsectionHeadersyskey",
                    reslut["data"]["respHdrSyskey"].toString()),
                print(
                    "445-->" + this.storage.getItem("allsectionHeadersyskey")),
                ShowToast("Saved successfully."),
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => OutsideInsideNeighborhood(
                        this.widget.isNeighborhood,
                        this.widget.isOutside,
                        this.widget.isInside,
                        this.widget.isStoreOperater,
                        this.widget.storeName,
                        this.widget.storeNumber,
                        this.widget.address,
                        this.widget.regOrAss,
                        this.widget.passData,
                        this.widget.allsection,
                        this.widget.header),
                  ),
                )
              }
            else
              {}
          });
    }
  }

  void newImageName() {
    var nowdate = DateTime.now();
    imageName = "${nowdate.year}" +
        "${nowdate.month}" +
        "${nowdate.day}" +
        "${nowdate.hour}" +
        "${nowdate.minute}" +
        "${nowdate.second}" +
        "${nowdate.millisecond}";
  }

  String base64String;

  Future getImageFromCamera(var syskey, var images) async {
    final image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (image != null) {
        if (image.path == '') {
        } else {
          newImageName();
          var datas = {};
          datas["image"] = image;
          datas["name"] = imageName;
          datas["type"] = "file";
          imageFileList(syskey, imageName, image, datas);
          images.add(datas);
        }
      }
    });
  }

  Future getImageFromGallery(var syskey, var images) async {
    List<File> files = await FilePicker.getMultiFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (files != null) {
      for (var i = 0; i < files.length; i++) {
        setState(() {
          newImageName();
          var datas = {};
          datas["image"] = files[i];
          datas["name"] = imageName;
          datas["type"] = "file";
          imageFileList(syskey, imageName, files[i], datas);
          images.add(datas);
          // images.add(files[i]);
        });
      }
    }
  }

  Future<void> imageFileList(
      var syskey, var imageName, var imageFileList, var datasobj) async {
    // List returnList = [];
    var result = await FlutterImageCompress.compressWithFile(
      imageFileList.path,
      minWidth: 400,
      minHeight: 400,
      quality: 50,
      rotate: 0,
    );

    String base64Image = "data:image/png;base64," + base64Encode(result);
    datasobj["base64"] = base64Image;
    imageList.add({
      "syskey": "$syskey",
      "base64Image": "$base64Image",
      "imageName": "$imageName"
    });
  }

  Future<String> convertBase64(var imagefile) async {
    var result = await FlutterImageCompress.compressWithFile(
      imagefile.path,
      minWidth: 400,
      minHeight: 400,
      quality: 50,
      rotate: 0,
    );
    String base64Image = "data:image/png;base64," + base64Encode(result);
    return base64Image;
  }

  Widget buildRadio(var answerList, var questionIndex) {
    //  return Text(answerList.toString());
    return Column(
      children: <Widget>[
        for (var q = 0; q < answerList.length; q++)
          for (var ee = 0; ee < this.newQuestionarray.length; ee++)
            if (answerList[q]["questionSyskey"].toString() ==
                this.newQuestionarray[ee]["questionSyskey"].toString())
              RadioListTile(
                groupValue:
                    this.newQuestionarray[ee]["answerSyskey"].toString(),
                title: Text(answerList[q]["text"].toString()),
                value: answerList[q]["syskey"].toString(),
                onChanged: (aaa) {
                  setState(() {
                    this.newQuestionarray[ee]["answerSyskey"] = aaa.toString();
                    this.newQuestionarray[ee]["answerDesc"] =
                        answerList[q]["text"].toString();
                  });
                },
              ),
      ],
    );
  }

  BoxDecoration flagDecoration(var flag) {
    if (flag == "1") {
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

  Widget attachPhotograph(data, _imageslist) {
    var t1 = data["QuestionCode"];
    var t2 = data["QuestionDescription"];
    var images = [];
    return Container(
      decoration: flagDecoration(data["Flag"]),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        t1 + " : " + t2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {},
            ),
          ),
          Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 1, 5, 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: CustomIcons.iconColor),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    padding: EdgeInsets.all(5),
                    // margin: EdgeInsets.fromLTRB(23, 20, 20, 20),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Instructions :",
                          style: TextStyle(),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            data["Instruction"],
                            style: TextStyle(color: CustomIcons.appbarColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
            color: Colors.grey[200],
            child: Row(
              children: <Widget>[
                Spacer(),
                RaisedButton(
                  child: Text("Camera"),
                  onPressed: () {
                    getImageFromCamera(data["QuestionSyskey"], _imageslist);
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  child: Text("Library"),
                  onPressed: () {
                    getImageFromGallery(data["QuestionSyskey"], _imageslist);
                  },
                ),
                Spacer(),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            child: GridView.count(
              shrinkWrap: true,
              controller: ScrollController(keepScrollOffset: false),
              scrollDirection: Axis.vertical,
              crossAxisCount: 4,
              children: List.generate(_imageslist.length, (index) {
                return storeImage(_imageslist[index], index, _imageslist);
              }),
            ),
          ),
          _commentWidget(data["Flag"], data),
        ],
      ),
    );
  }

  Widget multipleChoice(
      var t1, var t2, var data, var questionIndex, var singleQuestion) {
    return Container(
      decoration: flagDecoration(singleQuestion["Flag"]),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
//                    Text(
//                      t1,
//                      style: TextStyle(color: Colors.black),
//                    ),
//                    if (t1 != null && t2 != null)
//                      Text(
//                        " :",
//                        style: TextStyle(color: Colors.black),
//                      ),
//                    SizedBox(
//                      width: 10,
//                    ),
                    Flexible(
                      child: Text(
                        t1 + " : " + t2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {},
            ),
          ),
          Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[buildRadio(data, questionIndex)],
                // children: <Widget>[buildRadio(data, questionIndex)],
              )),
          _commentWidget(singleQuestion["Flag"], singleQuestion),
        ],
      ),
    );
  }

  Widget _commentWidget(var flag, var data) {
    if (flag.toString() == "1") {
      return Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(12),
        height: 10 * 24.0,
        child: TextField(
          enabled: false,
          maxLines: 10,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            hintText: data["Comment"].toString(),
            fillColor: Colors.grey[300],
            filled: true,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget checkBox(var data, var datas) {
    var t1 = data["QuestionCode"];
    var t2 = data["QuestionDescription"];
    return Container(
      decoration: flagDecoration(data["Flag"]),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
//                    Text(
//                      t1,
//                      style: TextStyle(color: Colors.black),
//                    ),
//                    if (t1 != null && t2 != null)
//                      Text(
//                        " :",
//                        style: TextStyle(color: Colors.black),
//                      ),
//                    SizedBox(
//                      width: 10,
//                    ),
                    Flexible(
                      child: Text(
                        t1 + " : " + t2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {},
            ),
          ),
          Container(
              color: Colors.grey[200],
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  for (var i = 0; i < datas.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Checkbox(
                              value: datas[i]["check"],
                              onChanged: (bool newValue) {
                                setState(() {
                                  datas[i]["check"] = !datas[i]["check"];
                                });
                              }),
                          SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Text(
                              datas[i]["text"].toString(),
                              // "asdfghjksdfghjkdfgdgdddddddddddddddddddddddddddddddddddddddddddddddddddddddsdfsdfsdfsfsfsfsdfsdfsdfsdfsdfsdfs",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              )),
          _commentWidget(data["Flag"], data),
        ],
      ),
    );
  }

  Widget fillintheBlank(var data, var primarydata) {
    var t1 = data["QuestionCode"];
    var t2 = data["QuestionDescription"];
    TextEditingController _textController = new TextEditingController();
    _textController.text = primarydata["AnswerDesc"];
    return Container(
      decoration: flagDecoration(data["Flag"]),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        t1 + " : " + t2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {},
            ),
          ),
          Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    // margin: EdgeInsets.fromLTRB(23, 20, 20, 20),
                    child: TextField(
                      controller: _textController,
                      onChanged: (val) {
                        primarydata["AnswerDesc"] = _textController.text;
                      },
                      decoration: InputDecoration(
                        focusColor: Colors.black,
                        prefixIcon: Icon(
                          Icons.question_answer,
                          color: CustomIcons.iconColor,
                        ),
                        hintText: 'Answer',
                        hintStyle: TextStyle(fontSize: 18, height: 1.5),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          _commentWidget(data["Flag"], data),
        ],
      ),
    );
  }

  Widget storeImage(var image, int index, var data) {
    var online = this.subUrl + image["image"].toString();
    if (image["image"] != "") {
      return Container(
        margin: EdgeInsets.all(5),
        child: Center(
          child: Stack(
            children: <Widget>[
              GestureDetector(onTap: () {
                if (image["type"] == "online") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowImage(
                                image: Image.network(online.toString()),
                              )));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowImage(
                                image: Image(
                                  image: FileImage(image["image"]),
                                ),
                              )));
                }
              }, child: Builder(builder: (context) {
                if (image["type"] == "online") {
                  return Image.network(
                    online.toString(),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  );
                } else {
                  return Image(
                    image: FileImage(image["image"]),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  );
                }
              })),
              Positioned(
                right: 2,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      data.removeAt(index);
                      // imageLists.removeAt(index);
//                    this.svr9DataList = [];
                    });
                  },
                  child: Container(
                    width: 22.0,
                    height: 22.0,
                    padding: const EdgeInsets.all(0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image(
                      image: AssetImage('assets/close.png'),
                      color: Colors.red,
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget headerBuilder(String title, String secondTitle) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: Row(
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    secondTitle,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container()
        ],
      ),
    );
  }

  var subUrl;

  // networkImageToBase64(String imageUrl) async {
  //   http.Response response = await http.get(imageUrl);
  //   final bytes = response?.bodyBytes;
  //   return (bytes != null ? base64Encode(bytes) : null);
  // }

  @override
  void initState() {
    super.initState();
//    if(){} for questionNature
    completeStatus = this.storage.getItem("completeStatus");
    svrhdrSyskey = this.storage.getItem("allsectionHeadersyskey");
    var tempData = this.storage.getItem("loginData");
    userSyseky = tempData["syskey"].toString();
    print("098-->" + userSyseky.toString());
    var _pssOject;
    if (this.widget.passData[0]["shopsyskey"] == null) {
      _pssOject = this.widget.passData[0]["id"];
    } else {
      _pssOject = this.widget.passData[0]["shopsyskey"];
    }

    this.url = this.storage.getItem('URL');
    this.subUrl = url.substring(0, url.lastIndexOf("8084/")) + "8084";

    if (this.widget.surveyType == "Neighborhood Survey") {
      this.questionNature = "Neighborhood Survey";
    } else if (this.widget.surveyType == "Outside of Store") {
      this.questionNature = "Outside of Store";
    } else if (this.widget.surveyType == "Inside of Store") {
      this.questionNature = "Inside of Store";
    } else if (this.widget.surveyType == "Store Operator") {
      this.questionNature = "Store Operator Information";
    }
    var param = {
      "HeaderShopSyskey": "",
      "ShopTransSyskey": "",
      "SectionSyskey": this.widget.question["sectionSyskey"].toString(),
      "HeaderSyskey": this.widget.header["headerSyskey"].toString(),
      "ShopSyskey": _pssOject.toString(),
    };
    var _data = {};
    var onlinePhoto = [];
    var checkData = [];
    var answers, shopPhoto, answerSyskey;
    var checkObj = {};
    var radioObj = {};
    var radioData = [];
    var syskeys = {};
    var getdefaultAns, year, month, day;
    DateTime selectedDate;
    String fulldate;
    showLoading();
    // this
    //     .onlineSerives
    //     .getQuestions(param, "eachsection")
    //     .then((result) => {
    //           // setState(() {
    //           this._checkSaveorupdate = result["checkSaveorupdate"],
    //           if (result["status"] == true)
    //             {
    //               questions = result["data"],
    //               print("Q->" + questions.toString()),
    //               //              setState(() {
    //               //    _consoleLable = result.toString();
    //               //   // hideLoadingDialog();
    //               // });s
    //               if (questions.length > 0)
    //                 {
    //                   for (var ss = 0; ss < questions.length; ss++)
    //                     {
    //                       _data = {},
    //                       _data["sysKey"] = questions[ss]["QuestionSyskey"],
    //                       if (questions[ss]["TypeDesc"] == "Attach Photograph")
    //                         {
    //                           print("1>>" + questions[ss].toString()),
    //                           onlinePhoto = [],
    //                           // getImage(ss, _data, onlinePhoto),
    //                         }
    //                       else if (questions[ss]["TypeDesc"] == "Checkbox")
    //                         {
    //                           print("2>>" + questions[ss].toString()),
    //                           checkData = [],
    //                           for (var x = 0;
    //                               x < questions[ss]["answers"].length;
    //                               x++)
    //                             {
    //                               answers = questions[ss]["answers"][x],
    //                               checkObj = {},
    //                               checkObj["text"] = answers["answerDesc"],
    //                               checkObj["syskey"] = answers["answerSK"],
    //                               checkObj["check"] = false,
    //                               if (questions[ss]["AnswerShopPhoto"].length >
    //                                   0)
    //                                 {
    //                                   for (var y = 0;
    //                                       y <
    //                                           questions[ss]["AnswerShopPhoto"]
    //                                               .length;
    //                                       y++)
    //                                     {
    //                                       shopPhoto = questions[ss]
    //                                           ["AnswerShopPhoto"][y],
    //                                       if (shopPhoto["AnswerSyskey"] ==
    //                                           answers["answerSK"])
    //                                         {
    //                                           checkObj["check"] = true,
    //                                         }
    //                                     },
    //                                   checkData.add(checkObj),
    //                                 }
    //                               else
    //                                 {
    //                                   checkData.add(checkObj),
    //                                 }
    //                             },
    //                           _data["checkDatas"] = checkData,
    //                           _data["images"] = [],
    //                           _data["radioDatas"] = [],
    //                           // print("ssdf-->" + _data.toString());
    //                         }
    //                       else if (questions[ss]["TypeDesc"] ==
    //                           "Multiple Choice")
    //                         {
    //                           print("3>>" + questions[ss].toString()),
    //                           answerSyskey = "",
    //                           if (questions[ss]["AnswerShopPhoto"].length > 0)
    //                             {
    //                               answerSyskey = questions[ss]
    //                                   ["AnswerShopPhoto"][0]["AnswerSyskey"],
    //                             }
    //                           else
    //                             {
    //                               answerSyskey =
    //                                   questions[ss]["answers"][0]["answerSK"],
    //                             },
    //                           print("123-->"),
    //                           radioObj = {},
    //                           radioData = [],
    //                           syskeys = {},
    //                           syskeys["questionSyskey"] =
    //                               questions[ss]["QuestionSyskey"].toString(),
    //                           for (var x = 0;
    //                               x < questions[ss]["answers"].length;
    //                               x++)
    //                             {
    //                               radioObj = {},
    //                               getdefaultAns = questions[ss]["answers"][0],
    //                               answers = questions[ss]["answers"][x],
    //                               radioObj["text"] = answers["answerDesc"],
    //                               radioObj["syskey"] = answers["answerSK"],
    //                               radioObj["questionSyskey"] = questions[ss]
    //                                       ["QuestionSyskey"]
    //                                   .toString(),
    //                               if (answerSyskey == "")
    //                                 {
    //                                   syskeys["answerSyskey"] =
    //                                       getdefaultAns["answerSK"].toString(),
    //                                   syskeys["answerDesc"] =
    //                                       getdefaultAns["answerDesc"]
    //                                           .toString(),
    //                                 }
    //                               else
    //                                 {
    //                                   syskeys["answerSyskey"] =
    //                                       answerSyskey.toString(),
    //                                   if (answerSyskey.toString() ==
    //                                       answers["answerSK"].toString())
    //                                     {
    //                                       syskeys["answerSyskey"] =
    //                                           answers["answerSK"].toString(),
    //                                       syskeys["answerDesc"] =
    //                                           answers["answerDesc"].toString(),
    //                                     }
    //                                 },
    //                               radioData.add(radioObj),
    //                             },
    //                           this.newQuestionarray.add(syskeys),
    //                           radioObj["qustionSyskey"] =
    //                               _data["radioDatas"] = radioData,
    //                           _data["checkDatas"] = [],
    //                           _data["images"] = [],
    //                         }
    //                       else if (questions[ss]["TypeDesc"] == "Date")
    //                         {
    //                           print("4>>" + questions[ss].toString()),
    //                           if (questions[ss]["AnswerShopPhoto"].length > 0)
    //                             {
    //                               fulldate = questions[ss]["AnswerShopPhoto"][0]
    //                                   ["AnswerDesc1"],
    //                               year = fulldate.substring(0, 4),
    //                               month = fulldate.substring(4, 6),
    //                               day = fulldate.substring(6, 8),
    //                               _data["servicedate"] = questions[ss]
    //                                   ["AnswerShopPhoto"][0]["AnswerDesc1"],
    //                               _data["dateFormat"] =
    //                                   year + "-" + month + "-" + day,
    //                               _data["showDate"] =
    //                                   day + "/" + month + "/" + year,
    //                             }
    //                           else
    //                             {
    //                               selectedDate = DateTime.now(),
    //                               fulldate = selectedDate.toString(),
    //                               day = fulldate.substring(8, 10),
    //                               month = fulldate.substring(5, 7),
    //                               year = fulldate.substring(0, 4),
    //                               _data["servicedate"] = year + month + day,
    //                               _data["dateFormat"] =
    //                                   year + "-" + month + "-" + day,
    //                               _data["showDate"] =
    //                                   day + "/" + month + "/" + year,
    //                             },
    //                           _data["radioDatas"] = [],
    //                           _data["checkDatas"] = [],
    //                           _data["images"] = [],
    //                         }
    //                       else if (questions[ss]["TypeDesc"] == "Number Range")
    //                         {
    //                           print("5>>" + questions[ss].toString()),
    //                           if (questions[ss]["AnswerShopPhoto"].length > 0)
    //                             {
    //                               _data["AnswerDesc1"] = questions[ss]
    //                                   ["AnswerShopPhoto"][0]["AnswerDesc1"],
    //                               _data["AnswerDesc2"] = questions[ss]
    //                                   ["AnswerShopPhoto"][0]["AnswerDesc2"],
    //                             }
    //                           else
    //                             {
    //                               _data["AnswerDesc1"] = "",
    //                               _data["AnswerDesc2"] = "",
    //                             },
    //                           _data["radioDatas"] = [],
    //                           _data["checkDatas"] = [],
    //                           _data["images"] = [],
    //                         }
    //                       else if (questions[ss]["TypeDesc"] == "Time Range")
    //                         {
    //                           print("6>>" + questions[ss].toString()),
    //                           if (questions[ss]["AnswerShopPhoto"].length > 0)
    //                             {
    //                               _data["AnswerDesc1"] = questions[ss]
    //                                   ["AnswerShopPhoto"][0]["AnswerDesc1"],
    //                               _data["AnswerDesc2"] = questions[ss]
    //                                   ["AnswerShopPhoto"][0]["AnswerDesc2"],
    //                             }
    //                           else
    //                             {
    //                               _data["AnswerDesc1"] = "",
    //                               _data["AnswerDesc2"] = "",
    //                             },
    //                           _data["radioDatas"] = [],
    //                           _data["checkDatas"] = [],
    //                           _data["images"] = [],
    //                         }
    //                       else if (questions[ss]["TypeDesc"] == "Rating 0-10")
    //                         {
    //                           print("7>>" + questions[ss].toString()),
    //                           if (questions[ss]["AnswerShopPhoto"].length > 0)
    //                             {
    //                               _data["rating"] = questions[ss]
    //                                   ["AnswerShopPhoto"][0]["AnswerDesc1"],
    //                             }
    //                           else
    //                             {
    //                               _data["rating"] = "0",
    //                             },
    //                           _data["radioDatas"] = [],
    //                           _data["checkDatas"] = [],
    //                           _data["images"] = [],
    //                         }
    //                       else if (questions[ss]["TypeDesc"] ==
    //                           "Fill in the Blank")
    //                         {
    //                           print("8>>" + questions[ss].toString()),
    //                           if (questions[ss]["AnswerShopPhoto"].length > 0)
    //                             {
    //                               _data["AnswerDesc"] = questions[ss]
    //                                   ["AnswerShopPhoto"][0]["AnswerDesc1"],
    //                             }
    //                           else
    //                             {
    //                               _data["AnswerDesc"] = "",
    //                             },
    //                           _data["radioDatas"] = [],
    //                           _data["checkDatas"] = [],
    //                           _data["images"] = [],
    //                         }
    //                       else
    //                         {
    //                           _data["radioDatas"] = [],
    //                           _data["checkDatas"] = [],
    //                           _data["images"] = [],
    //                         },
    //                       _primaryData.add(_data),
    //                       print("conditionEnd->" + _primaryData.toString()),
    //                     },
    //                   // hideLoadingDialog(),
    //                   // setState(() {
    //                   //
    //                   // }),
    //                 },
    //               _status = true,
    //             }
    //           else
    //             {
    //               _status = false,
    //               hideLoadingDialog(),
    //             }
    //           // }),
    //         })
    //     .catchError((err) => {});
    samplefunction(param);

    // if (this.widget.headershopKey == "") {
    //   saveCondition = "1";
    // } else {
    //   // setState(() {
    //   for (var i = 0; i < questions.length; i++) {
    //     if (questions[i]["AnswerShopPhoto"].length > 0) {
    //       saveCondition = "";
    //       break;
    //     }
    //     if (questions[i]["AnswerDesc"] != "") {
    //       saveCondition = "";
    //       break;
    //     }
    //     if (questions[i]["AnswerSyskey"] != "") {
    //       saveCondition = "";
    //       break;
    //     }
    //   }
    //   // hideLoadingDialog();
    //   // }),
    // }
    print("12300->" + _primaryData.toString() + "_____" + _status.toString());
  }

  samplefunction(param) async {
    var _data = {};
    var onlinePhoto = [];
    var checkData = [];
    var answers, shopPhoto, answerSyskey;
    var checkObj = {};
    var radioObj = {};
    var radioData = [];
    var syskeys = {};
    var datas = {};
    List<int> imageBytes;
    String base64Image;
    var getdefaultAns, year, month, day, fullurl;
    DateTime selectedDate;
    String fulldate;
    await this
        .onlineSerives
        .getQuestions(param, "eachsection")
        .then((result) async => {
              // setState(() {
              this._checkSaveorupdate = result["checkSaveorupdate"],
              if (result["status"] == true)
                {
                  questions = result["data"],
                  print("Q->" + questions.toString()),
                  //              setState(() {
                  //    _consoleLable = result.toString();
                  //   // hideLoadingDialog();
                  // });s
                  if (questions.length > 0)
                    {
                      for (var ss = 0; ss < questions.length; ss++)
                        {
                          _data = {},
                          _data["sysKey"] = questions[ss]["QuestionSyskey"],
                          if (questions[ss]["TypeDesc"] == "Attach Photograph")
                            {
                              print("1>>" + questions[ss].toString()),
                              onlinePhoto = [],
                              if (questions[ss]["AnswerShopPhoto"].length > 0)
                                {
                                  for (var y = 0;
                                      y <
                                          questions[ss]["AnswerShopPhoto"]
                                              .length;
                                      y++)
                                    {
                                      datas = {},
                                      shopPhoto =
                                          questions[ss]["AnswerShopPhoto"][y],
                                      datas["image"] = shopPhoto["PhotoPath"],
                                      datas["name"] = shopPhoto["PhotoName"],
                                      datas["type"] = "online",
                                      fullurl = this.subUrl +
                                          shopPhoto["PhotoPath"].toString(),
                                      print("1->" + y.toString()),
                                      file = await urlToFile(fullurl),
                                      print("3->"),
                                      if (file.toString() != "")
                                        {
                                          imageBytes = file.readAsBytesSync(),
                                          print("4->"),
                                          base64Image =
                                              "data:image/png;base64," +
                                                  base64Encode(imageBytes)
                                                      .toString(),
                                          datas["base64"] = base64Image,
                                        }
                                      else
                                        {
                                          datas["base64"] = "",
                                        },
                                      onlinePhoto.add(datas),
                                    },
                                  _data["images"] = onlinePhoto,
                                }
                              else
                                {
                                  _data["images"] = [],
                                },
                              _data["checkDatas"] = [],
                              // getImage(ss, _data, onlinePhoto),
                            }
                          else if (questions[ss]["TypeDesc"] == "Checkbox")
                            {
                              print("2>>" + questions[ss].toString()),
                              checkData = [],
                              for (var x = 0;
                                  x < questions[ss]["answers"].length;
                                  x++)
                                {
                                  answers = questions[ss]["answers"][x],
                                  checkObj = {},
                                  checkObj["text"] = answers["answerDesc"],
                                  checkObj["syskey"] = answers["answerSK"],
                                  checkObj["check"] = false,
                                  if (questions[ss]["AnswerShopPhoto"].length >
                                      0)
                                    {
                                      for (var y = 0;
                                          y <
                                              questions[ss]["AnswerShopPhoto"]
                                                  .length;
                                          y++)
                                        {
                                          shopPhoto = questions[ss]
                                              ["AnswerShopPhoto"][y],
                                          if (shopPhoto["AnswerSyskey"] ==
                                              answers["answerSK"])
                                            {
                                              checkObj["check"] = true,
                                            }
                                        },
                                      checkData.add(checkObj),
                                    }
                                  else
                                    {
                                      checkData.add(checkObj),
                                    }
                                },
                              _data["checkDatas"] = checkData,
                              _data["images"] = [],
                              _data["radioDatas"] = [],
                              // print("ssdf-->" + _data.toString());
                            }
                          else if (questions[ss]["TypeDesc"] ==
                              "Multiple Choice")
                            {
                              print("3>>" + questions[ss].toString()),
                              answerSyskey = "",
                              if (questions[ss]["AnswerShopPhoto"].length > 0)
                                {
                                  answerSyskey = questions[ss]
                                      ["AnswerShopPhoto"][0]["AnswerSyskey"],
                                }
                              else
                                {
                                  answerSyskey =
                                      questions[ss]["answers"][0]["answerSK"],
                                },
                              print("123-->"),
                              radioObj = {},
                              radioData = [],
                              syskeys = {},
                              syskeys["questionSyskey"] =
                                  questions[ss]["QuestionSyskey"].toString(),
                              for (var x = 0;
                                  x < questions[ss]["answers"].length;
                                  x++)
                                {
                                  radioObj = {},
                                  getdefaultAns = questions[ss]["answers"][0],
                                  answers = questions[ss]["answers"][x],
                                  radioObj["text"] = answers["answerDesc"],
                                  radioObj["syskey"] = answers["answerSK"],
                                  radioObj["questionSyskey"] = questions[ss]
                                          ["QuestionSyskey"]
                                      .toString(),
                                  if (answerSyskey == "")
                                    {
                                      syskeys["answerSyskey"] =
                                          getdefaultAns["answerSK"].toString(),
                                      syskeys["answerDesc"] =
                                          getdefaultAns["answerDesc"]
                                              .toString(),
                                    }
                                  else
                                    {
                                      syskeys["answerSyskey"] =
                                          answerSyskey.toString(),
                                      if (answerSyskey.toString() ==
                                          answers["answerSK"].toString())
                                        {
                                          syskeys["answerSyskey"] =
                                              answers["answerSK"].toString(),
                                          syskeys["answerDesc"] =
                                              answers["answerDesc"].toString(),
                                        }
                                    },
                                  radioData.add(radioObj),
                                },
                              this.newQuestionarray.add(syskeys),
                              radioObj["qustionSyskey"] =
                                  _data["radioDatas"] = radioData,
                              _data["checkDatas"] = [],
                              _data["images"] = [],
                            }
                          else if (questions[ss]["TypeDesc"] == "Date")
                            {
                              print("4>>" + questions[ss].toString()),
                              if (questions[ss]["AnswerShopPhoto"].length > 0)
                                {
                                  fulldate = questions[ss]["AnswerShopPhoto"][0]
                                      ["AnswerDesc1"],
                                  year = fulldate.substring(0, 4),
                                  month = fulldate.substring(4, 6),
                                  day = fulldate.substring(6, 8),
                                  _data["servicedate"] = questions[ss]
                                      ["AnswerShopPhoto"][0]["AnswerDesc1"],
                                  _data["dateFormat"] =
                                      year + "-" + month + "-" + day,
                                  _data["showDate"] =
                                      day + "/" + month + "/" + year,
                                }
                              else
                                {
                                  selectedDate = DateTime.now(),
                                  fulldate = selectedDate.toString(),
                                  day = fulldate.substring(8, 10),
                                  month = fulldate.substring(5, 7),
                                  year = fulldate.substring(0, 4),
                                  _data["servicedate"] = year + month + day,
                                  _data["dateFormat"] =
                                      year + "-" + month + "-" + day,
                                  _data["showDate"] =
                                      day + "/" + month + "/" + year,
                                },
                              _data["radioDatas"] = [],
                              _data["checkDatas"] = [],
                              _data["images"] = [],
                            }
                          else if (questions[ss]["TypeDesc"] == "Number Range")
                            {
                              print("5>>" + questions[ss].toString()),
                              if (questions[ss]["AnswerShopPhoto"].length > 0)
                                {
                                  _data["AnswerDesc1"] = questions[ss]
                                      ["AnswerShopPhoto"][0]["AnswerDesc1"],
                                  _data["AnswerDesc2"] = questions[ss]
                                      ["AnswerShopPhoto"][0]["AnswerDesc2"],
                                }
                              else
                                {
                                  _data["AnswerDesc1"] = "",
                                  _data["AnswerDesc2"] = "",
                                },
                              _data["radioDatas"] = [],
                              _data["checkDatas"] = [],
                              _data["images"] = [],
                            }
                          else if (questions[ss]["TypeDesc"] == "Time Range")
                            {
                              print("6>>" + questions[ss].toString()),
                              if (questions[ss]["AnswerShopPhoto"].length > 0)
                                {
                                  _data["AnswerDesc1"] = questions[ss]
                                      ["AnswerShopPhoto"][0]["AnswerDesc1"],
                                  _data["AnswerDesc2"] = questions[ss]
                                      ["AnswerShopPhoto"][0]["AnswerDesc2"],
                                }
                              else
                                {
                                  _data["AnswerDesc1"] = "",
                                  _data["AnswerDesc2"] = "",
                                },
                              _data["radioDatas"] = [],
                              _data["checkDatas"] = [],
                              _data["images"] = [],
                            }
                          else if (questions[ss]["TypeDesc"] == "Rating 0-10")
                            {
                              print("7>>" + questions[ss].toString()),
                              if (questions[ss]["AnswerShopPhoto"].length > 0)
                                {
                                  _data["rating"] = questions[ss]
                                      ["AnswerShopPhoto"][0]["AnswerDesc1"],
                                }
                              else
                                {
                                  _data["rating"] = "0",
                                },
                              _data["radioDatas"] = [],
                              _data["checkDatas"] = [],
                              _data["images"] = [],
                            }
                          else if (questions[ss]["TypeDesc"] ==
                              "Fill in the Blank")
                            {
                              print("8>>" + questions[ss].toString()),
                              if (questions[ss]["AnswerShopPhoto"].length > 0)
                                {
                                  _data["AnswerDesc"] = questions[ss]
                                      ["AnswerShopPhoto"][0]["AnswerDesc1"],
                                }
                              else
                                {
                                  _data["AnswerDesc"] = "",
                                },
                              _data["radioDatas"] = [],
                              _data["checkDatas"] = [],
                              _data["images"] = [],
                            }
                          else
                            {
                              _data["radioDatas"] = [],
                              _data["checkDatas"] = [],
                              _data["images"] = [],
                            },
                          _primaryData.add(_data),
                          print("conditionEnd->" + _primaryData.toString()),
                        },
                      // hideLoadingDialog(),
                      // setState(() {
                      //
                      // }),
                    },
                  _status = true,
                }
              else
                {
                  _status = false,
                  hideLoadingDialog(),
                }
              // }),
            })
        .catchError((err) => {});
    print("await data ----------");
    if (this.widget.headershopKey == "") {
      saveCondition = "1";
    } else {
      for (var i = 0; i < questions.length; i++) {
        if (questions[i]["AnswerShopPhoto"].length > 0) {
          saveCondition = "";
          break;
        }
        if (questions[i]["AnswerDesc"] != "") {
          saveCondition = "";
          break;
        }
        if (questions[i]["AnswerSyskey"] != "") {
          saveCondition = "";
          break;
        }
      }
      print("121--");
    }
    hideLoadingDialog();
    setState(() {});
  }

  getImage(index, _data, onlinePhoto) async {
    if (questions[index]["AnswerShopPhoto"].length > 0) {
      for (var y = 0; y < questions[index]["AnswerShopPhoto"].length; y++) {
        var datas = {};
        var shopPhoto = questions[index]["AnswerShopPhoto"][y];
        datas["image"] = shopPhoto["PhotoPath"];
        datas["name"] = shopPhoto["PhotoName"];
        datas["type"] = "online";
        var fullurl = this.subUrl + shopPhoto["PhotoPath"].toString();
        print("1->" + y.toString());
        file = await urlToFile(fullurl);
        print("3->");
        if (file.toString() != "") {
          List<int> imageBytes = file.readAsBytesSync();
          print("4->");
          String base64Image =
              "data:image/png;base64," + base64Encode(imageBytes).toString();
          datas["base64"] = base64Image;
        } else {
          datas["base64"] = "";
        }
        onlinePhoto.add(datas);
      }
      _data["images"] = onlinePhoto;
      // if (_data["images"].length ==
      //     questions[index]["AnswerShopPhoto"].length) {
      //   setState(() {});
      // }
    } else {
      _data["images"] = [];
    }
    _data["checkDatas"] = [];
  }

  Future<void> showMessageAlert(String message) async {
    double width = MediaQuery.of(context).size.width * 0.5;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          // title: Center(child: Text('Message')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  "$message",
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              color: Color(0xffe53935),
              child: Row(
                children: <Widget>[
                  Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              width: 10,
            ),
          ],
        );
      },
    );
  }

  Widget _allWidget(var data, var questionIndex, var primarydata) {
    print("ss-->");
    if (primarydata["images"] == null) {
      primarydata["images"] = [];
    }
    Widget _widget;
    if (data["TypeDesc"] == "Attach Photograph") {
      _widget = attachPhotograph(data, primarydata["images"]);
    } else if (data["TypeDesc"] == "Fill in the Blank") {
      _widget = fillintheBlank(data, primarydata);
    } else if (data["TypeDesc"] == "Checkbox") {
      _widget = checkBox(data, primarydata["checkDatas"]);
    } else if (data["TypeDesc"] == "Multiple Choice") {
      var t1 = data["QuestionCode"];
      var t2 = data["QuestionDescription"];
      _widget = multipleChoice(
          t1, t2, primarydata["radioDatas"], questionIndex, data);
    } else if (data["TypeDesc"] == "Date") {
      _widget = dateTimePicker(data, primarydata);
    } else if (data["TypeDesc"] == "Number Range") {
      _widget = fromToWidget(data, primarydata);
    } else if (data["TypeDesc"] == "Rating 0-10") {
      _widget = ratingWidget(data, primarydata);
    } else if (data["TypeDesc"] == "Time Range") {
      _widget = timeRangeWidget(data, primarydata);
    } else {
      _widget = Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Text(data.toString()),
      );
    }

    return _widget;
  }

  String datePicker;
  DateTime selectedDate = DateTime.now();
  Widget dateTimePicker(var data, var primaryData) {
    var t1 = data["QuestionCode"];
    var t2 = data["QuestionDescription"];
    TextEditingController _textController = new TextEditingController();
    _textController.text = primaryData["showDate"];

    DateTime nowDate = DateTime.parse(primaryData["dateFormat"]);
    //  DateTime nowDate;
    return Container(
      decoration: flagDecoration(data["Flag"]),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        t1 + " : " + t2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: TextField(
                      onTap: () {
                        showMaterialDatePicker(
                          context: context,
                          selectedDate: nowDate,
                          onChanged: (value) => setState(() {
                            nowDate = value;
                            var selected = value.toString();
                            var dateonly = selected.substring(0, 10);
                            String day = dateonly.substring(8, 10);
                            String month = dateonly.substring(5, 7);
                            String year = dateonly.substring(0, 4);
                            primaryData["servicedate"] = year + month + day;
                            primaryData["dateFormat"] =
                                year + "-" + month + "-" + day;
                            primaryData["showDate"] =
                                day + '/' + month + '/' + year;
                            data["AnswerDesc"] = year + month + day;
                          }),
                        );
                      },
                      controller: _textController,
                      readOnly: true,
                      decoration: InputDecoration(
                        focusColor: Colors.black,
                        prefixIcon: Icon(
                          Icons.date_range,
                          color: CustomIcons.iconColor,
                        ),
                        hintText: 'Date',
                        hintStyle: TextStyle(fontSize: 18, height: 1.5),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          _commentWidget(data["Flag"], data),
        ],
      ),
    );
  }

  String choice;
  String _radioValue;
  void radioButtonChanges(String value) {
    setState(() {
      _radioValue = value;
      switch (value) {
        case 'one':
          choice = value;
          break;
        case 'two':
          choice = value;
          break;
        case 'three':
          choice = value;
          break;
        default:
          choice = null;
      }
      debugPrint(choice); //Debug the choice in console
    });
  }

  Widget ratingWidget(var data, var dummyData) {
    var t1 = data["QuestionCode"];
    var t2 = data["QuestionDescription"];
    return Container(
      decoration: flagDecoration(data["Flag"]),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        t1 + " : " + t2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.grey[200],
            height: 50.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("0"),
                    value: "0",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("1"),
                    value: "1",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("2"),
                    value: "2",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("3"),
                    value: "3",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("4"),
                    value: "4",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("5"),
                    value: "5",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("6"),
                    value: "6",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("7"),
                    value: "7",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("8"),
                    value: "e",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 100.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("9"),
                    value: "9",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
                Container(
                  width: 110.0,
                  child: RadioListTile(
                    groupValue: dummyData["rating"],
                    title: Text("10"),
                    value: "10",
                    onChanged: (aaa) {
                      setState(() {
                        dummyData["rating"] = aaa;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          _commentWidget(data["Flag"], data),
        ],
      ),
    );
  }

  Widget fromToWidget(var data, var primaryData) {
    //  questions[ss]["AnswerShopPhoto"][0]["AnswerDesc1"];
    //             _data["AnswerDesc2"] =  questions[ss]["AnswerShopPhoto"][0]["AnswerDesc2"];
    TextEditingController _fromController = new TextEditingController();
    _fromController.text = primaryData["AnswerDesc1"];
    TextEditingController _toController = new TextEditingController();
    _toController.text = primaryData["AnswerDesc2"];
    var t1 = data["QuestionCode"];
    var t2 = data["QuestionDescription"];
    return Container(
      decoration: flagDecoration(data["Flag"]),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        t1 + " : " + t2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: 2,
                            ),
                            child: TextField(
                              controller: _fromController,
                              onChanged: (val) {
                                primaryData["AnswerDesc1"] =
                                    _fromController.text;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'From',
                                labelStyle: TextStyle(
                                    color: Colors.black54, fontSize: 18),
                                focusColor: Colors.black,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 2,
                            ),
                            child: TextField(
                              controller: _toController,
                              onChanged: (val) {
                                primaryData["AnswerDesc2"] = _toController.text;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'To',
                                labelStyle: TextStyle(
                                    color: Colors.black54, fontSize: 18),
                                focusColor: Colors.black,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          _commentWidget(data["Flag"], data),
        ],
      ),
    );
  }

  Widget timeRangeWidget(var data, var primaryData) {
    // var fromTime = TimeOfDay.now();

    TextEditingController _fromController = new TextEditingController();
    _fromController.text = primaryData["AnswerDesc1"];

    TextEditingController _toController = new TextEditingController();
    _toController.text = primaryData["AnswerDesc2"];
    var t1 = data["QuestionCode"];
    var t2 = data["QuestionDescription"];
    return Container(
      decoration: flagDecoration(data["Flag"]),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            color: CustomIcons.dropDownHeader,
            child: ListTile(
              title: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        t1 + " : " + t2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: 2,
                            ),
                            child: TextField(
                              readOnly: true,
                              controller: _fromController,
                              onChanged: (val) {
                                primaryData["AnswerDesc1"] =
                                    _fromController.text;
                              },
                              onTap: () {
                                DatePicker.showTime12hPicker(context,
                                    showTitleActions: true,
                                    onChanged: (date) {}, onConfirm: (date) {
                                  var selected = date.toString();
                                  var timeonly = selected.substring(11, 16);
                                  var hour = timeonly.substring(0, 2);
                                  var minute = timeonly.substring(3, 5);
                                  var finalTime;
                                  print("time only" + timeonly.toString());
                                  if (int.parse(hour) < 12) {
                                    int finalHour = int.parse(hour);
                                    if (finalHour == 0) {
                                      finalHour = 12;
                                    }
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " AM";
                                  } else if (int.parse(hour) > 12) {
                                    int finalHour = int.parse(hour) - 12;
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " PM";
                                  } else if (int.parse(hour) == 12 &&
                                      int.parse(minute) > 0) {
                                    int finalHour = int.parse(hour);
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " PM";
                                  } else if (int.parse(hour) == 12 &&
                                      int.parse(minute) == 0) {
                                    int finalHour = int.parse(hour);
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " PM";
                                  } else if (int.parse(hour) == 0 &&
                                      int.parse(minute) == 0) {
                                    int finalHour = 12;
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " AM";
                                  } else {
                                    int finalHour = int.parse(hour);
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " AM";
                                  }
                                  if (primaryData["AnswerDesc2"] != "") {
                                    if (primaryData["AnswerDesc2"] ==
                                        finalTime) {
                                      ShowToast("Invalid Selected date");
                                    } else {
                                      String endDate =
                                          primaryData["AnswerDesc2"];
                                      int sHour = int.parse(finalTime
                                          .toString()
                                          .substring(
                                              0,
                                              finalTime
                                                  .toString()
                                                  .indexOf(":")));
                                      int sMin = int.parse(finalTime
                                          .toString()
                                          .substring(
                                              finalTime
                                                      .toString()
                                                      .indexOf(":") +
                                                  1,
                                              finalTime
                                                      .toString()
                                                      .indexOf(":") +
                                                  3));
                                      String sDON = finalTime
                                          .toString()
                                          .substring(
                                              finalTime
                                                      .toString()
                                                      .indexOf(" ") +
                                                  1,
                                              finalTime
                                                      .toString()
                                                      .indexOf("M") +
                                                  1);
                                      int totalStart = (sHour * 60) + sMin;
                                      int eHour = int.parse(endDate.substring(
                                          0, endDate.indexOf(":")));
                                      int eMin = int.parse(endDate.substring(
                                          endDate.indexOf(":") + 1,
                                          endDate.indexOf(":") + 3));
                                      String eDON = endDate.substring(
                                          endDate.indexOf(" ") + 1,
                                          endDate.indexOf("M") + 1);
                                      int totalEnd = (eHour * 60) + eMin;
                                      if (eDON == sDON) {
                                        if (sHour == 12) {
                                          if (eHour == 12) {
                                            if (eMin > sMin) {
                                              setState(() {
                                                primaryData["AnswerDesc1"] =
                                                    finalTime;
                                                _fromController.text =
                                                    finalTime;
                                              });
                                            } else {
                                              ShowToast("Invalid Time");
                                              primaryData["AnswerDesc1"] = "";
                                              _fromController.text = "";
                                            }
                                          } else if (sHour > eHour) {
                                            setState(() {
                                              primaryData["AnswerDesc1"] =
                                                  finalTime;
                                              _fromController.text = finalTime;
                                            });
                                          } else {
                                            ShowToast("Invalid Time");
                                            primaryData["AnswerDesc1"] = "";
                                            _fromController.text = "";
                                          }
                                        } else if (eHour == 12) {
                                          if (sHour == 12) {
                                            if (eMin > sMin) {
                                              setState(() {
                                                primaryData["AnswerDesc1"] =
                                                    finalTime;
                                                _fromController.text =
                                                    finalTime;
                                              });
                                            } else {
                                              ShowToast("Invalid Time");
                                              primaryData["AnswerDesc1"] = "";
                                              _fromController.text = "";
                                            }
                                          } else if (sHour > eHour) {
                                            setState(() {
                                              primaryData["AnswerDesc1"] =
                                                  finalTime;
                                              _fromController.text = finalTime;
                                            });
                                          } else {
                                            ShowToast("Invalid Time");
                                            primaryData["AnswerDesc1"] = "";
                                            _fromController.text = "";
                                          }
                                        } else {
                                          if (totalStart >= totalEnd) {
                                            ShowToast("Invalid Time");
                                            setState(() {
                                              primaryData["AnswerDesc1"] = "";
                                              _fromController.text = "";
                                            });
                                          } else {
                                            setState(() {
                                              primaryData["AnswerDesc1"] =
                                                  finalTime;
                                              _fromController.text = finalTime;
                                            });
                                          }
                                        }
                                      } else {
                                        setState(() {
                                          primaryData["AnswerDesc1"] =
                                              finalTime;
                                          _fromController.text = finalTime;
                                        });
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      primaryData["AnswerDesc1"] = finalTime;
                                      _fromController.text = finalTime;
                                    });
                                  }
                                }, currentTime: DateTime.now());
                              },
                              decoration: InputDecoration(
                                labelText: 'Start Time',
                                labelStyle: TextStyle(
                                    color: Colors.black54, fontSize: 18),
                                focusColor: Colors.black,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 2,
                            ),
                            child: TextField(
                              readOnly: true,
                              controller: _toController,
                              onChanged: (val) {
                                primaryData["AnswerDesc2"] = _toController.text;
                              },
                              onTap: () {
                                DatePicker.showTime12hPicker(context,
                                    showTitleActions: true,
                                    onChanged: (date) {}, onConfirm: (date) {
                                  var selected = date.toString();
                                  var timeonly = selected.substring(11, 16);
                                  var hour = timeonly.substring(0, 2);
                                  var minute = timeonly.substring(3, 5);
                                  var finalTime;
                                  if (int.parse(hour) < 12) {
                                    int finalHour = int.parse(hour);
                                    if (finalHour == 0) {
                                      finalHour = 12;
                                    }
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " AM";
                                  } else if (int.parse(hour) > 12) {
                                    int finalHour = int.parse(hour) - 12;
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " PM";
                                  } else if (int.parse(hour) == 12 &&
                                      int.parse(minute) > 0) {
                                    int finalHour = int.parse(hour);
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " PM";
                                  } else if (int.parse(hour) == 12 &&
                                      int.parse(minute) == 0) {
                                    int finalHour = int.parse(hour);
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " PM";
                                  } else if (int.parse(hour) == 0 &&
                                      int.parse(minute) == 0) {
                                    int finalHour = 12;
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " AM";
                                  } else {
                                    int finalHour = int.parse(hour);
                                    finalTime = finalHour.toString() +
                                        ":" +
                                        minute +
                                        " AM";
                                  }
                                  if (primaryData["AnswerDesc1"] != "") {
                                    String startDate =
                                        primaryData["AnswerDesc1"];
                                    int eHour = int.parse(finalTime
                                        .toString()
                                        .substring(0,
                                            finalTime.toString().indexOf(":")));
                                    int eMin = int.parse(finalTime
                                        .toString()
                                        .substring(
                                            finalTime.toString().indexOf(":") +
                                                1,
                                            finalTime.toString().indexOf(":") +
                                                3));
                                    String eDON = finalTime
                                        .toString()
                                        .substring(
                                            finalTime.toString().indexOf(" ") +
                                                1,
                                            finalTime.toString().indexOf("M") +
                                                1);
                                    int totalEnd = (eHour * 60) + eMin;
                                    int sHour = int.parse(startDate.substring(
                                        0, startDate.indexOf(":")));
                                    int sMin = int.parse(startDate.substring(
                                        startDate.indexOf(":") + 1,
                                        startDate.indexOf(":") + 3));
                                    String sDON = startDate.substring(
                                        startDate.indexOf(" ") + 1,
                                        startDate.indexOf("M") + 1);
                                    int totalStart = (sHour * 60) + sMin;
                                    if (eDON == sDON) {
                                      if (sHour == 12) {
                                        if (eHour == 12) {
                                          if (eMin > sMin) {
                                            setState(() {
                                              primaryData["AnswerDesc2"] =
                                                  finalTime;
                                              _toController.text = finalTime;
                                            });
                                          } else {
                                            ShowToast("Invalid Time..");
                                            setState(() {
                                              primaryData["AnswerDesc2"] = "";
                                              _toController.text = "";
                                            });
                                          }
                                        } else if (sHour > eHour) {
                                          setState(() {
                                            primaryData["AnswerDesc2"] =
                                                finalTime;
                                            _toController.text = finalTime;
                                          });
                                        } else {
                                          ShowToast("Invalid Time");
                                          setState(() {
                                            primaryData["AnswerDesc2"] = "";
                                            _toController.text = "";
                                          });
                                        }
                                      } else if (eHour == 12) {
                                        if (sHour == 12) {
                                          if (eMin > sMin) {
                                            setState(() {
                                              primaryData["AnswerDesc2"] =
                                                  finalTime;
                                              _toController.text = finalTime;
                                            });
                                          } else {
                                            ShowToast("Invalid Time..");
                                            setState(() {
                                              primaryData["AnswerDesc2"] = "";
                                              _toController.text = "";
                                            });
                                          }
                                        } else if (sHour > eHour) {
                                          setState(() {
                                            primaryData["AnswerDesc2"] =
                                                finalTime;
                                            _toController.text = finalTime;
                                          });
                                        } else {
                                          ShowToast("Invalid Time");
                                          setState(() {
                                            primaryData["AnswerDesc2"] = "";
                                            _toController.text = "";
                                          });
                                        }
                                      } else {
                                        if (totalEnd <= totalStart) {
                                          ShowToast("Invalid Time");
                                          setState(() {
                                            primaryData["AnswerDesc2"] = "";
                                            _toController.text = "";
                                          });
                                        } else {
                                          setState(() {
                                            primaryData["AnswerDesc2"] =
                                                finalTime;
                                            _toController.text = finalTime;
                                          });
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        primaryData["AnswerDesc2"] = finalTime;
                                        _toController.text = finalTime;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      primaryData["AnswerDesc2"] = finalTime;
                                      _toController.text = finalTime;
                                    });
                                  }
                                }, currentTime: DateTime.now());
                              },
                              decoration: InputDecoration(
                                labelText: 'End Time',
                                labelStyle: TextStyle(
                                    color: Colors.black54, fontSize: 18),
                                focusColor: Colors.black,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          _commentWidget(data["Flag"], data),
        ],
      ),
    );
  }

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: LoadingProvider(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: MainMenuWidget(),
          appBar: AppBar(
            backgroundColor: CustomIcons.appbarColor,
            title: Text("Questions"),
          ),
          body: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      color: Colors.grey[200],
                      child: Container(
                        width: 700,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // SelectableText(_consoleLable.toString()),
                                    Text(
                                      this.widget.surveyType,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (this.widget.surveyType ==
                                        "Store Operator")
                                      Text(
                                        this.widget.storeName,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    if (this.widget.surveyType ==
                                        "Store Operator")
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                    if (this.widget.surveyType ==
                                        "Store Operator")
                                      Text(
                                        this.widget.storeNumber,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          height: 1.0,
                                        ),
                                      ),
                                    if (this.widget.surveyType ==
                                        "Store Operator")
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                    if (this.widget.surveyType ==
                                        "Store Operator")
                                      Text(
                                        this.widget.address,
                                        style: TextStyle(height: 1.3),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_status)
                      if (questions.length > 0)
                        for (var i = 0; i < questions.length; i++)
                          _allWidget(questions[i], i, _primaryData[i]),
                    if (!_status || questions.length == 0)
                      Container(
                        height: 50,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            "No Data",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ],
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
                      // showLoading();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => OutsideInsideNeighborhood(
                              this.widget.isNeighborhood,
                              this.widget.isOutside,
                              this.widget.isInside,
                              this.widget.isStoreOperater,
                              this.widget.storeName,
                              this.widget.storeNumber,
                              this.widget.address,
                              this.widget.regOrAss,
                              this.widget.passData,
                              this.widget.allsection,
                              this.widget.header),
                        ),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
//                          decoration: BoxDecoration(color: Color(0xffe53935)),
                          constraints: BoxConstraints(minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Back",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (completeStatus != "Complete") {
                        showLoading();
                        if (this._status == true && this.questions.length > 0) {
                          // Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            // showLoading();
                            // showLoading();
                            _clickDoneAssignStore();
                            // });
                          });
                        } else {
                          // showLoading();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => OutsideInsideNeighborhood(
                                  this.widget.isNeighborhood,
                                  this.widget.isOutside,
                                  this.widget.isInside,
                                  this.widget.isStoreOperater,
                                  this.widget.storeName,
                                  this.widget.storeNumber,
                                  this.widget.address,
                                  this.widget.regOrAss,
                                  this.widget.passData,
                                  this.widget.allsection,
                                  this.widget.header),
                            ),
                          );
                        }
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(minHeight: 50.0),
                          alignment: Alignment.center,
                          child: completeStatus == "Complete"
                              ? Text(
                                  "Done",
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 16),
                                )
                              : Text(
                                  "Done",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowImage extends StatefulWidget {
  final image;

  ShowImage({Key key, @required this.image}) : super(key: key);

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.image,
    );
  }
}
