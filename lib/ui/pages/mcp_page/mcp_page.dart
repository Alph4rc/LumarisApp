import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/mcp/mcp_constants.dart';
import 'package:ios_club_app/features/mcp/models/mcp_probe_result.dart';
import 'package:ios_club_app/features/mcp/models/mcp_tool.dart';
import 'package:ios_club_app/features/mcp/services/mcp_config_generator.dart';
import 'package:ios_club_app/features/mcp/services/mcp_probe_service.dart';
import 'package:ios_club_app/features/mcp/services/mcp_token_store.dart';

/// 光序 MCP 配置页：展示服务地址、保存令牌，并生成可复制的客户端配置。
class McpPage extends StatefulWidget {
  const McpPage({super.key, this.tokenStore, this.probeService});

  /// 测试可注入的令牌存储。
  final McpTokenStore? tokenStore;

  /// 测试可注入的探测服务。
  final McpProbeService? probeService;

  @override
  State<McpPage> createState() => _McpPageState();
}

class _McpPageState extends State<McpPage> {
  final TextEditingController _tokenController = TextEditingController();
  late final McpTokenStore _tokenStore;
  late final McpProbeService _probeService;

  bool _tokenLoaded = false;
  bool _obscureToken = true;
  bool _savingToken = false;
  bool _testing = false;
  String? _savedToken;
  McpProbeResult? _probeResult;

  @override
  void initState() {
    super.initState();
    _tokenStore = widget.tokenStore ?? const McpTokenStore();
    _probeService = widget.probeService ?? McpProbeService();
    _tokenController.addListener(_onTokenChanged);
    _loadToken();
  }

  @override
  void dispose() {
    _tokenController.removeListener(_onTokenChanged);
    _tokenController.dispose();
    super.dispose();
  }

  void _onTokenChanged() {
    setState(() {});
  }

  Future<void> _loadToken() async {
    final token = await _tokenStore.read();
    if (!mounted) {
      return;
    }

    if (_tokenController.text.isEmpty) {
      _tokenController.text = token ?? '';
    }
    setState(() {
      _savedToken = token;
      _tokenLoaded = true;
    });
  }

  Future<void> _saveToken() async {
    setState(() => _savingToken = true);
    final saved = await _tokenStore.save(_tokenController.text);
    if (!mounted) {
      return;
    }

    setState(() {
      _savingToken = false;
      if (saved) {
        _savedToken = McpConfigGenerator.normalizeToken(_tokenController.text);
      }
    });

    McFeedback.showMessage(
      context,
      message: saved
          ? context.l10n.mcpTokenSaved
          : context.l10n.mcpTokenSaveFailed,
    );
  }

