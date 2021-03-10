### FUll details: http://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/support/getting-started/using-ssh/

# Connect to VPN (find ID with nmcli con, might change over time?)
nmcli con up d40351d6-52cf-4060-ac8c-d6691f6808f9

# start secure shell
ssh -XY bjn20@login.hpc.ic.ac.uk
# (enter imperial password)

# Root to relevent dir
cd ~/../projects/human-popgen-datasets/live/HGDP_1000g

# Root to my main directory
cd ~/project/

# To unzip .gz file:
gunzip #fname


# info from README file from imperial:
# RDS Individual allocation.

# Do not store sensitive or personally-identifiable data here.

# Data within $RDS/ephemeral/ is unquotaed but will be DELETED 30 DAYS AFTER CREATION.

# Data within $RDS/home/ will count against your 1TB usage quota.


# Any project allocations that you have access to will be accessible via $RDS/projects


#     THIS SPACE WILL BE DELETED WHEN YOU LEAVE THE COLLEGE