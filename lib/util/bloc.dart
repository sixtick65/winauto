import 'package:flutter/material.dart';

typedef ChangeHandler<T> = void Function(T value);

class Bloc<T> {
  Bloc(T value): _state = value;
  T _state;
  T get state => _state;
  set state(T value){
    _state = value; 
    _map.forEach((name, func) => func(_state));
  }
  final Map<String, ChangeHandler<T>> _map = {}; 

  void onChanged(ChangeHandler<T> handler, String? name){
    _map[name ?? UniqueKey().toString()] = handler;
  }

  void removeHanler(String name){
    _map.remove(name);
  }
}