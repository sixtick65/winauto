import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


void debug(Object text){
  if(kDebugMode){
    debugPrint(text.toString());
  }
}

typedef ChangeHandler<T> = void Function(T value);

class Bloc<T> {
  Bloc(T value): _state = value;
  T _state;
  T get state => _state;
  set state(T value){
    _state = value; 
    // debug('set state : $value');
    _map.forEach((name, func){
      func(_state);
      // debug('event $name $_state');
    });
  }
  final Map<String, ChangeHandler<T>> _map = {}; 

  void onChanged(ChangeHandler<T> handler, {String? name}){
    name ??= UniqueKey().toString();
    if(_map.containsKey(name)){
      debug('already exist $name $_state');
      return;
    }
    _map[name] = handler;
    debug("add event handler $name $_state");
  }

  void removeHanler(String name){
    _map.remove(name);
  }
}

void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // 표시 시간
      ),
    );
  }