# Scripts Directory

## Скрипти для todo_app

### 🚀 Web Preview (рекомендовано)
`web-preview.sh` - найпростіший спосіб запустити веб-прев'ю локально

```bash
# Реліз режим
./scripts/web-preview.sh

# Debug режим
./scripts/web-preview.sh debug
```

**Переваги:**
- Немає Docker/Git проблем
- Швидкий старт
- Автоматично сервірує на http://localhost:8080
- Підтримує debug/release режими

### 🐳 Docker Wrapper
`docker-wrapper.sh` - для роботи з Docker контейнерами

```bash
# Білд + запуск
./scripts/docker-wrapper.sh preview release
./scripts/docker-wrapper.sh preview debug
```

### 🔍 Лінтінг та тести
`simple-lint.sh` - локальна перевірка без Docker

```bash
./scripts/simple-lint.sh
```

### Проблеми з Docker?

Якщо виникають помилки з Git/Flutter в Docker:
1. Використовуй `web-preview.sh` (рекомендовано)
2. Або `simple-lint.sh` для перевірки коду

### Чому Docker не працює?
Flutter SDK в Docker образі має проблеми з:
- Правами доступу до `.flutter-plugins-dependencies`
- Git репозиторіями всередині контейнера
- Налаштуванням шляхів

Тому для веб-розробки простіші рішення без Docker.
