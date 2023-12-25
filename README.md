# pve-parent
Parental Controls for Proxmox


## Installation
1. Clone this repository for the latest version of the script

```bash
cd /opt
git clone https://github.com/mdsketch/pve-parent
```

#### Note: All commands below must be run from the pve-parent repository root

2. Install the monitor service

```bash
cp monitor.service /etc/systemd/system/monitor.service
systemctl daemon-reload
systemctl enable --now monitor.service
```

3. Install cron job

- Edit the crontab file

```bash
cp monitor.cron /etc/cron.d/monitor
```


## Optional: Use Power Button to start VM
1. Disable the default power button action

```
sed -i 's/HandlePowerKey=poweroff/HandlePowerKey=ignore/g' /etc/systemd/logind.conf
sed -i 's/HandleSuspendKey=suspend/HandleSuspendKey=ignore/g' /etc/systemd/logind.conf
sed -i 's/HandleHibernateKey=hibernate/HandleHibernateKey=ignore/g' /etc/systemd/logind.conf
```

2. Install ACPI event handler

```bash
apt install acpid
```

3. Edit the acpi handler file and add custom action

```bash
cp powerbtn-acpi-support /etc/acpi/events/powerbtn-acpi-support
cp pwbtn.sh /etc/acpi/pwbtn.sh
```
 