#!/bin/bash

# Function to read email and app password from user
read_email_and_password() {
    echo ">> Enter your Gmail email address:"
    read sender_email
    echo ">> Enter your Gmail app password:"
    read -s app_password
    echo ">> Email and password collected."
}

# Function to create a temporary bashrc file, update it, and copy to home directory
update_and_copy_bashrc() {
    echo ">> Updating bashrc with the Gmail app password..."
    cp bashrc bashrc_temp
    sed -i "s|<YOUR_APP_PASSWORD>|$app_password|" bashrc_temp
    cp bashrc_temp ~/.bashrc
    rm bashrc_temp
    echo ">> bashrc updated and copied."
}

# Function to update sender_email in reminder.py and approach.py
update_sender_email() {
    echo ">> Updating sender_email in scripts..."
    sed -i "s|^sender_email = .*|sender_email = \"$sender_email\"|" ../approach-recruiters/reminder.py
    sed -i "s|^sender_email = .*|sender_email = \"$sender_email\"|" ../approach-recruiters/approach.py
    echo ">> sender_email updated."
}

# Function to create Termux boot directory
create_termux_boot() {
    echo ">> Creating Termux boot directory..."
    mkdir -p ~/.termux/boot
    echo ">> Termux boot directory created."
}

# Function to copy the start-cron.sh script to the boot directory
copy_start_cron_script() {
    echo ">> Copying start-cron.sh to Termux boot directory..."
    cp start-cron.sh ~/.termux/boot/
    chmod +x ~/.termux/boot/start-cron.sh
    echo ">> start-cron.sh copied and made executable."
}

# Function to check if cron job exists, if not add it
setup_cron_job() {
    echo ">> Setting up cron job..."
    cron_job="0 10 * * 2-4 export GIT_GMAIL_APP_PASSWORD=\"$app_password\" && cd ~/custom-termux/approach-recruiters && python /data/data/com.termux/files/home/custom-termux/approach-recruiters/reminder.py"

    # Check if the cron job already exists
    (crontab -l 2>/dev/null | grep -Fxq "$cron_job") || (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    echo ">> Cron job setup completed."
}

# Function to create logs folder
create_logs_folder() {
    echo ">> Creating logs folder..."
    mkdir -p ~/logs
    echo ">> Logs folder created."
}

# Function to clear EmailBody, EmailSubject, and attachments
clear_email_and_attachments() {
    echo ">> Clearing email body and subject files..."
    > ../approach-recruiters/data/EmailBody.txt
    > ../approach-recruiters/data/EmailSubject.txt
    echo ">> Email body and subject files cleared."

    echo ">> Clearing attachment folder..."
    rm -rf ../approach-recruiters/attachments/*
    echo ">> Attachment folder cleared."

    echo ""
    echo "================================================================"
    echo "⚠️ WARNING: Please populate the following files before running emails:"
    echo "   1. EmailBody.txt  ->  Add the content for your email body."
    echo "   2. EmailSubject.txt  ->  Add the subject for your email."
    echo "   3. Attachment folder -> Add the resume or any files you want to attach."
    echo "================================================================"
    echo ""
}

# Main function to run the setup
main() {
    echo ""
    echo "===== Starting Environment Setup ====="
    
    # Step 1: Get email and app password from user
    read_email_and_password

    # Step 2: Create a temporary bashrc, update it, and copy to home directory
    update_and_copy_bashrc

    # Step 3: Update sender_email in reminder.py and approach.py
    update_sender_email

    # Step 4: Create Termux boot directory
    create_termux_boot

    # Step 5: Copy start-cron.sh to boot directory and make it executable
    copy_start_cron_script

    # Step 6: Set up cron job for reminder
    setup_cron_job

    # Step 7: Create logs directory
    create_logs_folder

    # Step 8: Clear email body, subject, and attachments
    clear_email_and_attachments

    echo ""
    echo "=========== Environment Setup Completed Successfully ==========="
    echo ""
    echo "🚨 Please run the following command manually to apply changes 🚨"
    echo ""
    echo "       source ~/.bashrc"
    echo ""
    echo "================================================================"
}

# Run the main setup function
main
