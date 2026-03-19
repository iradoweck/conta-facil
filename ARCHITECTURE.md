# ARCHITECTURE.md - Conta Fácil

> Documento de Arquitetura e Especificação Técnica (v1.0)
> Proprietário: Edmilson Adelino Muacigarro

## 1. Visão Geral
O **Conta Fácil** é uma plataforma distribuída (Mobile-first) para gestão financeira e educação fiscal, focada no mercado de Moçambique.

## 2. Pilares Arquiteturais
- **Security-First**: Cifragem ao nível do campo e imutabilidade dos registos de auditoria.
- **Compliance-Driven**: Validação rigorosa de fluxos de chat e avisos legais obrigatórios.
- **Scalability**: Preparado para escalabilidade horizontal da API e réplicas de leitura para relatórios.

## 3. Modelo de Dados (Conceptual)
### Entidades Principais:
- **User**: Perfil, jurisdição, consentimento.
- **Account**: Múltiplas contas (Numerário, Banco, Empresa).
- **Transaction**: Registos imutáveis com anexo e regra de recorrência.
- **Budget**: Planeamento mensal/anual por categoria.
- **ChatSession/Message**: Histórico com etiquetas de tópico e flags de aviso legal.
- **Lead**: Captura de solicitações para profissionais.
- **AuditLog**: Registo imutável de ações críticas.

## 4. Sistema de Chat & Escalonamento
### Fluxo de Camadas:
1. **Bot (Nível 1)**: Baseado em regras, responde FAQs e conceitos gerais.
2. **Humano (Nível 2)**: Profissional licenciado (Edmilson) para consultoria preliminar.

### Gatilhos de Escalonamento:
- Três erros consecutivos de intenção.
- Palavras-chave: "urgente", "erro", "problema fiscal", "execução fiscal".
- Solicitação direta do utilizador.

## 5. Requisitos Não Funcionais (MVP)
- **Performance**: < 2s carregamento de ecrã em 4G.
- **Disponibilidade**: 99.5%.
- **Mobile**: iOS 14+, Android 8.0+.
- **Moeda**: MZN (Metical).

## 6. Stack Técnica
- **Frontend**: Flutter
- **Backend / API**: Laravel (ou Firebase Functions)
- **Base de Dados**: Firestore / PostgreSQL (com AES-256)
- **Auth**: Firebase Auth (MFA obrigatório para Admin/Pro)
