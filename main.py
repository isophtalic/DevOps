import os
import psutil
import shutil
from datetime import datetime
from dotenv import load_dotenv
from email.message import EmailMessage
import ssl
import smtplib
import time

load_dotenv()
email_sender = os.getenv('EMAIL_SENDER')
email_password = os.getenv('EMAIL_PASSWORD')
email_receiver = os.getenv('EMAIL_RECEIVER')


def makeEmailNotifications(current_time, cpu, ram, disk):
    subject = "Overload Performance"
    body = f'{current_time}: CPU {cpu}, RAM {ram}, Disk {disk} \n'
    em = EmailMessage()
    em['From'] = email_sender
    em['To'] = email_receiver
    em['Subject'] = subject
    em.set_content(body)

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL('smtp.gmail.com', 465, context=context) as smtp:
        smtp.login(email_sender, email_password)
        smtp.sendmail(email_sender, email_receiver, em.as_string())


def logFile(current_time, cpu, ram, disk):
    f = open("./log/performance_log.txt", "a+", encoding='utf-8')
    f.writelines(f'{current_time}: CPU {cpu}, RAM {ram}, Disk {disk} \n')


def performanceChecking():
    _, _, load15 = psutil.getloadavg()
    cpu_usage = (load15/os.cpu_count()) * 100
    ramUsed = psutil.virtual_memory()[2]

    path = "/"
    # Get the disk usage statistics
    # about the given path
    stat = shutil.disk_usage(path)

    # Print disk usage statistics
    diskUsed = stat.used/stat.total*100

    now = datetime.now()
    current_time = now.strftime("%Y:%b:%d | %H:%M:%S")

    if cpu_usage >= 90 or ramUsed >= 90 or diskUsed >= 90:
        makeEmailNotifications(current_time, cpu_usage, ramUsed, diskUsed)
    logFile(current_time, cpu_usage, ramUsed, diskUsed)


if __name__ == "__main__":
    while True:
        performanceChecking()
        time.sleep(3600)
