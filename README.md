# 🚀 GitHub Backup System

## Diagram
Below is a high-level diagram illustrating the structure and flow of the backup system:

![Backup System Diagram](https://github.com/bilelfeki/backup-script/blob/master/architecture/hld-schedular.jpg)

## Overview
The **GitHub Backup System** automates private repository backups by cloning your original and backup repositories, comparing commit histories, and ensuring that the backup repository is up-to-date. The system:
- Clones repositories if they are not already cloned.
- Extracts commit logs from both the original and backup repositories using **GitLog**.
- Compares the commit logs and updates the backup repository if necessary.
- Sends notifications if issues arise during the backup process, such as broken or missing commits.
  


## How It Works
- The script retrieves repository names from their URLs and checks if they have already been cloned.
- Commits from both repositories are pulled and compared using a **hashmap** structure.
- If the backup repository is behind, the missing commits are pushed to the backup repository.
- The system sends a **Windows notification** if there are problems during the comparison (e.g., broken commits).

## Setup
1. Clone the original and backup repositories or allow the script to handle the cloning automatically.
2. Configure the **PowerShell** script for your environment.
3. Use the **Tkinter** interface to schedule automatic backups (optional).

## Dependencies
- **PowerShell**
- **GitLog** (for commit extraction)
- **Tkinter** (for the configuration interface)
- **Windows Notifications** libraries for toast notifications

## Usage
The system ensures that your backup repository is always up-to-date with the original repository, helping to avoid potential data loss or commit discrepancies. If issues are detected, a notification will be sent.


## Repositories
- Task Scheduler Interface and Backup Configuration: [GitHub - Task Scheduler Interface Backup](https://github.com/bilelfeki/task-scheduler-interface-backup)

## License
This project is licensed under the **MIT License**.

---

Excited to hear your thoughts and feedback!
