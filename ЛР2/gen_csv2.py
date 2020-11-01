import random
#Функция для генерации имен
def gen_name():
	sogl=("б","г","д","ж","з","к","л","м","н","п","р","с","т","ф","х","ц","ч","ш")
	gl=("а","e","и","о","у")
	name_length=random.randint(2,6);
	name_ending=random.randint(0,1)
	s=""
	for i in range(name_length):
		s=s+sogl[random.randint(0,len(sogl)-1)]
		s=s+gl[random.randint(0,len(gl)-1)]
	if name_ending==1:
		s=s+sogl[random.randint(0,len(sogl)-1)]
	return s.capitalize()
#Функция для генерации дат
def gen_dob(m1,y1,m2,y2):
	day=random.randint(1,28)
	month=random.randint(m1,m2)
	year=random.randint(y1,y2)
	return str(day)+"."+str(month)+"."+str(year)
	
#Инициализациия ГСЧ
random.seed()

#Открытие файлов
Enrollee=open("./DATA/Enrollee.csv","w")
PassedEGE=open("./DATA/PassedEGE.csv","w")
PassedVIPS=open("./DATA/PassedVIPS.csv","w")
Enrollee2Citizenship=open("./DATA/Enrollee2Citizenship.csv","w")
ReceivedCertificate=open("./DATA/ReceivedCertificate.csv","w")
Application=open("./DATA/Application.csv","w")
#Установка начальных значений счетчиков
ID_Enrollee=0
ID_Application=0
ID_EGE=0
ID_VIPS=0
#Группа 1
for i in range(40):
	#Атрибуты Enrollee
	ID_Enrollee=ID_Enrollee+1
	Name=gen_name()+" "+gen_name()
	DOB=gen_dob(1,1980,12,2003)
	EducationDocument="At11"
	AchievmentPoints=str(random.randint(0,5))
	RightToSpecialQuota="0"
	AgreementOnTargetTraining="0"
	if random.random()<0.1:
		RightToPriorityAdmission="1"
	else:
		RightToPriorityAdmission="0"
	Disabled="0"
	Compatriot="0"
	Enrollee.write(str(ID_Enrollee)+","+Name+","+DOB+","+EducationDocument+ \
		","+AchievmentPoints+","+RightToSpecialQuota+","+AgreementOnTargetTraining+","+ \
		RightToPriorityAdmission+","+Disabled+","+Compatriot+"\n")
	#Гражданство
	#РФ
	Enrollee2Citizenship.write(str(ID_Enrollee)+","+"1"+"\n")
	#Заявление1
	ID_Application=ID_Application+1
	ID_Faculty="5"
	ID_PaymentMethod="2"
	ID_Quota="NULL"
	ID_EducationalProgram="3"
	if random.random()<0.9:
		EnrolmentConsent=1
	else:
		EnrolmentConsent=0
	Application.write(str(ID_Application)+","+ID_Faculty+","+ID_PaymentMethod+ \
		","+ID_Quota+","+ID_EducationalProgram+","+str(ID_Enrollee)+ \
		","+str(EnrolmentConsent)+"\n")
	#ЕГЭ
	#Математика
	ID_EGE=ID_EGE+1
	ID_Subject="1"
	Score=str(random.randint(30,100))
	DateOfExam="1.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Физика
	ID_EGE=ID_EGE+1
	ID_Subject="2"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Русский
	ID_EGE=ID_EGE+1
	ID_Subject="5"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")

#Группа 2
for i in range(20):
	#Атрибуты Enrollee
	ID_Enrollee=ID_Enrollee+1
	Name=gen_name()+" "+gen_name()
	DOB=gen_dob(1,1980,12,2003)
	if random.random()<0.5:
		EducationDocument="SPO"
	else:
		EducationDocument="VO"
		
	AchievmentPoints=str(random.randint(0,5))
	RightToSpecialQuota="0"
	AgreementOnTargetTraining="0"
	if random.random()<0.1:
		RightToPriorityAdmission="1"
	else:
		RightToPriorityAdmission="0"
	Disabled="0"
	Compatriot="0"
	Enrollee.write(str(ID_Enrollee)+","+Name+","+DOB+","+EducationDocument+ \
		","+AchievmentPoints+","+RightToSpecialQuota+","+ \
		AgreementOnTargetTraining+","+RightToPriorityAdmission+","+Disabled+","+Compatriot+"\n")
	#Гражданство
	#РФ
	Enrollee2Citizenship.write(str(ID_Enrollee)+","+"1"+"\n")
	#Заявление1
	ID_Application=ID_Application+1
	ID_Faculty="5"
	ID_PaymentMethod="2"
	ID_Quota="NULL"
	ID_EducationalProgram="3"
	if random.random()<0.9:
		EnrolmentConsent=1
	else:
		EnrolmentConsent=0
	Application.write(str(ID_Application)+","+ID_Faculty+","+ID_PaymentMethod+ \
		","+ID_Quota+","+ID_EducationalProgram+ \
		","+str(ID_Enrollee)+","+str(EnrolmentConsent)+"\n")
	ID_VIPS=ID_VIPS+1
	ID_Subject="2"
	Score=str(random.randint(0,300))
	PassedVIPS.write(str(ID_VIPS)+","+str(ID_Enrollee)+","+ID_Subject+","+Score+"\n")

