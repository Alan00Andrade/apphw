#!/bin/bash
pkill -f app.py
pkill -f app2.py
nohup python3 app.py > app5000.log 2>&1 &
nohup python3 app2.py > app5001.log 2>&1 &
echo "Apps reiniciados com sucesso."
