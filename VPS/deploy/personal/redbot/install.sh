# Setup deps
sudo apt update
sudo apt -y install python3 python3-dev python3-venv git openjdk-17-jre-headless build-essential nano

# Virtual Env
python3.11 -m venv ~/redenv
source ~/redenv/bin/activate

#Install pips
python -m pip install -U pip wheel
python -m pip install -U "Red-DiscordBot[postgres]"


# TODO:
redbot-setup
# This has follow-up prompts that need to be fed info
# BOT_NAME is the env variable provided rn but you might need more