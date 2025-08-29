# Gerando Modelos SQLAlchemy

## Comando Principal

```bash
make generate-models
```

Gera automaticamente modelos SQLAlchemy baseados no banco de dados existente.

## O que gera

- **Arquivo**: `src/sportifyapi/infrastructure/database/models/generated_models.py`
- **Modelos**: 14+ classes SQLAlchemy completas
- **Inclui**: Relacionamentos, constraints, tipos corretos

## Como usar

```python
from sportifyapi.infrastructure.database.models.generated_models import (
    Countries, 
    Federations, 
    Clubs, 
    Athletes,
    People
)

# Modelos prontos para usar!
```

## Próximos passos

1. Revisar o arquivo gerado
2. Mover modelos para arquivos individuais se necessário
3. Importar no `__init__.py` para uso geral

Simples assim! 🚀
