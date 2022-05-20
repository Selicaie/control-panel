import 'dart:async';

import 'package:controlpanel/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class Sign_in extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Sign_in();
  }

}

class _Sign_in extends State<Sign_in>{

  TextEditingController email_controller = TextEditingController();
  TextEditingController pass_controller = TextEditingController();
  StreamSubscription <User?> ?user_listen;

  @override
  void initState() {
    user_listen = FirebaseAuth.instance.authStateChanges().listen((User ?user) {
      if (user != null) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>Home()), (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image.asset('assets/images/logo.png'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 20),
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: 'E_mail...',
                      border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                  ),
                  controller: email_controller,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25) ,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 30),
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Password...',
                      border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                  ),
                  obscuringCharacter: '*',
                  obscureText: true,
                  controller: pass_controller,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25) ,
                ),
              ),

              TextButton(
                child: Text('Login'),
                 onPressed: (){
                  log_in();
                 },
                style: ButtonStyle(alignment: Alignment.center,
                       backgroundColor: MaterialStateProperty.all<Color>(Color(0xff013764),),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: Colors.red)
                        )
                    ),
                  textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff11B3EB),
                    fontSize: 25,
                  )),
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10)),
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  log_in() async{
    if(email_controller.text.isNotEmpty) {
      if(pass_controller.text.isNotEmpty) {
        try {
         await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email_controller.text, password: pass_controller.text).whenComplete(() {
                //if(FirebaseAuth.instance.currentUser!=null)
                   //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>Home()), (route) => false);
          });
        }on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
            Text('No user found for that email.',style: TextStyle(fontSize: 20),)));
            print('No user found for that email.');
          } else if (e.code == 'wrong-password') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
            Text('Wrong password provided for that user.',style: TextStyle(fontSize: 20),)));
            print('Wrong password provided for that user.');
          }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
            Text(e.message.toString(),style: TextStyle(fontSize: 20),)));
          }
        }catch(e){
          print('error');
        }
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
        Text('check your password...',style: TextStyle(fontSize: 20),)));
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
      Text('check your email...',style: TextStyle(fontSize: 20),)));
    }
  }

@override
  void dispose() {
    user_listen!.cancel();
    super.dispose();
  }

}