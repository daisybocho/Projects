#!/usr/bin/env python

import cgi
import cx_Oracle

def main(): #A: NEW
    form = cgi.FieldStorage()
    #theStr = form.getfirst('theList','')
    contents = processInput(form)
    print contents

def processInput(form):
    path = form['path'].value
    #B/g
    con = cx_Oracle.connect('DAISY/"62368102Dc"')
    cur = con.cursor()
    cur.execute('drop table beeGenes')
    #h
    cur.execute('''create table beeGenes (
                    gi varchar2(10),
                    sequence clob,
                    freq_A number,
                    freq_C number,
                    freq_G number,
                    freq_T number,
                    freq_GC number)''')
    #i
    cur.bindarraysize = 50
    #j: see maxNum.py for max seq size
    cur.setinputsizes(10,14440,float,float,float,float,float)
    #a: read raw data from a file
    infile=file(path,'r')
    myStr = ""
    finalStr = ''

    #form a string with the raw data
    for aline in infile:
        if aline.startswith('>gi|'):
            #b
            aline = aline +'_**gene_seq_starts_here**_'
        myStr = myStr + aline

    #form a continuous string
    strL=myStr.replace('\n','')

    #change the string into a list, one protein per list item
    aList = strL.split('>')


    #keep the list items that contains the substring, Apis mellifera    
    for anItem in aList:
        if 'Apis mellifera' in anItem:
            finalStr = finalStr +anItem
            

    end=0
    totalLength = len(finalStr)
    repetitions = finalStr.count('_**gene_seq_starts_here**_')

    #extract the target substrings, the gi number and the protein sequence
    for i in range(repetitions):

        #c
        start = finalStr.find('gi|', end) +3
        end = finalStr.find('|', start)
        gi = finalStr[start : end]
        #print 'gi= ', gi
        start = finalStr.find('_**gene_seq_starts_here**_',end) +26
        end = finalStr.find('gi|',start)
        #d
        if end == -1:
            end = totalLength
        seq = finalStr[start:end]
        #print 'seq=', seq
        seqLength = len(seq)
        #e
        freq_A = seq.count('A')/float(seqLength)
        freq_C = seq.count('C')/float(seqLength)
        freq_G = seq.count('G')/float(seqLength)
        freq_T = seq.count('T')/float(seqLength)
        #f
        freq_GC = seq.count('GC')/float(seqLength)



        cur.execute('''insert into beeGenes (gi, sequence, freq_A, freq_C, freq_G, freq_T, freq_GC) values(
                :v1,:v2,:v3,:v4,:v5,:v6,:v7)''',
                (gi, seq, freq_A, freq_C, freq_G, freq_T, freq_GC))

    con.commit()

    cur.close()
    con.close()
    
    return makePage('done_submission_Template.html', ("Thank you for uploading."))

def fileToStr(fileName):
    '''C: Return a string containing the contents of the named file.'''
    fin = open(fileName);
    contents = fin.read();
    fin.close()
    return contents

def makePage(templateFileName, substitutions):
    '''D: Make the final formatted string for displaying on a web page'''
    pageTemplate = fileToStr(templateFileName)
    return pageTemplate % substitutions

try:
    print "Content-type: text/html\n\n"
    main()
except:
    cgi.print_exception()
