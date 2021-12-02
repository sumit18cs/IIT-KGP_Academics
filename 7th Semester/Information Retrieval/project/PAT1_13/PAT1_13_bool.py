import os
import nltk
from nltk import pos_tag
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet
from nltk.tokenize import RegexpTokenizer
from nltk.tokenize import word_tokenize
import pickle
import sys

PATH_pth = sys.argv[1]
PATH_query = sys.argv[2]

#load
dbfile = open(PATH_pth, 'rb')     
newdict = pickle.load(dbfile)
dbfile.close

with open(PATH_query, "rb") as f:
    query_data = f.read().decode("UTF-8")

query_ = query_data.split("\r\n")
# print(query_)

parsed_query_dic = {}
for line in query_:
    query_full = line.split(",")
    if len(query_full) > 1:
        try:
            diff_words = query_full[1].split(" ")
        except:
            pass
        parsed_query_dic[query_full[0]] = diff_words

def merge_list(list1, list2):
    n, m = len(list1), len(list2)
    i, j = 0, 0
    res = []
    while i < n and j < m:
        if list1[i] == list2[j]:
            res.append(list1[i])
            i += 1
            j += 1
        elif list1[i] < list2[j]:
            i += 1
        else:
            j += 1
    return res        

def get_list(token, newdict):
    curr = []
    try:
        curr = newdict[token]
    except:
        pass
    res = []
    for val in curr:
        res.append(val[0])
    return res

def get_results(parsed_query, inverted_index):
    '''
    INPUT: parsed_query_dic: dictionaries having quiries
           inverted_index: retrivied from pth file
    OUTPUT: result: dictionary containing result
    '''
    result = {}
    for key in parsed_query.keys():
        query = parsed_query[key]
        tokens = []

        for token in query:
            curr = get_list(token, inverted_index)
            tokens.append((len(curr), token))
        tokens.sort()
        res = get_list(tokens[0][1], inverted_index)
        for token_ in tokens:
            token = token_[1]
            curr = get_list(token, inverted_index)
            res = merge_list(res, curr)
        result[key] = res
    return result

result_dic = get_results(parsed_query_dic, newdict)

with open("PAT1_13_results.txt", "w") as text_file:
    for key in result_dic:
        res = " ".join(str(x) for x in result_dic[key])
        text_file.write(key + ":" + res + "\n")

