import 'package:Event_Finder_App/models/Event.dart';
import 'package:Event_Finder_App/models/Filter.dart';
import 'package:Event_Finder_App/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreCloud{
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // --- FUTURE FUNCTIONS --- //
  
  //Function to add event onto cloud
  Future addEvent(Event event)async{
    DocumentReference eventRef=await firestore.collection('events').add(
      event.toMap()
    );
    return eventRef;
  }
  
  //Returns list of all events
  Future<List<Event>> getListOfAllEvents(Filter eventType)async{
    List<Event> eventList=new List<Event>();
    QuerySnapshot eventListSnapshot;
    if(eventType.value!="All"){
      eventListSnapshot=await this.firestore.collection("events").where("type",isEqualTo: eventType.value).get();
    }else{
      eventListSnapshot=await this.firestore.collection("events").get();

    }
    for(int i=0;i<eventListSnapshot.docs.length;i++){
      DocumentReference eventRef=await eventListSnapshot.docs[i].reference;
      DocumentSnapshot eventInfo=await eventRef.get();
      Event newEvent= Event.fromMap(eventInfo.data(),reference: eventRef);
      eventList.add(newEvent);
    }
    return eventList;
  }

  //Removes user from attending list of an event
  void removeRSVP(DocumentReference currentUserRef, DocumentReference eventToAttendRef,Event event)async{
    CollectionReference RSVPList=await event.reference.collection('RSVP');
    QuerySnapshot query = await RSVPList.where("uid",isEqualTo: currentUserRef).get();
    await query.docs[0].reference.delete();
    await eventToAttendRef.delete();
  }

  //Checks if a given user is in the attending list of a given event
  Future<DocumentReference> isRSVPForUser(DocumentReference currentUserRef,Event event)async{
    CollectionReference eventsToAttend=await currentUserRef.collection('eventsToAttend');

    QuerySnapshot query = await eventsToAttend.where("eventID",isEqualTo: event.reference).get();
    if(query.docs.length>0){
      return query.docs[0].reference;
    }
    return null;
  }

  //Get event from a given eventRef
  Future<Event> getEventFromRef(DocumentReference eventRef)async{
    DocumentSnapshot eventData=await eventRef.get();
    if(!eventData.exists){
      return null;
    }
    Event event=Event.fromMap(eventData.data());
    event.reference=eventRef;
    DocumentSnapshot hostData=await event.hostid.get();
    event.setHostData(AppUser.fromMap(hostData.data()));
    return event;
  }

  //Get attending list given from some event ref
  Future<List<AppUser>> getRSVPListFromEventRef(DocumentReference eventRef)async{
    List<AppUser> rsvpList=new List<AppUser>();
    QuerySnapshot rsvpListSnapshot=await eventRef.collection("RSVP").get();
    for(int i=0;i<rsvpListSnapshot.docs.length;i++){
      DocumentSnapshot rsvpRef=await rsvpListSnapshot.docs[i].data()['uid'].get();
      rsvpList.add(AppUser.fromMap(rsvpRef.data()));
    }
    return rsvpList;

  }
  
  //Return the current user Ref, used to access their information
  Future<DocumentReference> getCurrentUserRef(String uid)async{
    DocumentReference currentUserRef=await firestore.collection("users").doc(uid);
    return currentUserRef;

  }

  //Returns app user from a given UserRef, used to access username, email, etc
  Future<AppUser> getAppUserFromRef(DocumentReference userRef) async {
    DocumentSnapshot userDataSnapshot=await userRef.get();
    return AppUser.fromMap(userDataSnapshot.data(),reference: userRef);
    
  }
  
  //Deletes an event from cloud
  void removeEvent(DocumentReference hostedEventRef,Event event)async{
    await hostedEventRef.delete();
    QuerySnapshot RSVPList=await event.reference.collection('RSVP').get();
    for(int i=0;i<RSVPList.docs.length;i++){
      DocumentReference RSVPUser=RSVPList.docs[i].data()["uid"];
      CollectionReference userEvents=await RSVPUser.collection("eventsToAttend");
      QuerySnapshot query = await userEvents.where("eventID",isEqualTo: event.reference).get();
      await query.docs[0].reference.delete();
    }
    await event.reference.delete();
  }

  //Updates an event on the cloud given new event information
  void updateEvent(Event eventToUpdate)async{
    await eventToUpdate.reference.update(eventToUpdate.toMap());
  }

  //Updates user given user ref and new user information
  Future<void> updateUser(DocumentReference originalUserRef,AppUser newUserDataInstance) async {
    await originalUserRef.update(newUserDataInstance.toMap());
  }
}