import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:esrgan_flutter2_ocean_app/authentication/authentication.dart';
import 'package:esrgan_flutter2_ocean_app/screens/image_view.dart';
import 'package:esrgan_flutter2_ocean_app/screens/loading_enhance_screen.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/app_drawer.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/appbar_title.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/scaler.dart';
import 'package:esrgan_flutter2_ocean_app/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

class EnhanceScreen extends StatefulWidget {
  const EnhanceScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _EnhanceScreenState createState() => _EnhanceScreenState();
}

class _EnhanceScreenState extends State<EnhanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late User _user;
  File? selectedImage;
  File? upscaledImage;
  var imgSize;
  String? message = "";
  bool isEnhancing = false;
  bool isEnhanced = false;
  bool _isSigningOut = false;
  String imgFileSize = "";
  String imgResolution = "";
  bool isImageExceeds = false;
  var subscription;

  @override
  initState() {
    _user = widget._user;
    super.initState();
  }

  String getFileSize(int fileSize) {
    double kb = fileSize / 1000;
    if (kb > 1000) {
      return (kb /= 1000).toStringAsFixed(2) + " mb";
    } else {
      return kb.toStringAsFixed(2) + " kb";
    }
  }

  String getImageResolution(String imgSize) {
    var imgRes = imgSize.split(" ");
    var height = imgRes[1].split(",");
    var width = imgRes[2];

    print("H: " + height[0].toString());
    print("W: " + width.toString());

    if (int.parse(width) > 720 || int.parse(height[0]) > 1280) {
      setState(() {
        isImageExceeds = true;
        print(isImageExceeds);
      });

      showSnackBar(
          context,
          "Image resolution too high. Change image to a lower resolution. (1280x720 Max Limit)",
          Colors.red,
          5000);
    } else {
      setState(() {
        isImageExceeds = false;
        print(isImageExceeds);
      });
    }

    return height[0] + "x" + width;
  }

  getImageFromGallery() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    selectedImage = File(pickedImage!.path);
    imgSize = ImageSizeGetter.getSize(FileInput(selectedImage!));

    var fileSize = await selectedImage!.length();

    imgFileSize = getFileSize(fileSize);
    imgResolution = getImageResolution(imgSize.toString());
    setState(() {});
  }

  getImageFromCamera() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    selectedImage = File(pickedImage!.path);

    imgSize = ImageSizeGetter.getSize(FileInput(selectedImage!));

    var fileSize = await selectedImage!.length();

    imgFileSize = getFileSize(fileSize);
    imgResolution = getImageResolution(imgSize.toString());
    setState(() {});
  }

  void displayResponseImage(String outputFile) {
    print("Updating Image");
    outputFile = 'http://35.223.166.50:8080/download/' + outputFile;
    setState(() {
      upscaledImage = Image(image: NetworkImage(outputFile)) as File?;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Choose image by:"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text(
                  "Photo with Camera",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {
                  await getImageFromCamera();
                  Navigator.pop(context);
                }),
            SimpleDialogOption(
                child: Text("Image from Gallery",
                    style: TextStyle(color: Colors.blue)),
                onPressed: () async {
                  await getImageFromGallery();
                  Navigator.pop(context);
                }),
            SimpleDialogOption(
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler()..init(context);

    Widget imageBox = Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        height: scaler.getHeight(40),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Color(0xFFeeeeee), //.grey[400],
            border: Border.all(color: Colors.black38 //Colors.grey,

                ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListView(
          children: [
            Column(
              children: [
                Center(
                  child: Container(
                    child: selectedImage == null
                        ? Image.asset("assets/images/please_select_Image_0.gif",
                            width: scaler.getWidth(80),
                            height: scaler.getHeight(40),
                            fit: BoxFit.fitHeight)
                        : Image.file(
                            selectedImage!,
                            width: scaler.getWidth(80),
                            height: scaler.getHeight(35),
                            fit: BoxFit.fitHeight,
                          ),
                  ),
                ),
                selectedImage != null
                    ? Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Image Resolution: " + imgResolution,
                                style: TextStyle(color: Colors.black87)),
                            Text("File Size: " + imgFileSize,
                                style: TextStyle(color: Colors.black87)),
                          ],
                        ),
                      )
                    : Container()
              ],
            )
          ],
        ));

    Widget btnSelectImage = Container(
        margin: EdgeInsets.only(top: 12),
        child: TextButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xff3765f8))),
            onPressed: () {
              selectImage(context);
            }, //getImage,
            icon: Icon(Icons.upload_file, color: Colors.white),
            label: Text("Select Image",
                style: TextStyle(
                  color: Colors.white,
                ))));

    Widget btnEnhanceImage = Container(
      margin: EdgeInsets.only(top: 8),
      child: TextButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  (selectedImage != null && isImageExceeds == false)
                      ? Color(0xff3765f8)
                      : Color(0xff3765f8).withAlpha(86))),
          onPressed: () => (selectedImage != null && isImageExceeds == false)
              ? showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text('Enhance Image'),
                        content: const Text(
                            'Do you want to enhance this selected image?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context)
                                .pop(), //Navigator.pop(context, 'Cancel'),

                            child: const Text(
                              'No',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LoadingEnhanceScreen(
                                            user: widget._user,
                                            selectedImage: selectedImage!,
                                            imgResolution: imgResolution,
                                          )));
                              //   Navigator.pushReplacement(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) => ImageView(
                              //                 image: selectedImage!,
                              //                 orgImage: selectedImage!,
                              //                 user: widget._user,
                              //               )));
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ))
              : null,
          icon: FaIcon(FontAwesomeIcons.handSparkles, color: Colors.white),
          label: Text("Enhance Image",
              style: TextStyle(
                color: Colors.white,
              ))),
    );

    Widget body = Center(
        child: isEnhancing
            ? Container(
                child: Text("HAHAHAHAAHAHAH"),
              )
            : Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    imageBox,
                    btnSelectImage,
                    btnEnhanceImage,
                  ],
                ),
              ));

    return Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        key: _scaffoldKey,
        appBar: customAppBar,
        body: body,
        endDrawer: CustomAppDawer(user: widget._user));
  }
}
