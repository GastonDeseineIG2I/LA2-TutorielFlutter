# Tutoriel Flutter

> Gaston Deseine
>
> juin 2021
>
> LA2 IG2I

## Bienvenue



Bienvenue sur ce tutoriel pour vous initier à Flutter.



<u>Dans ce tutoriel vous apprendrez à :</u>

- Mettre en place un environnement de développement
- Initialiser un projet Flutter
- Communiquer avec une API
- Créer vos premières vues
- Utiliser les notifications
- Accéder au stockage du téléphone
- Déployer votre application sur un appareil

Ce tutoriel est disponible à cette adresse: https://gastondeseineig2i.github.io/

Vous trouverez le code final sur GitHub à cette adresse https://github.com/GastonDeseineIG2I/LA2-TutorielFlutter/

Un commit sur Git correspond à une étape de ce tutoriel, n'hésitez pas à aller jeter un œil si vous êtes en difficulté.



Nous allons utiliser cet API: http://dourlens-monchy.fr:8091/swagger-ui/#/



Ce tutoriel a comme ligne directrice la création d'un journal personnel.



## Installation et mise en place de l'environnement



Ici les instructions d'installation sont pour un système d'exploitation Windows.

Pour un autre système d'exploitation suivez les étapes sur le site officiel de Flutter: https://flutter.dev/docs/get-started/install 



### Installation de Flutter SDK

- J'utilise Chocolatey de Microsoft pour gérer mes applications sur Windows 10

```bash
	choco install flutter
```



- Pour une installation plus classique:

  - Télécharger le Flutter SDK sur le site de Flutter et extraire le ZIP téléchargé là où vous le souhaitez

    **OU**

  - ```bash
    git clone https://github.com/flutter/flutter.git -b stable
    ```

  

  - Mettez à jour votre PATH en ajoutant le chemin complet vers *flutter/bin*



### Vérification de l'installation

```bash
flutter doctor
```

Cette commande vérifie la bonne installation et nous donne des conseils si elle détecte un problème.



### Installation de l'IDE

Android Studio ou IntelliJ sont recommandés pour Flutter.

J'ai utilisé Android Studio.

https://developer.android.com/studio

Vous pourrez ajouter le plugin Flutter après avoir installé le SDK Android.



### Installation de Android SDK

Au démarrage de Android Studio passez par l '«Assistant de configuration d'Android Studio». 

Cela installe le dernier SDK Android, les outils de ligne de commande du SDK Android et les outils de construction du SDK Android, qui sont requis par Flutter lors du développement pour Android.



### Initialisation de l'émulateur Android

Suivez les démarches sur le site de Flutter ou d'Android Studio pour mettre en place un émulateur Android.

Si vous utilisez un téléphone Android, vous pouvez utiliser ADB pour installer l'application directement sur votre smartphone. Cela permet d'utiliser l'application dans des conditions réelles et cela soulagera votre ordinateur. 



## Création de l'application Flutter



Si vous avez fait le choix d'utiliser Android Studio avec le plugin Flutter suivez ces étapes, sinon renseignez vous sur la façon de créer une application avec votre IDE.

```
Fichier > Nouveau > Nouvelle application Flutter > Application Flutter
```

Vous pouvez ensuite suivre les étapes de création.



<u>Pour ce tutoriel j'ai utilisé:</u>

- Nom du projet : tutoriel_flutter
- Nom du package : ig2i.mobile.tutorielflutter



Le fichier lancé au démarrage de l'application est le fichier ***main.dart*** contenu dans **<u>*/lib*</u>** 

Essayez de lancer votre projet fraîchement créé pour vérifier que tout se passe bien.



Vous devez obtenir cet affichage :

<img src="img\image-20210525201407287.png" alt="image-20210525201407287" style="zoom: 25%;" />





Nous devons ajouter une permission pour accéder à Internet et ainsi utiliser l'API. Du fait que l'API est en HTTP et pas en HTTPS on doit le spécifier avec "*android:usesCleartextTraffic="true*""

Pour ajouter cette permission il faut ajouter dans le fichier les informations manquantes ***/android/app/src/main/AndroidManifest.xml***

```xml
<manifest>
    ...
    <!-- Required to fetch data from the internet. -->
	<uses-permission android:name="android.permission.INTERNET" />
    ...
    <application
        ...
        android:usesCleartextTraffic="true">
        ....
    </application>
</manifest>
```



