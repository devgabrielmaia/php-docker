# PHP + Docker

Imagem Docker multi-stage para PHP 8.3 FPM (Alpine) com Nginx, Composer, OPcache de produção e exemplo funcional.

## Stack

- **PHP 8.3 FPM** (Alpine 3.20)
- **Nginx** 1.27 (reverse proxy + arquivos estáticos)
- **Composer 2**
- Extensões: `pdo_pgsql`, `pgsql`, `mbstring`, `intl`, `zip`, `gd`, `opcache`

## Para testar a imagem:

```bash
cd example
docker compose up -d --build
```

Acesse: **http://localhost:8000/**

Para parar:

```bash
docker compose down
```

## Dockerfile — stages

| Stage | Uso |
|-------|-----|
| `base` | PHP-FPM, extensões e configs base |
| `runner` | CI/CD com dependências de desenvolvimento |
| `builder` | **Produção** — sem dev, autoload otimizado, OPcache ativo |

Para build de produção:

```bash
docker build --target builder -t php-docker .
```

O `docker-compose.yml` do exemplo usa o stage `builder`.

## Configuração

### PHP-FPM

Pool configurado em `config/zz-custom.conf` (process manager dinâmico, até 8 workers).

### OPcache (produção)

Ativo apenas no stage `builder` via `config/opcache.ini`:

- JIT habilitado (`tracing`, buffer de 64M)
- `validate_timestamps=0` — máxima performance; código imutável na imagem

Para verificar se está ativo:

```bash
docker compose exec app php -i | grep opcache.enable
```

Para limpar o cache após alterar arquivos PHP no volume local:

```bash
docker compose restart app
```

### Nginx

- Porta **8000** (host) → **80** (container)
- Document root: `/var/www/public`
- PHP repassado ao container `app` via FastCGI na porta 9000
- Health check: `GET /nginx-health`

