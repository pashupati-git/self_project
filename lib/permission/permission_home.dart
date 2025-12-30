import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHome extends StatefulWidget {
  const PermissionHome({super.key});

  @override
  State<PermissionHome> createState() => _PermissionHomeState();
}

class _PermissionHomeState extends State<PermissionHome> {
  PermissionStatus _storageStatus= PermissionStatus.denied;
  PermissionStatus _cameraStatus= PermissionStatus.denied;

  @override
  void initState(){
    super.initState();
    _checkStoragePermission();
    //_checkCameraPermission();
  }


  ///for storage
  Future<void> _checkStoragePermission() async {
    final status = await Permission.storage.status;
    setState((){
      _storageStatus= status;
    });
  }

  Future<void> _requestStoragePermission() async{
    final status= await Permission.storage.request();
    setState((){
      _storageStatus= status;
    });
    if(status.isGranted){
      _showSnackBar("Storage permission granted!");
    }
    else if(status.isDenied){
      _showSnackBar('Storage permission denied!');
    }
    else if(status.isPermanentlyDenied){
      _showSnackBar('Please enable storage permission in settings');
    }
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content:Text(message)),
    );
  }

  // ///for camera
  // Future<void> _checkCameraPermission() async{
  //   final status= await Permission.camera.status;
  //   setState(() {
  //     _cameraStatus=status;
  //   });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Permission'),
        centerTitle: true,
      ),
      body:Center(
        child: Padding(padding: const EdgeInsets.all(24.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(
               _storageStatus.isGranted? Icons.check_circle:Icons.folder_open,
               size: 100,
               color: _storageStatus.isGranted?Colors.green:Colors.grey,
             ),
             const SizedBox(height: 16,),
             Text(
               _storageStatus.isGranted?'Granted ✔️'
                   :_storageStatus.isDenied?'Denied'
                   :_storageStatus.isPermanentlyDenied?'Permanently Denied'
                   :'Not requested',
               style:Theme.of(context).textTheme.titleLarge?.copyWith(
                 color: _storageStatus.isGranted
                     ?Colors.green:Colors.red,
                 fontWeight:FontWeight.bold,
               )

             ),
             const SizedBox(height: 48,),
             ElevatedButton.icon(onPressed:_storageStatus.isGranted? null: _requestStoragePermission,
                icon:const Icon(Icons.storage),
                label: Text(
               _storageStatus.isGranted?'Permission Granted':'Request Storage permission',

             ),
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(
                   horizontal:24,
                   vertical:16,
                 ),
               ),
             )



           ],
         ),
        ),
      )
    );
  }
}
