import 'package:mongo_dart/mongo_dart.dart';

class DatabaseService {
  static late Db db;
  static late DbCollection volunteerApplicationCollection;
  static late DbCollection personalDetailsCollection;
  static late DbCollection specialtiesCollection;
  static late DbCollection bookPickupCollection;

  static Future<void> connect() async {
  db = await Db.create("mongodb+srv://aadarsh:Himms123@cluster0.tr6rk.mongodb.net/Himms?retryWrites=true&w=majority&tls=true");
  await db.open();
  
  volunteerApplicationCollection = db.collection("volunteer_application");
  personalDetailsCollection = db.collection("personal_details");
  specialtiesCollection = db.collection("specialties");
  bookPickupCollection = db.collection("book_pickup");

  print("Connected to MongoDB");
}

  static Future<void> insertVolunteerApplication(Map<String, dynamic> data) async {
    await volunteerApplicationCollection.insertOne(data);
    print("Volunteer Application Inserted");
  }

  static Future<void> insertPersonalDetails(Map<String, dynamic> data) async {
    await personalDetailsCollection.insertOne(data);
    print("Personal Details Inserted");
  }

  static Future<void> insertSpecialties(Map<String, dynamic> data) async {
    await specialtiesCollection.insertOne(data);
    print("Specialties Inserted");
  }

  static Future<void> insertBookPickup(Map<String, dynamic> data) async {
    await bookPickupCollection.insertOne(data);
    print("Book Pickup Inserted");
  }
}
