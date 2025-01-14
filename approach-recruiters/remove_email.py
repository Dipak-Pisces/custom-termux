import os
import sys

# Path to Approached.txt
approached_file_path = "data/Approached.txt"

# Function to remove the email from Approached.txt
def remove_email_from_file(file_path, email_to_remove):
    # Check if the file exists
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    try:
        # Read all lines from the file
        with open(file_path, 'r') as file:
            lines = file.readlines()

        # Check if the email is in the file
        email_found = False
        with open(file_path, 'w') as file:
            for line in lines:
                if line.strip() == email_to_remove:
                    email_found = True  # Found the email to remove
                    continue  # Skip this line
                file.write(line)

        if email_found:
            print(f"Email '{email_to_remove}' has been removed from the file.")
        else:
            print(f"Email '{email_to_remove}' not found in the file.")

    except Exception as e:
        print(f"Error: {e}")

# Main execution
if __name__ == "__main__":
    # Check if an email is provided as a command line argument
    if len(sys.argv) < 2:
        print("Usage: python remove_email.py <email_to_remove>")
        sys.exit(1)

    # Get the email to remove from command line argument
    email_to_remove = sys.argv[1].strip()

    if not email_to_remove:
        print("Error: No email provided.")
    else:
        # Call the function to remove the email from the file
        remove_email_from_file(approached_file_path, email_to_remove)
