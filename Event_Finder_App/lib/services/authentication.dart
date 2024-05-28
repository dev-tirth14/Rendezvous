import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserModel.dart';
class Authentication{

  FirebaseAuth firebaseAuth=FirebaseAuth.instance;

  Stream<User> getAuthState(){
    print('USER STATE CHANGED');
    return firebaseAuth.authStateChanges();
  }

  //sign in annon
  Future signInAnnon()async{
    UserCredential response=await firebaseAuth.signInAnonymously();
    User user=response.user;
    return user;
  }

  //sign in email pass
  Future signInWithEmailPass(String email,String password) async{
    try{
      UserCredential response=await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      User user=response.user;
      //user.getIdToken(true);
      return user;
    }catch(e){
      return e;
    }
  }

  //register in email pass
  Future registerWithEmailPass(String email,String password) async {
    try{
      UserCredential response=await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User user=response.user;
      await user.sendEmailVerification();
      signOut();
      return user;
    }catch(e){
      print(e.code);
      return e;
    }
    
  }

  //sign out
  Future signOut() async {
    print("Sign out Called");
    await firebaseAuth.signOut().then((value) => print(firebaseAuth.currentUser));
  }
}