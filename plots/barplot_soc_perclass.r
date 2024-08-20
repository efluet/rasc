


# Read in extracted dfs
soc_df  <- read.csv('../output/results/soilgrids2/soc_0-30cm_mean_perclass.csv')
bdod_df <- read.csv('../output/results/soilgrids2/bdod_0-30cm_mean_perclass.csv')



# Get GWO class lookup names
gwo_area <- read.csv('../output/results/gwo/gwo_class_area_wnames.csv')


# Join together
df <- full_join(soc_df, bdod_df, by=c('lon','lat','gwo_class_num')) %>% 
      left_join(., gwo_area, by='gwo_class_num') %>% 
      # Convert SOC from dg/kg to OC%
      # Convert BDOD to g/cm^3
      mutate(cstock_gcm3 = soc_0_30cm_mean*0.0001 * bdod_0_30cm_mean*0.01)




# /-----------------------------------------------------------------------------
#/  DIAGNOSTIC FIGURES



# Histogram distribution of of %OC per GWO class
ggplot(sample_n(df, 100000))+
  geom_histogram(aes(x= soc_0_30cm_mean*0.0001*100, fill=gwo_class_name)) +
  xlab('%OC (g/g*100)') +
  line_plot_theme +
  facet_wrap(.~gwo_class_name, scales='free') +
  theme(legend.position = 'none')



# Histogram distribution of of BDOD per GWO class
ggplot(sample_n(df, 100000))+
  geom_histogram(aes(x= bdod_0_30cm_mean*0.01, fill=gwo_class_name)) +
  xlab('Bulk density (g/cm^3)') +
  line_plot_theme +
  facet_wrap(.~gwo_class_name, scales='free') +
  theme(legend.position = 'none')



# Histogram distribution of of SOC raters per GWO class
ggplot(sample_n(df, 100000))+
  geom_histogram(aes(x=cstock_gcm3, fill=gwo_class_name)) +
  xlab('Belowground carbon stock (g/cm^3)') +
  line_plot_theme +
  facet_wrap(.~gwo_class_name, scales='free') +
  theme(legend.position = 'none')





# /----------------------------------------------------------------------------#
#/   SCATTERPLOT of %OC vs BDOD

# Scatterplot of SoilGrids2.0 of %OC vs BDOD
ggplot(sample_n(df, 100000))+
  geom_point(aes(x=soc_0_30cm_mean*0.0001*100, y=bdod_0_30cm_mean*0.01, color=gwo_class_name)) +
  line_plot_theme +
  xlab('%OC (g/g*100)') +
  ylab('Bulk density (g/cm^3)') +
  facet_wrap(.~gwo_class_name, scales='free') +
  theme(legend.position = 'none')



# /----------------------------------------------------------------------------#
#/  GLOBAL SUMMARY VALUES


# Summarize SOC values per class
soc_df_perclass <- 
  soc_df %>% 
  group_by(gwo_class_num, gwo_class_name) %>% 
  summarise_all(.funs=list(soc_0_30cm_min = min, 
                           soc_0_30cm_mean= mean, 
                           soc_0_30cm_max = max))


#  Join the GWO class # and name
df <- left_join(soc_df_perclass, gwo_area, by='gwo_class_num') %>% 
  mutate(soc_tot = soc_0_30cm_mean * area_Mkm2)


# /-----------------------------------------------------------------------------
#/  GLOBAL SUMMARY FIGURES

# Barplot of area per GWO class
ggplot(sample_n(df, 10))+
  geom_bar(aes(x=gwo_class_name, y=area_Mkm2), stat='identity') +
  coord_flip() +
  xlab('') +
  line_plot_theme


# Boxplot of SOC raters per GWO class
ggplot(df)+
  geom_boxplot(aes(x=gwo_class_num, y=cstock_gcm3)) +
  coord_flip() +
  xlab('') +
  line_plot_theme


# Barplot of total carbon per GWO class
ggplot()+
  geom_boxplot(data=soc_df, aes(x=gwo_class, y=value)) +
  line_plot_theme

