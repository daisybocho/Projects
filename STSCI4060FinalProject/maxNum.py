infile=file('honeybee_gene_sequences.txt','r')
myStr = ""
finalStr = ''

#form a string with the raw data
for aline in infile:
    if aline.startswith('>gi|'):
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

seqlen = []
#find list of sequence length
for i in range(repetitions):
    start = finalStr.find('_**gene_seq_starts_here**_',end) +26
    end = finalStr.find('gi|',start)
    #d
    if end == -1:
        end = totalLength
    seq = finalStr[start:end]
    #print 'seq=', seq
    seqLength = len(seq)
    seqlen.append(seqLength)

maxNumseq = max(seqlen)

print maxNumseq

