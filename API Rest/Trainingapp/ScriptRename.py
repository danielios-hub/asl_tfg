import os

x = 0
for i in range(1,7):
    for letter in os.listdir(str(i)):
        for file in os.listdir(str(i) + "/" + letter):
            oldname = str(i) + "/" + letter + "/" + file
            filename, file_extension = os.path.splitext(oldname)
            newname = str(i) + "/" + letter + "/" + letter + "_" + str(i) + "_rename_" + str(x) + file_extension
            x += 1
            os.rename(oldname, newname)
            print(oldname)
            print(newname)