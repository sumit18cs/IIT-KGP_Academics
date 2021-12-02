# Name : Sumit Kumar Yadav
# Roll No. : 18CS30042

import xml.etree.ElementTree as ET
import sys
import numpy as np 
import csv

tree=ET.parse('File.pdml')
root=tree.getroot()

total=0
mail_subject=[]
body=[]
for first in root:
    for second in first:
        string_s=(second.get('name'))
        if string_s=="imf":
            total=total+1
            value=0

            for third in second:
                string_s1=third.get("showname")
                mail_subject.append(string_s1)
                break

            for third in second:
                value=value+1
                if value==2:
                    for check in third:
                        s3=check.get("show")
                        body.append(s3)
                        
print(total)
print(mail_subject)
print(body)
