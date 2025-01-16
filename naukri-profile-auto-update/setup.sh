#!/bin/bash

# Function to create Termux boot directory
mkdir -p ~/.termux/boot
echo ">> Termux boot directory created."

# Function to copy the start-cron.sh script to the boot directory
cp ../environment-setup/start-cron.sh ~/.termux/boot/
chmod +x ~/.termux/boot/start-cron.sh
echo ">> start-cron.sh copied and made executable."

# Function to create logs folder
mkdir -p ~/logs
echo ">> Logs folder created."

if [[ $(pwd) == *"com.termux"* ]]; then
    echo "Termux detected. Installing Brotli and Cronie..."
    pkg update -y
    pkg install brotli cronie -y
    echo "✓ Brotli and Cronie installed"
fi

DATA_DIR="./data"
CREDENTIALS_FILE="$DATA_DIR/credentials.txt"
HEADLINE_FILE="$DATA_DIR/headline.txt"
TEMPLATE_FILE="./script-templates/welcome.sh"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"
rm -f ./scheduled.sh
rm -rf "$DATA_DIR"/*

# Step 1: Collect credentials
echo "Step 1: Collecting credentials..."
read -p "Enter username: " USERNAME
read -sp "Enter password: " PASSWORD
echo

# Store credentials
echo "username=$USERNAME" > "$CREDENTIALS_FILE"
echo "password=$PASSWORD" >> "$CREDENTIALS_FILE"
chmod 644 "$CREDENTIALS_FILE"
echo "✓ Credentials saved"

# Step 2: Collect profile headline with validation
echo "Step 2: Collecting profile headline..."
while true; do
    read -p "Enter profile headline (at least 5 words): " HEADLINE
    WORD_COUNT=$(echo $HEADLINE | wc -w)
    if [ $WORD_COUNT -ge 5 ]; then
        echo "$HEADLINE" > "$HEADLINE_FILE"
        chmod 644 "$HEADLINE_FILE"
        echo "✓ Profile headline saved"
        break
    else
        echo "✗ Error: Headline must contain at least 5 words. Please try again."
    fi
done

# Step 3: Copy template files
echo "Step 3: Copying template files..."
rm -f ./script-templates/*x.sh
cp ./script-templates/welcome.sh ./script-templates/welcome-x.sh
cp ./script-templates/update.sh ./script-templates/update-x.sh
cp ./script-templates/login.sh ./script-templates/login-x.sh
cp ./script-templates/self.sh ./script-templates/self-x.sh
chmod +x ./script-templates/welcome-x.sh
chmod +x ./script-templates/update-x.sh
chmod +x ./script-templates/login-x.sh
chmod +x ./script-templates/self-x.sh
echo "✓ Template files copied and made executable"

# Step 4: Replace credentials in login-x.sh
echo "Step 4: Replacing credentials in login-x.sh..."
sed -i "s|<EMAIL>|$USERNAME|g" ./script-templates/login-x.sh
sed -i "s|<PASSWORD>|$PASSWORD|g" ./script-templates/login-x.sh
echo "✓ Credentials replaced in login-x.sh"

# Step 5: Run welcome and login scripts
echo "Step 5: Running initial scripts..."
./script-templates/welcome-x.sh > /dev/null 2>&1
./script-templates/login-x.sh > /dev/null 2>&1
echo "✓ Scripts executed successfully"

# Step 6: Extract bearer token
echo "Step 6: Extracting bearer token..."
COOKIES_FILE="./data/cookies.txt"
COOKIE_VALUE=$(awk -F'\t' '$6 == "nauk_at" {print $7}' "$COOKIES_FILE")

if [ -n "$COOKIE_VALUE" ]; then
    sed -i "s|<BEARER_TOKEN>|$COOKIE_VALUE|g" ./script-templates/self-x.sh
    sed -i "s|<BEARER_TOKEN>|$COOKIE_VALUE|g" ./script-templates/update-x.sh
    echo "✓ Bearer token replaced"
else
    echo "✗ Error: nauk_at cookie not found"
    exit 1
fi

# Step 7: Run self-x.sh and decompress data
echo "Step 7: Fetching profile data..."
./script-templates/self-x.sh > /dev/null 2>&1
brotli -d ./data/self.txt -o ./data/self_decoded.txt
echo "✓ Profile data fetched and decompressed"

# Step 8: Extract profile ID
echo "Step 8: Extracting profile ID..."
PROFILE_FILE="$DATA_DIR/self_decoded.txt"
PROFILE_ID=$(grep -o '"profileId":"[^"]*"' "$PROFILE_FILE" | awk -F':' '{print $2}' | tr -d '"')

if [ -n "$PROFILE_ID" ]; then
    sed -i "s|<PROFILE_ID>|$PROFILE_ID|g" ./script-templates/update-x.sh
    echo "✓ Profile ID replaced: $PROFILE_ID"
else
    echo "✗ Error: profileId not found"
    exit 1
fi

# Step 9: Replace profile headline
echo "Step 9: Replacing profile headline..."
PROFILE_HEADING=$(cat "$HEADLINE_FILE")

if [ -n "$PROFILE_HEADING" ]; then
    sed -i "s|<PROFILE_HEADING>|$PROFILE_HEADING|g" ./script-templates/update-x.sh
    echo "✓ Profile headline replaced"
else
    echo "✗ Error: Headline file is empty"
    exit 1
fi

# Step 10: Run update-x.sh
echo "Step 10: Updating profile..."
./script-templates/update-x.sh > /dev/null 2>&1
echo "✓ Profile updated successfully"

# Step 11: Copy schedule.sh and make it executable
echo "Step 11: Setting up scheduled script..."
cp ./script-templates/schedule.sh ./scheduled.sh
chmod +x ./scheduled.sh
echo "✓ Scheduled script copied and made executable"

# Step 12: Add cron job to run scheduled.sh every hour (if not already added)
CRON_JOB="0 * * * * /data/data/com.termux/files/home/custom-termux/naukri-profile-auto-update/scheduled.sh"
# Check if the cron job already exists
(crontab -l 2>/dev/null | grep -F "$CRON_JOB") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
echo "✓ Cron job checked and added if necessary"

echo -e "\nSetup complete! All steps executed successfully."
