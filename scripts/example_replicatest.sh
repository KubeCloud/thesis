#!/bin/bash

for i in "$@"
do
case $i in
    -h=*|--host=*)
    HOST="${i#*=}"
    ;;
    *)
            # unknown option
    ;;
esac
done


if [ -z "$HOST" ]
  then
    echo "One argument required. Examples:"
  else
  	rates=(100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000)
    requests=10000
    duration=5s
    filename="replicas_1"

	   echo
	echo 
	echo SETUP DONE

	echo STARTING TEST

	NOW=$(date "+%y-%m-%d_%H-%M-%S")
	DIR=${filename}_${NOW}
	mkdir $DIR

	for j in $(seq 0 2); do
    echo ITERATION ${j}
		for i in $(seq 0 `expr ${#rates[@]} - 1`); do

        current_rate=${rates[$i]}
        current_duration=`echo "($requests + $current_rate-1)/$current_rate" | bc`

        echo
        echo Starting test with duration: $current_duration seconds and rate: $current_rate req/sec
  			echo "GET http://"$HOST"" | vegeta attack -rate="$current_rate" -duration="${current_duration}s" | tee $DIR/rate_${rates[$i]}-${j}.bin | vegeta report
		done
    echo ITERATION ${j}: Done - sleeping 1 minute
    sleep 30s
	done
fi

