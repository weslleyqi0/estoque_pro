#!/bin/bash
# Script de Build Phase — copia o GoogleService-Info.plist correto por flavor/configuration
#
# Adicione este script como Build Phase no Xcode:
#   Runner TARGET → Build Phases → + → New Run Script Phase
#   Mova para ANTES do "Copy Bundle Resources"
#   Cole o conteúdo deste arquivo no campo de script

# Detecta o ambiente pelo nome da configuração de build
if [[ "${CONFIGURATION}" == *"development"* ]]; then
    FLAVOR="development"
elif [[ "${CONFIGURATION}" == *"production"* ]]; then
    FLAVOR="production"
else
    # Fallback para Debug/Release padrão — usa production
    FLAVOR="production"
fi

PLIST_SOURCE="${SRCROOT}/config/${FLAVOR}/GoogleService-Info.plist"
PLIST_DEST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

echo "Copiando GoogleService-Info.plist para flavor: ${FLAVOR}"
echo "  Origem:  ${PLIST_SOURCE}"
echo "  Destino: ${PLIST_DEST}"

if [ -f "${PLIST_SOURCE}" ]; then
    cp -v "${PLIST_SOURCE}" "${PLIST_DEST}"
else
    echo "ERRO: GoogleService-Info.plist não encontrado em ${PLIST_SOURCE}"
    exit 1
fi
