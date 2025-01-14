import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import os
import sys
import logging
import re  # For email validation

# Configure logging
logging.basicConfig(
    filename="log/logs.txt",
    level=logging.INFO,
    format="%(asctime)s - [APPROACH] - %(levelname)s - %(message)s"
)

# Check if recipient email is passed as an argument
if len(sys.argv) < 2:
    print("Usage: approach <recipient_email>")
    sys.exit(1)

recipient_email = sys.argv[1]

# Paths to files and directories
approached_file_path = "data/Approached.txt"
email_body_path = "data/EmailBody.txt"
email_subject_path = "data/EmailSubject.txt"
attachments_folder = "attachments"
resume_name_file = os.path.join(attachments_folder, "resume_name.txt")

# Email credentials
sender_email = "pdipak945@gmail.com"
password = os.getenv("GIT_GMAIL_APP_PASSWORD")  # App password

# Function to validate email format
def is_valid_email(email):
    email_regex = r'^[a-zA-Z0-9_.+-]+@[a-zAZ0-9-]+\.[a-zA-Z0-9-.]+$'
    return re.match(email_regex, email)

# Function to read content from a file
def read_file_content(file_path):
    try:
        with open(file_path, 'r') as file:
            return file.read().strip()  # Remove leading/trailing spaces or newlines
    except FileNotFoundError:
        logging.error(f"Error: File '{file_path}' not found.")
        return None

# Function to check if recipient email is already in Approached.txt
def is_email_approached(file_path, email):
    if not os.path.exists(file_path):
        return False  # File doesn't exist, so email hasn't been approached
    with open(file_path, "r") as file:
        approached_emails = {line.strip() for line in file if line.strip()}
        return email in approached_emails

# Function to get the resume path dynamically
def get_resume_path():
    # Check if resume_name.txt exists and contains a resume name
    if os.path.exists(resume_name_file):
        with open(resume_name_file, 'r') as file:
            resume_name = file.read().strip()
            if resume_name:  # If resume name is present in the file
                resume_path = os.path.join(attachments_folder, resume_name)
                if os.path.exists(resume_path):
                    return resume_path
    
    # If no valid resume name is found, lookup in the attachments folder
    # Rescan the folder to identify .pdf, .doc, and .docx files only
    for file_name in os.listdir(attachments_folder):
        if file_name.endswith((".txt", ".DS_Store")):
            continue  # Skip .txt and .DS_Store files

        if file_name.endswith((".pdf", ".doc", ".docx")):  # Only pick .pdf, .doc, .docx
            resume_path = os.path.join(attachments_folder, file_name)
            with open(resume_name_file, 'w') as file:
                file.write(file_name)  # Update resume_name.txt with the selected file name
            logging.info(f"Found new resume: {resume_path}")
            return resume_path

    logging.warning("No valid resume found in the attachments folder.")
    print("Error: No valid resume found in the attachments folder.")
    sys.exit(1)

# Validate the recipient email format
if not is_valid_email(recipient_email):
    logging.error(f"Invalid email format: {recipient_email}. Exiting.")
    print("Error: Invalid email format.")
    sys.exit(1)

# Read the email subject and body
subject = read_file_content(email_subject_path)
body = read_file_content(email_body_path)

# Check if subject or body is blank
if not subject:
    logging.warning("Email subject is blank. Exiting without sending email.")
    print("Error: Email subject is blank.")
    sys.exit(1)

if not body:
    logging.warning("Email body is blank. Exiting without sending email.")
    print("Error: Email body is blank.")
    sys.exit(1)

# Skip sending email if already approached
if is_email_approached(approached_file_path, recipient_email):
    logging.info(f"Email to {recipient_email} has already been sent. Skipping.")
    print(f"Email to {recipient_email} has already been sent. Skipping...")
    sys.exit(0)

# Get the resume path
resume_path = get_resume_path()

# Create the email
msg = MIMEMultipart()
msg['From'] = sender_email
msg['To'] = recipient_email
msg['Subject'] = subject
msg.attach(MIMEText(body, 'plain'))

# Attach the resume file
if resume_path and os.path.exists(resume_path):
    attachment = MIMEBase('application', 'octet-stream')
    with open(resume_path, 'rb') as file:
        attachment.set_payload(file.read())
    encoders.encode_base64(attachment)
    attachment.add_header('Content-Disposition', f"attachment; filename={os.path.basename(resume_path)}")
    msg.attach(attachment)
    logging.info(f"Attached file: {resume_path}")
else:
    logging.warning(f"Warning: Attachment '{resume_path}' not found. Skipping attachment.")
    print(f"Warning: Attachment '{resume_path}' not found. Skipping attachment.")

try:
    # Connect to the Gmail SMTP server
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(sender_email, password)
    server.send_message(msg)
    logging.info(f"Email sent successfully to {recipient_email}!")

    # Append the recipient email to Approached.txt
    with open(approached_file_path, "a") as approached_file:
        approached_file.write(f"{recipient_email}\n")

    print(f"Email sent successfully to {recipient_email}!")

except Exception as e:
    logging.error(f"Failed to send email to {recipient_email}: {e}")
    print(f"Failed to send email to {recipient_email}: {e}")
finally:
    server.quit()
