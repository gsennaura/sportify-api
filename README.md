# SportifyAPI

A modern **sports management backend API** built with **FastAPI**, **PostgreSQL**, **SQLAlchemy**, and **Docker**.

> 🏆 **Complete sports ecosystem management** - from federations to athletes, clubs to competitions.

---

## 🚀 Technologies

- **Python 3.12** - Modern Python with async support
- **FastAPI** - High-performance web framework
- **SQLAlchemy (Async ORM)** - Database modeling and queries
- **PostgreSQL 16** - Robust relational database
- **Docker & Docker Compose** - Containerized development
- **Poetry** - Modern Python dependency management

---

## ✅ Prerequisites

**Required:**
- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)

**Optional (for local development):**
- [Python 3.12+](https://www.python.org/downloads/)
- [Poetry](https://python-poetry.org/docs/#installation)

---

## 🚀 Quick Start (30 seconds!)

### 1. Clone and navigate:

```bash
git clone <repository-url>
cd sportify-api
```

### 2. Start everything:

```bash
make up
```

**That's it!** 🎉 The command will:
- 🔨 Build all Docker containers
- 🚀 Start database + API services  
- 📊 Automatically create tables and sample data
- 📝 Show live logs

### 3. Access your API:

- **🌐 API Root**: [`http://localhost:8000`](http://localhost:8000)
- **📚 Swagger Docs**: [`http://localhost:8000/docs`](http://localhost:8000/docs) ← **Start here!**
- **📖 ReDoc**: [`http://localhost:8000/redoc`](http://localhost:8000/redoc)

### 4. Stop when done:

```bash
make down
```

> 💡 **Tip**: Visit [`http://localhost:8000/docs`](http://localhost:8000/docs) to explore the interactive API documentation!

---

## 🛠 Complete Command Reference

All operations use simple **Makefile commands**:

| Command | Description | When to use |
|---------|-------------|-------------|
| `make up` | 🚀 **Start everything** | First time setup, daily development |
| `make down` | 🛑 **Stop all services** | End of work session |
| `make logs` | 👀 **View live logs** | Debug issues, monitor activity |
| `make connect` | 💾 **Database terminal** | Query data, check tables |
| `make reset` | 🔄 **Fresh start** | Fix corrupted data, clean slate |
| `make test` | 🧪 **Run all tests** | Before commits, CI/CD |
| `make tidy` | 🧹 **Format code** | Code cleanup, before commits |
| `make help` | ❓ **Show all commands** | When you forget something |

### Common Workflows:

**🌅 Daily Development:**
```bash
make up      # Start your day
# ... code, test, develop ...
make down    # End your day
```

**🔧 When things break:**
```bash
make reset   # Nuclear option - clean everything
make up      # Start fresh
```

**🧪 Before committing:**
```bash
make test    # Run tests
make tidy    # Format code
```

---

## 📊 Database & Sample Data

### 🏗️ **Auto-Setup Database**

The database is **automatically created** when you run `make up`:

- ✅ **PostgreSQL 16** running in Docker
- ✅ **All tables created** (federations, people, teams)
- ✅ **Sample data loaded** (realistic Brazilian football structure)
- ✅ **Relationships established** (FIFA → CBF → FPF → São Paulo FC)

### 🌟 **What's Included Out-of-the-Box:**

| 🌍 **Countries** | 🏛️ **Federations** | ⚽ **Clubs** | 👥 **People** |
|------------------|---------------------|--------------|---------------|
| Brazil, Argentina | FIFA, CBF, AFA, FPF | São Paulo, Santos | Athletes, Staff |
| US, Germany | FFERJ (Rio de Janeiro) | Flamengo, Atlético-MG | Referees, Coaches |

### 🔍 **Explore Your Data:**

```bash
# Connect to database
make connect

# Try these queries:
SELECT * FROM countries;
SELECT name, acronym FROM federations;
SELECT name, short_name FROM clubs;
```

### 📈 **Database Structure (Simplified):**

```
🌍 Countries → 🏛️ States → 🏙️ Cities
                ↓
⚽ Sports → 🏛️ Federations → 🏟️ Clubs
                ↓              ↓
👥 People → 🏃‍♂️ Athletes → 📝 Club Assignments
           ↘️ 👨‍💼 Staff → 📝 Staff Assignments  
           ↘️ 👨‍⚖️ Referees
```

> 💡 **Deep Dive**: Check `scripts/sql/creation_database/README.md` for detailed schema documentation.

---

## 🏗️ Project Architecture

Built with **Clean Architecture** + **Domain-Driven Design (DDD)**:

```
src/sportifyapi/
├── 🎯 api/                  # FastAPI routes & controllers
├── 💼 application/          # Business use cases  
├── 🏛️ domain/              # Core business entities & rules
├── 🔧 infrastructure/      # Database, repositories, external services
└── ⚙️ core/               # Configuration, database connections
```

### 🔄 **Request Flow Example:**

```
🌐 HTTP Request → 🎯 API Controller → 💼 Use Case → 🏛️ Domain Entity
                                            ↓
🔧 Infrastructure ← 🗃️ Repository ← 📊 Database
```

### 🎯 **Real Example - Country Management:**

| Layer | File | Purpose |
|-------|------|---------|
| 🎯 **API** | `api/controllers/country/` | HTTP endpoints |
| 💼 **Application** | `application/use_cases/country/` | Business logic |
| 🏛️ **Domain** | `domain/entities/country.py` | Core business rules |
| 🔧 **Infrastructure** | `infrastructure/database/repositories/` | Data persistence |

> 🎓 **Benefits**: Testable, maintainable, and easy to extend!

---

## 🧪 Testing & Development

### 🚀 **Run Tests:**

```bash
make test    # Run all tests (unit + integration)

# Or run specific test types:
poetry run pytest tests/unit/         # Unit tests only
poetry run pytest tests/integration/  # Integration tests only
```

### 🧹 **Code Quality:**

```bash
make tidy    # Auto-format with Black, isort, autoflake
```

### 🔄 **Development Workflow:**

```bash
# 1. Start development environment
make up

# 2. Make your changes...
# (Edit code in src/sportifyapi/)

# 3. Test your changes
make test

# 4. Format code
make tidy

# 5. Check logs if needed
make logs

# 6. Connect to DB for debugging
make connect
```

### 🆘 **Troubleshooting:**

| Problem | Solution |
|---------|----------|
| 🔥 **Something's broken** | `make reset && make up` |
| 🐌 **Slow performance** | `make clean` |
| 📊 **Database issues** | `make connect` to investigate |
| 🚫 **Port conflicts** | Change ports in `docker-compose.yml` |

---

## 🔄 Environment Reset

**When to reset:**
- Database corruption
- Docker issues
- "It was working yesterday..." syndrome

```bash
make reset    # ⚠️ DANGER: Deletes ALL data
make up       # Start fresh
```

**What `reset` does:**
- 🛑 Stops all containers
- 🗑️ Removes PostgreSQL data volume  
- 🧹 Cleans Docker resources
- 🔄 Requires fresh `make up`

---

## 🎯 Current Features & Roadmap

### ✅ **What's Ready Now:**

| Feature | Status | Description |
|---------|--------|-------------|
| 🌍 **Federations** | ✅ Complete | Countries, states, sports, federation hierarchy |
| 👥 **People** | ✅ Complete | Athletes, staff, referees with roles & capabilities |  
| ⚽ **Teams** | ✅ Complete | Clubs, player assignments, staff relationships |
| 📊 **Database** | ✅ Complete | Full schema with sample data & validation |
| 🔧 **API Foundation** | ✅ Complete | FastAPI setup, Clean Architecture |

### 🔮 **Coming Soon:**

| Feature | Priority | Description |
|---------|----------|-------------|
| 🏆 **Competitions** | High | Leagues, tournaments, seasons |
| ⚽ **Matches** | High | Games, events, results, statistics |
| 💸 **Transfers** | Medium | Player transfer history & market |
| 📈 **Analytics** | Medium | Performance metrics & insights |
| 🔐 **Authentication** | Medium | User management & permissions |

### 🚀 **Quick API Test:**

Once running, try these endpoints in [`http://localhost:8000/docs`](http://localhost:8000/docs):

- `GET /countries` - List all countries
- `GET /federations` - List all federations  
- `GET /clubs` - List all clubs
- `GET /athletes` - List all athletes

---

## 🤝 Contributing

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Make changes and test**: `make test`
4. **Format code**: `make tidy`
5. **Commit changes**: `git commit -m 'Add amazing feature'`
6. **Push to branch**: `git push origin feature/amazing-feature`
7. **Open Pull Request**

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 💡 Need Help?

- 📚 **API Docs**: [`http://localhost:8000/docs`](http://localhost:8000/docs)
- 🗃️ **Database Schema**: `scripts/sql/creation_database/README.md`
- ❓ **Commands**: `make help`
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-repo/issues)

**Happy coding!** 🚀⚽
