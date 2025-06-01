![CI/CD Status](https://github.com/SEU_USUARIO/apphw/actions/workflows/deploy.yml/badge.svg)


# Teste Técnico - Infraestrutura e DevOps H&W Publishing

Este repositório contém a aplicação e automações para o teste técnico da H&W Publishing, abordando:

- Criação e configuração de ambiente Linux
- Deploy automatizado via GitHub Actions
- Execução de aplicações Flask em múltiplas portas
- Balanceamento de carga com NGINX

---

## ️ Atenção

> Substitua todos os trechos com `SEU_USUARIO` pelo nome do usuário configurado na sua VM Linux.

---

## ️ Etapa 1 - Criação do Ambiente

1. Criada uma VM no **Google Cloud (GCE)** com Ubuntu 22.04 LTS
2. Configurado acesso via SSH com **chave ED25519**
3. Criado diretório `/home/SEU_USUARIO/apphw/` para a aplicação
4. Adicionadas as permissões `sudo` ao usuário da VM

---

## ️ Etapa 2 - Execução da Aplicação

1. Aplicações `app.py` (porta 5000) e `app2.py` (porta 5001) são scripts Flask simples.
2. Criado `requirements.txt` com:

```txt
flask
```

3. Criados arquivos de service do systemd:

- `/etc/systemd/system/app1.service`
- `/etc/systemd/system/app2.service`

```ini
[Unit]
Description=App Flask na porta 5000
After=network.target

[Service]
User=SEU_USUARIO
WorkingDirectory=/home/SEU_USUARIO/apphw
ExecStart=/usr/bin/python3 /home/SEU_USUARIO/apphw/app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

*(app2 igual, só muda a porta e o script)*

4. Habilitados com:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable app1
sudo systemctl enable app2
sudo systemctl start app1
sudo systemctl start app2
```

---

##  Etapa 2.5 - Deploy automático com GitHub Actions

Workflow `.github/workflows/deploy.yml` com `appleboy/ssh-action@v1.0.0` que:

- Se conecta via chave SSH
- Atualiza repositório
- Instala dependências
- Reinicia apps

```yaml
    - name: Deploy remoto via SSH
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.REMOTE_HOST }}
        username: ${{ secrets.REMOTE_USER }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          pkill -f app.py || true
          pkill -f app2.py || true
          cd ~/apphw
          pip3 install -r requirements.txt
          nohup python3 app.py > app5000.log 2>&1 &
          nohup python3 app2.py > app5001.log 2>&1 &
```

---

##  Etapa 3 - Load Balancer com NGINX

Configuração de balanceamento no NGINX para redirecionar tráfego da porta 80 para as portas 5000 e 5001 alternadamente:

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

Reinício com:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

---

##  Testes realizados

- Acesso via IP externo da VM (porta 80) alternando entre `app.py` e `app2.py`
- Reboot testado com serviços persistentes
- Deploy com push via GitHub 100% funcional

---

##  Estrutura do Projeto

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

##  Observações

- O balanceamento é do tipo round-robin.
- O GitHub Actions usa chave SSH para deploy automático.
- Serviços são mantidos com `systemd`, garantindo persistência após reboot.

---

##  Autor

Alan Henrique Andrade  
[LinkedIn](https://www.linkedin.com/in/alan-andrade-81482a97/)  
Email: alanh.andrade@gmail.com
Fone: (31) 9 7207-8434
