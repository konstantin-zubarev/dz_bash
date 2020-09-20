#!/bin/bash
filename=/var/log/bash_access/access.log
result=/var/log/bash_access/result.log
runtime=/var/log/bash_access/runtime.log
temp=/var/log/bash_access/temp.log
error=/var/log/bash_access/error.log
lockfile=/tmp/localfile


process(){
if [ -f $temp ]; then
        process=$(cat $runtime | sed 's!/!\\/!g')
        starttime=$(cat $runtime | sed 's/\//\./g')
        sed -n "/${process}/,$ p" $filename > $temp
        tail -1 $temp | awk '{print $4}' | sed 's/\[//' > $runtime
        endtime=$(cat $runtime | sed 's/\//\./g')
else
        if [ -f $filename ]; then
                head -1 $filename | awk '{print $4}' | sed 's/\[//' > $runtime;
        else
                echo $(date  +%Y-%m-%d\ %H:%M:%S) no file access.log >> $error
                exit
        fi
        process=$(cat $runtime | sed 's!/!\\/!g')
        starttime=$(cat $runtime | sed 's/\//\./g')
        sed -n "/${process}/,$ p" $filename > $temp
        tail -1 $temp | awk '{print $4}' | sed 's/\[//' > $runtime
        endtime=$(cat $runtime | sed 's/\//\./g')
        echo $(date  +%Y-%m-%d\ %H:%M:%S) no file temp.log >> $error
fi
}

get_top_ip_active(){
	awk '{ ipcount[$1]++ } END { for (i in ipcount) { printf "IP:%16s - %d times\n", i, ipcount[i] } }' | sort -rnk 4 | head -5
}

get_top_url_address(){
	awk '{print $7}' | sort | uniq -cd | sort -nr | head -5 | awk '{print $1 " requests for: " $2}'
}

get_all_errors_code(){
	awk '{error[$9]++} END {for (i in error) { printf"errors with code:%5s - %d times\n", i, error[i] } }' | grep -E '(500|499|40.)' | sort -rn
}

get_all_code(){
        awk '{cod[$9]++} END {for (i in cod) { printf"HTTP status code:%4s - %d times\n", i, cod[i] } }' | sort -rn
}

result(){
	echo ++++++++++++++++++++++++++++++++++++++++++++++++
       	echo
	echo from $starttime before $endtime
	echo ------------------------------------------------
	echo TOP IP addressese
	echo ------------------------------------------------
	cat $temp | get_top_ip_active
	echo ------------------------------------------------
	echo Top URL s  address
	echo ------------------------------------------------
	cat $temp | get_top_url_address
	echo ------------------------------------------------
	echo All errors code:
	echo ------------------------------------------------
	cat $temp | get_all_errors_code
	echo ------------------------------------------------
	echo All return codes:
	echo ------------------------------------------------
	cat $temp | get_all_code
	echo *********************end************************
} >> $result

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then
    trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
    while true
    do
        process
	result
        exit
    done
   rm -f "$lockfile"
   trap - INT TERM EXIT
else
   echo "Failed to acquire lockfile: $lockfile."
   echo "Held by $(cat $lockfile)"
fi

