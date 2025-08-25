# 🗃️ Migrações de Banco com Alembic - Guia Prático

> **Guia conciso para gerenciar mudanças no esquema do banco usando Makefile + Alembic**
> 
> 📖 Para conceitos de arquitetura, veja [README principal](../README.md)

## 🚀 **PRIMEIRA EXECUÇÃO - Setup Inicial**

### **Cenário: Você acabou de clonar o projeto**

**1. 📥 Clone e navegue:**
```bash
git clone <repository-url>
cd sportify-api
```

**2. ⚙️ Configure ambiente (se necessário):**
```bash
# Verifique se existe .env na raiz do projeto
ls -la | grep .env

# Se NÃO existir, copie do exemplo:
cp .env.example .env

# Edite se necessário (URLs, senhas, etc):
nano .env
```

**3. 🚀 Inicie containers:**
```bash
make up
```

**4. 🗃️ Configure Alembic (APENAS primeira vez):**
```bash
# PRIMEIRO: Crie a estrutura de diretórios se não existir
mkdir -p src/sportifyapi/infrastructure/database/models
mkdir -p src/sportifyapi/infrastructure/database/repositories

# Crie arquivos __init__.py necessários:
touch src/sportifyapi/infrastructure/__init__.py
touch src/sportifyapi/infrastructure/database/__init__.py
touch src/sportifyapi/infrastructure/database/models/__init__.py
touch src/sportifyapi/infrastructure/database/repositories/__init__.py

# Crie o arquivo base para modelos:
cat > src/sportifyapi/infrastructure/database/models/__init__.py << 'EOF'
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
EOF

# DEPOIS: Configure Alembic
make migrate-init

# Isso cria a estrutura de migrations:
# infrastructure/database/migrations/
# ├── alembic.ini
# ├── env.py  
# └── versions/
```

**5. ⚙️ Configure o env.py (APENAS primeira vez):**
```bash
# Edite o arquivo gerado:
nano src/sportifyapi/infrastructure/database/migrations/env.py

# Cole a configuração abaixo (substitua o conteúdo)
```

**Configuração do env.py:**
```python
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
import os
import sys

# Adicionar src ao path para imports
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..'))

# IMPORTANTE: Importe TODOS os modelos aqui conforme criar
from sportifyapi.infrastructure.database.models import Base
# from sportifyapi.infrastructure.database.models.country import CountryModel
# from sportifyapi.infrastructure.database.models.user import UserModel
# ... adicione novos imports conforme criar modelos

config = context.config
target_metadata = Base.metadata

def get_url():
    return os.getenv("DATABASE_URL", "postgresql://postgres:postgres@db:5432/sportify")

def run_migrations_online():
    configuration = config.get_section(config.config_ini_section)
    configuration["sqlalchemy.url"] = get_url()
    
    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()

run_migrations_online()
```

**6. 🎯 Crie sua primeira migração:**
```bash
# PRIMEIRO: Crie um modelo de exemplo
cat > src/sportifyapi/infrastructure/database/models/country.py << 'EOF'
from sqlalchemy import Integer, String, Boolean, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func
from . import Base

class CountryModel(Base):
    __tablename__ = "countries"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    iso_code: Mapped[str] = mapped_column(String(2), unique=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[DateTime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[DateTime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())
EOF

# SEGUNDO: Adicione o import no env.py
# Edite src/sportifyapi/infrastructure/database/migrations/env.py
# Descomente/adicione a linha:
# from sportifyapi.infrastructure.database.models.country import CountryModel

# TERCEIRO: Gere a migração:
make migration msg="Initial database structure"

# QUARTO: Aplique no banco:
make migrate

# QUINTO: Verifique se deu certo:
make migrate-status
```

**📋 Resultado esperado:**
```bash
# make migrate-status deve mostrar algo como:
Current revision: abc123def (head)
Rev: abc123def (head)
Path: .../versions/001_initial_database_structure.py
```

### **✅ Checklist da Primeira Execução:**

