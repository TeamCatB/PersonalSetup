adduser $ACCOUNT_USERNAME --gecos "$ACCOUNT_USERNAME,RoomNumber,WorkPhone,HomePhone" --disabled-password
sh -c "echo '$ACCOUNT_USERNAME:${ACCOUNT_PASSWORD}' | chpasswd"
usermod -aG sudo $ACCOUNT_USERNAME
