#!/bin/bash
set -e

# ==== CONFIG ====
SERVER_USER="ec2-user"
SERVER_HOST="ec2-54-187-133-136.us-west-2.compute.amazonaws.com"
PEM_PATH="rny-web-institucional.pem"
REMOTE_DIR="/home/ec2-user"
PACKAGE_NAME="frontend_package.tar.gz"

# ==== BUILD ====
echo "📦 Gerando build de produção..."
npm run build

# ==== COMPACTAÇÃO ====
echo "🎁 Compactando arquivos..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "➡ macOS detectado: removendo arquivos extras"
  tar --exclude='._*' --exclude='.DS_Store' -czf $PACKAGE_NAME dist
else
  tar -czf $PACKAGE_NAME dist
fi

# ==== ENVIO ====
echo "📤 Enviando pacote para o servidor..."
scp -i "$PEM_PATH" $PACKAGE_NAME $SERVER_USER@$SERVER_HOST:$REMOTE_DIR/

# ==== DEPLOY REMOTO ====
echo "🛠 Executando deploy no servidor..."
ssh -i "$PEM_PATH" $SERVER_USER@$SERVER_HOST "bash /home/ec2-user/deploy_frontend_install.sh"

# ==== LIMPEZA ====
rm $PACKAGE_NAME

echo "🎉 Deploy concluído com sucesso!"