## Système d'authentification

Pour réaliser un système d'authentification on a besoin de trois choses :

- Un **formulaire** de connexion (La vue)
- Un **service** qui permet de se mettre en relation avec l'API
- Un **modèle d'utilisateur** qui permettra de manipuler un objet Utilisateur



Commençons par le modèle d'utilisateur ! 



### Création d'un modèle : L'utilisateur

On a besoin de créer une classe User qui contient des attributs et des méthodes.

Nous allons donc créer le fichier **/lib/models/user.model.dart**

Nous créons la classe et nous ajoutons ensuite les attributs : 

```dart
class User {
  int? id;
  String? name;
  String? password;
  String? token;
}
```

On ajoute ensuite le constructeur dans la classe : 

```dart
User({this.id, this.name, this.password, this.token});
```

Puis nous créons deux méthodes qui nous serons utile lors de la création de notre service. En effet l'API utilise le format JSON, nous allons donc créer une methode qui permet de passer d'un objet Dart à un objet JSON et inversement.

```dart
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      token: json['token']
    );
  }

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'password': password,
      'token': token
  };
```



### Création du service de redirection

On peut désormais créer le dossier ***/lib/services*** qui contiendra nos différents services.

Nous allons ensuite créer un fichier ***locator.service.dart*** dans le dossier ***/lib/services*** qui contiendra le systeme de redirection vers le bon service. Cela nous permettra ensuite de gérer le mode en ligne et hors ligne.

Juste avant créons ce fichier qui servira a stocker l'URL de l'API :

```dart
// /lib/services/const.dart

const API_URL = 'dourlens-monchy.fr:8091';
```



```dart
// /lib/services/locator.service.dart

import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'const.dart';

GetIt locator = GetIt.instance;

// Fonction qui teste la réponse du serveur
Future<bool> ping() async {
  try {
    final response = await http.get(Uri.http(API_URL, 'ping')).timeout(
        new Duration(seconds: 5),
        onTimeout: () => throw new TimeoutException('TimeOut'));
    return response.body == 'pong';
  } catch (error) {
    return false;
  }
}

// Fonction permettant d'utiliser le bon service en fonction du cas de figure (Réponse de l'API ou non)
setupServiceLocator() async {
  if (await ping()) {
    // locator.registerLazySingleton<UserService>(() => UserApiService());
  } else {
    // locator.registerLazySingleton<UserService>(() => UserOfflineService());
  }
}
```



Nous avons besoin du package Get_It et HTTP:

```bash
flutter pub add get_it
```

```bash
flutter pub add http
```



### Création d'un service: Le service utilisateur

Nous allons désormais créer notre premier service!

Commençons par créer le dossier qui va l'accueillir : ***/lib/services/user***

Ce dossier va contenir trois fichier :

- La classe  abstraite contenant les méthodes à implémenter :  ***user.abstract.service.dart***
- La classe qui utilisera l'API : ***user.api.service.dart***
- La classe qui prendra le relai lorsqu'on n'aura pas accès à l'API : ***user.offline.service.dart***



#### La classe abstraite 

Cette classe contient toute les méthodes à implémenter dans les classes filles.

Nous avons donc :

```dart
// /lib/services/user/user.abstract.service.dart

import 'package:tutoriel_flutter/models/user.model.dart';

abstract class UserService {
  Future<int> createUser(User user);
  Future<int> login(User user);
  Future<int> logout();
  Future<User> getCurrentUser(User user);
}
```

#### La classe API

Cette classe contient les méthodes implémentées qui réalisent des appels à l'API

On va ajouter le package *SharedPreferences* qui permet d'accéder au stockage de l'appareil.

```bash
flutter pub add shared_preferences
```



On va ensuite implémenter la classe **UserApiService** dans ***user.api.service.dart***



Pour effectuer une requête API en HTTP on retrouve un code de cette forme :

```dart
final response = await http.post(
        Uri.http(API_URL, 'v1/authentication/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': user.name,
          'password': user.password
        }
       ));
```



Voici le résultat final de cette implémentation :

