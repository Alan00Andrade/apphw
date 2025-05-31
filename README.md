# Teste Técnico - DevOps | H&W Publishing

Este projeto demonstra a criação de uma aplicação Flask balanceada com NGINX e deploy automatizado via GitHub Actions.

## ️ Tecnologias

- Python 3 + Flask
- NGINX
- GitHub Actions
- Google Cloud VM (Ubuntu Server)
- SSH + pip

##  Como testar

1. Acesse: [http://SEU_IP](http://SEU_IP)
2. Dê vários F5
3. Você verá as mensagens alternando entre as duas instâncias (`Primária` e `Secundária`)

##  Deploy CI/CD

Ao fazer `git push` na branch `main`, o GitHub Actions:
- Acessa a VM via SSH
- Atualiza os arquivos
- Instala dependências
- Reinicia os apps

##  Estrutura

apphw/
├── app.py
├── app2.py
├── requirements.txt
├── .github/workflows/deploy.yml
├── scripts/start.sh
└── README.md


## 🧪 Testado com sucesso em:

- Ubuntu 20.04 LTS no Google Cloud
- GitHub Actions com chave SSH

---