- [ ] `.env` existe na raiz (copie de `.env.example` se necessário)
- [ ] `make up` executado com sucesso
- [ ] **Estrutura de diretórios criada** (`infrastructure/database/models/`)
- [ ] **Arquivo base criado** (`models/__init__.py` with Base)
- [ ] `make migrate-init` executado
- [ ] `env.py` configurado com imports dos modelos
- [ ] **Primeiro modelo criado** (ex: `country.py`)
- [ ] Primeira migração criada com `make migration`
- [ ] Migração aplicada com `make migrate`
- [ ] Status verificado com `make migrate-status`

### **🎯 Estrutura Final Esperada:**
```
src/sportifyapi/
├── infrastructure/
│   └── database/
│       ├── models/
│       │   ├── __init__.py          # ✅ Contém Base = declarative_base()
│       │   ├── country.py           # 📝 Seus modelos SQLAlchemy
│       │   └── user.py              # 📝 Mais modelos...
│       ├── repositories/            # 🔧 Implementações dos repositórios
│       └── migrations/              # 🗃️ Gerado pelo Alembic
│           ├── alembic.ini
│           ├── env.py
│           └── versions/
│               └── 001_initial.py
└── domain/                          # 💎 Entidades e regras de negócio
    └── entities/
```

---

## 🎯 O que é Alembic?

**Alembic = "Git para seu banco de dados"**

- ✅ **Controle de versão** do schema do banco
- ✅ **Colaboração em equipe** - todos têm a mesma estrutura
- ✅ **Deploy seguro** - aplica mudanças incrementais
- ✅ **Rollback** - volta atrás se algo der errado

## 🚀 Comandos Essenciais (com Makefile)

### **Workflow Diário:**

```bash
# 1. 🏗️ Criei um novo modelo? Gero migração:
make migration msg="Add users table"

# 2. 🚀 Aplico no banco:
make migrate

# 3. 📊 Verifico se deu certo:
make migrate-status
```

### **Comandos Completos:**

| Comando | Quando Usar | O que Faz |
|---------|-------------|-----------|
| `make migration msg="Descrição"` | ✏️ **Após criar/alterar modelos** | Gera arquivo de migração |
| `make migrate` | 🚀 **Aplicar mudanças no banco** | Executa migrações pendentes |
| `make migrate-status` | 📊 **Verificar estado atual** | Mostra migrações aplicadas |
| `make migrate-rollback` | ⏪ **Desfazer última migração** | Volta uma migração atrás |

## 📁 Estrutura de Arquivos (Auto-criada)

```
infrastructure/database/
├── migrations/              # 🆕 Pasta criada automaticamente
│   ├── alembic.ini         # Configuração
│   ├── env.py              # Setup do ambiente
│   └── versions/           # 📝 Arquivos de migração
│       ├── 001_add_countries.py
│       ├── 002_add_users.py
│       └── 003_add_clubs.py
└── models/                 # Seus modelos SQLAlchemy
    ├── country.py
    ├── user.py
    └── club.py
```

## 🔄 Cenários Práticos

### **Cenário 1: Criou um Novo Modelo**

```python
# Você criou: infrastructure/database/models/user.py
class UserModel(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True)
```

**O que fazer:**
```bash
# 1. Gerar migração
make migration msg="Add users table"

# 2. Aplicar no banco
make migrate
```

### **Cenário 2: Modificou um Campo**

```python
# Mudou de String(100) para String(200)
name: Mapped[str] = mapped_column(String(200), nullable=False)
```

**O que fazer:**
```bash
make migration msg="Extend user name to 200 chars"
make migrate
```

### **Cenário 3: Algo Deu Errado**

```bash
# Rollback da última migração
make migrate-rollback

# Verificar estado
make migrate-status
```

## ⚙️ Setup Inicial (Primeira Vez)

### **Quando você clona o projeto:**

```bash
# 1. Subir containers
make up

# 2. Aplicar migrações existentes
make migrate

# 3. Verificar se deu certo
make migrate-status
```

### **Quando você cria um projeto novo:**

```bash
# 1. Subir containers
make up

# 2. Configurar Alembic (apenas primeira vez)
make migrate-init

# 3. Editar o arquivo de configuração
# Edite: infrastructure/database/migrations/env.py
# (veja exemplo abaixo)

# 4. Criar primeira migração
make migration msg="Initial database structure"

# 5. Aplicar
make migrate
```

## 📝 Configuração do env.py

**Arquivo**: `infrastructure/database/migrations/env.py`

