import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/shared/components/fintech_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/providers/subscription_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser}) : timestamp = DateTime.now();
}

class EdmilsonPortalScreen extends ConsumerStatefulWidget {
  const EdmilsonPortalScreen({super.key});

  @override
  ConsumerState<EdmilsonPortalScreen> createState() => _EdmilsonPortalScreenState();
}

class _EdmilsonPortalScreenState extends ConsumerState<EdmilsonPortalScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Olá, Parceiro! Sou o Edmilson, o teu mentor financeiro impulsionado por IA. Estou a monitorar as tuas contas. Como posso ajudar com o teu negócio hoje?",
      isUser: false,
    ),
  ];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  
  final List<String> _suggestions = [
    "Onde cortei custos mês passado?",
    "Dicas para margem de lucro",
    "Explicar IRPS de forma fácil",
    "Resumo da semana"
  ];

  void _handleSend([String? text]) async {
    final messageText = text ?? _textController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: messageText, isUser: true));
      if (text == null) _textController.clear();
    });

    _scrollToBottom();

    final isPro = ref.read(subscriptionProvider) == SubscriptionPlan.pro;
    final userMessagesCount = _messages.where((m) => m.isUser).length;

    if (!isPro && userMessagesCount >= 3) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Opa! Atingiste o limite de consultas gratuitas do Plano Free. Para continuar a receber insights profundos e ilimitados, torna-te um parceiro PRO! 🚀",
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
      return;
    }

    // Mock AI typing delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    String response = "Excelente pergunta. Baseado na arquitetura do 'Conta Fácil', posso afirmar que manter disciplina financeira é o primeiro passo para o sucesso.";
    
    final lowerText = messageText.toLowerCase();
    if (lowerText.contains("custos")) {
      response = "Analisando o teu DRE recente, notei uma redução de 12% em 'Transporte'. Excelente trabalho a otimizar a logística!";
    } else if (lowerText.contains("margem")) {
      response = "Para melhorar a margem, tente rever contratos de fornecedores fixos ou focar nos produtos/serviços com menor Custo de Operação (CMV). As tuas vendas cresceram, só precisamos segurar os custos.";
    } else if (lowerText.contains("irps") || lowerText.contains("imposto")) {
      response = "O IRPS (Imposto sobre Rendimento das Pessoas Singulares) em Moçambique incide sobre rendimentos anuais. Para PMEs inscritas no ISPC, o processo é mais simples. Recomendo sempre separar uma \$-reserva trimestral para evitar surpresas.";
    } else if (lowerText.contains("resumo")) {
      response = "A tua semana está positiva! O saldo aumentou em 4.5% comparado à semana passada. A eficiência geral do teu Fluxo de Caixa está em torno de 68%. Mantém o foco!";
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Portal do Edmilson', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Flexible(
                        child: Text(
                          'A analisar tuas finanças...', 
                          style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (index == 0) {
                  return Column(
                     children: [
                       _buildMessageBubble(msg),
                       const SizedBox(height: 24),
                       _buildEducationHubHero(),
                       const SizedBox(height: 24),
                     ],
                  );
                }
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildSuggestionsList(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEducationHubHero() {
     return FintechCard(
       color: AppColors.secondary.withValues(alpha: 0.1),
       padding: const EdgeInsets.all(20),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               const Icon(Icons.school_rounded, color: AppColors.secondary),
               const SizedBox(width: 8),
               const Text('Trilhas de Sucesso', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
             ],
           ),
           const SizedBox(height: 12),
           const Text('Aprende a separar as finanças pessoais da empresa com o nosso curso rápido.', style: TextStyle(fontSize: 13, color: Colors.black87)),
           const SizedBox(height: 12),
           ElevatedButton(
             onPressed: () {},
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColors.secondary,
               foregroundColor: Colors.white,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               elevation: 0,
             ),
             child: const Text('Começar Agora'),
           ),
         ],
       ),
     );
  }

  Widget _buildSuggestionsList() {
    return Container(
      color: Colors.white,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final prompt = _suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(prompt, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () => _handleSend(prompt),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                  bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(20),
                ),
                border: isUser ? null : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.black38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
             const SizedBox(width: 8),
             Container(
               width: 32,
               height: 32,
               decoration: BoxDecoration(
                 color: Colors.grey.withValues(alpha: 0.2),
                 shape: BoxShape.circle,
               ),
               child: const Center(child: Icon(Icons.person, size: 16, color: Colors.black54)),
             ),
          ]
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), // Adapta SafeArea no bottom
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Faz uma pergunta ao Edmilson...',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
               padding: const EdgeInsets.all(14),
               decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
               child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
