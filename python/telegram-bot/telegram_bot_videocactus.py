#!/bin/python3
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
# pip3 install python-telegram-bot

import json
from os import path
import random

tokens = "TOKEN"
botik = Updater(tokens, use_context=True)
dispatcher = botik.dispatcher
chat_stat = {
        "hate":"on"
}
list_dirt_phrase = [
    "Тебе по голові часто били?! Нєхуй свої відео сюди слати!",
    "Оааайййй бляяя, пробнік ти оператора невдалий...",
    "Ееееее.......фууу!"
    "Зайнятися нічим чи просто мозгів бог не дав?",
    "Слиш, ти, вакуумна насадка, досить це робити",
    "Ну чого як знімати відеоповідомлення ти знаєш, а те що вони нахуй нікому не нужні ти не знаєш",
    "Та я вірю що в тебе сорок сім хромосом, вірю, не треба доказів",
    "Вже всі поняли що ти не вмієш друкувати, хватить про це нагадувати",
    "Чергова байда, можна не дивитися",
    "Я готовий повірити в бога якщо він вилікує тебе",
    "Адмін, ну видали з групи ОЦЕ",
    "Пряма трансляція з місцевої помийки!",
    "Коли, нарешті стемніє, ти напевно будеш виглядати краще!",
    "Ахтунг! Відеодрочери онлайн",
    "Тобі пора покинути цей чат",
    "Нуууу йоообааане обличчя цього повідомлення",
    "Піздуй звідси зі своїми відосaми куди подалі",
    "Хто навчив цю макаку знімати відео?",
    "Отже ти, син руснявого зйобка і нещасного випадку вирішив що присилати сюди свої відеоматеріали то дуже гарна ідея. Що ж, розумію немає чим, але все ж, подумай ще раз!"
    "Що це? Я думав, що зоопарк закривається на ніч!",
    "Ах ти гуманоїд красножопий, знов за старе -_-",
    "Кадри з громадського туалету?",
    "Ще трохи і підеш вслід за рускім кораблем",
    "Блять, відоси??? А ти часом не москаль?!",
    "Викликайте відьмака, скільки ми будемо терпіти терор цієї потвори ще?"
]
start_text = "Привіт. Я бот який ненавидить усіх хто посилає відео-повідомлення у телеграмі, тому я буду принижувати таких персонажів по максимуму! 😎\n\nАле, раптом, якщо дуже буде потрібно, навіть не знаю при яких умовах, хейт можна ввимкнути командою /videohate_off...Навіть не знаю навіщо тобі це.\n\nВвімкнути назад можна командою /videohate_on\n\nДля активування задійте будь-яку з двох вищеперечислених команд."

def main():
    dispatcher.add_handler(MessageHandler(Filters.video_note, video_hate))
    dispatcher.add_handler(CommandHandler("videohate_off", hate_off))
    dispatcher.add_handler(CommandHandler("videohate_on", hate_on))
    dispatcher.add_handler(CommandHandler("start", start_work))
    dispatcher.add_handler(CommandHandler("ping", winter_2023_comming))
    botik.start_polling(timeout = 30)

def start_work(update, context):
    context.bot.send_message(update.effective_message.chat_id, text=start_text)

def winter_2023_comming(update, context):
    context.bot.send_message(update.effective_message.chat_id, text="Ping")

def rand_mess():
    return list_dirt_phrase[random.randint(0,len(list_dirt_phrase)-1)]

def new_member(update, context):
    with open(chatfile,'r+') as fi:
        data = json.load(fi)
        fi.close()
    update.message.reply_text('OK')
    chats = str(update.effective_message.chat_id)
    data["chats_id"][chats] = chat_stat
    file = open(chatfile,'w')
    json.dump(data, file, indent = 4)
    file.close()

def video_hate(update, context):
    chats = str(update.effective_message.chat_id)
    with open(chatfile,'r+') as fi:
        data = json.load(fi)
        fi.close()
    try:
        if data["chats_id"][chats]["hate"] == "on":
            context.bot.send_message(update.effective_message.chat_id, reply_to_message_id = update.message.message_id, text=rand_mess())
    except KeyError:
        new_member(update, context)
        video_hate(update, context)

def hate_off(update, context):
    chats = str(update.effective_message.chat_id)
    with open(chatfile,'r+') as fi:
        data = json.load(fi)
        fi.close()
    try:
        data["chats_id"][chats]["hate"] = "off"
        file = open(chatfile,'w+')
        json.dump(data, file, indent = 4)
        file.close()
    except KeyError:
        new_member(update, context)

def hate_on(update, context):
    chats = str(update.effective_message.chat_id)
    with open(chatfile,'r+') as fi:
        data = json.load(fi)
        fi.close()
    try:
        data["chats_id"][chats]["hate"] = "on"
        file = open(chatfile,'w+')
        json.dump(data, file, indent = 4)
        file.close()
    except KeyError:
        new_member(update, context)

#update.message.reply_to_message(text = "dsfgfdgffd")

if __name__ == '__main__':
    chatfile = path.dirname(__file__)
    chatfile = path.join(chatfile, "chatfile.json")
    if path.exists(chatfile) != True:
        with open(chatfile, 'w') as f:
            f.write('{\"chats_id\": {} }')
        f.close()
    main()
