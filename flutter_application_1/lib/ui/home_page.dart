// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'dart:convert';

import 'package:flutter_application_1/ui/gif_page.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:share/share.dart';

import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado inicial
  String? _search;
  int _offset = 0;
  int _limite = 5;
  List novaLista = [];
  List listaDuplicada = [];

  // Requisitando dados da API

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search!.isEmpty) {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=OKVv8YkE87MULZSZX7K9BRn5iqSF1I8C&limit=6&rating=g"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=OKVv8YkE87MULZSZX7K9BRn5iqSF1I8C&q=$_search&limit=$_limite&offset=$_offset&rating=g&lang=en"));
    }

    var decode = json.decode(response.body);
    return decode;
  }

  //Init State
  @override
  void initState() {
    super.initState();
  }

  // Criando minha tela inicial
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          barraPesquisa(),
          Expanded(
            child: buildFutureBuilder(),
          ),
        ],
      ),
    );
  }

  // Indicando o tamanho da minha lista
  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  // Criando a lista e retornando a tela de compartilhamento = telaShare caso o gif seja selecionado

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    var listaGifs = snapshot.data["data"];
    novaLista = [...listaGifs];
    listaDuplicada = [...novaLista, novaLista];
    // novaLista = [...listaGifs, ...listaGifs];
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getCount(novaLista),
        itemBuilder: (context, index) {
          if (_search == null || index < novaLista.length) {
            return telaERota(index, context);
          } else {
            return carregaMais();
          }
        });
  }

//transformando em metodos

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Image.network(
          "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
      centerTitle: true,
    );
  }

  Padding barraPesquisa() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
            labelText: "Pesquise aqui",
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder()),
        style: TextStyle(color: Colors.white, fontSize: 18),
        textAlign: TextAlign.center,
        onSubmitted: (text) {
          setState(() {
            _search = text;
            _offset = 0;
            _limite = 5;
          });
        },
      ),
    );
  }

  FutureBuilder<Map<dynamic, dynamic>> buildFutureBuilder() {
    return FutureBuilder(
      future: _getGifs(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:

          case ConnectionState.none:
            return Container(
              width: 200,
              height: 200,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 5,
              ),
            );

          default:
            if (snapshot.hasError) {
              return Container();
            } else {
              return _createGifTable(context, snapshot);
            }
        }
      },
    );
  }

  GestureDetector telaERota(int index, BuildContext context) {
    return GestureDetector(
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: novaLista[index]["images"]["fixed_height"]["url"],
        height: 300,
        fit: BoxFit.cover,
      ),
      // Redirecionando telas
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GifPage(novaLista[index])));
      },
      onLongPress: () {
        Share.share(novaLista[index]["images"]["fixed-height"]["url"]);
      },
    );
  }

  Container carregaMais() {
    return Container(
      child: GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: <Widget>[
            Icon(
              Icons.add,
              color: Colors.white,
              size: 70,
            ),
            Text(
              "Carregar Mais...",
              style: TextStyle(color: Colors.white, fontSize: 22),
            )
          ],
        ),
        onTap: () {
          setState(() {
            _offset = _offset + 4;
            _limite += _offset;
          });
        },
      ),
    );
  }
}
