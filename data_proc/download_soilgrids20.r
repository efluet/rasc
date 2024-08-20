library(terra)
library(gdalUtilities)

# /-----------------------------------------------------------------------
#/ Get Soil Grids 2.0

# bounding box
# bb=c(-337500.000,1242500.000,152500.000,527500.000)
bb=c(-120, 55, -111, 50)
# igh='+proj=igh +lat_0=0 +lon_0=0 +datum=WGS84 +units=m +no_defs' # proj string for Homolosine projection

sg_url="/vsicurl?max_retry=3&retry_delay=1&list_dir=no&url=https://files.isric.org/soilgrids/latest/data/"


# Convert VRT to Tiff
gdal_translate(paste0(sg_url,'soc/soc_0-5cm_mean.vrt'),
               "../output/results/soilgrids2/soc_0-5cm_mean_mosaic.tif",
               tr=c(500,500),
               projwin=bb)
               # projwin_srs =igh)
