import os
import pickle
import math
import copy
import nltk
from nltk.tokenize import word_tokenize
import csv
import sys
import pandas as pd

PATH_relevant = sys.argv[1] 
PATH_rankedlist = sys.argv[2]
PATH_query = sys.argv[3]

query_file=open(PATH_query)
lines = query_file.readlines()
queries = {}
queries[''] = ''
for line in lines:
    line_list = line.split(',');
    query_id = line_list[0]
    queries[query_id] = line_list[1]

file_name = PATH_relevant
xl_file = pd.read_csv(file_name)

relevant = {}
for index, row in xl_file.iterrows():   
    Query_ID, Document_ID, Relevance_Score, = str(row['Query_ID']), str(row['Document_ID']), int(row['Relevance_Score'])
    if Query_ID not in relevant:
        relevant[Query_ID] = {}    
    relevant[Query_ID][Document_ID] = Relevance_Score

def evaluate(ranked_list, relevant, write_file = False, file_name=None):       
    mAP_10, mAP_20 = 0.0, 0.0
    averNDCG_10, averNDCG_20 = 0.0, 0.0 
    ap_10, ap_20, query_id = [], [], []
    query = []
    ndcg_10, ndcg_20 = [], []
      
    for key in ranked_list:       
        query_id.append(key)        
        if key not in relevant:
            # print("key: ", key + ", Data Not provided!")           
            ap_10.append(0)
            ap_20.append(0)
            ndcg_10.append(0)
            ndcg_20.append(0)            
        else:
            count = 0
            score = 0.0
            relevant_count = 0
            dcg_i = 0.0
            Query_ID = key
            NDCG = []            
            for doc in ranked_list[Query_ID]:
                if doc[0] in relevant[Query_ID]:
                    NDCG.append(relevant[Query_ID][doc[0]])
                else:
                    NDCG.append(0)

            NDCG.sort()
            NDCG.reverse()           
            for i in range(1, len(NDCG)):
                NDCG[i] = NDCG[i-1] + NDCG[i]/math.log(i+1, 10)
                
            for doc in ranked_list[key]:
                count += 1
                if doc[0] in relevant[key]:
                    relevant_count += 1
                    if count == 1:
                        dcg_i += relevant[Query_ID][doc[0]] 
                    else:
                        dcg_i += (relevant[Query_ID][doc[0]] / math.log(count, 10)) 
                score += (relevant_count / count)
                if count == 10:
                    # print(key, "Average @10: ", score/10)
                    ndcg_val = NDCG[count-1]
                    if ndcg_val == 0:
                        ndcg_val = 1
                    # print(key, "NDCG @10: ", dcg_i/ndcg_val)                    
                    ap_10.append(score/10)
                    ndcg_10.append(dcg_i/ndcg_val)                    
                    mAP_10 += score/10
                    averNDCG_10 += dcg_i/ndcg_val                    
                if count == 20:                    
                    ndcg_val = NDCG[count-1]
                    if ndcg_val == 0:
                        ndcg_val = 1
                    
                    # print(key, "Average @20: ", score/20)
                    # print(key, "NDCG @20: ", dcg_i/ndcg_val)
                    mAP_20 += score/20
                    averNDCG_20 += dcg_i/ndcg_val
                    ap_20.append(score/20)
                    ndcg_20.append(dcg_i/ndcg_val)
                    break
    #     print("________________________________")
    # print(":::Average Values:::")
    m = len(ranked_list)
    # print("mAP@10: ", mAP_10/m)
    # print("mAP@20: ", mAP_20/m)
    # print("averNDCG@10: ", averNDCG_10/m)
    # print("averNDCG@20: ", averNDCG_20/m)    
    query_id.append('')
    ap_10.append(mAP_10/m)
    ap_20.append(mAP_20/m)
    ndcg_10.append(averNDCG_10/m)
    ndcg_20.append(averNDCG_20/m)
               
    if not write_file:
        return
    
    with open(file_name, "w") as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        writer.writerow(['query_id', 'query','AP@10', 'AP@20', 'NDCG@10', 'NDCG@20'])
        for i in range(0, len(query_id)):
            writer.writerow([query_id[i], queries[query_id[i]], ap_10[i],ap_20[i], ndcg_10[i], ndcg_20[i]])


file_name_ranked = PATH_rankedlist
rank_file = pd.read_csv(file_name_ranked)

ranked_list={}
for index, row in rank_file.iterrows():
    Query_ID, Document_ID = str(row['Query_ID']), str(row['Document_ID'])
    if Query_ID in ranked_list.keys():
        ranked_list[Query_ID].append([Document_ID])
    else:
        ranked_list[Query_ID]=[]
        ranked_list[Query_ID].append([Document_ID])

if PATH_rankedlist == 'PAT2_13_ranked_list_A.csv':
	evaluate(ranked_list, relevant, True, 'PAT2_13_metrics_A.csv')
elif PATH_rankedlist == 'PAT2_13_ranked_list_B.csv':
	evaluate(ranked_list, relevant, True, 'PAT2_13_metrics_B.csv')
else:
	evaluate(ranked_list, relevant, True, 'PAT2_13_metrics_C.csv')