# UX_FLOW.md - Conta Fácil

> Fluxo de Experiência do Usuário (Sitemap e Navegação)

## 1. Mapa de Telas
1. **Splash Screen**: Logo + Slogan.
2. **Auth Flow**: Login/Cadastro -> Google/Email.
3. **Onboarding**: Aceite de Termos e Aviso Legal Geral.
4. **Dashboard (Home)**: Visão de Saldo, Lucro/Prejuízo, Ações Rápidas (+ Entrada, - Saída).
5. **Transações**: Lista com filtros, busca e detalhe (com anexo).
6. **Módulo Fiscal**: Alertas de datas, Simulador de Impostos (Estimativas).
7. **Educação**: Lista de artigos e dicas rápidas.
8. **Perfil Profissional**: Bio de Edmilson, Serviços, Simulação de Orçamento.
9. **Chat**: Interface de mensagens com Bot inicial e transição para Edmilson.
10. **Configurações**: Perfil, Backup, Segurança (MFA), Exportação de Dados.

## 2. Lógica de Navegação
- **Bottom Navigation**: Home, Transações, Módulo Fiscal, Mais (Menu Expandido).
- **Ações Rápidas (Floating Button)**: Atalho para Nova Entrada/Saída.
- **Contextual Notifications**: Alerta de orçamento atingindo 80%.

## 3. Regras de Design (Conformidade)
- **Touch Targets**: Mínimo 48dp (Android) / 44pt (iOS).
- **Acessibilidade**: Suporte a Dynamic Type e leitores de ecrã.
- **Visual**: Cores conforme branding (Verde para Lucro, Vermelho para Prejuízo, Azul Profissional para Financeiro). **Sem tons de Roxo/Violeta** (conforme regras do Agente).
