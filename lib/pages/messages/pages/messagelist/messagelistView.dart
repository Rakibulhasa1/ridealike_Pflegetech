import 'package:async_builder/async_builder.dart';
import 'package:conditioned/conditioned.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/models/message.dart';
import 'package:ridealike/pages/messages/models/swap.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:ridealike/pages/messages/widgets/emptyview.dart';
import 'package:ridealike/pages/messages/widgets/loadingview.dart';
import 'package:ridealike/pages/messages/widgets/swapview/swapView.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'messagelistController.dart';

class MessageListView extends StatefulWidget {
  final Thread? thread;
  final bool initSocket;

  const MessageListView({Key? key,  this.thread, this.initSocket = false})
      : super(key: key);

  @override
  _MessageListViewState createState() =>
      _MessageListViewState(this.thread as Thread, this.initSocket);
}

class _MessageListViewState extends StateMVC<MessageListView> {
 MessageListController? _con;

  _MessageListViewState(Thread thread, bool initSocket)
      : super(MessageListController()) {
     _con = controller as MessageListController?;
    _con!.thread = thread;
    // _con!.context = context;
    _con!.socketOn = initSocket;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _con!.scaffoldKey,
      appBar: AppBar(
        elevation: 3,
        iconTheme: IconThemeData(
          color: Color(0xffFF8F68),
        ),
        backgroundColor: Colors.white,
        title: Text(
          _con!.thread!.verificationStatus == "Undefined"?"Deleted User":
          _con!.thread!.name,
          style: TextStyle(color: Colors.black,fontFamily: 'Urbanist'),
        ),
        centerTitle: true,
      ),
      body: VisibilityDetector(
          key: Key('messageview-key'),
          onVisibilityChanged: (visibilityInfo) {
            _con!.visiblePercentage = visibilityInfo.visibleFraction * 100;
            if (_con!.visiblePercentage == 100.0) {
              Future.delayed(Duration(seconds: 1), () {
                //_con!.startSocket();
                _con!.getThreadList();
              });
            }
          },
          child: _mainView()),
    );
  }

  Widget _mainView() {
    return SafeArea(
      child: Stack(
        children: [
          _messageBuilder(),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: _chatBar(),
          ),
        ],
      ),
    );
  }

  Widget _messageBuilder() {
    return AsyncBuilder<List<Message>>(
      stream: _con!.messageStreamController.stream,
      waiting: (context) => LoadingView(),
      builder: (context, value) => value!.length > 0
          ? Column(
              children: [
                Visibility(
                  visible: _con!.showLoadMore,
                  child: LinearProgressIndicator(),
                ),
                Expanded(
                  child: _messageListView(value),
                ),
              ],
            )
          : EmptyView(
              message: "No Messages Found",
            ),
      error: (context, error, stackTrace) => EmptyView(
        message: "Error Loading Messages",
      ),
    );
  }

  Widget _messageListView(List<Message> list) {
    return ListView.builder(
      controller: _con!.scrollController,
      padding: EdgeInsets.only(bottom: 100),
      itemCount: list.length,
      itemBuilder: (context, pos) {
        return Column(
          children: [
            Visibility(
              visible: (list[pos].type == "Text" ||
                      list[pos].type == "Image" ||
                      list[pos].type == "SwapAgreementCard") &&
                  (pos == 0 ||
                      DateUtil.instance
                              .formatMessageGroupDate(list[pos].time) !=
                          DateUtil.instance
                              .formatMessageGroupDate(list[pos - 1].time)),
              child: Container(
                margin: EdgeInsets.only(bottom: 10, top: 10),
                child: Text(
                  DateUtil.instance.formatMessageGroupDate(list[pos].time),
                  style: TextStyle(color: Colors.black54,fontFamily: 'Urbanist'),
                ),
              ),
            ),
            Visibility(
              visible: (list[pos].type == "SwapAgreementCard" &&
                  list[pos].swap != null),
              child: Container(
                margin: EdgeInsets.only(bottom: 10, top: 10),
                child: Text(
                  DateUtil.instance.formatMessageTime(list[pos].time),
                  style: TextStyle(color: Colors.black54,fontFamily: 'Urbanist'),
                ),
              ),
            ),
            _messageListItem(list[pos]),
          ],
        );
      },
    );
  }

  Widget _messageListItem(Message message) {
    return Conditioned(
      cases: [
        Case(
          message.type == "Image",
          builder: () => _imageView(message),
        ),
        Case(
          message.type == "Text",
          builder: () => _textView(message),
        ),
        Case(
          message.type == "SwapAgreementCard" && message.swap != null,
          builder: () => SwapView(
            swap: Swap(
              userVerificationStatus: _con!.thread!.verificationStatus,
              agreementId: message.swap!.agreementId,
              userId: message.swap!.userId,
              load: message.load
            ),
            onClicked: () {
              print("message list swap click");
            },
          ),
        ),
      ],
      defaultBuilder: () => Container(),
    );
  }

  Widget _textView(Message message) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: message.senderId == _con!.userId
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: message.senderId == _con!.userId
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Card(
                  color: message.senderId == _con!.userId
                      ? Colors.white
                      : Color(0xffFF8F68),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      message.message,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: message.senderId == _con!.userId
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                _timeView(message)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeView(Message message) {
    return Row(
      mainAxisAlignment: message.senderId == _con!.userId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(5),
          child: Text(
            DateUtil.instance.formatMessageTime(message.time),
            style: TextStyle(
              fontFamily: 'Urbanist',
              color: Colors.black87,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chatBar() {
    return _con!.thread!.verificationStatus=="Undefined"?Container(): Container(
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 0,
          ),
          ValueListenableBuilder(
            builder: (BuildContext context, bool value, Widget? child) {
              return value
                  ? CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: 35,
                      ),
                      onPressed: () {
                        _con!.settingModalBottomSheet(context);
                      },
                    );
            },
            valueListenable: _con!.imageUploading,
          ),
          Container(
            width: 10,
            height: 0,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TextField(
                  onChanged: (value) {
                    _con!.enableButton.value = value.trim().length > 0;
                  },
                  controller: _con!.messageEditController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      border: InputBorder.none,
                      hintText: 'Send a message', hintStyle: TextStyle(
                    fontFamily: 'Urbanist',
                  )),
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            builder: (BuildContext context, bool value, Widget? child) {
              return value
                  ? IconButton(
                      onPressed: () {
                        _con!.sendMessage(_con!.messageEditController.text);
                        _con!.messageEditController.clear();
                        _con!.enableButton.value = false;
                      },
                      icon: Icon(
                        Icons.send,
                        color: Color(0xFFF68E65),
                      ),
                    )
                  : IconButton(
                      onPressed: null,
                      icon: Icon(
                        Icons.send,
                        color: Colors.grey,
                      ),
                    );
            },
            valueListenable: _con!.enableButton,
          ),
        ],
      ),
    );
  }

  Widget _imageView(Message message) {
    print("$storageServerUrl/" + message.message);
    return GestureDetector(
      onTap: () {
        _con!.viewImageDetails(
            context, "$storageServerUrl/" + message.message);
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: message.senderId == _con!.userId
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: message.senderId == _con!.userId
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.width / 3,
                  width: MediaQuery.of(context).size.width / 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "$storageServerUrl/" + message.message,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _timeView(message)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
