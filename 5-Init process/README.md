# Busybox init process
#### Configure Inittab
**MUST** to setup **inittab** file because it's the first thing that the **init** process look at
```bash
# inittab file 
::sysinit:/etc/init.d/rcS
# Start an "askfirst" shell on the console (whatever that may be)
ttyAMA0::askfirst:-/bin/sh
# Stuff to do when restarting the init process
::restart:/sbin/init
```
#### Conifigure rc 
```
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
```

### SystemV Init Process
System Five *(SysV)* init is one of the earliest init systems used in Unix-like operating systems. It follows a **sequential and script**-based approach to **starting and stopping system services** for system initialization. System V init uses a series of **runlevels** to define the state of the system and the services that are running ... The **Init Process** reads **`inittab`** configurations and runs the corresponding scripts for services.

- **Script-Based Configuration:** SysV init relies heavily on shell scripts located in directories like **`/etc/init.d/`** and **runlevels** specified in directories like **`/etc/rc*.d/`**.
- **Limited Parallelization:** SysV init processes start services **sequentially**, leading to slower boot times on systems with many services.
- **Lacks Dependency Management:** Managing dependencies between services in SysV init scripts requires **manual handling within the scripts**.


After choosing **`SystemV`** ... and starting the machine ... it's time to modify **SystemV** 

#### Modify `inittab`
In a **SystemV init system**, **`/etc/inittab`** is used to configure the behavior of the **init process**, including specifying the default `runlevel` and defining `actions` for various `events` such as **system startup, shutdown, and console management**.

There are **8 runlevels**, numbered from 0 to 6, plus S:
- **S:** run startup task
- **0:** Halts the system (shutdown)
- **1 to 5:** Available for general use
- **6:** Reboots the system

**`inittab`** file modifications to be added:
``` text
# Run Levels
l0:0:wait:/etc/init.d/rc 0
l1:1:wait:/etc/init.d/rc 1
l2:2:wait:/etc/init.d/rc 2
l3:3:wait:/etc/init.d/rc 3
l4:4:wait:/etc/init.d/rc 4
l5:5:wait:/etc/init.d/rc 5
l6:6:wait:/etc/init.d/rc 6
```
#### Create `rc.d` directory with subdirectories
Runlevel directory **`rc.d`** needs to be created and also create the **`rcN.d`** sub-directories **for each runlevel** **`(/etc/rc.d/rc[1-5].d/)`**. These directories contain symbolic links to specific scripts inside **`/etc/init.d`**, indicating which services should be started or stopped when the system enters a particular runlevel.

``` sh
# Create rc.d directory
mkdir /etc/rc.d

# Create rcN.d sub-directories
cd /etc/rc.d/
mkdir rc1.d rc2.d rc3.d rc4.d rc5.d
```
#### Create `rc` script
The script is responsible for managing **runlevels** and **executing** the specific scripts in **`/etc/init.d`** or correspondingly, the **soft-linked** scripts in **`/etc/rc.d/rcN.d/`** ... based on which run level.
``` sh
#!/bin/sh

# SystemV init script for different runlevels

# Check if a runlevel argument is provided
if [ -z "$1" ]; then
	echo "Usage: $0 <runlevel>"
	exit 1
fi

# Determine the target runlevel
RUNLEVEL=$1

# Define the path to the init.d and rc.d directories
INIT_D_DIR="/etc/init.d"
RC_D_DIR="/etc/rc.d/"

# Function to start or stop services based on their
# initial 'S' or 'K'
manage_services() 
{
	local rc_dir="$1"
	echo "Executing services for runlevel $RUNLEVEL..."
	for service in "$RC_D_DIR"/"$rc_dir"/*; do
	
		# Ignore dangling symlinks (if any).
     	[ ! -f "$service" ] && continue

		if [ -x "$service" ]; then
            # Check if the service name starts with 'S' or 'K'
            
			case "$(basename "$service")" in
				S* )
					trap - INT QUIT TSTP
					"$service" "start"
					;;
				K* )
					trap - INT QUIT TSTP
                    "$service" "stop"
					;;
				* )
					# Do Nothing!
					;;
			esac
		fi
	done
	echo "Finished Executing services for runlevel $RUNLEVEL!"
}


# Determine the action based on the runlevel
case "$RUNLEVEL" in
	1)
		manage_services "rc1.d"
		;;
	2)
		manage_services "rc2.d"
		;;
    3)
		manage_services "rc3.d"
        ;;
	4)
		manage_services "rc4.d"
		;;
	5) 
		manage_services "rc5.d"
		;;
	*)
		echo "Unsupported runlevel: $RUNLEVEL"
        exit 1
        ;;
esac

exit 0
```
#### Add Service Script
Create the **service script** inside **`/etc/init.d`** directory ... that will be executed during the specific runlevel ... **the script shall contain the application/binaries/scripts to be run!**
``` sh
# Create the script inside init.d
vim anyservice
# Example --> vim testpckg

# ... After adding the script
# Make Sure To chmod to be executable!!!
chmod +x anyservice
```

