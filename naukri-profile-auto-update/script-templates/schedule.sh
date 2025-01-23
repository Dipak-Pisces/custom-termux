#!/bin/bash

echo "Termux:Boot triggered at $(date)" >> ~/logs/naukri.log

DATA_DIR="./data"
CREDENTIALS_FILE="$DATA_DIR/credentials.txt"
HEADLINE_FILE="$DATA_DIR/headline.txt"
TEMPLATE_FILE="./script-templates/welcome.sh"

# Step 1: Clean up data directory except credentials.txt and headline.txt
echo "Step 1: Cleaning up data directory..."
find "$DATA_DIR" -type f ! -name "credentials.txt" ! -name "headline.txt" -delete

# Step 2: Copy template files
echo "Step 2: Copying template files..."
rm -f ./script-templates/*-x.sh
cp ./script-templates/welcome.sh ./script-templates/welcome-x.sh
cp ./script-templates/update.sh ./script-templates/update-x.sh
cp ./script-templates/login.sh ./script-templates/login-x.sh
cp ./script-templates/self.sh ./script-templates/self-x.sh
chmod +x ./script-templates/*-x.sh
echo "✓ Template files copied and made executable"

# Step 3: Replace credentials in login-x.sh
echo "Step 3: Replacing credentials in login-x.sh..."
USERNAME=$(grep '^username=' "$CREDENTIALS_FILE" | cut -d'=' -f2)
PASSWORD=$(grep '^password=' "$CREDENTIALS_FILE" | cut -d'=' -f2)

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    sed -i "s|<EMAIL>|$USERNAME|g" ./script-templates/login-x.sh
    sed -i "s|<PASSWORD>|$PASSWORD|g" ./script-templates/login-x.sh
    echo "✓ Credentials replaced in login-x.sh"
else
    echo "✗ Error: Missing username or password in credentials file"
    exit 1
fi

# Step 4: Run welcome and login scripts
echo "Step 4: Running initial scripts..."
./script-templates/welcome-x.sh > /dev/null 2>&1
./script-templates/login-x.sh > /dev/null 2>&1
echo "✓ Scripts executed successfully"

# Step 5: Extract bearer token
echo "Step 5: Extracting bearer token..."
COOKIES_FILE="$DATA_DIR/cookies.txt"
COOKIE_VALUE=$(awk -F'\t' '$6 == "nauk_at" {print $7}' "$COOKIES_FILE")

if [ -n "$COOKIE_VALUE" ]; then
    sed -i "s|<BEARER_TOKEN>|$COOKIE_VALUE|g" ./script-templates/self-x.sh
    sed -i "s|<BEARER_TOKEN>|$COOKIE_VALUE|g" ./script-templates/update-x.sh
    echo "✓ Bearer token replaced"
else
    echo "✗ Error: nauk_at cookie not found"
    exit 1
fi

# Step 6: Run self-x.sh and decompress data
echo "Step 6: Fetching profile data..."
./script-templates/self-x.sh > /dev/null 2>&1
brotli -d ./data/self.txt -o ./data/self_decoded.txt
echo "✓ Profile data fetched and decompressed"

# Step 7: Extract profile ID
echo "Step 7: Extracting profile ID..."
PROFILE_FILE="$DATA_DIR/self_decoded.txt"
PROFILE_ID=$(grep -o '"profileId":"[^"]*"' "$PROFILE_FILE" | awk -F':' '{print $2}' | tr -d '"')

if [ -n "$PROFILE_ID" ]; then
    sed -i "s|<PROFILE_ID>|$PROFILE_ID|g" ./script-templates/update-x.sh
    echo "✓ Profile ID replaced: $PROFILE_ID"
else
    echo "✗ Error: profileId not found"
    exit 1
fi

# Step 8: Replace profile headline
echo "Step 8: Replacing profile headline..."
PROFILE_HEADING=$(cat "$HEADLINE_FILE")

# Step 8: Replace profile headline
echo "Step 8: Replacing profile headline..."
PROFILE_HEADING=$(cat "$HEADLINE_FILE")

if [ -n "$PROFILE_HEADING" ]; then
    ESCAPED_PROFILE_HEADING=$(echo "$PROFILE_HEADING" | sed 's|[&/|]|\\&|g' | sed 's/|/,/g')
    CURRENT_TIME=$(date '+%d/%H:%M')
    sed -i "s|<PROFILE_HEADING>|$ESCAPED_PROFILE_HEADING {$CURRENT_TIME}|g" ./script-templates/update-x.sh
    echo "✓ Profile headline replaced with timestamp: $CURRENT_TIME"
else
    echo "✗ Error: Headline file is empty"
    exit 1
fi

# Step 9: Run update-x.sh
echo "Step 9: Updating profile..."
./script-templates/update-x.sh > /dev/null 2>&1
echo "✓ Profile updated successfully"

echo -e "\nSchedule complete! All steps executed successfully."
