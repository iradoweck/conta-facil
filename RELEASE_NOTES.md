# 📋 Notas de Lançamento - Conta Fácil

Este documento regista a evolução do projeto **Conta Fácil**, desde o protótipo inicial até à versão atual funcional e estabilizada.

---

## ⭐ v1.4.0 (Funcionalidades PRO & Detalhes) - 30/03/2026

### 💎 Modelo de Subscrição (Gating)
- **Restrição de Contexto**: A opção de visualizar "Ambos" (Negócio + Pessoal) simultaneamente agora é um recurso exclusivo PRO em todas as telas (Dashboard, Transações e Relatórios).
- **Filtros Temporais Avançados**: O "Período Personalizado" em Relatórios e Análises foi movido para o tier PRO, incentivando o upgrade para análises profundas.
- **Visual Gating**: Implementação de ícones de cadeado e diálogos de "Upgrade" contextuais para uma experiência de venda não-intrusiva.

### 📝 Gestão de Transações
- **Central de Adição**: Novo Botão de Ação Flutuante (FAB) na tela de Todas as Transações para registo rápido sem voltar ao dashboard.
- **Detalhes da Transação (PRO)**: Nova tela de visualização detalhada que exibe metadados completos, ID da transação e categorização clara.

### 🛠️ Arquitetura
- **Pro Gate Helper**: Criação de utilitário centralizado para gestão de permissões e diálogos de subscrição.

---

## 🔝 v1.3.0 (Escalabilidade & Refinamento UI) - 30/03/2026

### 📊 Dashboard & Navegação
- **Transações Minimalistas**: Remoção do botão "Ver Tudo" e foco exclusivo nas últimas 5 transações.
- **Ecossistema de Sabedoria**: Navegação directa para ecrãs (TI & Dev, Gestão, Guia Fiscal).
- **Contexto Educativo**: Mapeamento de cards para placeholders funcionais.

### 📈 Analytics & Insights
- **Experiência Unificada**: Incorporação do Rodapé no ecrã "Estudo das minhas Finanças".
- **Insights Dinâmicos**: Refinamento do `InsightEngine` com mensagens reais e motivacionais (Dicas ISPC).
- **Estudo Financeiro**: Padronização do título para "Estudo das minhas Finanças".

### 🧹 Manutenção
- **Workspace Clean**: Limpeza de logs de construção e arquivos de análise.
- **Dev Mode Support**: Suporte para symlinks e Developer Mode no Windows.

---

## 🚀 Versão Atual: v1.2.0 (Estabilização & Identidade) - 19/03/2026

### 🎨 Identidade Visual (Phase 21)
- **Marca Unificada**: Integração do logótipo e ícone oficial em todo o aplicativo.
- **Experiência Premium**: Nova Splash Screen, Login e Dashboard com branding "Conta Fácil".
- **AppBar Branding**: Substituição de texto estático pela logo oficial no topo do Dashboard.
- **Perfil Branded**: Inclusão de elementos visuais de marca no Perfil Profissional do Edmilson.

### 📜 Dogmas de Desenvolvimento (Phase 22)
- **Localhost Dogma**: Estabelecimento da regra "App Sempre Online" durante o desenvolvimento.
- **Build Recovery**: Correção total de erros de compilação e limpeza de dívida técnica (modelos redundantes).
- **Análise Rigorosa**: Zero erros de análise no código (`flutter analyze`).

---

## 🛠 v1.1.0 (Gestão Avançada & Humanização) - 18/03/2026

### 🏦 Gestão Multi-Contas (Phase 20)
- **Contas Financeiras**: Suporte para múltiplas contas (Banco, M-Pesa, Dinheiro vivo).
- **Categorização de Contexto**: Separação clara entre contas de Negócio e contas Pessoais.
- **Central de Configurações**: Novo hub unificado que combina Perfil, Metas, Categorias e Gestão de Contas.

### 🎯 Metas & Contexto (Phase 18-19)
- **Metas Dual**: Definição de metas mensais separadas para Pessoal e Negócio.
- **Tracking no Dashboard**: Barra de progresso dinâmica que reage aos filtros da Dashboard.
- **Feedback Motivacional**: Mensagens de incentivo ("Rumo ao Sucesso!") integradas na UI.

### 🤝 Humanização & IA (Phase 17)
- **Parceiro AI**: Redesenho do Chat para agir como um colaborador amigável, não um robô.
- **Sabedoria do Edmilson**: Implementação de sessões de mentoria baseadas na experiência real de Edmilson (Contabilista & Dev).
- **UX Empática**: Estados vazios encorajadores que convidam o utilizador a crescer.

---

## ⚙️ v1.0.0 (Core Financeiro Real) - 17/03/2026

### 📈 Motor de Dados Reais (Phase 16)
- **CRUD Completo**: Edição e eliminação de transações, categorias e despesas fixas.
- **Relatórios Contabilísticos**: Telas reais de DRE, Balanço Patrimonial e Fluxo de Caixa alimentadas por dados do utilizador.
- **Analytics Profissional**: "Estudo das minhas Finanças" com gráficos de distribuição e análise de performance.
- **Filtros Temporais**: Seleção de períodos entre 7 dias e 3 anos para conformidade fiscal.

### 💾 Estabilidade & Persistência (Phase 14-15)
- **Local Storage Hardening**: Garantia de que nenhum dado é perdido ao fechar o app via SharedPreferences.
- **State Sync**: Sincronização em tempo real entre ecrãs de configuração e o motor de cálculo.

---

## 🏗 v0.9.0 (O Início - MVP) - 16/03/2026
- **Base**: Estrutura de navegação com Flutter & Riverpod.
- **Auth**: Login e Registro via Firebase.
- **Fiscal**: Simulador ISPC base para Moçambique.
- **Perfil**: Portfólio inicial e Simulador de Orçamentos de Edmilson.

---
*Assinado: Senior Debug Engineer & Flutter Architect*
