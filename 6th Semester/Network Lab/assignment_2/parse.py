# Name : Sumit Kumar Yadav
# Roll No.: 18CS30042

# Install Library Package
# 1. Geolite: pip install maxminddb-geolite2
# 2. pycountry: pip install pycountry
# 3. Numpy: pip install numpy

import xml.etree.ElementTree as ET
import csv
import numpy as np
from geolite2 import geolite2
import sys
import pycountry

# run as   python parse.py filename.xml
# input xml file name as argv[1] argument

mytree = ET.parse(sys.argv[1])		# store the xml tree
myroot = mytree.getroot()			# assign root of the xml tree

ip_list = []							# List to store the all the IP address of the Users

# Parse code 
for packet in myroot:													# Iterate over all the packet from the root
    for proto in packet:												# Iterate over all the proto of any particular packet
        if proto.get('name') == 'http':									# Condition to check whether name of the protocol is http or not
            for field in proto:											# Iterate over all the fields of http protocols
                if field.get('name') == 'http.x_forwarded_for':			# Condition to check whether name of field is "http.x_forwarded_for" or not
                    possible_ip=field.get('show')						# Store current IP address which may lead to the required IP 
                if field.get('showname') == 'Via: Internet.org\\r\\n':	# Check whether this IP has showname of "Via: Internet.org" or not
                    ip_list.append(possible_ip)							# if satisfy previous condition then current IP lead to the IP of user accessing Internet.org


final_ip_list = []						# List to store only the unique IP address
arr = np.array(ip_list)				
final_ip_list = np.unique(arr)			# convert the list into unique element list using numpy library

country_count = {}					# create a empty dictionary to calculate no of users from different countries

for ip_address in final_ip_list:			# Iterate on all the Ip address
    reader = geolite2.reader()				# using library geolite 
    find_country = (reader.get(ip_address))				# find all the details of Ip address using geolite function
    country_code = (find_country['country']['iso_code'])	# Fetch the Country code using all the details of Ip 
    country = pycountry.countries.get(alpha_2=country_code).name.upper()    # Fetch the country name from country code using pycountry library

    if country not in country_count:		# Count the number of Users from all the country 
        country_count[country]=0
    country_count[country]+=1
geolite2.close()							# close the geolite library


final_list = country_count.items()				# Store all the details of country and its users
with open('data.csv','w', newline = '') as out:			# Open the csv file
    csv_out=csv.writer(out)								
    for item in final_list:						# Iterate all the details of final_list
        csv_out.writerow(item)					# write the details in the csv file