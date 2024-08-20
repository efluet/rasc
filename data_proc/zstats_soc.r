# zonal stats of GLWDv2 and SOC grid from soil grids



# /----------------------------------------------------------------------------
#/ Read input rasters

# Organic carbon concentration 
# SOC g/kg dg/kg Gravimetric content of organic carbon in the fine earth fraction of the soil
soc <- rast('../output/results/soilgrids2/soc_0-30cm_mean_500m.tif')

# Bulk density 
# BDOD kg/dm3 cg/cm3 Bulk density of the fine earth fraction oven dry
bdod <- rast('../output/results/soilgrids2/bdod_0-30cm_mean_500m.tif')


# /-----------------------------------------------------------------------------
#/

get_perwetclass <- function(rast, class_string){
  
  # Get GLWDv2
  fname <- paste0('../output/results/glwdv2/GLWD_v2_delta_GWO_class_', class_string,'_ha_x10.tif')
  glwdv2 <- rast(fname)
  
  # Get pixel area
  pixarea_x10ha <- cellSize(glwdv2, unit='ha')*10
  
  # Convert class fractioin to percentage
  glwdv2_prc <- glwdv2 / pixarea_x10ha
  glwdv2_prc[glwdv2_prc > 1] <- 1
  
  
  # Set a class area threshold to sample SOC per class
  # Remove pixels lower than threshold; this way a pixel cannot contribute to two classes
  glwdv2_prc[glwdv2_prc <= 0.5] <- NA
  
  # Apply GLWDv2 mask to SOC raster
  rast[is.na(glwdv2_prc)] <- NA
  
  # Set two extents; splitting bc it runs out of memory when attempted in one go
  ext1 <- ext(-180, 0, -56, 84)
  ext2 <- ext(0, 180, -56, 84)
  
  # Crop extents
  rast1 <- crop(rast, ext1, snap="near", extend=FALSE)
  rast2 <- crop(rast, ext2, snap="near", extend=FALSE)
  
  # Conver to dataframe
  rast1_class_df<- as.data.frame(rast1, na.rm=T, xy=T)
  rast2_class_df<- as.data.frame(rast2, na.rm=T, xy=T)
  
  
  rast_class_df <- bind_rows(rast1_class_df, rast2_class_df)
  rast_class_df$gwo_class <- as.numeric(class_string)
  
  return(rast_class_df)
  }


# /-----------------------------------------------------------------------------
#/  Run function extracting the SOC and BDOD per GWOS class

# Create output
soc_df <- data.frame()
bdod_df <- data.frame()

# List of classes
gwo_class_list <- c('01','02','03','04','05','06','07','08','09','16','19')

# Loop through classes
for (c in gwo_class_list){
  
  print(c)
  
  # soc_df <- bind_rows(soc_df,
  #                     get_perwetclass(soc, c))

  bdod_df <- bind_rows(bdod_df,
                      get_perwetclass(bdod, c))
  
  }

names(soc_df)  <- c('lon','lat','soc_0_30cm_mean','gwo_class_num')
names(bdod_df) <- c('lon','lat','bdod_0_30cm_mean','gwo_class_num')
bdod_df <-bdod_df[,1:4]

# Write to file
write.csv(soc_df, '../output/results/soilgrids2/soc_0-30cm_mean_perclass.csv')
write.csv(bdod_df, '../output/results/soilgrids2/bdod_0-30cm_mean_perclass.csv')