#Группа 3
for i in range(10):
	#Атрибуты Enrollee
	ID_Enrollee=ID_Enrollee+1
	Name=gen_name()+" "+gen_name()
	DOB=gen_dob(1,1980,12,2003)
	#if random.random()<0.5:
		#EducationDocument="SPO"
	#else:
		#EducationDocument="VO"
	EducationDocument="VO"
		
	AchievmentPoints="0"
	RightToSpecialQuota="0"
	AgreementOnTargetTraining="0"
	#if random.random()<0.1:
		#RightToPriorityAdmission="1"
	#else:
		#RightToPriorityAdmission="0"
	RightToPriorityAdmission="0"
	Disabled="0"
	Compatriot="0"
	Enrollee.write(str(ID_Enrollee)+","+Name+","+DOB+","+EducationDocument+ \
		","+AchievmentPoints+","+RightToSpecialQuota+ \
		","+AgreementOnTargetTraining+","+RightToPriorityAdmission+","+Disabled+","+Compatriot+"\n")
	#Гражданство
	#РФ
	Enrollee2Citizenship.write(str(ID_Enrollee)+","+str(random.randint(2,10))+"\n")
	#Заявление1
	ID_Application=ID_Application+1
	ID_Faculty="5"
	ID_PaymentMethod="2"
	ID_Quota="NULL"
	ID_EducationalProgram="3"
	if random.random()<0.9:
		EnrolmentConsent=1
	else:
		EnrolmentConsent=0
	Application.write(str(ID_Application)+","+ID_Faculty+","+ID_PaymentMethod+ \
		","+ID_Quota+","+ID_EducationalProgram+ \
		","+str(ID_Enrollee)+","+str(EnrolmentConsent)+"\n")
	#ВИПС
	ID_VIPS=ID_VIPS+1
	ID_Subject="2"
	Score=str(random.randint(0,300))
	PassedVIPS.write(str(ID_VIPS)+","+str(ID_Enrollee)+","+ID_Subject+","+Score+"\n")
	
#Группа 4
for i in range(5):
	#Атрибуты Enrollee
	ID_Enrollee=ID_Enrollee+1
	Name=gen_name()+" "+gen_name()
	DOB=gen_dob(1,1980,12,2003)
	#if random.random()<0.5:
		#EducationDocument="SPO"
	#else:
		#EducationDocument="VO"
	EducationDocument="VO"
		
	AchievmentPoints="0"
	RightToSpecialQuota="0"
	AgreementOnTargetTraining="0"
	#if random.random()<0.1:
		#RightToPriorityAdmission="1"
	#else:
		#RightToPriorityAdmission="0"
	RightToPriorityAdmission="0"
	Disabled="0"
	Compatriot="0"
	Enrollee.write(str(ID_Enrollee)+","+Name+","+DOB+","+EducationDocument+","+ \
		AchievmentPoints+","+RightToSpecialQuota+ \
		","+AgreementOnTargetTraining+","+RightToPriorityAdmission+","+Disabled+ \
		","+Compatriot+"\n")
	#Гражданство
	#Не РФ
	Enrollee2Citizenship.write(str(ID_Enrollee)+","+str(random.randint(2,10))+"\n")
	#Заявление1
	ID_Application=ID_Application+1
	ID_Faculty="5"
	ID_PaymentMethod="2"
	ID_Quota="NULL"
	ID_EducationalProgram="3"
	if random.random()<0.9:
		EnrolmentConsent=1
	else:
		EnrolmentConsent=0
	Application.write(str(ID_Application)+","+ID_Faculty+","+ID_PaymentMethod+ \
		","+ID_Quota+","+ \
		ID_EducationalProgram+","+str(ID_Enrollee)+","+str(EnrolmentConsent)+"\n")
	#Заявление2
	ID_Application=ID_Application+1
	ID_Faculty="2"
	ID_PaymentMethod="2"
	ID_Quota="NULL"
	ID_EducationalProgram="4"
	#if random.random()<0.9:
		#EnrolmentConsent=1
	#else:
		#EnrolmentConsent=0
	EnrolmentConsent="0"
	Application.write(str(ID_Application)+","+ID_Faculty+","+ID_PaymentMethod+","+ID_Quota+","+ \
		ID_EducationalProgram+","+str(ID_Enrollee)+","+str(EnrolmentConsent)+"\n")
	
	#ВИПС
	#Физика
	ID_VIPS=ID_VIPS+1
	ID_Subject="2"
	Score=str(random.randint(0,300))
	PassedVIPS.write(str(ID_VIPS)+","+str(ID_Enrollee)+","+ID_Subject+","+Score+"\n")
	#Химия
	ID_VIPS=ID_VIPS+1
	ID_Subject="3"
	Score=str(random.randint(0,300))
	PassedVIPS.write(str(ID_VIPS)+","+str(ID_Enrollee)+","+ID_Subject+","+Score+"\n")
	
