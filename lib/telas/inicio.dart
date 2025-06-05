import 'package:flutter/material.dart';
import 'package:youtube_clone_new/Api.dart';
import 'package:youtube_clone_new/model/Video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Inicio extends StatefulWidget {
  final String pesquisa;

  const Inicio(this.pesquisa, {super.key});

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  YoutubePlayerController? _controller;
  String? _currentVideoId;

  _listarVideos(String pesquisa) {
    Api api = Api();
    return api.pesquisar(pesquisa);
  }

  void _onVideoTap(String videoId) {
    if (_currentVideoId == videoId) {
      _controller?.play();
    } else {
      setState(() {
        _currentVideoId = videoId;
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("chamado 1-initState");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("chamado 2-didChangeDependencies");
  }

  @override
  void didUpdateWidget(covariant Inicio oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("chamado 3-didUpdateWidget");
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
    print("chamado 4-dispose");
  }

  @override
  Widget build(BuildContext context) {
    print("chamado 3-build");

    return FutureBuilder<List<Video>>(
      future: _listarVideos(widget.pesquisa),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasData) {
              return ListView.separated(
                itemBuilder: (context, index) {
                  List<Video>? videos = snapshot.data;
                  Video video = videos![index];
                  bool isCurrentVideo = _currentVideoId == video.id;

                  return GestureDetector(
                    onTap: () {
                      _onVideoTap(video.id);
                    },
                    child: Column(
                      children: <Widget>[
                        if (isCurrentVideo)
                          Container(
                            height: 200,
                            child: YoutubePlayer(
                              controller: _controller!,
                              showVideoProgressIndicator: true,
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(video.imagem),
                              ),
                            ),
                          ),
                        ListTile(
                          title: Text(video.titulo),
                          subtitle: Text(video.canal),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  height: 2,
                  color: Colors.grey,
                ),
                itemCount: snapshot.data!.length,
              );
            } else {
              return const Center(
                child: Text("Nenhum dado a ser exibido!"),
              );
            }
        }
      },
    );
  }
}
