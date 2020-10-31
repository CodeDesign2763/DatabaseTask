#Основной файл
mainfile=open("csv_base.txt","r")
#Начальное состояние
initialstate=1
for line in mainfile:
	#Если строка не пустая
	if line!="\n":
		#Если это заголовок
		if line.find(",")==-1:
			if initialstate==0:
				#Закрыть файл предыдущего заголовка
				outputfile.close()
			else:
				initialstate=0
			#Создать соответствующий файл
			outputfile=open("./DATA/"+line.rstrip("\n")+".csv","w")
			first_string=1
		else:
			if first_string==1:
				#Строку с именами атрибутов пропустить
				first_string=0
			else:
				#Записать строку в соотв. вых. файл
				outputfile.write(line)
#Закрыть последний выходной файл
outputfile.close()
			
				

	
