#!/bin/bash
###########################################################
# Load all mails into Bayes database:
# HAM = all boxes except inbox, trash, *spam*, *junk*
# SPAM = boxes *spam*, *ham*
###########################################################

###########################################################
# CONFIG
###########################################################

#mail root directory 
MAILDIR=/data/domains

#directory where bayes_tok is stored
DBDIR=/tmp/.spamassassin

###########################################################

echo "====== `date` $THIS $* started" 

#create db path if not existing
mkdir -p $DBDIR

#DELETE BAYES DATABASE
###echo "deleting database" 
###sa-learn --dbpath "$DBDIR" --clear 

#HAM - TODO remove inbox from ham ?
find "$MAILDIR" -type d \( -path "*/.*/cur" -or -path "*/.*/new" \) \
  -not -ipath "*trash*" -not \( -ipath "*spam*" -or -ipath "*junk*" \) \
  -exec echo "HAM:{}" \; -exec sa-learn --dbpath "$DBDIR" --ham "{}" \;  

#SPAM
find "$MAILDIR" -type d \( -path "*/.*/cur" -or -path "*/.*/new" \) \
  -not -ipath "*trash*" \( -ipath "*spam*" -or -ipath "*junk*" \) \
  -exec echo "SPAM:{}" \; -exec sa-learn --dbpath "$DBDIR" --spam "{}" \; 

#create journal if not exists
touch "$DBDIR/bayes_journal"

#set owner of database files
chown -R smtpd.smtpd "$DBDIR"

#DUMP
sa-learn --dbpath "$DBDIR" --dump magic 

echo "====== `date` $THIS $* completed"


