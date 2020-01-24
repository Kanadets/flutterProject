import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';


class Post {
  // ignore: non_constant_identifier_names
  final String id;
  final String author;
  final String download_url;


  Post(this.id, this.author, this.download_url);
}

class TestHttp extends StatefulWidget {
    final String url;

    TestHttp({String url}):url = url;



    @override
    State<StatefulWidget> createState() => TestHttpState();
    
}
// TestHttp


class TestHttpState extends State<TestHttp> {
  final _formKey = GlobalKey<FormState>();

  String _url, _body;
  int _status;



  @override
  void initState() {
    _url = widget.url;
    super.initState();
  }//initState


  _sendRequestGet() {
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();//update form data

      http.get(_url).then((response){
        _status = response.statusCode;
        _body = response.body;

        setState(() {});//reBuildWidget
        print(_status);
      }).catchError((error){
        _status = 0;
        _body = error.toString();

        setState(() {});//reBuildWidget
      });
    }
  }//_sendRequestGet

  Future<List<Post>> _getPost() async {
    var data = await http.get(_url);

    var jsonData = json.decode(data.body);
    print(jsonData);
    List<Post> posts = [];

    for (var i in jsonData) {
      Post post = Post(i["author"], i["id"], i["download_url"]);

      posts.add(post);

    }
    print(posts.length);

    return posts;
  }


  @override
  Widget build(BuildContext context) {
    return Form(key: _formKey, child: SingleChildScrollView(child: Column(
      children: <Widget>[
        Container(
            child: Text('API url', style: TextStyle(fontSize: 20.0,color: Colors.blue)),
            padding: EdgeInsets.all(10.0)
        ),
        Container(
            child: TextFormField(initialValue: _url, validator: (value){if (value.isEmpty) return 'API url isEmpty';}, onSaved: (value){_url = value;}, autovalidate: true),
            padding: EdgeInsets.all(10.0)
        ),
        SizedBox(height: 20.0),
        RaisedButton(child: Text('Send request GET'), onPressed: _sendRequestGet),
        SizedBox(height: 20.0),
        Text('Response status', style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        Text(_status == null ? '' :_status.toString()),
        SizedBox(height: 20.0),
        Text('Response body', style: TextStyle(fontSize: 20.0,color: Colors.blue)),

        Container (
          width: 600,
          height: 600,
          child: FutureBuilder(
            future: _getPost(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              print(snapshot.data);
              if(snapshot.data == null) {
                return Container(
                  child: Center(
                    child: Text("Loading..."),
                  ),
                );
              } else {
                return ListView.builder (
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    return ListTile (
                      leading: Container(
                        height: 100,
                        width: 100,
                        child: Image.network(snapshot.data[index].download_url),
                      ),
                      title: Text(snapshot.data[index].id),
                      subtitle: Text(snapshot.data[index].author),
                    );
                  },
                );
              }
            },
          ),
        )
//        Text(_body == null ? '' : _body),
      ],
    )));
  }

}//TestHttpState




class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Test HTTP API'),
        ),
        body: TestHttp(url: 'https://picsum.photos/v2/list')
    );
  }
}

void main() => runApp(
    MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp()
    )
);

//leading: CircleAvatar(
//backgroundImage: NetworkImage(snapshot.data[index].download_url)
//),