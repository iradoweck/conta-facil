import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser}) : timestamp = DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Olá! Sou o assistente do Conta Fácil. Posso ajudar com dúvidas sobre ISPC, IVA ou gestão do seu negócio em Moçambique. O que deseja saber?",
      isUser: false,
    ),
  ];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  
  final List<String> _suggestions = [
    "Como pagar ISPC?",
    "Limite do ISPC",
    "Dicas de Poupança",
    "Falar com Edmilson"
  ];

  void _handleSend([String? text]) async {
    final messageText = text ?? _textController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: messageText, isUser: true));
      if (text == null) _textController.clear();
    });

    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));
    
    String response = "Interessante! Para este ponto específico, recomendo consultar o nosso Guia Fiscal no menu anterior ou falar com o especialista Edmilson Muacigarro.";
    
    final lowerText = messageText.toLowerCase();
    if (lowerText.contains("ispc") || lowerText.contains("limite")) {
      response = "O limite do ISPC em Moçambique é de 2.500.000 MT anuais. Se ultrapassar, deverá transitar para o regime geral (IVA/IRPC). Quer que eu ajude a calcular?";
    } else if (lowerText.contains("pagar") || lowerText.contains("como")) {
      response = "O pagamento do ISPC pode ser feito via Guia de Recolhimento nas recebedorias de impostos ou canais bancários autorizados até ao dia 15 do mês seguinte ao trimestre.";
    } else if (lowerText.contains("dica") || lowerText.contains("poupança")) {
      response = "Uma dica de ouro: Reserve sempre 3% de cada venda imediatamente numa conta separada. Assim, o imposto já estará garantido no fim do trimestre!";
    } else if (lowerText.contains("edmilson") || lowerText.contains("falar")) {
      response = "Com certeza! O Edmilson Muacigarro é o mentor por trás desta visão. Pode contactá-lo para consultoria avançada de gestão e fiscalidade.";
    }

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FinTech Bot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Online • Especialista Fiscal', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildLegalDisclaimer(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          _buildSuggestionsList(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(_suggestions[index], style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              backgroundColor: AppColors.primary.withOpacity(0.05),
              side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
              onPressed: () => _handleSend(_suggestions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegalDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withOpacity(0.05),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'Sugestões baseadas na legislação fiscal de Moçambique.',
            style: TextStyle(fontSize: 10, color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
            bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
          boxShadow: [
            if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.black38,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Escreva sua dúvida aqui...',
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