```dart
// /lib/services/user/user.api.service.dart

import 'dart:convert';

import 'package:tutoriel_flutter/models/user.model.dart';
import 'package:tutoriel_flutter/services/user/user.abstract.service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';

class UserApiService extends UserService {
  @override
  Future<int> createUser(User user) async {
    print(user.toJson());
    final response = await http.post(Uri.http(API_URL, 'v1/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));
    if (response.statusCode == 201) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return 0;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to create user');
    }
  }

  @override
  Future<int> login(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
        Uri.http(API_URL, 'v1/authentication/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': user.name,
          'password': user.password
        }));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      user.id = jsonDecode(response.body)['idUser'];
      user.token = jsonDecode(response.body)['token'];
      prefs.setString('user', json.encode(user));
      print(prefs.getString('user'));
      return 0;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      print(jsonDecode(response.body));
      throw Exception('Failed to login');
    }
  }

  @override
  Future<int> logout() async {
    String? token;
    http.Response response;
    final prefs = await SharedPreferences.getInstance().then((value) async {
      token = value.getString('token');
      response = await http.post(Uri.http(API_URL, 'v1/authentication/logout'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'token': '$token'
          });

      if(response.statusCode == 200){
        return 0;
      }
      else{
        throw Exception('Failed to login');
      }
    });
    return 0;
  }

  @override
  Future<User> getCurrentUser(User user) {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

}
```



#### La classe offline

On peut maintenant créer la classe qui servira à récupérer les données hors connexion.

Voici un exemple d'implémentation d'une des méthodes :

```dart
class UserOfflineService extends UserService {
  @override
  Future<int> createUser(User user) {
    // TODO: implement createUser
    throw UnimplementedError();
  }
	...
}
```



#### Ajout des services au Locator

Nous pouvons désormais ajouter notre service à notre Locator contenu dans ***/lib/services/locator.service.dart***

Voici le nouveau contenu de la méthode ***setupServiceLocator()***

```dart
// /lib/services/locator.service.dart

setupServiceLocator() async {
  if (await ping()) {
    locator.registerLazySingleton<UserService>(() => UserApiService());
  } else {
    locator.registerLazySingleton<UserService>(() => UserOfflineService());
  }
}
```



### Création de notre vue : Le formulaire de connexion

Nous allons enfin modifier notre affichage!

Cette étape permet de réaliser un formulaire de connexion permettant à l'utilisateur de s'identifier.

Nos vues se trouveront dans le dossier ***/lib/pages***

Nous allons créer le fichier ***login.page.dart*** :



```dart
import ...

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late User user;

  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  UserService _userService = locator<UserService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Login'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: ...
      ),
    );
  }
}
```

Voici la structure du code, essayez d'y ajouter un formulaire d'identification, n'hésitez pas a vous aider de la documentation de Flutter et de mon code GitHub en cas de difficultés.



On aimerait obtenir cette structure :

```text
Container > Column > Form > {TextFormField; TextFormField; ElevatedButton}
```



On peut désormais mettre à jour ***/lib/main.dart*** pour qu'il affiche la bonne vue au démarrage.

Pour rappel la méthode main() de ce fichier est la méthode appelé au lancement de l'application. 

On va également réaliser un peu de ménage dans ce fichier pour supprimer la vue d'exemple créé par Android Studio.

```dart
// /lib/main.dart

import 'package:flutter/material.dart';
import 'package:tutoriel_flutter/pages/login.page.dart';
import 'package:tutoriel_flutter/services/locator.service.dart';

void main() async {
  await setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutoriel Flutter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

```



Essayez de relancer l'application, vous devez obtenir un résultat similaire :

<img src="img\image-20210526210506671.png" alt="image-20210526210506671" style="zoom:33%;" />



## Notre premier affichage : Liste déroulante

Maintenant que nous pouvons nous authentifier nous allons pouvoir afficher des informations propres à l'utilisateur.



Nous allons afficher les topics d'un utilisateur. Pour cela nous allons devoir recommencer les étapes de la partie précédente : 

- Créer un modèle
- Créer un service
- Créer une vue

### Création du modèle

