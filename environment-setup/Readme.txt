# 🚀 Environment Setup – Approach Recruiters

Follow these steps to set up your environment for sending email reminders automatically.

---

## 🛠️ Step 1: Make setup.sh Executable

1. **Grant Execute Permissions**:

    ```bash
    chmod +x setup.sh
    ```

    This will make `setup.sh` executable.

---

## 🖊️ Step 2: Customize and Run setup.sh

1. **Run setup.sh**:

    ```bash
    ./setup.sh
    ```

2. **During the Setup**:
    - Enter your **Gmail email** and **App Password** when prompted.
    - The script will update your `~/.bashrc`, copy necessary files, and set up a cron job for email reminders.

---

## ⏰ Step 3: Cron Job Setup

- By default, emails will be sent every **Tuesday to Thursday at 10:00 AM**.

- You can view or modify the cron job by running:

    ```bash
    crontab -l
    ```

---

## 🔑 Step 4: Verify Termux Permissions

1. **Check if start-cron.sh is Executable**:

    ```bash
    ls -l ~/.termux/boot/start-cron.sh
    ```

    Ensure the script has executable permissions (`rwx`).

---

## ⚡ Step 5: Sending Emails

1. **To manually send an email**, run:

    ```bash
    approach <recipient_email>
    ```

---

## 🛠️ Troubleshooting

- **Permission Denied Error**:  
  Run `chmod +x setup.sh` to ensure the script is executable.

- **Cron Job Not Running**:  
  Verify Termux permissions and make sure cron jobs are enabled on boot.

---

## 🎉 Congratulations!

You’ve completed the setup! Your system is now ready to send email reminders automatically.

For any further assistance, feel free to reach out!

