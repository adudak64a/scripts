string1 = ""
string2 = ""
string3 = ""
string4 = ""
coun = 1
i = 0
with open('2.txt', 'rb') as f:
    stri = str(f.read())
    for char in stri:
        df = ord(char)
        if (ord(char) == 32 or ord(char) == 10 or ord(char) == 13):
            if i == 1:
                if coun == 1:
                    string1+="\n"
                elif coun == 2:
                    string2+="\n"
                elif coun == 3:
                    string3+="\n"
                elif coun == 4:
                    string4+="\n"
                coun+=1
                i = 0
                if coun > 4:
                    coun = 1
            continue
        if (ord(char) != 32 and ord(char) != 10 and ord(char) != 13):
            i=1
            if coun == 1:
                string1+=char
            elif coun == 2:
                string2+=char
            elif coun == 3:
                string3+=char
            elif coun == 4:
                string4+=char
print(string1+string2+string3+string4)
