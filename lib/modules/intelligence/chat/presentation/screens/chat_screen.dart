import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

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
      text: "Olá, parceiro! Que bom te ver por aqui. Eu e o Edmilson estamos prontos para ajudar o seu negócio e as suas finanças a crescerem. O que vamos organizar hoje?",
      isUser: false,
    ),
  ];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  
  final List<String> _suggestions = [
    "Como pagar ISPC?",
    "Dicas para o Negócio",
    "Falar com Edmilson",
    "Analise minhas contas"
  ];

  void _handleSend([String? text]) async {
    final messageText = text ?? _textController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: messageText, isUser: true));
      if (text == null) _textController.clear();
    });

    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1200));
    
    String response = "Excelente ponto! Vamos analisar isso juntos. O Edmilson sempre diz que o segredo está nos detalhes. Quer que eu verifique algo específico no seu fluxo?";
    
    final lowerText = messageText.toLowerCase();
    if (lowerText.contains("ispc") || lowerText.contains("limite")) {
      response = "Olha, para o ISPC em Moçambique, o limite é de 2.500.000 MT/ano. É um regime ótimo para quem está a crescer como você! Se precisar, podemos simular se já está perto desse valor.";
    } else if (lowerText.contains("pagar") || lowerText.contains("como")) {
      response = "Podemos resolver isso fácil! O pagamento é trimestral via Guia de Recolhimento. Eu posso te avisar quando a data estiver próxima, o que acha?";
    } else if (lowerText.contains("dica") || lowerText.contains("negócio")) {
      response = "Uma dica de parceiro: Tente sempre separar o que é lucro do que é capital de giro. Use o app para marcar bem o que é 'Negócio' e o Edmilson e eu te ajudamos a ver o crescimento real no fim do mês.";
    } else if (lowerText.contains("edmilson") || lowerText.contains("falar")) {
      response = "Com certeza! O Edmilson Muacigarro é o mentor desta jornada. Ele adora ver o sucesso dos nossos parceiros. Vou preparar o link de contacto direto para você!";
    } else if (lowerText.contains("analise") || lowerText.contains("contas")) {
      response = "Com todo o gosto! Já vi as tuas transações recentes e estamos no bom caminho. Gostaria de ver o relatório de Fluxo de Caixa ou o DRE para termos uma visão estratégica?";
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
            const Text('Edmilson & IA (Parceiro)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Online • Pronto para crescermos juntos', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
