#!/usr/bin/env python

import scipy as sp
import cgi
import cx_Oracle

def main(): #NEW
    #form = cgi.FieldStorage()
    #theStr = form.getfirst('theList', '')
    contents = processInput()
    print contents

def processInput(): #This function extracts data from a Oracle table
    con = cx_Oracle.connect('DAISY/"62368102Dc"')
    cur = con.cursor()
    aaList = ['A', 'C', 'G','T', 'GC']
    fList = [() for t in range(5)]
    for i in range(5):
        myDict = {'aa':aaList[i]}
        obj = cur.execute('''select gi, freq_%(aa)s from beeGenes, (select max(freq_%(aa)s)
                    as max%(aa)s from beeGenes) where freq_%(aa)s = max%(aa)s''' % myDict)
        for x in obj:
            fList[i] = x

    myTuple =()
    for t in range(5):
        myTuple = myTuple + fList[t]

    cur.close()
    con.close()
    
    return makePage('see_result_template.html', myTuple)

def fileToStr(fileName):
    '''Return a string containing the contents of the named file.'''
    fin = open(fileName);
    contents = fin.read();
    fin.close()
    return contents

def makePage(templateFileName, substitutions):
    '''Make the final formatted string for displaying on a web page'''
    pageTemplate = fileToStr(templateFileName)
    return pageTemplate % substitutions

try:
    print "Content-type: text/html\n\n"
    main()
except:
    cgi.print_exception()
