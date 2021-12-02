import os
import pickle
import math
import copy
import nltk
from nltk.tokenize import word_tokenize
import csv
import sys

nltk.download('punkt')

PATH_data = sys.argv[1]
PATH_pth = sys.argv[2]
PATH_query = sys.argv[3]

dbfile = open(PATH_pth, 'rb')     
newdict = pickle.load(dbfile)
dbfile.close

total_num = len(newdict.keys())

name_to_num = {}
num_to_name = {}
index = 0
for x in newdict.keys():
    name_to_num[x] = index
    num_to_name[index] = x
    index += 1

num_document = 0
document_vectors = {}

for dirname in os.listdir(PATH_data):
    for filename in os.listdir(os.path.join(PATH_data,dirname)):
        num_document += 1
        document_vectors[filename] = {}

for key in newdict.keys():
    pos = name_to_num[key]
    for temp in newdict[key]:
        try:
            document_vectors[temp[0]][pos] = temp[1]
        except KeyError:
            print(keyError)

query_file=open(PATH_query)
lines = query_file.readlines()

query_vectors = {}
queries = {}
queries[''] = 'Average'
for line in lines:
    
    line_list = line.split(',');
    query_id = line_list[0]
    queries[query_id] = line_list[1]
    words = word_tokenize(line_list[1])
    query_vectors[query_id] = {}
    
    for key in words:
        if key in name_to_num:
            pos = name_to_num[key]
            query_vectors[query_id][pos]=1   

def Sort(sub_li):
    sub_li.sort(key = lambda x: x[1],reverse=True)
    return sub_li

# ltc.lnc Scheme
document_vectors1 = copy.deepcopy(document_vectors)
query_vectors1 = copy.deepcopy(query_vectors)

for x in document_vectors1:
    for y in document_vectors1[x]:
        document_vectors1[x][y]= 1+math.log(document_vectors1[x][y],10)  #(1 +log(tf))*1  --> ln

        
for x in query_vectors:
    for y in query_vectors[x]:
        #(1+log(tf))*log(N/df) -->lc
        query_vectors1[x][y]=(1+math.log(query_vectors1[x][y],10))*math.log(num_document/len(newdict[num_to_name[y]]),10)
        
priority_list=[]
ranked_list_A={}
for x in query_vectors1:
    #print(queryVectors1[x])
    query_norm=0
    for y in query_vectors1[x]:
        query_norm+=query_vectors1[x][y]*query_vectors1[x][y]
    query_norm=math.sqrt(query_norm) 
    
    for dv in document_vectors1:
        val=0
        for pos in query_vectors1[x]:
            if pos in document_vectors1[dv]:
                val+=query_vectors1[x][pos]*document_vectors1[dv][pos]
        doc_norm=0
        for y in document_vectors1[dv]:
            doc_norm+=document_vectors1[dv][y]*document_vectors1[dv][y]
        doc_norm=math.sqrt(doc_norm)
        #print(val/(doc_norm*query_norm))
        if doc_norm!=0 and query_norm!=0:
            priority_list.append([dv,val/(doc_norm*query_norm)])
    Sort(priority_list)
    ranked_list_A[x]=priority_list[:50]
    priority_list.clear()

#Lnc.Lpc
document_vectors2 = copy.deepcopy(document_vectors)
query_vectors2 = copy.deepcopy(query_vectors)

for x in document_vectors2:
    total_freq = 0
    count = 0
    for y in document_vectors2[x]:
        count += 1
        total_freq += document_vectors2[x][y]
    for y in document_vectors2[x]:
        #(1 +log(tf))/(1+log(avg(tf)))  --> Ln
        document_vectors2[x][y]=(1+math.log(document_vectors2[x][y],10))/(1+math.log(total_freq/count,10))  

        
for x in query_vectors2:
    total_freq = 0
    count = 0
    for y in query_vectors2[x]:
        count += 1
        total_freq += query_vectors2[x][y]
    for y in query_vectors2[x]:
        #(1+log(tf))*log(N/df) -->Lp
        query_vectors2[x][y]=((1+math.log(query_vectors2[x][y],10))/(1+math.log(total_freq/count,10)))*max(0,math.log(num_document-len(newdict[num_to_name[y]])/(len(newdict[num_to_name[y]]))))
        

