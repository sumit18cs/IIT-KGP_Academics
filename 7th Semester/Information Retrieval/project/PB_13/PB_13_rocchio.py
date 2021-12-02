import os
import pickle
import math
import copy
import nltk
from nltk.tokenize import word_tokenize
import csv
import sys
import pandas as pd
nltk.download('punkt')

PATH_data = sys.argv[1]
PATH_pth = sys.argv[2]
PATH_relevant = sys.argv[3]
PATH_ranked = sys.argv[4]
PATH_query = sys.argv[5]

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

query_file = open(PATH_query)
lines = query_file.readlines()
query_vectors = {}
for line in lines:
    line_list = line.split(',')
    query_id = int(line_list[0])
    words = word_tokenize(line_list[1])
    query_vectors[query_id] = {}
    for key in words:
        if key in name_to_num:
            pos = name_to_num[key]
            query_vectors[query_id][pos] = 1

for query_id in query_vectors:
    for term in query_vectors[query_id]:
        temp1 = 1 + math.log(query_vectors[query_id][term], 10)
        temp2 = math.log(num_document
                         / len(inverted_index[num_to_name[term]]), 10)
        query_vectors[query_id][term] = temp1 * temp2

file_name = PATH_relevant
xl_file = pd.read_csv(file_name)
relevant = {}
for index, row in xl_file.iterrows():  
    query_id, document_id, score, = int(row['Query_ID']), str(row['Document_ID']), int(row['Relevance_Score'])
    if query_id not in relevant:
        relevant[query_id] = {}     
    relevant[query_id][document_id] = score

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


def add(vector1, vector2):
    '''
    input:: 
             vector1: dictionary
             vector2: dictionary
    output::
             vector1 + vector2
    '''
    vector = {}
    for key in vector1:
        vector[key] = 0.
    for key in vector2:
        vector[key] = 0.

    for key in vector1:
        vector[key] = vector1[key]

    for key in vector2:
        vector[key] += vector2[key]

    return vector


def multiply(_vector, val):
    '''
    input:: 
             _vector: dictionary
             val: float32
    output::
             _vector * val
    '''
    if val == 0:
        return {}
    vector = copy.deepcopy(_vector)
    for key in vector:
        vector[key] *= val
    return vector

def add_feedback_to_query(_query_vectors,document_vectors,ranked_list,params,relevant,):
    '''
    description:: 
                  takers query_vector and add relevant feedback w.r.t relevant --
                  which is a dictionary and relevant[query_id] contains relevant
                  documents for query_id
    input:: 
                  _query_vectors: dictionary
                  document_vectors: dictionary
                  ranked_list: dictionary
                  params: dictionary
                  relevant: dictionary
            
    output::
                  modified query_vectors
    '''
    query_vectors = copy.deepcopy(_query_vectors)
    (alpha, beta, gamma) = (params['alpha'], params['beta'],
                            params['gamma'])
    # print (params)
    for query_id in query_vectors:
        (count_r, count_nr) = (0., 0.)
        (centroid_r, centroid_nr) = ({}, {})
        query_vector = query_vectors[query_id]

        if query_id not in relevant:
            continue

        for document_id in ranked_list[query_id]:
            if document_id in relevant[query_id]:
                count_r += 1
                centroid_r = add(centroid_r,
                                 document_vectors[document_id])
            else:
                centroid_nr = add(centroid_nr,
                                  document_vectors[document_id])
                count_nr += 1

        query_vector = multiply(query_vector, alpha)

        if count_r != 0:
            centroid_r = multiply(centroid_r, beta / count_r)
        if count_nr != 0:
            centroid_nr = multiply(centroid_nr, -gamma / count_nr)

        query_vectors[query_id] = add(add(query_vector, centroid_r), centroid_nr)

    return query_vectors

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

def dot(vector1, vector2):
    
    '''
    input:: 
             vector1: dictionary
             vector2: dictionary
    output:
             vector1 . vector2: float32
    '''
    res = 0.
    
    for k1 in vector1:
        if k1 in vector2:
            res += vector1[k1] * vector2[k1]
            
    return res


def retrive_ranked_list(query_vectors, document_vectors):
    '''
    description:: takes query_vectors and document_vectors and return ranked_list,
                  where ranked_list[query_id] contains a list of all relevant doc_id
    input:: 
                  query_vectors: dictionary
                  document_vectors: dictionary
    output::
                  ranked_list : dictionary
    '''

    priority_list = []
    ranked_list = {}

    for query_id in query_vectors:
        query_vector = query_vectors[query_id]
        query_mod = modulus(query_vector)

        for document_id in document_vectors:
            document_vector = document_vectors[document_id]
            doc_mod = modulus(document_vector)

            cos_value = dot(query_vector, document_vector)

            priority_list.append([document_id, cos_value / (doc_mod * query_mod)])

        priority_list.sort(key=lambda x: x[1], reverse=True)
        ranked_list[query_id] = priority_list[:50]
        priority_list.clear()

    return ranked_list


def RF(
    _query_vectors,
    _document_vectors,
    old_ranked_list,
    params,
    feedback_relevant_docs,
    ):

    query_vectors = copy.deepcopy(_query_vectors)
    document_vectors = copy.deepcopy(_document_vectors)

    query_vectors = add_feedback_to_query(query_vectors,
            document_vectors, old_ranked_list, params,
            feedback_relevant_docs)

    ranked_list = retrive_ranked_list(query_vectors, document_vectors)
    return ranked_list


