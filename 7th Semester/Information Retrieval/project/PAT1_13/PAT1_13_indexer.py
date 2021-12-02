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

PATH = sys.argv[1]
# print(PATH)

stop_words = list(stopwords.words('english'))
lemmatizer = WordNetLemmatizer()

def remStopWords(text):
    tokens = word_tokenize(text)
    tokens_filtered= [word for word in tokens if not word in stop_words]
    return (" ").join(tokens_filtered)

def remPunct(text):
    tokenizer = RegexpTokenizer(r'\w+')
    tokens=tokenizer.tokenize(text)
    return (" ").join(tokens)

def lemma(text):
    tokens=word_tokenize(text)
    afterlemmatize = [lemmatizer.lemmatize(word.lower()) for word in tokens ]
    return (" ").join(afterlemmatize)

def modify_list(posting_list):
    n = len(posting_list)
    count = 1
    res = []
    if n == 0:
        return res
    for i in range(1,n):
        if posting_list[i] == posting_list[i-1]:
            count += 1
        else:
            res.append((posting_list[i-1], count))
            count = 1
            
    res.append((posting_list[n-1], count))
    
    return res


def get_inverted_index():
    inverted_index = {}
    for dirname in os.listdir(PATH):
        
        for filename in os.listdir(os.path.join(PATH,dirname)):
            with open(os.path.join(os.path.join(PATH, dirname),filename), 'r') as f:
                s=f.read()
                s=s.split('<TEXT>')[1].split('</TEXT>')[0]
                
                s=remStopWords(s)
                s=remPunct(s)
                s=lemma(s)
                
                tokens=word_tokenize(s)
                for token in tokens:
                    if token in inverted_index.keys():
                        inverted_index[token].append(filename)
                    else:
                        inverted_index[token]=[filename]

    for key in inverted_index.keys():
        inverted_index[key].sort()
        inverted_index[key] = modify_list(inverted_index[key])
        
    return inverted_index


inverted_index = get_inverted_index()

#saving
dbfile = open('model_queries_13.pth', 'wb')
# source, destination
pickle.dump(inverted_index, dbfile)                     
dbfile.close()