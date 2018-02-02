#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

import argparse
import json
import os
import requests
import sys
from pprint import pprint

CODE_EXIT_ERROR = 2


#
# Allows to import the given dashboard json file into Elasticsearch using the given index
#
class BDCFImportDashboard:

    # filename: dashboard json file name
    # esURL: URL of Elasticsearch
    # esIndex: Elasticsearch index to use
    def __init__(self, filename, esURL, esIndex):
        self.f = filename
        self.url = esURL
        self.index = esIndex

    def importdashboard(self):
        print "==> Import the dashboard '", self.f, "' in Elasticsearch '", self.url, "' at the index '", self.index, "'"

        with open(self.f) as data_file:
            db = json.load(data_file)
        # print "--> db: ", db

        headerInfo = {'Accept' : 'text/plain', 'content-type': 'text/plain' }
        for elt in db:
            print "-->", elt["_type"], ":", elt["_id"]
            if ((elt["_type"] == "config") or (elt["_type"] == "index-pattern") or (elt["_type"] == "dashboard") or (elt["_type"] == "visualization") or (elt["_type"] == "search")):
                # print "--> elt[\"_source\"]: ", elt["_source"]
                urlRequest = self.url + "/" + self.index + "/" + elt["_type"] + "/" + elt["_id"]
                # print "--> urlRequest: ", urlRequest
                r = requests.put(urlRequest, json=elt["_source"], headers=headerInfo)
                if ((r.status_code != 200) and (r.status_code != 201)):
                    print "--> ERROR: Problem in PUT request for ", urlRequest, ": status code is ", r.status_code, "(", r.text, ")"
                # else:
                #     print "--> r.status_code: ", r.status_code
                #     print "--> r.text: ", r.text
            else:
                print "--> WARNING: Unknown type '", elt["_type"], "'"
                pprint(elt)


if __name__ == '__main__':

    # Parse arguments
    parser = argparse.ArgumentParser(description='Import Kibana dashboard Ystia tool')
    parser.add_argument('-f', help='Path of the json dashboard file', required=True)
    parser.add_argument('-es', help='Elasticsearch URL (Default: \'http://localhost:9200\')', default='http://localhost:9200')
    parser.add_argument('-k', help='Kibana index (Default: \'.kibana\'', default='.kibana')
    args = parser.parse_args()

    # Test if the given json file exist
    if (not os.path.isfile(args.f)):
        print "--> ERROR: File '", args.f, "' does NOT exist"
        sys.exit(CODE_EXIT_ERROR)

    # Import dashboard
    idb = BDCFImportDashboard(args.f, args.es, args.k)
    idb.importdashboard()

