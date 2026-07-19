import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../private_reflections.dart';

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final privateReflections = ref.watch(privateReflectionProvider);
    final state = privateReflections.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(header: true, child: Text(localizations.savedTitle)),
      ),
      body: SunnahContentFrame(
        child: switch (state) {
          PrivateReflectionReady(:final snapshot, :final isMutating) =>
            _PrivateReflectionContent(
              snapshot: snapshot,
              isMutating: isMutating,
            ),
          _ when privateReflections.isLoading => const Center(
            child: CircularProgressIndicator(),
          ),
          _ => SunnahEmptyState(
            icon: Icons.lock_outline,
            title: localizations.privateReflectionStorageUnavailableTitle,
            message: localizations.privateReflectionStorageUnavailableMessage,
          ),
        },
      ),
    );
  }
}

class _PrivateReflectionContent extends ConsumerStatefulWidget {
  const _PrivateReflectionContent({
    required this.snapshot,
    required this.isMutating,
  });

  final PrivateReflectionSnapshot snapshot;
  final bool isMutating;

  @override
  ConsumerState<_PrivateReflectionContent> createState() =>
      _PrivateReflectionContentState();
}

class _PrivateReflectionContentState
    extends ConsumerState<_PrivateReflectionContent> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSave =>
      !_isSaving &&
      !widget.isMutating &&
      !widget.snapshot.isFull &&
      PrivateReflection.normalizeBody(_controller.text) != null;

  Future<void> _saveReflection() async {
    if (!_canSave) {
      return;
    }

    setState(() => _isSaving = true);
    final didSave = await ref
        .read(privateReflectionProvider.notifier)
        .addReflection(_controller.text);
    if (!mounted) {
      return;
    }

    if (didSave) {
      _controller.clear();
    } else {
      _showMessage(AppLocalizations.of(context).privateReflectionSaveFailed);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _deleteReflection(String id) async {
    final didDelete = await ref
        .read(privateReflectionProvider.notifier)
        .deleteReflection(id);
    if (!mounted || didDelete) {
      return;
    }
    _showMessage(AppLocalizations.of(context).privateReflectionDeleteFailed);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: SunnahLayout.mobilePagePadding,
      children: [
        Semantics(
          header: true,
          child: Text(
            localizations.privateReflectionsHeading,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.privateReflectionsDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        SunnahSectionCard(
          title: localizations.privateReflectionInputLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('private-reflection-input'),
                controller: _controller,
                maxLength: PrivateReflection.maximumBodyLength,
                maxLines: 5,
                minLines: 3,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                autofillHints: null,
                decoration: InputDecoration(
                  labelText: localizations.privateReflectionInputLabel,
                  hintText: localizations.privateReflectionInputHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (widget.snapshot.isFull) ...[
                const SizedBox(height: 8),
                Text(localizations.privateReflectionsLimitReached),
              ],
              const SizedBox(height: 8),
              FilledButton(
                key: const ValueKey('private-reflection-save'),
                onPressed: _canSave ? _saveReflection : null,
                child: Text(localizations.savePrivateReflection),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (widget.snapshot.isEmpty)
          SunnahEmptyState(
            icon: Icons.edit_note_outlined,
            title: localizations.privateReflectionsEmptyTitle,
            message: localizations.privateReflectionsEmptyMessage,
          )
        else
          ...widget.snapshot.reflections.map(
            (reflection) => Card(
              key: ValueKey('private-reflection-${reflection.id}'),
              child: ListTile(
                title: Text(reflection.body),
                trailing: IconButton(
                  key: ValueKey('private-reflection-delete-${reflection.id}'),
                  tooltip: localizations.deletePrivateReflection,
                  onPressed: widget.isMutating
                      ? null
                      : () => _deleteReflection(reflection.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
        const SizedBox(height: 32),
        Semantics(
          header: true,
          child: Text(
            localizations.savedContentHeading,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SunnahEmptyState(
          icon: Icons.bookmark_outline,
          title: localizations.savedContentUnavailableTitle,
          message: localizations.savedContentUnavailableMessage,
        ),
      ],
    );
  }
}
