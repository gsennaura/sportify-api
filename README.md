
# 🏆 Sportify API

> **API para gestão de ecossistemas esportivos com arquitetura limpa e modelos auto-gerados**

## 🎯 O que este projeto faz?

Este projeto implementa uma **API REST** para gestão de dados esportivos (países, federações, clubes, atletas) usando uma abordagem única:

- ✅ **Banco de dados primeiro**: Partimos de um schema PostgreSQL pronto com dados
- ✅ **Modelos auto-gerados**: SQLAlchemy models são criados automaticamente do DB
- ✅ **Arquitetura limpa**: Separação clara entre API, business logic e infraestrutura

## � Como usar

### 1. Subir o projeto
```bash
make up
```
Isso iniciará PostgreSQL + FastAPI com dados de exemplo já carregados.

### 2. Gerar modelos SQLAlchemy 
```bash
make generate-models
```

**O que acontece aqui?**
1. 🔍 O comando analisa o **schema atual** do PostgreSQL
2. 🤖 Usa `sqlacodegen` para **gerar automaticamente** modelos SQLAlchemy 
3. 📁 Salva em `src/sportifyapi/infrastructure/database/models/generated_models.py`
4. ✨ Inclui **relacionamentos**, **constraints** e **tipos** corretos

### 3. Acessar a API
- **Swagger Docs**: http://localhost:8000/docs
- **Exemplo de endpoint**: http://localhost:8000/api/v1/countries/

## 🔄 Fluxo de dados fim-a-fim

### Quando você acessa `/api/v1/countries/`:

```
🌐 HTTP Request 
    ↓
📍 FastAPI Router (/api/controllers/country.py)
    ↓  
🎯 Use Case (/application/use_cases/country/get_all_countries.py)
    ↓
🏗️ Repository Interface (/domain/repositories/country_repository.py)
    ↓
🔧 Repository Implementation (/infrastructure/database/repositories/country_repository.py)
    ↓
📊 SQLAlchemy Model (generated_models.py)
    ↓
🗄️ PostgreSQL Database
    ↓
📋 JSON Response
```

### Por que essa arquitetura?

- **🧪 Testável**: Cada camada pode ser testada isoladamente
- **🔄 Flexível**: Mudanças no DB são refletidas automaticamente nos models
- **📚 Didática**: Separação clara de responsabilidades
- **🚀 Produtiva**: Não precisamos escrever models manualmente

## 📋 Comandos essenciais

```bash
make up                 # Iniciar aplicação (PostgreSQL + FastAPI)
make generate-models    # Sincronizar models com o banco
make down              # Parar aplicação
make test              # Executar testes
make logs              # Ver logs em tempo real
```

## 💡 Entendendo o `generate-models`

### Antes:
```python
# Você teria que escrever isso manualmente:
class Countries(Base):
    __tablename__ = 'countries'
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    iso_code = Column(CHAR(2), unique=True)
    # ... mais 50 linhas de código
```

### Depois do `make generate-models`:
```python
# Automático! Baseado no schema real do banco:
from sportifyapi.infrastructure.database.models.generated_models import Countries

# Pronto para usar, com relacionamentos e tudo!
countries = session.query(Countries).all()
```

## �️ Dados de exemplo incluídos

O banco vem pré-carregado com:
- 🌍 **8 países** (Brasil, Argentina, EUA, etc.)
- 🏛️ **Federações** esportivas por país
- ⚽ **Clubes** e modalidades
- 👥 **Pessoas**, atletas e staff

## 🔧 Comandos de desenvolvimento

```bash
make tidy              # Formatar código (black, isort)
make test              # Rodar testes unitários
make help              # Ver todos comandos disponíveis
```

---

## � Por que essa abordagem?

1. **Database-First**: Muitas vezes já temos um banco definido
2. **Zero Drift**: Models sempre sincronizados com a realidade  
3. **Menos Bugs**: Impossível ter models desatualizados
4. **Mais Produtivo**: Foco na lógica de negócio, não em boilerplate

**Happy coding!** 🚀
