import 'package:async_builder/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:ridealike/pages/messages/widgets/emptyview.dart';
import 'package:ridealike/pages/messages/widgets/loadingview.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'threadlistController.dart';

class ThreadListView extends StatefulWidget {
  @override
  _ThreadListViewState createState() => _ThreadListViewState();
}

class _ThreadListViewState extends StateMVC<ThreadListView> {
  ThreadListController? _con;
  bool _firstTimeLoaded = false;

  Color getColorForUser(String name) {
    final colors = [Color(0xFFFF9965), Color(0xFFFF6383), Color(0xFF66CBFF)];
    final index = name.hashCode % colors.length;
    return colors[index];
  }

  _ThreadListViewState() : super(ThreadListController()) {
    _con = controller as ThreadListController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: VisibilityDetector(
        key: Key('threadview-key'),
        onVisibilityChanged: (visibilityInfo) {
          _con!.visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (_con!.visiblePercentage == 100.0) {
            setState(() {
              _con!.dataLoaded = false;
            });
            Future.delayed(Duration(seconds: 3), () {
              _con!.getThreadList();
            });
          }
        },
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: 10),
            child: RefreshIndicator(
              onRefresh: () async {
                await LoadingView();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:16.0),
                    child: Text(
                      "Messages",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          fontFamily: 'Urbanist'),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: AsyncBuilder<List<Thread>>(
                      stream: _con!.threadStreamController.stream,
                      waiting: (context) => LoadingView(),
                      builder: (context, value) => value!.length > 0
                          ? _threadListView(value!)
                          : EmptyView(
                        message: "No Message Threads",
                      ),
                      error: (context, error, stackTrace) => EmptyView(
                        message: "Error Loading Threads",
                      ),
                    )
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  Widget _threadListView(List<Thread> list) {
    return list.length > 0
        ? ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.black38,
              height: 1,
            ),
            itemCount: list.length,
            itemBuilder: (context, pos) {
              return _threadListItem(list[pos]);
            },
          )
        : EmptyView(
            message: "No Messages Found",
          );
  }

  Widget _threadListItem(Thread thread) {
    return ListTile(
      onTap: () {
        _con!.sendThreadRead(thread, context);
      },
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 60,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(right: 2.5, left: 7.5),
              height: 7.5,
              width: 7.5,
              decoration: !thread.seen
                  ? BoxDecoration(
                      color: Color(0xffFF8F68),
                      border: Border.all(
                        color: Color(0xffFF8F68),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)))
                  : BoxDecoration(),
            ),
            SizedBox(
              width: 40,
              child: CircleAvatar(
                backgroundImage: thread.image.isNotEmpty
                    ? NetworkImage(thread.image)
                    : null,
                child: thread.image.isEmpty
                    ? Text(
                  thread.name.isNotEmpty ? thread.name[0] : 'U',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                )
                    : null,
                backgroundColor: getColorForUser(thread.name),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        thread.verificationStatus == "Undefined" ? "Deleted User" : thread.name,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Urbanist'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        thread.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, fontFamily: 'Urbanist'),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateUtil.instance.formatMessageDate(thread.time),
            style: TextStyle(fontSize: 12, fontFamily: 'Urbanist'),
          ),
          Icon(
            Icons.navigate_next,
            color: Colors.black87,
          ),
          SizedBox(
            width: 7.5,
          )
        ],
      ),
    );
  }
}
