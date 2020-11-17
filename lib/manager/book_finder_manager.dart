import 'dart:async';
import 'package:book_finder/models/book_search.dart';
import 'package:book_finder/service/book_finder_service.dart';
import 'package:rxdart/rxdart.dart';

class BookFinderManager{

  final PublishSubject _controller = PublishSubject<BFState>();
  Stream<BFState> get finder$ => _controller.stream;

  void search(BookSearch search) async {
    _controller.add(LoadingBFState());
    Future.delayed(Duration(seconds: 2));
    await BookFinderService.browseBook(search)
        .then((value) => _controller.add(LoadedBFState(value)))
        .catchError((error){
          print(error.toString());
          _controller.add(ErrorFBState());
        });
  }

  void dispose(){
    _controller.close();
  }

  void searchLeftNavigate(BookSearch bookSearch) async {
    if(bookSearch.startIndex>=0){
      _controller.add(LoadingBFState());
      Future.delayed(Duration(seconds: 2));
      if(bookSearch.startIndex-bookSearch.maxResults>=0) bookSearch.startIndex-=bookSearch.maxResults;
      else bookSearch.startIndex = 0;
      await BookFinderService.browseBook(bookSearch)
          .then((value) => _controller.add(LoadedBFState(value)))
          .catchError((error){
        print(error.toString());
        _controller.add(ErrorFBState());
      });
    }
  }

  void searchRightNavigate(BookSearch bookSearch) async {
    if(bookSearch.startIndex+bookSearch.maxResults<bookSearch.totalItems){
      _controller.add(LoadingBFState());
      Future.delayed(Duration(seconds: 2));
      print(bookSearch.maxResults);
      bookSearch.startIndex+=bookSearch.maxResults;
      print(bookSearch.maxResults);
      await BookFinderService.browseBook(bookSearch)
          .then((value) => _controller.add(LoadedBFState(value)))
          .catchError((error){
        print(error.toString());
        _controller.add(ErrorFBState());
      });
    }
  }

}

abstract class BFState{
  const BFState();
}

class InitialBFState extends BFState{
  const InitialBFState();
}

class LoadingBFState extends BFState{
  const LoadingBFState();
}

class LoadedBFState extends BFState{
  final BookSearch search;
  const LoadedBFState(this.search);
}

class ErrorFBState extends BFState{
  const ErrorFBState();
}