Nous allons créer le fichier ***topic.model.dart*** dans le dossier ***/lib/models/***

Il contiendra les attributs qui lui sont liés et les méthodes de conversion JSON.

```dart
class Topic {
  int? id;
  DateTime? creationDate;
  String? name;
  User? user;
}
```

Ajoutez le constructeur et les méthodes de conversion vues plus haut.

### Création du service

Une fois de plus nous allons créer trois fichiers :

- La classe **TopicService** abstraite contenant les méthodes à implémenter :  ***topic.abstract.service.dart***
- La classe **TopicApiService** qui utilisera l'API : ***topic.api.service.dart***
- La classe **TopicOfflineService** qui prendra le relai lorsqu'on n'aura pas accès à l'API : ***topic.offline.service.dart***

Nous implémenterons ces trois méthodes:

```dart
Future<int> createTopic(Topic topic);
Future<List<Topic>> getTopics();
Future<Topic> getTopic(int id);
```

Pour l'implémentation cela se déroule de la même manière que l'implémentation des services utilisateur.

Il faut également ajouter nos services au Locator.

### Création de la vue

Nous allons maintenant créer la vue qui affichera les topics récupérés avec le service.

```dart
import ...

class TopicsPage extends StatefulWidget {
  TopicsPage({Key? key}) : super(key: key);

  _TopicsPageState createState() => _TopicsPageState();

}

class _TopicsPageState extends State<TopicsPage> {
  late User user;

  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final List<int> colorCodes = <int>[700, 600, 500, 400];

  TopicService _topicService = locator<TopicService>();
  late List<Topic> topics;

  @override
  void initState() {
    super.initState();
  }

  _getTopics() async {
    topics = await _topicService.getTopics();
    return topics;
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('My Topics'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LoginPage()
            ),
          ),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

          child: Column(
              children: <Widget>[
                Container(
                    child: TextFormField(),
                ),
                Container(
                    child: _getTopicsView()
                ),
              ]
          )
      ),
    );
  }
}
```



On ajoute cette méthode qui génère la liste de topics.

```dart
Widget _getTopicsView() {
    return FutureBuilder(
        future: _getTopics(),
        builder:(context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (topics.isEmpty) {
            return Center(child:Text('No topics.'));
          } else {
            return Container(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: topics.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                        onTap: () {
                        },
                        child:  Container(
                          height: 70,
                          color: Colors.blue[colorCodes[index%4]],
                          child: Center(child: Text('${topics[index].name}')),
                        ),

                      );
                    }
                )
            );
          }
        }
    );
  }
```



### Relier la vue avec l'application

Maintenant que tout est prêt nous souhaitons afficher la vue après qu'on se soit connecté.

Nous allons ajouter dans le **ElevatedButton** de la page ***login.page.dart*** un évènement de redirection.

On ajoute donc ce morceau de code qui permet de naviguer entre les pages:

```dart
Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TopicsPage()),
)
```



Vous devez à la connexion vous retrouver sur une page qui ressemble à ceci :

<img src="img\image-20210526223422399.png" alt="image-20210526223422399" style="zoom:33%;" />



## Ajouter des données : L'ajout de Topic

Nous avons appris à afficher des données, nous allons maintenant voir pour en créer !

Nous avons déjà implémenté les méthodes de création dans notre service, il nous reste seulement à créer la vue et à la relier au système.



### Création de la vue

Nous allons créer un formulaire permettant d'ajouter un topic.

Pour cela nous allons créer le fichier ***new.topic.page.dart***

```dart
import ...
    
class NewTopicsPage extends StatefulWidget {
  NewTopicsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  _NewTopicsPageState createState() => _NewTopicsPageState();
}

class _NewTopicsPageState extends State<NewTopicsPage> {
  late User user;

  final nameController = TextEditingController();

  TopicService _topicService = locator<TopicService>();
  late Topic topic;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
            child: ...
        )
    );
  }
}

```

Complétez pour obtenir un résultat sous cette forme :

```text
Center > Container > Column > Form > {TextFormField; ElevatedButton}
```



### Implantation dans le système existant

Nous allons simplement ajouter un bouton permettant de créer un topic sur notre page affichant l'ensemble des topics.

Modifions donc le fichier ***topics.page.dart***

Ajoutez ce morceau de code juste après le container contenant *_getTopicsView()*

```dart
 Container(
     child: Column(
         children: <Widget>[
             Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                     ElevatedButton(onPressed: () => {
                         Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => NewTopicsPage(title: 'New Topic')),
                         )
                     }, child: Text('New'))
                 ],
             )
         ],
     ),
 )
```

<u>Voici les nouveaux affichages :</u>

<img src="img\image-20210526225201890.png" alt="image-20210526225201890" style="zoom:33%;" />



<img src="img\image-20210526225213631.png" alt="image-20210526225213631" style="zoom:33%;" />



## Accéder au stockage du téléphone



Pour accéder au stockage du téléphone nous avons utilisé le package **SharedPreferences**

```bash
flutter pub add shared_preferences
```

Pour l'utiliser il faut l'importer

```dart
import 'package:shared_preferences/shared_preferences.dart';
```

Puis dans une méthode on peut :

```dart
// Recuperer l'instance
final prefs = await SharedPreferences.getInstance();

// Ajouter la variable user contenant le contenu de user encodé en JSON
prefs.setString('user', json.encode(user));

// Pour récupérer la valeur
prefs.getString('user');
```



## Les notifications

Les applications utilisent très souvent des notifications push pour vous avertir. 

Nous allons ici créer une notification simple afin de prendre en main ce système. 



### Autoriser les notifications pour Android

Dans le fichier `android/app/src/main/AndroidManifest.xml` ajoutez ces différentes autorisations dans la balise `manifest`

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

Puis ajoutez dans la balise `application` dans le même fichier la configuration de certains événements Android

```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

### Installation du package flutter_local_notifications

Executez la commande ci-dessous pour ajouter le package en dépendance du projet

```bash
flutter pub add flutter_local_notifications
```

Ou ajoutez la directement dans le fichier `pubspec.yaml`.

```yaml
dependencies:
  flutter_local_notifications: ^6.0.0
```

Puis installez les dépendances avec la commande suivante

```bash
dart pub get
```

### Configuration des paramètres des notification pour Android, IOS et MacOS

Dans le fichier `main.dart` ajoutez les différents paramètres/préférences pour chaque appareil en utilisant le package ***flutter_local_notifications***

<u>Exemple :</u>

```dart
/// Initialisation du plugin flutter pour les notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {

  await initNotification(); //Initialise le systeme de notification
  await setupServiceLocator();
  runApp(MyApp());
  _notify(); //Envoie une notification
}

Future initNotification() async {

  /// Attend que le WidgetsBinding soit initialisé pour pouvoir paramètrer correctement les notifications
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialisation des paramètres Android
  var initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  /// Note: Les permissions IOS eet Mac ne sont pas forcement requisent ici si elles sont déjà défini.
  /// Initialisation des paramètres IOS
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});
  /// Initialisation des paramètres MacOS
  const MacOSInitializationSettings initializationSettingsMacOS =
  MacOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true);

  /// Mappage des paramètres
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  /// Initialisation des paramètres
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {});
}
```

### Exemple d'une fonction de notification

```dart
void _notify() async {
  /// Paramètrage Android
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    'channel description',
    icon: '@mipmap/ic_launcher',
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'test_ticker'
  );
  /// Paramètrage IOS
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(0, 'Bienvenue !', 'Voici votre premiere notification avec Flutter !!!',
      platformChannelSpecifics);
}
```



Cela devrait vous donner ceci : 

<img src="img\image-20210526214220524.png" alt="image-20210526214220524" style="zoom:33%;" />

## Déploiement de l'application

Pour déployer l'application il faut suivre ce tutoriel présent sur le site de Flutter: https://flutter.dev/docs/deployment/android

### Build un APK

1. Taper `cd [project]`
2. Lancez `flutter build apk --split-per-abi`

Cette commande génère trois fichiers APK:

- `[project]/build/app/outputs/apk/release/app-armeabi-v7a-release.apk`
- `[project]/build/app/outputs/apk/release/app-arm64-v8a-release.apk`
- `[project]/build/app/outputs/apk/release/app-x86_64-release.apk`

### Installer un APK sur un appareil

Suivez ces étapes pour installer l'APK sur un appareil Android connecté.

Depuis la ligne de commande:

1. Connectez votre appareil Android à votre ordinateur avec un câble USB.
2. Taper `cd [project]`.
3. Lancez la commande `flutter install`.



## Conclusion

Merci d'avoir suivi ce tutoriel, j'espère qu'il vous a permis de découvrir les bases de Flutter.



### Liens utiles

- https://flutter.dev/
- https://flutter.dev/docs
- https://www.ionos.fr/digitalguide/sites-internet/developpement-web/tutoriel-flutter/
- https://github.com/GastonDeseineIG2I/LA2-TutorielFlutter/
- http://dourlens-monchy.fr:8091/swagger-ui/#/
