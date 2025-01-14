##########################################
#   Naukri Profile Auto-Update Script - README   #
##########################################

## Purpose of the Script:
This script automates the process of updating your Naukri profile by logging in, 
fetching profile details, and updating your profile headline at regular intervals. 
It simplifies the task of keeping your profile active and updated on Naukri, 
increasing visibility to recruiters without manual intervention.

The script also handles token extraction, data decompression, and profile ID 
retrieval automatically, making the process seamless.

------------------------------------------

## Features:

- **Automated login**: Logs into your Naukri account using stored credentials 
  and extracts the necessary token for profile updates.
- **Headline update**: Automatically updates your profile headline with the 
  user-provided headline (must contain at least 5 words).
- **Token and profile ID extraction**: Extracts the required bearer token and 
  profile ID from Naukri’s responses.
- **Data decompression**: Handles Brotli-compressed responses to fetch and process 
  profile data.
- **Scheduled updates**: Sets up a cron job to update your profile at regular 
  intervals automatically.
- **File handling**: Manages credentials, headline, and token files securely.

------------------------------------------

## Notes:
- Ensure that the setup script is executed in the correct directory structure.
- The `data` folder will be cleared and recreated during each setup.
- Make sure that Brotli is installed on your system before running the script. 
  The setup script will attempt to install Brotli automatically on Termux.
- Once the setup is complete, the cron job will run automatically every hour.
