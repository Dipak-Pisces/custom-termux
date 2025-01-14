
##########################################
#   Resume Sending Script - README      #
##########################################

## Purpose of the Script:
This script is designed to automate the process of sending job application emails 
with a resume attached. The script simplifies the task of sending personalized emails 
to recruiters during a job search by automatically attaching the most recent resume 
and sending the email to the specified recipient.

It also provides a mechanism to track which emails have already been approached 
(i.e., emails that have already been sent) and avoids sending duplicate emails.

## Features:
- **Automatic email sending**: Sends emails with a pre-written body and the most recent resume.
- **Email tracking**: Keeps track of emails that have been approached (i.e., already sent), 
  preventing duplicate emails.
- **File handling**: Automatically attaches the most recent resume (PDF, DOC, DOCX).
- **Remove emails from tracked list**: Allows you to manually remove an email from the 
  "Approached" list, so you can resend the email (if necessary).

## Usage:

### 1. **Sending an email (approach alias)**
To send an email with your resume attached, run the script with the recipient's email address 
as a command-line argument:

```
approach <recipient_email>
```

**Example:**
```
approach recruiter@example.com
```

### 2. **Removing an email from the Approached list (approached alias)**
If you need to manually remove an email from the "Approached" list (so that a reminder email 
can be sent again), you can use the `approached` alias:

```
approached <recipient_email>
```

**Example:**
```
approached recruiter@example.com
```

## Files:
- **Approached.txt**: A text file where all the emails that have been approached are logged. 
  The script checks this file to prevent sending duplicate emails.
- **EmailBody.txt**: A text file containing the body of the email to be sent.
- **EmailSubject.txt**: A text file containing the subject of the email to be sent.
- **resume_name.txt**: A text file storing the name of the most recent resume to attach.

## Notes:
- Ensure that **GIT_GMAIL_APP_PASSWORD** is set as an environment variable for the script 
  to authenticate via Gmail SMTP.
- Make sure to place your resume (PDF, DOC, DOCX) in the `attachments` folder.
- The script will automatically identify the most recent resume and attach it to the email.
- The script skips sending emails to those already listed in the `Approached.txt` file.

Enjoy automating your job applications!

##########################################
