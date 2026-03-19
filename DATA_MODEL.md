# DATA_MODEL.md - Conta Fácil

> Definição Física do Banco de Dados (PostgreSQL / Firestore)

## 1. Tabelas / Coleções

### `users`
- `id`: UUID (PK)
- `full_name`: String (Encrypted)
- `email`: String (Unique, Indexed, Encrypted)
- `phone`: String (Encrypted)
- `account_type`: Enum ('pessoal', 'empresarial')
- `jurisdiction`: String ('MZ')
- `consent_pro`: Boolean
- `status`: Enum ('active', 'suspended')
- `created_at`: Timestamp
- `updated_at`: Timestamp

### `accounts`
- `id`: UUID (PK)
- `user_id`: UUID (FK -> users.id)
- `type`: Enum ('checking', 'savings', 'cash', 'credit', 'business', 'investment')
- `name`: String
- `currency`: String ('MZN')
- `initial_balance`: Decimal
- `current_balance`: Decimal
- `is_archived`: Boolean (Default: false)

### `transactions`
- `id`: UUID (PK)
- `account_id`: UUID (FK -> accounts.id)
- `user_id`: UUID (FK -> users.id, De-normalized)
- `type`: Enum ('income', 'expense', 'transfer_in', 'transfer_out')
- `amount`: Decimal (Precision: 20, Scale: 2)
- `description`: String (Encrypted)
- `category_id`: UUID (FK -> categories.id)
- `payment_method`: Enum ('cash', 'card', 'transfer', 'other')
- `recurrence_id`: UUID (Nullable)
- `attachment_url`: String (Nullable)
- `is_deleted`: Boolean (Logical delete)

### `categories`
- `id`: UUID (PK)
- `user_id`: UUID (FK -> users.id, Null for system default)
- `name`: String
- `type`: Enum ('income', 'expense')
- `parent_id`: UUID (Self-relation)

### `chat_sessions`
- `id`: UUID (PK)
- `user_id`: UUID (FK -> users.id)
- `type`: Enum ('bot_only', 'escalated')
- `professional_id`: UUID (FK -> users.id, Nullable)
- `status`: Enum ('active', 'closed', 'archived')
- `escalation_reason`: Text

### `chat_messages`
- `id`: UUID (PK)
- `session_id`: UUID (FK -> chat_sessions.id)
- `sender_type`: Enum ('user', 'bot', 'pro')
- `content`: Text (Encrypted)
- `topic_tag`: Enum ('general', 'fiscal', 'budget', 'education', 'escalation', 'other')
- `legal_notice_shown`: Boolean
- `created_at`: Timestamp

### `audit_logs` (Imutável)
- `id`: UUID (PK)
- `actor_id`: UUID (FK)
- `action_type`: String (e.g., 'DELETE_TRANSACTION')
- `target_id`: UUID
- `justification`: Text
- `ip_address`: String
- `created_at`: Timestamp