def evaluate(
    ranked_list,
    relevant
    ):

    (mAP_10, mAP_20) = (0.0, 0.0)
    (averNDCG_10, averNDCG_20) = (0.0, 0.0)

    (ap_10, ap_20, query_id) = ([], [], [])
    query = []
    (ndcg_10, ndcg_20) = ([], [])

    for key in ranked_list:
        query_id.append(key)
        if key not in relevant:
            # print (str(key) + ':  Data Not provided!')
            ap_10.append(0)
        else:

            count = 0
            score = 0.0
            relevant_count = 0

            dcg_i = 0.0

            Query_ID = key
            NDCG = []

            for (doc, _) in ranked_list[Query_ID]:
                if doc in relevant[Query_ID]:
                    NDCG.append(relevant[Query_ID][doc])
                else:
                    NDCG.append(0)

            NDCG.sort()
            NDCG.reverse()

            for i in range(1, len(NDCG)):
                NDCG[i] = NDCG[i - 1] + NDCG[i] / math.log(i + 1, 10)

            for (doc, _) in ranked_list[key]:
                count += 1
                if doc in relevant[key]:
                    relevant_count += 1
                    if count == 1:
                        dcg_i += relevant[Query_ID][doc]
                    else:
                        dcg_i += relevant[Query_ID][doc] \
                            / math.log(count, 10)
                score += relevant_count / count
                if count == 20:
                    ndcg_val = NDCG[count - 1]
                    if ndcg_val == 0:
                        ndcg_val = 1
                    mAP_20 += score / 20
                    averNDCG_20 += dcg_i / ndcg_val
                    break
    m = len(ranked_list)
    return mAP_20 / m, averNDCG_20 / m

# relevant_documents[query_id] will store all document_ids
# whose relevant_score is 2 in golden output w.r.t query_id
'''
For Relevant Feedback Model
'''

relevant_documents = {}

for query_id in relevant:
    relevant_documents[query_id] = []
    for (doc_id, score) in relevant[query_id].items():
        if score == 2:
            relevant_documents[query_id].append(doc_id)

file_name = 'PB_13_rocchio_RF_metrics.csv'

with open(file_name, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow(['alpha','beta','gamma','mAP@20','NDCG@20',])


# part (a)
params = {'alpha': 1.0, 'beta': 1.0, 'gamma': 0.5}
feedback_ranked_list = RF(query_vectors, document_vectors, ranked_list,
                          params, relevant_documents)
map_20, ndcg_20 = evaluate(feedback_ranked_list, relevant)

with open(file_name, 'a') as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow([params['alpha'],params['beta'],params['gamma'],map_20,ndcg_20,])

# part (b)
params = {'alpha': 0.5, 'beta': 0.5, 'gamma': 0.5}
feedback_ranked_list = RF(query_vectors, document_vectors, ranked_list,
                          params, relevant_documents)

map_20, ndcg_20 = evaluate(feedback_ranked_list, relevant)

with open(file_name, 'a') as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow([params['alpha'],params['beta'],params['gamma'],map_20,ndcg_20,])


# part (c)
params = {'alpha': 1.0, 'beta': 0.5, 'gamma': 0.0}
feedback_ranked_list = RF(query_vectors, document_vectors, ranked_list,
                          params, relevant_documents)
map_20, ndcg_20 = evaluate(feedback_ranked_list, relevant)

with open(file_name, 'a') as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow([params['alpha'],params['beta'],params['gamma'],map_20,ndcg_20,])


# relevant_documents[query_id] will store all
# document_ids who are in top 10 in ranked_list

'''
For Relevant Feedback Model
'''

# We are taking gamma as 0.0 in all the cases
# as the set of NR documents in considered null

relevant_documents = {}

for query_id in relevant:
    relevant_documents[query_id] = []
    for (doc_id, score) in relevant[query_id].items():
        if len(relevant_documents[query_id]) < 10:
            relevant_documents[query_id].append(doc_id)

file_name = 'PB_13_rocchio_PsRF_metrics.csv'

with open(file_name, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow(['alpha','beta','gamma','mAP@20','NDCG@20',])

# part (a)
params = {'alpha': 1.0, 'beta': 1.0, 'gamma': 0.0}
feedback_ranked_list = RF(query_vectors, document_vectors, ranked_list,
                          params, relevant_documents)
map_20, ndcg_20 = evaluate(feedback_ranked_list, relevant)

with open(file_name, 'a') as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow([params['alpha'],params['beta'],str(0.5),map_20,ndcg_20,])

# part (b)
params = {'alpha': 0.5, 'beta': 0.5, 'gamma': 0.0}
feedback_ranked_list = RF(query_vectors, document_vectors, ranked_list,
                          params, relevant_documents)
map_20, ndcg_20 = evaluate(feedback_ranked_list, relevant)

with open(file_name, 'a') as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow([params['alpha'],params['beta'],str(0.5),map_20,ndcg_20,])

# part (c)
params = {'alpha': 1.0, 'beta': 0.5, 'gamma': 0.0}
feedback_ranked_list = RF(query_vectors, document_vectors, ranked_list,
                          params, relevant_documents)
map_20, ndcg_20 = evaluate(feedback_ranked_list, relevant)

with open(file_name, 'a') as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow([params['alpha'],params['beta'],str(0.0),map_20,ndcg_20,])