``` sh
#!/bin/sh
# Running test Service ...

case "$1" in
      start)
           echo "Starting test Service........."
           start-stop-daemon -S -n testsrv -a /usr/bin/testpckg &
           # Could be any script or binary rather testpckg
           ;;
     stop)
           echo "Stopping test Service........."
           start-stop-daemon -K -n testsrv
           # Could be any script or binary rather testpckg
           ;;
	restart)
    		echo "Restarting test Service........"
    		$0 stop
    		$0 start
    		;;
     *)
           echo "Usage: $0 {start|stop}"
           exit 1
esac
exit 0
```
> :grey_exclamation: You can test this service script by running it with start argument **`./testpckg start`**

Finally, you can **soft-link** the specific scripts to the corresponding runlevel
``` sh
# Service Script to be started 'S'
ln -s /etc/init.d/testpckg /etc/rc.d/rc3.d/S40testpckg

# Service Script to be stopped 'K'
ln -s /etc/init.d/testpckg /etc/rc.d/rc4.d/K40testpckg
```

### Systemd
System Daemon is an init system process, that manage system settings and services. systemd organizes tasks into components called **units**, and groups of units into **targets**, that can be used to create dependencies on other system services and resources. **systemd can start units and targets automatically at boot time, or when requested by a user or another systemd target when a server is already running.**

The **`systemctl`** command is used to interact with processes that are controlled by **systemd**. It can examine the **`status`** of units and targets, as well as **`start`**, **`stop`**, and **`reconfigure`** them

- **Event-Driven and Parallel Initialization:** systemd initializes services in **parallel** whenever possible, resulting in **faster boot times**. It also utilizes sockets and D-Bus for communication, **allowing services to be started on-demand as needed**.
- **Unit Files:** systemd uses declarative unit files **`(*.service, *.socket, *.target, etc.)`** instead of shell scripts for service configuration. These unit files provide more flexibility and are easier to manage.
- **Dependency Management:** systemd handles service dependencies automatically based on the directives specified in unit files, simplifying service management.
- **Logging and Monitoring:** systemd includes advanced logging and monitoring capabilities through the **journal** **`(systemd-journald)`**, which centralizes system logs and provides efficient querying and filtering capabilities.

#### Create Unit File
Typically stored in the **`/usr/lib/systemd/system/`** directory or   **`/etc/systemd/system/`** directory ***(Usually as soft-link)***. You can create your unit file with a **.service** extension, as most unit files correspond to services.
``` bash
cd /etc/systemd/system/
sudo vim deamonapp.service # Create service
```

#### Unit File Structure
- **`Unit:`** This section defines **metadata** and **dependencies** for the unit.
- **`Service:`** The Service section contains details about the **execution** and **termination** of service.
- **`Install:`** handles the installation of a systemd service/unit file. This is used when you run either **systemctl enable** and **systemctl disable** command for enabling or disabling a service.
``` bash
[Unit]
Description=app server
[Service]
Type=simple
ExecStart=/bin/deamonapp

[Install]
WantedBy=multi-user.target
```

#### Running Service
Enable and start the service and check status
``` bash
# Useful for when starting the runlevel (target) ... 
# to auto start the service
sudo systemctl enable deamonapp.service

sudo systemctl start deamonapp.service	# Starts the service

sudo systemctl status deamonapp.service

# You can also check journal logs
journalctl

# For current boot journal logs
journalctl -k
```

---
### SystemV vs SystemD
:bulb: SystemV and Systemd are both **init systems** for Unix-like operating systems, responsible for **initializing and managing system services, processes, and daemons**. However, they have significant differences in design, features, and operation

|            `SystemV`            |          `SystemD`           |
| :-----------------------------: | :--------------------------: |
|   **Sequential** script-based   | Parallelization event-driven |
|      Uses **init scripts**      |     Uses **unit files**      |
|        Slower boot-time         |       Faster boot-time       |
| Default for modern distribution |   Common in older systems    |
|  Provides Dependency mangement  |  Must be handled in scripts  |
