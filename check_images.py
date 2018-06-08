import matplotlib.pyplot as plt
import numpy as np
from astropy.io import fits

img = fits.open("/Users/william/Downloads/c4d_140404_234050_ooi_i_v1.fits.fz")

for hdu in img[1:]:
    plt.clf()
    plt.imshow(np.ma.masked_invalid(np.log10(hdu.data[:500, :500])), cmap=plt.cm.gray_r,
               vmin=np.log10(hdu.header['AVSKY'] - 2 * hdu.header['AVSIG']),
               vmax=np.log10(hdu.header['AVSKY'] + 2 * hdu.header['AVSIG']))
    plt.title(hdu.header["EXTNAME"])
    plt.show()
    plt.savefig("out/%s.png" % hdu.header["EXTNAME"])
    print hdu.header["EXTNAME"]
    # raw_input("ENTER for next...")
