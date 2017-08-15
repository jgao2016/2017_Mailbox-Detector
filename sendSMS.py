import time
from twilio.rest import Client

def getTargets():
	array=[]
	file = open("targets.txt","r+")
	line = file.readline()
	while len(line)>0:
		array.append(int(line))
		line = file.readline()
	file.truncate(0)
	file.close()
	for i in range(0, len(array)):
		send(array[i])

def send(line):
	print ("I'm sending message to %s "%line)	
	
	account_sid = "ACf83c0fb88ddcdafea6d8838da4682a86"
	auth_token  = "2b186173945b51d58cfb6ea70d7d69f0"

	client = Client(account_sid, auth_token)

	message = client.messages.create(
	    to="+14707556674", 
	    from_="+19527777721",
	    body="You got a mail! Please come and check:)")

	print(message.sid)

i=0
while i< 5:
	print("iteration %s" % (i)) 
	getTargets()
	i = i+1
	time.sleep(3)

