import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/models/todo_item.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';

import 'package:ios_club_app/core/services/todo_service.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';

class TodoWidget extends ConsumerStatefulWidget {
  const TodoWidget({super.key});

  @override
  ConsumerState<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends ConsumerState<TodoWidget> {
  late Future<List<TodoItem>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _todosFuture = getTodoList();
  }

  Future<List<TodoItem>> getTodoList() async {
    List<TodoItem> list = await TodoService.getLocalTodoList();
    return list;
  }

  Future<void> scheduleTodoNotification(TodoItem todo) async {
    await NotificationService.instance.scheduleTodoNotification(
        todo, ref.read(settingsStoreProvider).todoRemindEnabled);
  }

  Future<void> updateTodoNotification(TodoItem todo) async {
    await NotificationService.instance.updateTodoNotification(
        todo, ref.read(settingsStoreProvider).todoRemindEnabled);
  }

  Future<void> _refreshTodos() {
    setState(() {
      _todosFuture = getTodoList();
    });
    return _todosFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.todoListLabel,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      TodoItem? newItem = await showAddTodoDialog(context);

                      if (newItem != null) {
                        // 添加新待办到列表
                        await TodoService.setTodoList([
                          ...await _todosFuture,
                          newItem,
                        ]);

                        // 添加新待办时安排提醒
                        await scheduleTodoNotification(newItem);

                        // 刷新列表
                        await _refreshTodos();
                      }
                    },
                    icon: const Icon(Icons.add))
              ],
            )),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: FutureBuilder<List<TodoItem>>(
            future: _todosFuture,
            builder: (context, snapshot) {
              final innerL10n = context.l10n;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ClubCard(
                  child: LoadingStateView(
                    title: innerL10n.readingTodos,
                    subtitle: innerL10n.readingTodosSubtitle,
                    compact: true,
                    showCard: false,
                    padding: const EdgeInsets.all(16),
                  ),
                );
              } else if (snapshot.hasError) {
                return ClubCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: EmptyWidget(
                      title: innerL10n.loadFailed,
                      icon: Icons.error,
                      subtitle: innerL10n.todoLoadFailedSubtitle,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                final todos = snapshot.data!;
                return ClubCard(
                    child: todos.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: EmptyWidget(
                              title: innerL10n.noTodos,
                              icon: Icons.done_all,
                              subtitle: innerL10n.noTodosSubtitle,
                            ),
                          )
                        : SizedBox(
                            height: math.min(todos.length * 88.0, 360.0),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: todos.length,
                              itemBuilder: (context, index) {
                                final todo = todos[index];
                                DateTime? deadline;
                                try {
                                  deadline = DateFormat('yyyy-MM-dd HH:mm')
                                      .parse(todo.deadline);
                                } catch (e) {
                                  try {
                                    deadline = DateFormat('yyyy-MM-dd')
                                        .parse(todo.deadline);
                                  } catch (e) {
                                    try {
                                      deadline = DateTime.parse(todo.deadline);
                                    } catch (e) {
                                      deadline = null;
                                    }
                                  }
                                }

                                final now = DateTime.now();
                                final isBefore =
                                    deadline?.isBefore(now) ?? false;

                                return AnimatedListItem(
                                  index: index,
                                  child: ClubListTile(
                                    leading: Checkbox(
                                      value: todo.isCompleted,
                                      onChanged: (value) async {
                                        final updatedTodo = TodoItem(
                                          title: todo.title,
                                          deadline: todo.deadline,
                                          id: todo.id,
                                          isCompleted: value!,
                                        );

                                        // 更新本地存储
                                        final updatedTodos =
                                            List<TodoItem>.from(todos);
                                        updatedTodos[index] = updatedTodo;
                                        await TodoService.setTodoList(
                                            updatedTodos);

                                        // 更新提醒状态
                                        await updateTodoNotification(
                                            updatedTodo);

                                        // 刷新列表
                                        await _refreshTodos();
                                      },
                                    ),
                                    title: Text(todo.title,
                                        style: TextStyle(
                                          decoration: todo.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    subtitle: Text(
                                        '${innerL10n.deadline}: ${deadline == null ? innerL10n.noData : DateFormat('yyyy-MM-dd HH:mm').format(deadline)}',
                                        style: TextStyle(
                                          decoration: isBefore
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        )),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        // 从列表中移除
                                        final updatedTodos =
                                            List<TodoItem>.from(todos)
                                              ..removeAt(index);
                                        await TodoService.setTodoList(
                                            updatedTodos);

                                        // 删除时取消提醒
                                        await NotificationService
                                            .instance.notifications
                                            .cancel(id: todo.id.hashCode);

                                        // 刷新列表
                                        await _refreshTodos();
                                      },
                                    ),
                                    onTap: () async {
                                      var result = await showAddTodoDialog(
                                        context,
                                        todo: todo,
                                      );

                                      if (result != null) {
                                        // 更新待办事项
                                        final updatedTodos =
                                            List<TodoItem>.from(todos);
                                        updatedTodos[index] = result;
                                        await TodoService.setTodoList(
                                            updatedTodos);

                                        // 编辑时更新提醒
                                        await updateTodoNotification(result);

                                        // 刷新列表
                                        await _refreshTodos();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ));
              } else {
                return ClubCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: EmptyWidget(
                      title: innerL10n.noTodos,
                      icon: Icons.done_all,
                      subtitle: innerL10n.noTodosSubtitle,
                    ),
                  ),
                );
              }
            },
          ),
        )
      ],
    );
  }

  Future<TodoItem?> showAddTodoDialog(BuildContext context,
      {TodoItem? todo}) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();

    titleController.text = todo?.title ?? '';
    deadlineController.text = todo?.deadline ?? '';

    final result = await PlatformDialog.showCustomDialog<TodoItem?>(
      context,
      title: l10n.addTodo,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: l10n.todoTitle,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.titleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: l10n.deadline,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && context.mounted) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null && context.mounted) {
                        final dateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        deadlineController.text =
                            DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                      }
                    }
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.deadlineRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        PlatformDialogAction<TodoItem?>(
          label: l10n.cancel,
          value: null,
        ),
        PlatformDialogAction<TodoItem?>(
          label: todo == null ? l10n.addTodo : l10n.change,
          isDefaultAction: true,
          autoPop: false,
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final todoItem = TodoItem(
                title: titleController.text,
                deadline: deadlineController.text,
                id: todo?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                isCompleted: todo?.isCompleted ?? false,
              );
              Navigator.of(context).pop(todoItem);
            }
          },
        ),
      ],
    );

    // 释放控制器资源
    titleController.dispose();
    deadlineController.dispose();

    return result;
  }
}
