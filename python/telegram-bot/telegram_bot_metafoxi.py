#!/bin/python3
from datetime import datetime
from telegram.ext import Updater, MessageHandler, Filters, CommandHandler
import subprocess

# pip3 install python-telegram-bot
# apt install exif
# apt install imagemagick

tokens = "TOKEN"
botik = Updater(tokens, use_context=True)
dispatcher = botik.dispatcher

def set_exif(update, context):
    context.user_data['metod'] = "exif"

def set_immag(update, context):
    context.user_data['metod'] = "immag"

def set_mat(update, context):
    context.user_data['metod'] = "mat"

def post_data(update, context):
    file_nick = str(datetime.timestamp(datetime.now()))
    file = context.bot.getFile(update.message.document.file_id)
    file.download(file_nick)
    try:
        if context.user_data['metod'] == "exif":
            bashcommand = "exif "+file_nick
        if context.user_data['metod'] == "mat":
            bashcommand = "mat2 -s "+file_nick
        if context.user_data['metod'] == "immag":
            bashcommand = "identify -verbose  "+file_nick
    except KeyError:
        bashcommand = "identify -verbose  "+file_nick
    output = subprocess.run(bashcommand, shell=True, stdout=subprocess.PIPE, universal_newlines=True)
    file_data = output.stdout
    context.bot.send_message(update.effective_message.chat_id, text=file_data)
    subprocess.run('rm -rf '+file_nick, shell=True)

def main():
    dispatcher.add_handler(MessageHandler(Filters.document, post_data))
    dispatcher.add_handler(CommandHandler("set_met_exif", set_exif))
    dispatcher.add_handler(CommandHandler("set_met_immag", set_immag))
    dispatcher.add_handler(CommandHandler("set_met_mat2", set_mat))
    botik.start_polling()

if __name__ == '__main__':
    main()