  Future<void> _clearToken() async {
    final confirmed = await showMcConfirmDialog(
      context: context,
      title: context.l10n.mcpTokenSection,
      message: context.l10n.mcpTokenClearConfirm,
      confirmText: context.l10n.delete,
      cancelText: context.l10n.cancel,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _savingToken = true);
    final cleared = await _tokenStore.clear();
    if (!mounted) {
      return;
    }

    setState(() {
      _savingToken = false;
      if (cleared) {
        _savedToken = null;
        _tokenController.text = '';
      }
    });

    if (!cleared) {
      McFeedback.showMessage(context, message: context.l10n.mcpTokenSaveFailed);
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }

    McFeedback.showMessage(context, message: context.l10n.copiedToClipboard);
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _probeResult = null;
    });

    final result = await _probeService.probe(token: _tokenController.text);
    if (!mounted) {
      return;
    }

    setState(() {
      _testing = false;
      _probeResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final jsonConfig = McpConfigGenerator.buildJson(_tokenController.text);
    final cliCommand = McpConfigGenerator.buildClaudeCodeCommand(
      _tokenController.text,
    );

    return Scaffold(
      appBar: McAppBar(title: l10n.mcpTitle),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 600 ? 32.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.mcpSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, l10n.mcpServerSection),
                    const SizedBox(height: 12),
                    _buildServerCard(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, l10n.mcpTokenSection),
                    const SizedBox(height: 12),
                    _buildTokenCard(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, l10n.mcpConfigSection),
                    const SizedBox(height: 12),
                    _buildConfigCard(context, jsonConfig, cliCommand),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, l10n.mcpConnectionSection),
                    const SizedBox(height: 12),
                    _buildConnectionCard(context),
                    const SizedBox(height: 20),
                    Text(
                      l10n.mcpSecurityNote,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colors.tertiaryLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.mc.colors;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: colors.secondaryLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildServerCard(BuildContext context) {
    final colors = context.mc.colors;
    final l10n = context.l10n;

    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          McListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Icon(CupertinoIcons.link, size: 20, color: colors.primary),
            title: Text(l10n.mcpServerAddress),
            subtitle: Text(
              McpConstants.endpoint,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.copy, size: 20),
              tooltip: l10n.copyTooltip,
              onPressed: () => _copy(McpConstants.endpoint),
            ),
          ),
          McListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Icon(
              CupertinoIcons.arrow_2_circlepath,
              size: 20,
              color: colors.tertiaryLabel,
            ),
            title: const Text('Streamable HTTP · POST'),
            subtitle: Text(
              'MCP ${McpConstants.protocolVersion}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenCard(BuildContext context) {
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final disabled = !_tokenLoaded || _savingToken;

    return McCard.elevated(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.mcpTokenLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.label,
                  ),
                ),
              ),
              _buildTokenStatusChip(context),
            ],
          ),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: _tokenController,
            obscureText: _obscureToken,
            autocorrect: false,
            enableSuggestions: false,
            placeholder: l10n.mcpTokenHint,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(McRadii.md),
              border: Border.all(
                color: colors.separator.withValues(alpha: 0.2),
              ),
            ),
            suffix: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() => _obscureToken = !_obscureToken);
              },
              child: Icon(
                _obscureToken ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                size: 20,
                color: colors.tertiaryLabel,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                onPressed: disabled ? null : _saveToken,
                child: _savingToken
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CupertinoColors.white,
                        ),
                      )
                    : Text(l10n.save),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                onPressed: disabled ? null : _clearToken,
                child: Text(
                  l10n.delete,
                  style: TextStyle(color: colors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenStatusChip(BuildContext context) {
    final colors = context.mc.colors;
    final normalized = McpConfigGenerator.normalizeToken(_tokenController.text);

    final String text;
    final Color color;
    if (normalized == null) {
      text = context.l10n.mcpTokenNotSet;
      color = colors.tertiaryLabel;
    } else if (normalized == _savedToken) {
      text = context.l10n.mcpTokenSaved;
      color = colors.success;
    } else {
      text = context.l10n.mcpTokenUnsaved;
      color = colors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildConfigCard(
    BuildContext context,
    String jsonConfig,
    String cliCommand,
  ) {
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final enabled = _tokenLoaded;

    return McCard.elevated(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mcpConfigSubtitle,
            style: TextStyle(fontSize: 13, color: colors.secondaryLabel),
          ),
          const SizedBox(height: 12),
          _buildCodeBlock(context, jsonConfig),
          const SizedBox(height: 8),
          _buildCopyButton(
            context,
            label: l10n.mcpCopyJson,
            onPressed: enabled ? () => _copy(jsonConfig) : null,
          ),
          const Divider(height: 24),
          _buildCodeBlock(context, cliCommand),
          const SizedBox(height: 8),
          _buildCopyButton(
            context,
            label: l10n.mcpCopyCli,
            onPressed: enabled ? () => _copy(cliCommand) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(BuildContext context, String text) {
    final colors = context.mc.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: colors.surfaceRaised,
        shape: McSmoothCorners.shape(McRadii.controlBorder),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.5,
          color: colors.label,
        ),
      ),
    );
  }

  Widget _buildCopyButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.copy, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(BuildContext context) {
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final normalized = McpConfigGenerator.normalizeToken(_tokenController.text);
    final result = _probeResult;

    return McCard.elevated(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: _testing || !_tokenLoaded ? null : _testConnection,
              child: _testing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.mcpTesting),
                      ],
                    )
                  : Text(l10n.mcpTestConnection),
            ),
          ),
          if (_tokenLoaded && normalized == null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.mcpNoTokenHint,
              style: TextStyle(fontSize: 12, color: colors.tertiaryLabel),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 14),
            _buildProbeResult(context, result),
          ],
        ],
      ),
    );
  }

  Widget _buildProbeResult(BuildContext context, McpProbeResult result) {
    final colors = context.mc.colors;

    if (!result.isSuccess) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            size: 18,
            color: colors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _probeFailureText(context, result.failure!),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.danger,
                  ),
                ),
                if (result.detail != null && result.detail!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    result.detail!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: colors.tertiaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.checkmark_circle_fill,
              size: 18,
              color: colors.success,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.mcpTestSuccess,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.success,
              ),
            ),
          ],
        ),
        if (result.serverName.isNotEmpty ||
            result.protocolVersion.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _serverSummary(result),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: colors.secondaryLabel,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          context.l10n.mcpToolCount(result.tools.length),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.label,
          ),
        ),
        const SizedBox(height: 8),
        ...result.tools.map((tool) => _buildToolRow(context, tool)),
      ],
    );
  }

  Widget _buildToolRow(BuildContext context, McpTool tool) {
    final colors = context.mc.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tool.name,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.label,
            ),
          ),
          if (tool.description.isNotEmpty)
            Text(
              tool.description,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: colors.secondaryLabel,
              ),
            ),
        ],
      ),
    );
  }

  String _serverSummary(McpProbeResult result) {
    final name = result.serverName;
    final version = result.serverVersion;
    final server = [name, version].where((part) => part.isNotEmpty).join(' ');
    final protocol = result.protocolVersion.isEmpty
        ? ''
        : 'MCP ${result.protocolVersion}';

    return [server, protocol].where((part) => part.isNotEmpty).join(' · ');
  }

  String _probeFailureText(BuildContext context, McpProbeFailure failure) {
    switch (failure) {
      case McpProbeFailure.unauthorized:
      case McpProbeFailure.forbidden:
        return context.l10n.mcpErrorAuth;
      case McpProbeFailure.rateLimited:
        return context.l10n.mcpErrorRateLimited;
      case McpProbeFailure.network:
        return context.l10n.mcpErrorNetwork;
      case McpProbeFailure.server:
        return context.l10n.mcpErrorServer;
      case McpProbeFailure.protocol:
      case McpProbeFailure.unexpected:
        return context.l10n.mcpErrorProtocol;
    }
  }
}
