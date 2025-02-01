#!/bin/bash

# Function to read email, app password, and employment status from user
read_email_and_password() {
    echo ">> Enter your Gmail email address:"
    read sender_email
    echo ">> Enter your Gmail app password:"
    read -s app_password

    # Collect employment status
    echo ">> Have you resigned from your current job? (yes/no):"
    read resigned_status

    if [ "$resigned_status" == "yes" ]; then
        echo ">> Enter your last working day (YYYY-MM-DD):"
        read last_working_day
    else
        echo ">> Enter the duration of your notice period (in days):"
        read notice_period
    fi

    echo ">> Email, password, and employment details collected."

    # Store data in Metadata.txt
    metadata_file="../approach-recruiters/data/Metadata.txt"
    echo "sender_email=$sender_email" > $metadata_file
    echo "resigned_status=$resigned_status" >> $metadata_file
    if [ "$resigned_status" == "yes" ]; then
        echo "last_working_day=$last_working_day" >> $metadata_file
    else
        echo "notice_period=$notice_period" >> $metadata_file
    fi
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

    # Step 1: Get email, app password, and employment details from user
    read_email_and_password

    # Step 2: Create a temporary bashrc, update it, and copy to home directory
    update_and_copy_bashrc

    # Step 3: Update sender_email in reminder.py and approach.py
    update_sender_email

    # Step 4: Create Termux boot directory
    create_termux_boot

    # Step 5: Copy start-cron.sh to boot directory and set permissions
    copy_start_cron_script

    # Step 6: Setup cron job
    setup_cron_job

    # Step 7: Create logs folder
    create_logs_folder

    # Step 8: Clear previous email data and attachments
    clear_email_and_attachments

    echo "===== Environment Setup Completed ====="
}

# Run the main function
main