priority_list = []
ranked_list_B = {}
for x in query_vectors2:
    query_norm = 0
    for y in query_vectors2[x]:
        query_norm += query_vectors2[x][y]*query_vectors2[x][y]
    query_norm = math.sqrt(query_norm) 
    
    for dv in document_vectors2:
        val=0
        for pos in query_vectors2[x]:
            if pos in document_vectors2[dv]:
                val += query_vectors2[x][pos] * document_vectors2[dv][pos]
        doc_norm = 0
        for y in document_vectors2[dv]:
            doc_norm += document_vectors2[dv][y] * document_vectors2[dv][y]
        doc_norm = math.sqrt(doc_norm)
        #print(val/(doc_norm*query_norm))
        if doc_norm != 0 and query_norm != 0:
            priority_list.append([dv,val/(doc_norm*query_norm)])
    Sort(priority_list)
    ranked_list_B[x]=priority_list[:50]
    priority_list.clear()

#anc.apc
document_vectors3 = copy.deepcopy(document_vectors)
query_vectors3 = copy.deepcopy(query_vectors)

for x in document_vectors3:
    max_freq=0
    for y in document_vectors3[x]:
        max_freq=max(max_freq, document_vectors3[x][y])
        
    for y in document_vectors3[x]:
        #(0.5+(0.5*tf)/maximum(tf))  --> an
        document_vectors3[x][y]=(0.5+(0.5*document_vectors3[x][y])/max_freq)  

        
for x in query_vectors3:
    max_freq=0
    for y in query_vectors3[x]:
        max_freq=max(max_freq,query_vectors3[x][y])
        
    for y in query_vectors3[x]:
        #(0.5+(0.5*tf)/maximum(tf))*max(0,log((N-df)/df))  --> ap
        query_vectors3[x][y]=(0.5+(0.5*query_vectors3[x][y])/max_freq)*max(0,math.log(num_document-len(newdict[num_to_name[y]])/(len(newdict[num_to_name[y]]))))


priority_list=[]
ranked_list_C={}
for x in query_vectors3:
    query_norm=0
    for y in query_vectors3[x]:
        query_norm+=query_vectors3[x][y]*query_vectors3[x][y]
    #query_norm=math.sqrt(query_norm) 
    
    for dv in document_vectors3:
        val=0
        idf=max(0,math.log(num_document-len(newdict[num_to_name[y]])/(len(newdict[num_to_name[y]]))))
        
        for pos in query_vectors3[x]:
            if pos in document_vectors3[dv]:
                val+=query_vectors3[x][pos]*document_vectors3[dv][pos]
            else:
                val+=query_vectors3[x][pos]*0.5
        query_norm=math.sqrt(query_norm)
        count=0        
        doc_norm=0
        for y in document_vectors3[dv]:
            doc_norm+=document_vectors3[dv][y]*document_vectors3[dv][y]
            #count+=1
        doc_norm=math.sqrt(doc_norm+(total_num-len(document_vectors3[dv]))*0.25)
        if doc_norm!=0 and query_norm!=0:
            priority_list.append([dv,val/(doc_norm*query_norm)])
    Sort(priority_list)
    ranked_list_C[x]=priority_list[:50]
    priority_list.clear()

csv_file = open("PAT2_13_ranked_list_A.csv", "w")
writer = csv.writer(csv_file)
writer.writerow(['Query_ID', 'Document_ID'])
for key in ranked_list_A:
    for val in ranked_list_A[key]:
        writer.writerow([key, val[0]])
csv_file.close()                       

csv_file = open("PAT2_13_ranked_list_B.csv", "w")
writer = csv.writer(csv_file)
writer.writerow(['Query_ID', 'Document_ID'])
for key in ranked_list_B:
    for val in ranked_list_B[key]:
        writer.writerow([key, val[0]])
csv_file.close()

csv_file = open("PAT2_13_ranked_list_C.csv", "w")
writer = csv.writer(csv_file)
writer.writerow(['Query_ID', 'Document_ID'])
for key in ranked_list_C:
    for val in ranked_list_C[key]:
        writer.writerow([key, val[0]])
csv_file.close()