

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';

int c = 0;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Contact> contacts = [];

  void initState() {
    super.initState();
    Permission.contacts.request().then((value) {
      if (value.isDenied || value.isRestricted || value.isPermanentlyDenied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Cancel")));
      } else if (value.isGranted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("OK")));
        FlutterContacts.getContacts(
                withProperties: true, withPhoto: true, withThumbnail: true, withAccounts: true)
            .then((value) => setState(() {
                  contacts = value;
                }));
      }
    });
  }

  void refreshContacts() {
    Permission.contacts.request().then((value) {
      if (value.isDenied || value.isRestricted || value.isPermanentlyDenied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Cancel")));
      } else if (value.isGranted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("OK")));
        FlutterContacts.getContacts(
            withProperties: true, withPhoto: true, withThumbnail: true, withAccounts: true)
            .then((value) => setState(() {
          contacts = value;
        }));
      }
    });
}



  @override
  Widget build(BuildContext context) {
    Contact a;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add),onPressed: () async { a = Contact();
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  EditPage(onSave: (){refreshContacts();},)));

      refreshContacts();

      },),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          var contact = contacts[index];
          return Row(children: [
            CircleAvatar(
                child: (contact.thumbnail != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(contact.thumbnail!))
                    : const Icon(Icons.person)),
            SizedBox(
              width: 25,
              height: 30,
            ),
            Text(contact.displayName, style: TextStyle(fontSize: 24)),
            IconButton(
                onPressed: () async {
                  print(contact);

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ContactPage(contact: contact, )));
                  refreshContacts();

                },
                icon: Icon(Icons.add)),
            IconButton(onPressed: (){setState(() {
              contact.delete();
              refreshContacts();
            });}, icon: Icon(Icons.delete))
          ]);
        },
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;



  const ContactPage({super.key, required this.contact});



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
            height: 150,
            width: double.infinity,
            child: CircleAvatar(
                child: (contact.thumbnail != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(contact.thumbnail!))
                    : const Icon(Icons.person))),
        SizedBox(
          width: 25,
          height: 30,
        ),
        Text(contact.displayName, style: TextStyle(fontSize: 48)),
        SizedBox(
          width: 25,
          height: 30,
        ),
        Text(
          (contact.phones.length != 0)
              ? contact.phones[0].number
              : "no phone number",
          style: TextStyle(fontSize: 48),
        ),
        SizedBox(
          width: 25,
          height: 30,
        ),
        Text(
          (contact.notes.length != 0) ? contact.notes[0].note : "no notes",
          style: TextStyle(fontSize: 48),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
                onPressed: () {Navigator.of(context).pop();},
                child: (Text(
                  "Return",
                  style: TextStyle(fontSize: 36),
                ))),
            SizedBox(
              height: 10,
              width: 25,
            ),
            OutlinedButton(
                onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            EditPage(contact: contact, onSave: (){})));},
                child: (Text(
                  "Edit",
                  style: TextStyle(fontSize: 36),
                )))
          ],
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    ));
  }
}

class EditPage extends StatelessWidget {
  late bool isNew;
  late final Contact contact;
  final Function onSave;

  EditPage({super.key, Contact? contact, bool? isNew, required this.onSave }){

    if(contact == null){
      this.contact = Contact();
      this.isNew = true;
    }
    else{
      this.isNew = false;
      this.contact = contact;

    }
    print(contact);

  }



  @override
  Widget build(BuildContext context) {
    TextEditingController firstname1 = TextEditingController(
        text: contact.name.first);
    TextEditingController lastname = TextEditingController(
        text: (contact.name.last != null) ? contact.name.last : "");
    TextEditingController number = TextEditingController(
        text: (contact.phones.length != 0) ? contact.phones[0].number : "");
    TextEditingController note = TextEditingController(
        text: (contact.notes.length != 0) ? contact.notes[0].note : "");
    return Scaffold(
        body: Column(
      children: [
        TextField(
          controller: firstname1,
          decoration: const InputDecoration(hintText: "Имя"),
          onChanged: (value) {
            contact.name.first = value;
          },
        ),
        TextField(
            controller: lastname,
            decoration: const InputDecoration(hintText: "Фамилия"),
            onChanged: (value) {
              contact.name.last = value;
            }),
        TextField(
            controller: number,
            decoration: const InputDecoration(hintText: "Номер"),
            onChanged: (value) {
              contact.phones[0].number = value;
            }),
        TextField(
            controller: note,
            decoration: const InputDecoration(hintText: "Заметка"),
            onChanged: (value) {
              contact.notes[0].note = value;
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
                onPressed: () { Navigator.of(context).pop();},
                child: (Text(
                  "Cancel",
                  style: TextStyle(fontSize: 24),
                ))),
            SizedBox(
              height: 10,
              width: 25,
            ),
            OutlinedButton(
                onPressed: () async {
                  if(isNew == true){
                    await contact.insert();
                    Navigator.of(context).pop();
                  }
                  else{ await contact.update();
                  Navigator.of(context).pop();}
                },
                child: (Text(
                  "Save",
                  style: TextStyle(fontSize: 24),
                )))
          ],
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    ));
  }
}
