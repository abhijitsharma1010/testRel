import os
import requests
from telegram.ext import Updater, CommandHandler, MessageHandler

# Telegram bot API token
TOKEN = '7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A'

# Telegram group chat ID
CHAT_ID = '1002149806561'

# Virtual machine IP addresses
VM_IPS = ['14.142.183.225', '117.250.113.138']

def check_vm_reachability(vm_ip):
    try:
        response = requests.head(f'http://{vm_ip}', timeout=5)
        if response.status_code == 200:
            return True
        else:
            return False
    except requests.ConnectionError:
        return False

def send_message(bot, update, message):
    bot.send_message(chat_id=CHAT_ID, text=message)

def main():
    updater = Updater(TOKEN, use_context=True)

    dp = updater.dispatcher

    dp.add_handler(CommandHandler('start', lambda update, context: send_message(context.bot, update, 'Bot started!')))

    for vm_ip in VM_IPS:
        if not check_vm_reachability(vm_ip):
            send_message(updater.bot, None, f'VM {vm_ip} is down!')

    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()