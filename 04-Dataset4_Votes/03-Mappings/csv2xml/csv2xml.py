#! /usr/bin/env python

import sys
import csv
from xml.sax.saxutils import escape

csv.register_dialect('custom',
                     delimiter=',',
                     doublequote=True,
                     escapechar=None,
                     quotechar='"',
                     quoting=csv.QUOTE_MINIMAL,
                     skipinitialspace=False)

with open(sys.argv[1]) as ifile:
    data = csv.DictReader(ifile, dialect='custom')

    limit = -1
    if len(sys.argv) > 2:
        limit = int(sys.argv[2])

    index = 0
    print "<document>"
    for record in data:
        if (limit == -1 or index < limit):
            print "  <record>"
            for key in record.keys():
              if record[key]:  
                print "      <%s>" % key + escape(record[key]) + "</%s>" % key
              # else:
                # print "      <%s />" % key
            print "  </record>"
        index += 1
    print "</document>"