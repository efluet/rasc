# https://files.isric.org/soilgrids/latest/data/

# Change dir
cd /Users/flue473/Library/CloudStorage/OneDrive-PNNL/Documents/projects/rasc/data/soilgrids20

# Change to dir
# cd soc_0-5cm_mean

# /------------------------------------------------------------------------------------
#/ Convert virtual mosaics to GeoTiff

# For SOC
gdal_translate -of GTiff -co COMPRESS=LZW soc_0-5cm_mean.vrt soc_0-5cm_mean.tif
gdal_translate -of GTiff -co COMPRESS=LZW soc_5-15cm_mean.vrt soc_5-15cm_mean.tif
gdal_translate -of GTiff -co COMPRESS=LZW soc_15-30cm_mean.vrt soc_15-30cm_mean.tif

# For Bulk density
gdal_translate -of GTiff -co COMPRESS=LZW bdod_0-5cm_mean.vrt bdod_0-5cm_mean.tif
gdal_translate -of GTiff -co COMPRESS=LZW bdod_5-15cm_mean.vrt bdod_5-15cm_mean.tif
gdal_translate -of GTiff -co COMPRESS=LZW bdod_15-30cm_mean.vrt bdod_15-30cm_mean.tif


# /------------------------------------------------------------------------------------
#/  Add multiple depth together

# For SOC
gdal_calc.py \
	-A soc_0-5cm_mean.tif \
	-B soc_5-15cm_mean.tif \
	-C soc_15-30cm_mean.tif \
	--outfile=soc_0-30cm_mean.tif \
	--calc="(A+B+C)/3"


# For Bulk density
gdal_calc.py \
	-A bdod_0-5cm_mean.tif \
	-B bdod_5-15cm_mean.tif \
	-C bdod_15-30cm_mean.tif \
	--outfile=bdod_0-30cm_mean.tif \
	--calc="(A+B+C)/3"


# /------------------------------------------------------------------------------------
#/  Aggregate to 500m; use GLWD2 to snap

# For SOC
gdalwarp \
	-tr 0.004166666666666670078 0.004166666666666670078 \
	-r average \
	-co COMPRESS=LZW \
	-te -180.0 -56.0 180.0000000000002842 84.0000000000001137 \
	-t_srs EPSG:4326 \
	-te_srs EPSG:4326 \
	-overwrite soc_0-30cm_mean.tif ../../output/results/soilgrids2/soc_0-30cm_mean_500m.tif


# For Bulk density
gdalwarp \
	-tr 0.004166666666666670078 0.004166666666666670078 \
	-r average \
	-co COMPRESS=LZW \
	-te -180.0 -56.0 180.0000000000002842 84.0000000000001137 \
	-t_srs EPSG:4326 \
	-te_srs EPSG:4326 \
	-overwrite bdod_0-30cm_mean.tif ../../output/results/soilgrids2/bdod_0-30cm_mean_500m.tif





# rio zonalstats \
# 	-r ../GLWDv2/grids/GLWD_v2_delta_combined_classes_tif/GLWD_v2_delta_main_class_50pct.tif \
# 	../../output/results/soilgrids2/soc_0-30cm_mean_500m.tif \
# 	../../output/results/soilgrids2/stats.tif

# # Get Zonal stats
# gdal_zonal_stats.py \
# 	-zoneraster  ../GLWDv2/grids/GLWD_v2_delta_combined_classes_tif/GLWD_v2_delta_main_class_50pct.tif \
# 	-valueraster ../../output/results/soilgrids2/soc_0-30cm_mean_500m.tif -stats