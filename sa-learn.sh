#!/bin/bash

###########################################################
# CONFIG
###########################################################

#logging on host
LOG=/data/log/sa-learn.log

#mail root directory 
MAILDIR=/data/domains

#directory where bayes_tok is stored
DBDIR=/tmp/.spamassassin

###########################################################

echo "====== `date` $THIS $* started" >> $LOG

#create db path if not existing
mkdir -p $DBDIR

#DELETE BAYES DATABASE
###echo "deleting database" >> $LOG
###sa-learn --dbpath "$DBDIR" --clear >> $LOG

#HAM - TODO remove inbox from ham ?
find $MAILDIR -type d \( -name "new" -or -name "cur" \) -not -name ".Trash" -not -iwholename "*junk*" -not -iwholename "*spam*" -exec echo "HAM:{}" \; -exec sa-learn --dbpath "$DBDIR" --ham "{}" \; >> $LOG

#SPAM
find "$MAILDIR" -type d \( -name "new" -or -name "cur" \) -not -wholename "*.Trash*" \( -wholename "*.Junk*" -or -wholename "*SPAM*" \) -exec echo "SPAM:{}" \; -exec sa-learn --dbpath "$DBDIR" --spam "{}" \; >> $LOG

#create journal if not exists
touch "$DBDIR/bayes_journal"

#set owner of database files
chown -R smtpd.smtpd "$DBDIR"

#DUMP
sa-learn --dbpath "$DBDIR" --dump magic >> $LOG

echo "====== `date` $THIS $* completed" >> $LOG

