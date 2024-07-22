import os
import time
import telegram

# Telegram bot API token
TOKEN = '7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A'

# Telegram group chat ID
CHAT_ID = '1002149806561'

# VM IP addresses
VM_IPS = ['14.142.183.225', '117.250.113.138']

def check_reachability(ip):
    response = os.system("ping -c 1 " + ip)
    if response == 0:
        return True
    else:
        return False

def send_message(bot, message):
    bot.send_message(chat_id=CHAT_ID, text=message)

def main():
    bot = telegram.Bot(token=TOKEN)

    while True:
        for ip in VM_IPS:
            if not check_reachability(ip):
                message = f"VM {ip} is down!"
                send_message(bot, message)
        time.sleep(60)  # Check every 1 minute

if __name__ == '__main__':
    main()
