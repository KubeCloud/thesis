#!/bin/bash
for i in "$@"
do
case $i in
    -h=*|--host=*)
    HOST="${i#*=}"
    ;;
    -r=*|--rate=*)
    RATE="${i#*=}"
    ;;
    *)
            # unknown option
    ;;
esac
done
if [ -z "$HOST" ]
  then
    echo "Host and rate required."
  else
	HOST0=$HOST:9000
	HOST1=$HOST:9001
	HOST2=$HOST:9002
	DELAYHOST1=0
	DELAYHOST2=15000
	RESULTS=10
	DURATION=30s
	TIMEOUTHOST0=1000
	TIMEOUTHOST1=1000
	curl $HOST0/circuitbreaker/enabled/true
	curl $HOST0/circuitbreaker/timeout/${TIMEOUTHOST0}
	curl $HOST0/fallbackenabled/true
	curl $HOST0/resultset/$RESULTS
	curl $HOST1/circuitbreaker/enabled/true
	curl $HOST1/circuitbreaker/timeout/${TIMEOUTHOST1}
	curl $HOST1/fallbackenabled/true
	curl $HOST1/resultset/$RESULTS
	curl $HOST1/delay/$DELAYHOST1
	curl $HOST2/resultset/$RESULTS
	curl $HOST2/delay/$DELAYHOST2

	echo SETUP DONE - Circuitbreakers, fallbacks, $DELAYHOST2 ms delayhost2, $RESULTS results, $RATE rate, $DURATION duration
	echo STARTING TEST
	NOW=$(date "+%m-%d_%H-%M-%S")
	DIR=4_cb_3svc_delay_${NOW}_d${DELAYHOST2}_r${RESULTS}_h${HOST}_rate${RATE}
	mkdir $DIR
	echo "GET http://"$HOST0"/resources" | vegeta attack -duration=${DURATION} -rate=$RATE | tee $DIR/results.bin | vegeta report
	echo "New directory with output: " $DIR
	vegeta report -inputs=$DIR/results.bin -reporter=json > $DIR/metrics.json
	vegeta report -inputs=$DIR/results.bin -reporter=plot > $DIR/plot.html
	vegeta report -inputs=$DIR/results.bin -reporter=text > $DIR/text.txt
	vegeta report -inputs=$DIR/results.bin -reporter="hist[0,100ms,200ms,300ms]" > $DIR/hist.txt
	vegeta dump -inputs=$DIR/results.bin -dumper=json > $DIR/dump.json
	vegeta dump -inputs=$DIR/results.bin -dumper=csv > $DIR/dump.csv
fi