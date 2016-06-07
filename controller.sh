#!/bin/bash

cev=$2    #ime cevi
spanec=$1 #sleep time
ime_procesatab=""

echo $cev




function kontrola_proc(){
	#inicializacija
	#echo "PPID kontrola: $BASHPID"
	pid_ozadje=$BASHPID
	pid_ozadje1=$$
	

	st=${input[1]}
	#tabela podanih PID-ov
	IFS=' ' read -r -a pid_tab <<< "$vsi_brezvejce"   #vse pide dam v tabelo za lažje delo naprej
	dolzina_pidtab=${#pid_tab[@]}
	potrebovani=$dolzina_pidtab
 	#pidof
	
	#stars_pidof=$(ps -o ppid=  2463)
	#echo $stars_pidof $pid_ozadje


	#infiniteloop#2
	while [ true ]
	do
	sleep $spanec
	str_pidof=$(pidof $ime_procesatemp)
	IFS=" " read -r -a tab_pidof <<< $str_pidof
	
	for pid in "${tab_pidof[@]}"; do
		#echo "$(ps -o ppid= $pid)--------""$BASHPID"
		if [[ $(ps -o ppid= $pid) -eq "$BASHPID" ]]; then #||  ! [[ $temp -eq $pid_opsredje ]]; then
			#echo "$imeprocesa1....$(cat /proc/$pid/cmdline)"

			if [ "$imeprocesa1" = "$(cat /proc/$pid/cmdline)" ]; then	
				potrebovani=$(($potrebovani+1))		
			fi
		fi

		for pid1 in "${pid_tab[@]}"; do
			if [ "$pid" = "$pid1" ]; then
				let potrebovani=potrebovani+1
		fi
		done
	
	done #///for
	

	if [ $potrebovani -lt $st ]; then    #pregledam če je podanih dovolj
		exec $ime_procesa &	
		#echo "NAREDIM NOVGA, mam$postrbovani, rabm$st"		
	fi

	let potrebovani=0	
	done #Konec infiniteloopa#2

}



#glavna funckija za ukaz PROC
function f_proc(){
	already_running=""
	napaka1=false
	napaka2=false
	dolzina=${#input[@]}
	matching_error="PID matching error:"
	i=2
	k=2					#prva je proc drugi zapis pa je stevilo instanc zato grem na 3.ga
	napaka=false
	pid_ospredje=$BASHPID	
	vsi=""
	
	vsi_zanapako=""

	for((;$i<$dolzina;i++))
	do
	vsi_zanapako="$vsi_zanapako${input[$i]},"

	


	if [ -f "/proc/${input[$i]}/cmdline" ] && [ $napaka1 == false ]; then
		
		#kanonicna pot
		kanon=$(readlink -f /proc/${input[$i]}/exe)
		argumenti=$(cat /proc/${input[$i]}/cmdline | tr "\0" " " | cut -d " " -f 2- -s)

		#ime procesa
		ime_procesa=$(xargs -0 < /proc/"${input[$i]}"/cmdline)
		IFS=' ' read -r -a ime_procesa_noarg <<< "$ime_procesa"
			#echo "ime itega procesa: $ime_procesa_noarg::$ime_procesa"
		imeprocesa1=$(cat < /proc/"${input[$i]}"/cmdline)      #imeprocesa1 IN NE ime_procesa1 nevem zakaj sem tako butasto poimenoval....
			
		IFS="-" read -r -a ime_procesatemp <<< $ime_procesa
		#echo $ime_procesatemp	
		ime_procesatab="$ime_procesatab$ime_procesa*"
		
		#procesor PID
		proc_pid=$(pidof $ime_procesatemp)

		
		#matching error
		osnova_pom=$(cat /proc/${input[$k]}/cmdline)	
		next_pom=$(cat /proc/${input[$i]}/cmdline)

		IFS='/ ' read -r -a osnova <<< "$osnova_pom";IFS='/ ' read -r -a next <<< "$next_pom" #Ce podamo /.-../.../... in pa xclock da dela normalno
		vsi_brezvejce="$vsi_brezvejce ${input[$i]}"
		vsi="$vsi${input[$i]},"

		
		if [ "${osnova[-1]}" != "${next[-1]}" ]; then
			napaka=true
	
		fi		
		
	
	#če proces ne obstaja=napaka1 	
	else    
			
		napaka1=true			
	fi
		
	done

	


	#izpisovanje errorjev napak1=proces ne obstaja, napaka=procaesa se ne ujemata
	if [ $napaka1 == true ]; then
		echo "$matching_error ${vsi_zanapako::-1}" >&2 | cut -c 2-
	fi
	if [ $napaka == true ]; then
		echo "$matching_error ${vsi::-1}" >&2 | cut -c 2-
	fi
		
	if [ $napaka == false ] && [ $napaka1 == false ]; then
		


		#Confing already exists
		IFS="," read -r -a prc <<< ${input[@]:2:6}
	        for pp in "${prc[@]}"; do
			for tmp in "${!tvojlajf[@]}"; do
			    if [[ "$(ps -o ppid= "$pp")" -eq "$tmp" ]]; then
				echo "Run configuration already exists." >&2
				return 10
			    fi
			    IFS=" " read -r -a pidpid <<< "${tvojlajf[$tmp]}" #notranjo tabelo, sspremenim v tabelo
			    for i in "${pidpid[@]}"; do
				if [ "$pp" -eq "$i" ]; then  #tuki je za tisto zgoraj, če se proces nahaja v tabeli
				    echo "Run configuration already exists." >&2
				    return 10
				fi
			    done
			done
		   done	
		kontrola_proc &
		tvojlajf[$!]=${input[@]:2:6}	
	fi
	


}




function f_loglast(){


		if [ $napaka1 == true ]; then
			pid_log="${vsi_zanapako::-1}"	

		elif [ $napaka == true ]; then
			pid_log="${vsi::-1}"
		else
			pid_log=$(pidof $ime_procesatemp)
		fi
	
		kanon="$kanon $argumenti" 
		echo "$(date +%s%3N)" >> active.log    #crkne Pravilno beleženje novega PID-a
		echo "${kanon::-1}" >> active.log    #ne dela geslo
	        echo "$pid_log" >> active.log
	

}



function f_log(){
	echo "$(date +%s%3N)" >> active.log 
	
	if ! [ -f "active.log" ]; then
		touch "active.log"
	fi

	if [ $napaka1 == true ]; then
		pid_log="${vsi_zanapako::-1}"	

	elif [ $napaka == true ]; then
		pid_log="${vsi::-1}"
	else
		IFS='*' read -r -a imeproctab1 <<< "$ime_procesatab"
		for ena in "${!tvojlajf[@]}"; do
			for dva in "${tvojlajf[$ena]}"; do
				if [ -f "/proc/$dva/cmdline" ] && [ $dva != " " ]; then
	    				pid_log="$pid_log$dva,"
					kanon=$(readlink -f /proc/$dva/exe)
					argumenti=$(cat /proc/$dva/cmdline | tr "\0" " " | cut -d " " -f 2- -s)
					kanon="$kanon $argumenti" 
				fi
			done	
			#kanon=$(echo "${kanon%?}")	
			if ! [ ${#kanon} -lt 1 ]; then
				echo "${kanon::(-1)}" >> active.log
		
				echo "${pid_log::-1}" >> active.log
				pid_log=""
				ime=""
				kanon=""
			fi
		done
	fi
	
	
	pid_log=""
	#ime=""
}


function f_stop() {

	for ena in "${!tvojlajf[@]}"; do
		kill -9 $ena	

	done

}




function f_exit() {

	
	pid123=$(ps -o pgid= $$ | grep -o [0-9]*)
	if ! [ $pid123 -eq 1 ];then
 	 	kill -- -$pid123
 	fi
 	#exit 0

	#echo "umri kurba  "
	kill -9 $$
	

}








while [ true ]
do


if ! [ -p $cev ]; then
	echo "error 10: cev je zaprta"    
	exit 10
fi

	if read var; then	
	IFS=':, ' read -r -a input <<< "$var"

	if [ "${input[0]}" == "proc" ]; then	       #input proc
		f_proc 
	  	
	fi
	
	if [ "$var" == "log last"  ]; then               #input Log
		f_loglast

	fi


	if [ "${input[0]}" == "log"  ]; then               #input Log
		f_log
		#echo "log"
	fi

	if [ "${input[0]}" == "stop" ];then             #input stop
		f_stop
		#echo "Stop"
	fi
	

	
	if [ "$var" == "exit" ]; then            #input exit
		f_exit
	fi	

	fi
	
	
	
	
done < $cev  #infinite while



exit 0
