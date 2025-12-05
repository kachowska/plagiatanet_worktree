#!/bin/bash

# Скрипт для проверки статуса webhook бота

echo "🔍 Проверка статуса webhook для бота..."

# Загружаем переменные окружения
if [ -f "../bot/server/.env" ]; then
    source ../bot/server/.env
elif [ -f "bot/server/.env" ]; then
    source bot/server/.env
else
    echo "⚠️  Файл .env не найден. Укажите токены вручную."
    read -p "Введите CLIENT_BOT_TOKEN: " CLIENT_BOT_TOKEN
fi

if [ -z "$CLIENT_BOT_TOKEN" ]; then
    echo "❌ CLIENT_BOT_TOKEN не установлен!"
    exit 1
fi

echo ""
echo "📊 Информация о webhook:"
echo "========================"

# Получаем информацию о webhook
WEBHOOK_INFO=$(curl -s "https://api.telegram.org/bot${CLIENT_BOT_TOKEN}/getWebhookInfo")

echo "$WEBHOOK_INFO" | python3 -m json.tool 2>/dev/null || echo "$WEBHOOK_INFO"

echo ""
echo "🔍 Проверка доступности сервера..."

# Получаем URL webhook из информации
WEBHOOK_URL=$(echo "$WEBHOOK_INFO" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)

if [ -z "$WEBHOOK_URL" ]; then
    echo "❌ Webhook URL не установлен!"
    echo ""
    echo "💡 Для установки webhook используйте:"
    echo "   curl -F \"url=https://your-domain.com/webhook/${CLIENT_BOT_TOKEN}\" \\"
    echo "        https://api.telegram.org/bot${CLIENT_BOT_TOKEN}/setWebhook"
    exit 1
fi

echo "✅ Webhook URL: $WEBHOOK_URL"
echo ""

# Проверяем доступность URL
if curl -s -o /dev/null -w "%{http_code}" "$WEBHOOK_URL" | grep -q "200\|404"; then
    echo "✅ Сервер доступен"
else
    echo "⚠️  Сервер может быть недоступен"
fi

echo ""
echo "📝 Последние обновления:"
PENDING_COUNT=$(echo "$WEBHOOK_INFO" | grep -o '"pending_update_count":[0-9]*' | cut -d':' -f2)
if [ -z "$PENDING_COUNT" ]; then
    PENDING_COUNT=0
fi

if [ "$PENDING_COUNT" -gt 0 ]; then
    echo "⚠️  Есть $PENDING_COUNT необработанных обновлений"
else
    echo "✅ Нет необработанных обновлений"
fi

