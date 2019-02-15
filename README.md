# Zabbix Speedtest template
# Tested on Zabbix 4.0.3

## Installation (Generic x86_64)
- Install python-pip: `sudo apt install python-pip`
- Install speedtest: `pip install speedtest-cli`
- Copy `speedtest.sh` to `/etc/zabbix/bin`: `sudo cp speedtest.sh /etc/zabbix/bin` (If the bin directory does not exist, create it `sudo mkdir /etc/zabbix/bin`)
- Make it executable: `sudo chmod a+x /etc/zabbix/bin/speedtest.sh`
- Install the systemd service and timer: `sudo cp speedtest.service /etc/systemd/system` and `sudo cp speedtest.timer /etc/systemd/system`
- Start and enable the timer: `systemctl enable --now speedtest.timer`
- Copy speedtest.conf into /etc/zabbix/zabbix-agentd.d: `sudo cp speedtest.conf /etc/zabbix/zabbix_agentd.d`
- Restart zabbix-agent: `sudo systemctl restart zabbix-agent`
- Import `template_speedtest.xml` on your Zabbix server
- Add template to server that has the speedtest.sh service on in Zabbix