#Группа 5
for i in range(60):
	#Атрибуты Enrollee
	ID_Enrollee=ID_Enrollee+1
	Name=gen_name()+" "+gen_name()
	DOB=gen_dob(1,2002,12,2003)
	#if random.random()<0.5:
		#EducationDocument="SPO"
	#else:
		#EducationDocument="VO"
	EducationDocument="At11"
		
	AchievmentPoints=str(random.randint(0,5))
	if random.random()<=0.1:
		RightToSpecialQuota="1"
	else: 
		RightToSpecialQuota="0"
	AgreementOnTargetTraining="0"
	if random.random()<0.1:
		RightToPriorityAdmission="1"
	else:
		RightToPriorityAdmission="0"
	Disabled="0"
	Compatriot="0"
	Enrollee.write(str(ID_Enrollee)+","+Name+","+DOB+","+EducationDocument+ \
		","+AchievmentPoints+","+ \
		RightToSpecialQuota+","+AgreementOnTargetTraining+","+RightToPriorityAdmission+","+Disabled+","+Compatriot+"\n")
	#Гражданство
	#РФ
	Enrollee2Citizenship.write(str(ID_Enrollee)+","+"1"+"\n")
	#Заявление1
	ID_Application=ID_Application+1
	ID_Faculty="1"
	ID_PaymentMethod="1"
	if RightToSpecialQuota==1:
		ID_Quota="3"
	else:
		ID_Quota="NULL"
	ID_EducationalProgram="2"
	if random.random()<0.9:
		EnrolmentConsent=1
	else:
		EnrolmentConsent=0
	Application.write(str(ID_Application)+","+ID_Faculty+","+ID_PaymentMethod+ \
		","+ID_Quota+","+ \
		ID_EducationalProgram+","+str(ID_Enrollee)+","+str(EnrolmentConsent)+"\n")
	#ЕГЭ
	#Математика
	ID_EGE=ID_EGE+1
	ID_Subject="1"
	Score=str(random.randint(30,100))
	DateOfExam="1.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Физика
	ID_EGE=ID_EGE+1
	ID_Subject="2"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Русский
	ID_EGE=ID_EGE+1
	ID_Subject="5"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Олимпиады
	if random.random()<=0.1:
		ID_OlympiadCertificate=str(random.randint(1,10))
		DateOfReceiving=gen_dob(2,2020,2,2020)
		ReceivedCertificate.write(str(ID_Enrollee)+","+str(ID_OlympiadCertificate)+","+DateOfReceiving+"\n")
