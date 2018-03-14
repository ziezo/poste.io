#!/bin/bash
###########################################################
# Load all mails into Bayes database:
# HAM = all boxes except inbox, trash, *spam*, *junk*
# SPAM = boxes *spam*, *ham*
###########################################################

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
###sa-learn --dbpath "$DBDIR" --clear 2>&1 >> $LOG

#HAM - TODO remove inbox from ham ?
find "$MAILDIR" -type d \( -path "*/.*/cur" -or -path "*/.*/new" \) -not -ipath "*trash*" -not \( -ipath "*spam*" -or -ipath "*junk*" \) -exec echo "HAM:{}" \; -exec sa-learn --dbpath "$DBDIR" --ham "{}" \; 2>&1 >> $LOG 

#SPAM
find "$MAILDIR" -type d \( -path "*/.*/cur" -or -path "*/.*/new" \) -not -ipath "*trash*" \( -ipath "*spam*" -or -ipath "*junk*" \) -exec echo "SPAM:{}" \; -exec sa-learn --dbpath "$DBDIR" --spam "{}" \; >> 2>&1 $LOG

#create journal if not exists
touch "$DBDIR/bayes_journal"

#set owner of database files
chown -R smtpd.smtpd "$DBDIR"

#DUMP
sa-learn --dbpath "$DBDIR" --dump magic 2>&1 >> $LOG

echo "====== `date` $THIS $* completed" >> $LOG