```python
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
import os
import sys

# Adicionar src ao path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..'))

# IMPORTANTE: Importar TODOS os modelos aqui
from sportifyapi.infrastructure.database.models import Base
from sportifyapi.infrastructure.database.models.country import CountryModel
from sportifyapi.infrastructure.database.models.user import UserModel
# ... importe todos os seus modelos

config = context.config
target_metadata = Base.metadata

def get_url():
    return os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/sportify")

def run_migrations_online():
    configuration = config.get_section(config.config_ini_section)
    configuration["sqlalchemy.url"] = get_url()
    
    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()

run_migrations_online()
```

## 🎯 Regras de Ouro

### ✅ **Sempre Faça:**

1. **Importe novos modelos no env.py**
```python
# Sempre que criar um modelo novo:
from sportifyapi.infrastructure.database.models.seu_novo_modelo import SeuNovoModel
```

2. **Use mensagens descritivas**
```bash
# 👍 Bom
make migration msg="Add user authentication fields"

# 👎 Ruim  
make migration msg="changes"
```

3. **Revise antes de aplicar**
```bash
# Sempre verifique o arquivo gerado em versions/ antes de:
make migrate
```

### ❌ **Nunca Faça:**

1. **Editar migrações já aplicadas**
2. **Fazer migrate em produção sem testar**
3. **Esquecer de importar modelos no env.py**

## 🐳 Como Funciona com Docker

**Todos os comandos do Makefile executam dentro do container:**

```bash
# Quando você faz:
make migration msg="Add users"

# Na verdade executa:
docker compose exec api alembic revision --autogenerate -m "Add users"
```

**Benefícios:**
- ✅ Não precisa instalar Python/Poetry local
- ✅ Mesmo ambiente para todos da equipe
- ✅ Funciona em qualquer OS (Linux, Windows, Mac)

## 🆘 Resolução de Problemas

### **❓ "Alembic não encontra meus modelos"**
**Solução:** Verifique se importou no `env.py`
```python
# infrastructure/database/migrations/env.py
from sportifyapi.infrastructure.database.models.seu_modelo import SeuModelo
```

### **❓ "Migration não foi gerada"**
**Solução:** 
1. Verifique import no `env.py`
2. Certifique-se que o modelo herda de `Base`
3. Reinicie containers: `make down && make up`

### **❓ "Erro: pasta migrations não existe"**
**Solução:**
```bash
# Execute o comando de inicialização:
make migrate-init

# Depois configure o env.py conforme mostrado acima
```

### **❓ "Erro de conexão com banco"**
**Solução:**
```bash
# Reinicie os containers
make down
make up

# Verifique se o banco está rodando:
make logs
```

### **❓ "make migrate-init não funciona"**
**Solução:**
```bash
# Execute manualmente dentro do container:
docker compose exec api alembic init infrastructure/database/migrations

# Ou se o container não estiver rodando:
make up
make migrate-init
```

### **❓ "Erro: alembic.ini not found"**
**Solução:** Você está no diretório errado ou não executou `make migrate-init`
```bash
# Certifique-se de estar na raiz do projeto:
cd sportify-api

# Execute a inicialização:
make migrate-init
```

### **❓ "Quero voltar tudo do zero"**
**Solução:**
```bash
make reset  # Remove tudo (containers, volumes, dados)
make up     # Recomeça limpo
make migrate-init  # Reconfigurar Alembic se necessário
```

### **❓ "Primeira execução - erro de DATABASE_URL"**
**Solução:**
1. Verifique se `.env` existe na raiz do projeto
2. Se não existir: `cp .env.example .env`
3. Verifique se DATABASE_URL está correto no `.env`

---

## 📚 Comandos de Referência Rápida

```bash
# === DESENVOLVIMENTO ===
make up                              # Iniciar ambiente
make migration msg="Sua descrição"   # Nova migração  
make migrate                         # Aplicar migrações
make migrate-status                  # Ver status

# === TROUBLESHOOTING ===
make migrate-rollback                # Voltar atrás
make reset && make up                # Reset completo
make logs                           # Ver o que está acontecendo

# === BANCO ===
make connect                        # Terminal do PostgreSQL
```

**Lembre-se:** O Alembic está no Infrastructure layer - cuida dos detalhes técnicos enquanto seu Domain layer fica focado no negócio! 🏗️