#Группа 6
for i in range(5):
	#Атрибуты Enrollee
	ID_Enrollee=ID_Enrollee+1
	Name=gen_name()+" "+gen_name()
	DOB=gen_dob(1,2002,12,2003)
	#if random.random()<0.5:
		#EducationDocument="SPO"
	#else:
		#EducationDocument="VO"
	EducationDocument="At11"
		
	AchievmentPoints=str(random.randint(0,5))
	if random.random()<=0.1:
		RightToSpecialQuota="1"
	else: 
		RightToSpecialQuota="0"
	AgreementOnTargetTraining="0"
	if random.random()<0.1:
		RightToPriorityAdmission="1"
	else:
		RightToPriorityAdmission="0"
	Disabled="0"
	Compatriot="0"
	Enrollee.write(str(ID_Enrollee)+","+Name+","+DOB+","+EducationDocument+","+AchievmentPoints+","+ \
		RightToSpecialQuota+","+AgreementOnTargetTraining+","+RightToPriorityAdmission+","+Disabled+","+Compatriot+"\n")
	#Гражданство
	#РФ
	Enrollee2Citizenship.write(str(ID_Enrollee)+","+"1"+"\n")
	#Заявление1
	ID_Application=ID_Application+1
	ID_Faculty="1"
	ID_PaymentMethod="1"
	if RightToSpecialQuota==1:
		ID_Quota="3"
	else:
		ID_Quota="NULL"
	ID_EducationalProgram="2"
	if random.random()<0.9:
		EnrolmentConsent=1
	else:
		EnrolmentConsent=0
	Application.write(str(ID_Application)+","+ID_Faculty+","+ID_PaymentMethod+","+ID_Quota+","+ \
		ID_EducationalProgram+","+str(ID_Enrollee)+","+str(EnrolmentConsent)+"\n")
	#ЕГЭ
	#Математика
	ID_EGE=ID_EGE+1
	ID_Subject="1"
	Score=str(random.randint(30,100))
	DateOfExam="1.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Физика
	ID_EGE=ID_EGE+1
	ID_Subject="2"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Русский
	ID_EGE=ID_EGE+1
	ID_Subject="5"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Информатика
	ID_EGE=ID_EGE+1
	ID_Subject="4"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Олимпиады
	ID_OlympiadCertificate=str(random.randint(1,10))
	DateOfReceiving=gen_dob(2,2020,2,2020)
	ReceivedCertificate.write(str(ID_Enrollee)+","+str(ID_OlympiadCertificate)+","+DateOfReceiving+"\n")
	#Абитуриент не может получить сертификаты по одному и тому же предмету
	new_id=str(random.randint(1,10))
	while new_id==ID_OlympiadCertificate:
		new_id=str(random.randint(1,10))
	ID_OlympiadCertificate=new_id
	DateOfReceiving=gen_dob(2,2020,2,2020)
	ReceivedCertificate.write(str(ID_Enrollee)+","+str(ID_OlympiadCertificate)+","+DateOfReceiving+"\n")
#Группа 7
for i in range(5):
	#Атрибуты Enrollee
	ID_Enrollee=ID_Enrollee+1
	Name=gen_name()+" "+gen_name()
	DOB=gen_dob(1,2002,12,2003)
	#if random.random()<0.5:
		#EducationDocument="SPO"
	#else:
		#EducationDocument="VO"
	EducationDocument="At11"
		
	AchievmentPoints=str(random.randint(0,5))
	if random.random()<=0.1:
		RightToSpecialQuota="1"
	else: 
		RightToSpecialQuota="0"
	AgreementOnTargetTraining="0"
	if random.random()<0.1:
		RightToPriorityAdmission="1"
	else:
		RightToPriorityAdmission="0"
	Disabled="0"
	Compatriot="0"
	Enrollee.write(str(ID_Enrollee)+","+Name+","+DOB+","+EducationDocument+ \
		","+AchievmentPoints+","+RightToSpecialQuota+ \
		","+AgreementOnTargetTraining+","+RightToPriorityAdmission+","+Disabled+","+Compatriot+"\n")
	#Гражданство
	#РФ
	Enrollee2Citizenship.write(str(ID_Enrollee)+","+"1"+"\n")
	#Еще одно
	Enrollee2Citizenship.write(str(ID_Enrollee)+","+str(random.randint(2,10))+"\n")
	#Заявление1
	ID_Application=ID_Application+1
	ID_Faculty="1"
	ID_PaymentMethod="1"
	if RightToSpecialQuota==1:
		ID_Quota="3"
	else:
		ID_Quota="NULL"
	ID_EducationalProgram="2"
	if random.random()<0.9:
		EnrolmentConsent=1
	else:
		EnrolmentConsent=0
	Application.write(str(ID_Application)+","+ID_Faculty+","+ID_PaymentMethod+","+ID_Quota+","+ \
		ID_EducationalProgram+","+str(ID_Enrollee)+","+str(EnrolmentConsent)+"\n")
	#ЕГЭ
	#Математика
	ID_EGE=ID_EGE+1
	ID_Subject="1"
	Score=str(random.randint(30,100))
	DateOfExam="1.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Физика
	ID_EGE=ID_EGE+1
	ID_Subject="2"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	#Русский
	ID_EGE=ID_EGE+1
	ID_Subject="5"
	Score=str(random.randint(30,100))
	DateOfExam="5.06.2020"
	PassedEGE.write(str(ID_EGE)+","+str(ID_Enrollee)+","+ID_Subject+","+DateOfExam+","+Score+"\n")
	
	#Олимпиады
	ID_OlympiadCertificate=str(random.randint(1,10))
	DateOfReceiving=gen_dob(2,2020,2,2020)
	ReceivedCertificate.write(str(ID_Enrollee)+","+str(ID_OlympiadCertificate)+","+DateOfReceiving+"\n")
	
	
	
	

		
	

	
	

	
