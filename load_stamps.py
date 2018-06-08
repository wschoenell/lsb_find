import os
import pickle
import numpy as np

from webserver.model import Stamp, Session

# with open(os.path.expanduser("~/ownCloud/ngc3115/work/stamps/stamp_list.pkl"), "rb") as fp:
with open(os.path.expanduser("~/data/ngc3115/work/stamps/stamp_list.pkl"), "r") as fp:
    stamp_data = pickle.load(fp)
# Format: filename, (x0,x1,y0,y1), wcs, exists?

# Separate stamps in groups...
images = [stamp_data[s][0] for s in stamp_data]
stamp_group = {j: i + 1 for i, j in enumerate(np.unique(images))}

session = Session()

stamps = list()
for s in stamp_data:
    print(s)
    if stamp_data[s][3]:
        stamp = Stamp(
            number=s,
            xypos=str(stamp_data[s][1]),
            # wcs=stamp_data[s][2],
            # file_prefix=stamp_data[s][4].replace('/Users/william/', os.path.expanduser('~/own')),
            file_prefix=stamp_data[s][4].replace('/Users/william/data/',
                                                 os.path.expanduser(
                                                     'c:\\Users\\William Schoenell\\ownCloud\\')).replace('/', '\\'),
            group=stamp_group[stamp_data[s][0]]
        )
        stamps.append(stamp)

session.add_all(stamps)
session.commit()
session.close()
