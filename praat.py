import sys
import glob
import os

import tkinter as tk
from tkinter import simpledialog

ROOT = tk.Tk()

ROOT.withdraw()
# the input dialog
USER_INP = simpledialog.askstring(title="Praat",
                                  prompt="What's the base directory?")

print("Hello", USER_INP)

os.chdir(USER_INP)
myFiles = glob.glob('*.flac')
print(myFiles)
numberOfFiles = len(myFiles)
print(numberOfFiles)

sys.path.append(r'C:\Users\georg\IdeaProjects\dddddddddddd\venv\Lib\site-packages')
#print(sys.path)
from mutagen.flac import  FLAC

def Timp(time):
    if time[0] is '0':
        return time[1]
    else:
        return time

for i in range(numberOfFiles):
    #flac_path = r"C:\Users\georg\Desktop\audioFiles\SWPOR_200206_144224\{}".format(myFiles[i])
    flac_path = USER_INP + r"\{}".format(myFiles[i])
    flac = FLAC(flac_path)
    print(flac)

    textName = myFiles[i].replace(".flac",".txt")
    file1 = open(USER_INP +  r"\{}".format(textName), "a")
    file1.truncate(0)
   
    time = str(flac.get('simustart'))
 #   print(time)

    if time == 'None':
        hour = '00'
        minute = '00'
        second = '00'
    else:
        hour = time[13:15]
        minute = time[16:18]
        second = time[19:21]

    frequency = str(flac.get('comment'))
   # print(frequency)
    if frequency == 'None':
        gik = '000.000'
    else:
        freq = frequency.index('Channel: ')
        #print(freq)
        length = len('Channel: ')
        index = freq + length
        #print(index)
        asd = index + 7
        gik = str(frequency[index:asd])
        #print(gik)
        file1.truncate(0)


        #print(Timp(hour) + '\n' + Timp(minute) + '\n' +  Timp(second) + '\n' + frequency)
    file1.write(Timp(hour) + '\n' + Timp(minute) + '\n' +  Timp(second) + '\n' + gik)


#PRAAT SCRIPT
#directory$ = "C:\Users\georg\Desktop\try\.idea"
#runSystem: "py ", directory$, "\praat.py"
