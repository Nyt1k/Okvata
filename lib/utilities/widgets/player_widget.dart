import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktava/data/model/audio_player_model.dart';
import 'package:oktava/services/audio-player/bloc/audio_player_bloc.dart';
import 'package:oktava/services/audio-player/bloc/audio_player_event.dart';
import 'package:oktava/services/audio-player/bloc/audio_player_state.dart';
import 'package:oktava/utilities/constants/color_constants.dart';
import 'package:oktava/views/full_player_view.dart';

class PlayerWidget extends StatelessWidget {
  final backRoute;
  const PlayerWidget({Key? key,required this.backRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is AudioPlayerInitialState ||
            state is AudioPlayerReadyState) {
          return const SizedBox.shrink();
        }

        if (state is AudioPlayerPlayingState) {
          return _showPlayer(context, state.playingEntity, state.entityList);
        }

        if (state is AudioPlayerPausedState) {
          return _showPlayer(context, state.pausedEntity, state.entityList);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _showPlayer(BuildContext context, AudioPlayerModel model,
      List<AudioPlayerModel> models) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            color: additionalColor,
            boxShadow: [
              BoxShadow(
                color: secondaryColor,
                blurRadius: 4,
                offset: Offset(0, -0.2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FullPlayerView(models: models,backRoute: backRoute,)));
            },
            child: ListTile(
              leading: setLeading(model),
              title: setTitle(model),
              subtitle: setSubTitle(model),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    color: mainColor,
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      size: 35,
                    ),
                    onPressed: setPrevCallBack(context, model),
                  ),
                  IconButton(
                    icon: setIcon(model),
                    color: mainColor,
                    onPressed: setCallBack(context, model),
                  ),
                  IconButton(
                    onPressed: setNextCallBack(context, model),
                    color: mainColor,
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      size: 35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

Widget setIcon(AudioPlayerModel model) {
  if (model.isPlaying) {
    return const Icon(
      Icons.pause_circle_filled_rounded,
      size: 35,
    );
  } else {
    return const Icon(
      Icons.play_circle_fill_rounded,
      size: 35,
    );
  }
}

Widget setLeading(AudioPlayerModel model) {
  return SizedBox(
    width: 60,
    height: 60,
    child: Image.network(
      model.audio.metas.image!.path.isNotEmpty
          ? model.audio.metas.image!.path
          : model.audio.metas.onImageLoadFail!.path,
      fit: BoxFit.cover,
    ),
  );
}

Widget setTitle(AudioPlayerModel model) {
  return Text(
    model.audio.metas.title!,
    style: const TextStyle(color: mainColor),
  );
}

Widget setSubTitle(AudioPlayerModel model) {
  return Text(
    model.audio.metas.artist!,
    style: const TextStyle(color: mainColor),
  );
}

void Function() setCallBack(BuildContext context, AudioPlayerModel model) {
  if (model.isPlaying) {
    return () {
      BlocProvider.of<AudioPlayerBloc>(context)
          .add(TriggeredPauseAudioPlayerEvent(model));
    };
  } else {
    return () {
      BlocProvider.of<AudioPlayerBloc>(context)
          .add(TriggeredPlayAudioPlayerEvent(model, context));
    };
  }
}

void Function() setPrevCallBack(BuildContext context, AudioPlayerModel model) {
  return () {
    BlocProvider.of<AudioPlayerBloc>(context)
        .add(TriggeredPrevAudioPlayerEvent(model));
  };
}

void Function() setNextCallBack(BuildContext context, AudioPlayerModel model) {
  return () {
    BlocProvider.of<AudioPlayerBloc>(context)
        .add(TriggeredNextAudioPlayerEvent(model));
  };
}
