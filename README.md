
[![CI/CD DevOps Teste H&W](https://github.com/Alan00Andrade/apphw/actions/workflows/deploy.yml/badge.svg)](https://github.com/Alan00Andrade/apphw/actions/workflows/deploy.yml)

# Teste Técnico - Infraestrutura e DevOps H&W Publishing

Este repositório contém a aplicação e automações para o teste técnico da H&W Publishing, abordando:

- Criação e configuração de ambiente Linux (Google Cloud VM)
- Execução de aplicações Flask em múltiplas portas
- Balanceamento de carga com NGINX (round-robin)
- Deploy automático via GitHub Actions com SSH

---

## 🧑‍💻 Etapa 1 - Criação do Ambiente

- Criada uma VM na **Google Cloud Platform (GCE)** com **Ubuntu 22.04 LTS**
- Configurado acesso via SSH com **chave ED25519**
- Concedido acesso `sudo` ao usuário padrão da VM
- Criado diretório `/home/alan/apphw/` para a aplicação

---

## 🚀 Etapa 2 - Execução da Aplicação Flask

A aplicação é composta por dois arquivos: `app.py` e `app2.py`, ambos executando serviços web simples com Flask nas portas 5000 e 5001.

Instalação das dependências:

```bash
pip3 install -r requirements.txt
```

Criação dos serviços com `systemd`:

**`/etc/systemd/system/app1.service`**
```ini
[Unit]
Description=App Flask na porta 5000
After=network.target

[Service]
User=alan
WorkingDirectory=/home/alan/apphw
ExecStart=/usr/bin/python3 /home/alan/apphw/app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

**`/etc/systemd/system/app2.service`**
Mesma estrutura, apenas altera o script para `app2.py`.

Habilitação e inicialização dos serviços:

```bash
sudo systemctl daemon-reload
sudo systemctl enable app1 app2
sudo systemctl start app1 app2
```

---

## ⚙️ Etapa 3 - Load Balancer com NGINX

Configuração de balanceamento na porta 80, com proxy para as aplicações nas portas 5000 e 5001 (round-robin):

**Arquivo `/etc/nginx/sites-available/default`:**

```nginx
server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}

upstream backend {
    server 127.0.0.1:5000;
    server 127.0.0.1:5001;
}
```

Reinício do serviço:

```bash
sudo nginx -t && sudo systemctl restart nginx
```

---

## 🔁 Etapa 4 - CI/CD com GitHub Actions

Ao realizar um push para o repositório, o workflow `deploy.yml` é executado utilizando `appleboy/ssh-action`, que:

- Acessa a VM via SSH
- Atualiza o repositório com `git pull`
- Instala dependências com `pip3`
- Reinicia os serviços com `systemd`
- Realiza teste de verificação nos endpoints

**Workflow: `.github/workflows/deploy.yml`**

```yaml
    - name: Deploy remoto via SSH
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.REMOTE_HOST }}
        username: ${{ secrets.REMOTE_USER }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          cd ~/apphw || exit 1
          git pull origin main || exit 1
          pip3 install -r requirements.txt || exit 1
          sudo systemctl restart app1 && sudo systemctl restart app2
          sleep 15
          sudo systemctl is-active --quiet app1 || exit 1
          sudo systemctl is-active --quiet app2 || exit 1
          curl --retry 5 --retry-delay 2 --fail http://localhost:5000 || exit 1
          curl --retry 5 --retry-delay 2 --fail http://localhost:5001 || exit 1
```

---

## 🧪 Testes Realizados

- Reboot testado: serviços persistem
- CI/CD com push validado com sucesso
- NGINX balanceando corretamente entre apps
- Verificação automática nos endpoints com `curl`

---

## 📁 Estrutura do Projeto

```
apphw/
├── app.py
├── app2.py
├── requirements.txt
├── .github/
│   └── workflows/
│       └── deploy.yml
```

---

## 👨‍💻 Autor

Alan Henrique Andrade  
📧 Email: alanh.andrade@gmail.com  
📱 Telefone: (31) 9 7207-8434  
🔗 [LinkedIn](https://www.linkedin.com/in/alan-andrade-81482a97/)
