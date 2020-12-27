import 'package:chat_app/presentation/my_name_edit/my_name_edit_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyNameEditPage extends StatelessWidget {
  MyNameEditPage(this.textEditingController);
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyNameEditModel>(
      create: (_) => MyNameEditModel(),
      child: Consumer<MyNameEditModel>(
        builder: (context, model, child) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: model.isLoading
                ? Container(
                    child: model.isLoading
                        ? Container(
                            color: Colors.grey.withOpacity(0.8),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : null)
                : Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        onPressed: () {
                          textEditingController.clear();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                      title: Text('名前'),
                      actions: [
                        IconButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          icon: Icon(
                            Icons.clear,
                          ),
                        ),
                      ],
                    ),
                    body: Container(
                      color: Colors.white10,
                      child: SafeArea(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                          child: Column(
                            children: [
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '名前',
                                  ),
                                  controller: textEditingController,
                                  onChanged: (text) {
                                    model.name = text;
                                    model.checkUpdateBtn();
                                  },
                                ),
                              ),
                              RaisedButton(
                                child: Text('保存'),
                                onPressed: model.isUpdateFlg
                                    ? () async {
                                        await model.updateName();
                                        Navigator.of(context).pop();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
