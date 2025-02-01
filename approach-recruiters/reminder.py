import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import os
import sys
import logging
import re  # For email validation
from datetime import datetime

# Configure logging
logging.basicConfig(
    filename="log/logs.txt",
    level=logging.INFO,
    format="%(asctime)s - [REMINDER] - %(levelname)s - %(message)s"
)

# Email credentials
sender_email = "pdipak945@gmail.com"
password = os.getenv("GIT_GMAIL_APP_PASSWORD")  # App password

# Paths to files and folders
approached_file_path = "data/Approached.txt"
email_body_path = "data/EmailBody.txt"
email_subject_path = "data/EmailSubject.txt"
resume_name_file = "attachments/resume_name.txt"
attachments_folder = "attachments"
metadata_file = "data/metadata.txt"

# Function to validate email format
def is_valid_email(email):
    email_regex = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'
    return re.match(email_regex, email)

# Function to read content from a file
def read_file_content(file_path):
    try:
        with open(file_path, 'r') as file:
            return file.read().strip()  # Remove leading/trailing spaces or newlines
    except FileNotFoundError:
        logging.error(f"Error: File '{file_path}' not found.")
        return None

# Function to get unique email IDs from Approached.txt
def get_unique_emails(file_path):
    try:
        with open(file_path, 'r') as file:
            emails = set(line.strip() for line in file if line.strip())  # Remove duplicates and empty lines
        logging.info(f"Found {len(emails)} unique email(s) to send reminders.")
        return emails
    except FileNotFoundError:
        logging.error(f"Error: File '{file_path}' not found.")
        return set()

# Function to read metadata values
def read_metadata():
    metadata = {}
    if os.path.exists(metadata_file):
        with open(metadata_file, 'r') as file:
            for line in file:
                if line.strip():
                    key, value = line.strip().split('=')
                    metadata[key] = value
    return metadata

# Function to get resume file path dynamically
def get_resume_path():
    if os.path.exists(resume_name_file):
        with open(resume_name_file, 'r') as file:
            resume_name = file.read().strip()
            if resume_name:  # If resume name is present in the file
                resume_path = os.path.join(attachments_folder, resume_name)
                if os.path.exists(resume_path):
                    return resume_path
    
    # If no valid resume name is found, lookup in the attachments folder
    for file_name in os.listdir(attachments_folder):
        if file_name.endswith(".pdf"):  # Assuming resume files are PDFs
            resume_path = os.path.join(attachments_folder, file_name)
            with open(resume_name_file, 'w') as file:
                file.write(file_name)  # Update resume_name.txt with the file name
            return resume_path

    logging.warning("No resume found in the attachments folder.")
    print("Error: No resume found in the attachments folder.")
    sys.exit(1)

# Function to send email
def send_email(recipient_email, subject, body, attachment_path):
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    # Attach the resume file
    if attachment_path and os.path.exists(attachment_path):
        attachment = MIMEBase('application', 'octet-stream')
        with open(attachment_path, 'rb') as file:
            attachment.set_payload(file.read())
        encoders.encode_base64(attachment)
        attachment.add_header('Content-Disposition', f"attachment; filename={os.path.basename(attachment_path)}")
        msg.attach(attachment)
        logging.info(f"Attached file: {attachment_path}")
    else:
        logging.warning(f"Warning: Attachment '{attachment_path}' not found. Skipping attachment.")
        print(f"Warning: Attachment '{attachment_path}' not found. Skipping attachment.")

    try:
        # Connect to the Gmail SMTP server
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(sender_email, password)
        server.send_message(msg)
        logging.info(f"Email sent successfully to {recipient_email}.")
        print(f"Email sent successfully to {recipient_email}.")
    except Exception as e:
        logging.error(f"Failed to send email to {recipient_email}: {e}")
        print(f"Failed to send email to {recipient_email}: {e}")
    finally:
        server.quit()

# Main script execution
if __name__ == "__main__":
    # Get unique email addresses
    unique_emails = get_unique_emails(approached_file_path)
    if not unique_emails:
        logging.info("No unique emails found to send reminders.")
        print("No unique emails found to send reminders.")
        sys.exit(0)

    # Read email subject and body
    subject = read_file_content(email_subject_path)
    # Read metadata
    metadata = read_metadata()
    # Modify subject based on metadata
    if metadata.get('resigned_status') == 'no':
        notice_period = metadata.get('notice_period')
        if notice_period:
            subject += f" - Official Notice Period: {notice_period} Days"
    elif metadata.get('resigned_status') == 'yes':
        last_working_day = metadata.get('last_working_day')
        if last_working_day:
            try:
                last_working_date = datetime.strptime(last_working_day, '%Y-%m-%d')
                today = datetime.today()
                # Calculate the difference in days, excluding the current day
                days_to_join = (last_working_date - today).days + 2
                if days_to_join < 0:
                    logging.error(f"Error: Last working day {last_working_day} is in the past.")
                    print(f"Error: Last working day {last_working_day} is in the past.")
                    sys.exit(1)
                subject += f" - Available to Join in {days_to_join} Days"
            except ValueError:
                logging.error(f"Invalid last working day format in metadata: {last_working_day}")
                print("Error: Invalid last working day format in metadata.")
                sys.exit(1)
    body = read_file_content(email_body_path)

    # Check if subject or body is blank
    if not subject:
        logging.warning("Email subject is blank. Exiting without sending emails.")
        print("Error: Email subject is blank.")
        sys.exit(1)

    if not body:
        logging.warning("Email body is blank. Exiting without sending emails.")
        print("Error: Email body is blank.")
        sys.exit(1)

    # Get the resume path
    resume_path = get_resume_path()

    # Send email to each unique recipient
    for email in unique_emails:
        if not is_valid_email(email):
            logging.error(f"Invalid email format: {email}. Skipping.")
            print(f"Warning: Invalid email format: {email}. Skipping...")
            continue
        send_email(email,"Reminder - "+ subject, body, resume_path)
