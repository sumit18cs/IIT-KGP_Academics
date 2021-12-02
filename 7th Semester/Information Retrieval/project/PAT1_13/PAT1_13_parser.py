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
from bs4 import BeautifulSoup

PATH = sys.argv[1]

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





with open(PATH, "rb") as f:
    data = f.read().decode("UTF-8")

def parse(title):
    title=remStopWords(title)
    title=remPunct(title)
    title=lemma(title)
    filtered_list = title.split(" ")
    return filtered_list


soup = BeautifulSoup(data, 'html.parser')
query_dic = {}
for topic in soup.topics:
    try:
        title = topic.title.text
        query_dic[(topic.num.text)] = parse(title)
    except:
        pass


with open("queries_13.txt", "w") as text_file:
    for key in query_dic:
        res = " ".join(str(x) for x in query_dic[key])
        text_file.write(key + "," + res + "\n")