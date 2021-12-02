import os
import pickle
import math
import copy
import nltk
from nltk.tokenize import word_tokenize
import csv
import pandas as pd
import sys

nltk.download('punkt')

PATH_data = sys.argv[1]
PATH_pth = sys.argv[2]
PATH_ranked = sys.argv[3]

dbfile = open(PATH_pth, 'rb')
inverted_index = pickle.load(dbfile)
dbfile.close

num_keys = len(inverted_index.keys())
name_to_num = {}
num_to_name = {}
for (index, key) in enumerate(inverted_index.keys()):
    name_to_num[key] = index
    num_to_name[index] = key

num_document = 0
document_vectors = {}

for dirname in os.listdir(PATH_data):
    for filename in os.listdir(os.path.join(PATH_data, dirname)):
        num_document += 1
        document_vectors[filename] = {}


for key in inverted_index.keys():
    pos = name_to_num[key]
    for (document, freq) in inverted_index[key]:
        document_vectors[document][pos] = freq

for document_id in document_vectors:
    for term in document_vectors[document_id]:
        document_vectors[document_id][term] = 1 \
            + math.log(document_vectors[document_id][term], 10)


columns = ['query_id', 'document_id']
df = pd.read_csv(PATH_ranked, header=None,names=columns)


ranked_list = {}
for (index, row) in df.iterrows():
    (query_id, document) = (row['query_id'], row['document_id'])
    if query_id == 'Query_ID':
        continue
    query_id= int(query_id)
    if query_id not in ranked_list:
        ranked_list[query_id] = []
    if len(ranked_list[query_id]) < 20:
        ranked_list[query_id].append(document)


def modulus(vector):
    '''
    input:: 
             vector: dictionary
    output:
             |vector|: float32
    '''
    res = 0.
    for key in vector:
        res += vector[key] * vector[key]
    res = math.sqrt(res)
    return res


vocab_size = len(inverted_index.keys())
names = {}
for query_id in ranked_list.keys():
    top_ten=ranked_list[query_id][:10]
    vec = [0 for i in range(vocab_size)]
    for doc_name in top_ten:
        mod_val=modulus(document_vectors[doc_name])
        for key,value in document_vectors[doc_name].items():
            vec[key]+=value/mod_val
    lst = []
    for i in range(vocab_size):
        lst.append([i,vec[i]])
    lst.sort(key = lambda x: x[1],reverse = True)
    names[query_id]=[]
    for i in range(5):
        names[query_id].append(num_to_name[lst[i][0]])


file_name = 'PB_13_important_words.csv'
with open(file_name, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow(['Query_ID','Words',])


with open(file_name, 'a') as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
#     printing in the file
    for key in names:
        s=[]
        for val in names[key]:
            s.append(val)
        writer.writerow([key,s])