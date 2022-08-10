from traceback import print_tb
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import os
cmd = 'scp .htaccess testdomain123.com@216.70.123.90:/home/230048/domains/testdomain123.com/html/.htaccess >/dev/null 2>&1'



file1 = open('1.txt', 'r')
Lines = file1.readlines()

count = 0
# Strips the newline character
for line in Lines:
    count+=1
    string1 = "<IfModule "
    string2 = line.strip()
    string3 = ">\n  DirectoryIndex first.php \n</IfModule>"
    string4 = string1 + string2 + string3
    print(string2, end = " ")
    file2 = open('.htaccess', 'w')
    file2.write(string4)
    file2.close()
    os.system(cmd)
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    d = webdriver.Chrome(options=chrome_options)
    d.get('http://testdomain123.com/')
    print(d.title)
    d.close()
