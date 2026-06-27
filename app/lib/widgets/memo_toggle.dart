import 'package:flutter/material.dart';
import '../services/user_memo.dart';
import '../theme.dart';

/// 카드 별 메모 토글 — 작은 아이콘 → 탭하면 입력 영역 펼침.
/// level = 덱 id ('native', 'r1', ...), turn = 카드 id 의 숫자 (또는 hash).
class MemoToggle extends StatefulWidget {
  final String level;
  final int turn;
  const MemoToggle({super.key, required this.level, required this.turn});

  @override
  State<MemoToggle> createState() => _MemoToggleState();
}

class _MemoToggleState extends State<MemoToggle> {
  bool _open = false;
  bool _loaded = false;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MemoToggle old) {
    super.didUpdateWidget(old);
    if (old.level != widget.level || old.turn != widget.turn) {
      _open = false;
      _loaded = false;
      _ctrl.text = '';
      _load();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final v = await UserMemo.get(widget.level, widget.turn);
    if (!mounted) return;
    setState(() {
      _ctrl.text = v;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    await UserMemo.set(widget.level, widget.turn, _ctrl.text);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasMemo = _ctrl.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _open
                      ? Icons.edit_note
                      : (hasMemo ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined),
                  size: 14,
                  color: hasMemo ? AppColors.sakuraDeep : AppColors.inkSoft,
                ),
                const SizedBox(width: 4),
                Text(
                  hasMemo ? '메모 있음' : '메모',
                  style: TextStyle(
                    fontSize: 10,
                    color: hasMemo ? AppColors.sakuraDeep : AppColors.inkSoft,
                    fontWeight: hasMemo ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                if (hasMemo) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.sakuraDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                const Spacer(),
                Text(_open ? '닫기 ▴' : '▾',
                    style: const TextStyle(fontSize: 10, color: AppColors.inkSoft)),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                    decoration: BoxDecoration(
                      color: AppColors.honeySoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.inkOutline.withValues(alpha: 0.6), width: 0.8),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      enabled: _loaded,
                      maxLines: null,
                      minLines: 2,
                      style: const TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 2),
                        border: InputBorder.none,
                        hintText: '예: 이 단어 헷갈림. 발음 더 듣고 싶음.',
                        hintStyle: TextStyle(
                          fontSize: 11,
                          color: AppColors.inkLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      onChanged: (_) => _save(),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
