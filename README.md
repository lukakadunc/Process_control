# Process Control
Process controler for Linux/Unix


<b>Instructions</b>

1. Run your BASH shell
2. make sure that controller.sh have rights to execute
          2.1 if not than use: chmod +x  ./controller.sh
3. Run another console and make new pipe (mkfifo pipe_name)
4. connect to pipe(cat < pipe_name)
5. in 1st console run controller(./controller.sh #refreshrate pipe_name)
6. enter comands in 2nd console

<b>Comands</b>
Proc:
Make new process and it will keep it running until we maunaly close script or we use STOP
Proc:#of_instances:PID of proces we want to run  (to get PID just type PIDOF procesname)
Exit:
Shuts down script
Stop:
Stops process that we give as parameter
Stop:PID
Log:
Save all info about running proces in file active.log
Log last:
Save info of last running process in file active.log

if you find any error or bugs feel free to contact me.
