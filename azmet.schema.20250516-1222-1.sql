/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.11-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: rds-mysql.cals.arizona.edu    Database: azmet
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `meta`
--

DROP TABLE IF EXISTS `meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meta` (
  `meta_id` char(36) NOT NULL,
  `meta_date` char(19) NOT NULL,
  `station_id` varchar(5) NOT NULL,
  `meta_type` varchar(4) NOT NULL,
  `meta_action` varchar(3) NOT NULL,
  `meta_source_id` varchar(36) NOT NULL,
  `meta_synch_status` char(1) NOT NULL,
  `update_status_timestamp` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`meta_id`),
  KEY `station_id` (`station_id`),
  KEY `meta_date` (`meta_date`),
  KEY `meta_synch_status` (`meta_synch_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_15min`
--

DROP TABLE IF EXISTS `obs_15min`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_15min` (
  `station_id` varchar(5) NOT NULL,
  `station_number` varchar(3) NOT NULL DEFAULT '',
  `obs_year` char(4) NOT NULL,
  `obs_doy` varchar(3) NOT NULL,
  `obs_datetime` datetime NOT NULL,
  `obs_hour` varchar(4) NOT NULL DEFAULT '',
  `obs_seconds` varchar(11) NOT NULL DEFAULT '',
  `obs_version` int unsigned NOT NULL DEFAULT '0',
  `obs_creation_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `obs_creation_reason` varchar(100) DEFAULT '',
  `obs_needs_review` tinyint(1) DEFAULT '0',
  `obs_15min_bat_volt` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_temp_panel` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_temp_soil_10cm` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_temp_soil_50cm` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_temp_air` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_relative_humidity` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_sol_rad_kwm2` varchar(15) NOT NULL DEFAULT '',
  `obs_15min_sol_rad` varchar(15) NOT NULL DEFAULT '',
  `obs_15min_wind_spd` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_wind_vector_dir` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_wind_2min_spd_mean` varchar(11) NOT NULL DEFAULT '-9999.0',
  `obs_15min_wind_2min_vector_dir_mean` varchar(25) NOT NULL DEFAULT '-99999',
  `obs_15min_wind_2min_spd_max_hourly` varchar(11) NOT NULL DEFAULT '-9999.0',
  `obs_15min_wind_2min_vector_dir_max_hourly` varchar(25) NOT NULL DEFAULT '-99999',
  `obs_15min_wind_2min_spd_max_daily` varchar(11) NOT NULL DEFAULT '-9999.0',
  `obs_15min_wind_2min_vector_dir_max_daily` varchar(25) NOT NULL DEFAULT '-99999',
  `obs_15min_temp_air_30cm` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_relative_humidity_30cm` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_leaf_wet_1_mv` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_leaf_wet_1_mins_dry` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_leaf_wet_1_mins_con` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_leaf_wet_1_mins_wet` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_leaf_wet_2_mv` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_leaf_wet_2_mins_dry` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_leaf_wet_2_mins_con` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_leaf_wet_2_mins_wet` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_vp_sat` varchar(26) NOT NULL DEFAULT '',
  `obs_15min_dwpt` varchar(26) NOT NULL DEFAULT '',
  `obs_15min_temp_wetbulb` varchar(26) NOT NULL DEFAULT '',
  `obs_15min_dwpt_30cm` varchar(26) NOT NULL DEFAULT '',
  `obs_15min_actual_vp` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_vpd` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_temp_air_max` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_temp_air_min` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_precip_total_dyly` varchar(11) NOT NULL DEFAULT '',
  `obs_15min_wind_spd_max` varchar(11) NOT NULL DEFAULT '',
  PRIMARY KEY (`station_id`,`obs_datetime`,`obs_version`),
  KEY `station_id` (`station_id`),
  KEY `obs_year` (`obs_year`),
  KEY `station_year` (`station_id`,`obs_year`),
  KEY `station_day` (`station_id`,`obs_year`,`obs_doy`),
  KEY `version_review` (`obs_version`,`obs_needs_review`),
  KEY `station_date` (`station_id`,`obs_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_dyly`
--

DROP TABLE IF EXISTS `obs_dyly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_dyly` (
  `station_id` varchar(5) NOT NULL,
  `station_number` varchar(3) NOT NULL DEFAULT '',
  `obs_year` char(4) NOT NULL,
  `obs_doy` varchar(3) NOT NULL,
  `obs_datetime` datetime NOT NULL,
  `obs_hour` varchar(4) NOT NULL DEFAULT '',
  `obs_seconds` varchar(11) NOT NULL DEFAULT '',
  `obs_version` int unsigned NOT NULL DEFAULT '0',
  `obs_creation_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `obs_creation_reason` varchar(100) DEFAULT '',
  `obs_needs_review` tinyint(1) DEFAULT '0',
  `obs_prg_code` varchar(4) NOT NULL DEFAULT '',
  `obs_dyly_temp_air_max` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_temp_air_min` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_temp_air_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_relative_humidity_max` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_relative_humidity_min` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_relative_humidity_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_vpd_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_sol_rad_total` varchar(18) NOT NULL DEFAULT '',
  `obs_dyly_precip_total` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_temp_soil_10cm_max` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_temp_soil_10cm_min` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_temp_soil_10cm_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_temp_soil_50cm_max` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_temp_soil_50cm_min` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_temp_soil_50cm_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_wind_spd_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_wind_vector_magnitude` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_wind_vector_dir` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_wind_vector_dir_stand_dev` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_wind_spd_max` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_bat_volt_max` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_bat_volt_min` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_bat_volt_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_actual_vp_max` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_actual_vp_min` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_actual_vp_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_dyly_wind_2min_spd_mean` varchar(11) NOT NULL DEFAULT '-9999.0',
  `obs_dyly_wind_2min_spd_max` varchar(11) NOT NULL DEFAULT '-9999.0',
  `obs_dyly_wind_2min_timestamp` varchar(25) NOT NULL DEFAULT '-99999',
  `obs_dyly_wind_2min_vector_dir` varchar(25) NOT NULL DEFAULT '-99999',
  PRIMARY KEY (`station_id`,`obs_datetime`,`obs_version`),
  KEY `station_id` (`station_id`),
  KEY `obs_year` (`obs_year`),
  KEY `station_year` (`station_id`,`obs_year`),
  KEY `station_day` (`station_id`,`obs_year`,`obs_doy`),
  KEY `version_review` (`obs_version`,`obs_needs_review`),
  KEY `station_date` (`station_id`,`obs_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_dyly_derived`
--

DROP TABLE IF EXISTS `obs_dyly_derived`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_dyly_derived` (
  `station_id` varchar(5) NOT NULL,
  `obs_year` char(4) NOT NULL,
  `obs_doy` varchar(3) NOT NULL,
  `obs_datetime` datetime NOT NULL,
  `obs_version` int unsigned NOT NULL DEFAULT '0',
  `obs_creation_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `obs_creation_reason` varchar(100) DEFAULT '',
  `obs_dyly_derived_temp_air_maxF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_temp_air_minF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_temp_air_meanF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_sol_rad_total_ly` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_precip_total_in` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_temp_soil_10cm_maxF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_temp_soil_10cm_minF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_temp_soil_10cm_meanF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_temp_soil_50cm_maxF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_temp_soil_50cm_minF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_temp_soil_50cm_meanF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_wind_spd_mean_mph` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_wind_vector_magnitude_mph` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_wind_spd_max_mph` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_dwpt_mean` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_dwpt_meanF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_eto_azmet` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_eto_azmet_in` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_eto_pen_mon` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_eto_pen_mon_in` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_chill_hours_32F` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_chill_hours_45F` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_chill_hours_68F` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_chill_hours_0C` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_chill_hours_7C` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_chill_hours_20C` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heat_units_7C` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heat_units_10C` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heat_units_13C` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heat_units_3413C` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heat_units_45F` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heat_units_50F` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heat_units_55F` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heat_units_9455F` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heatstress_cotton_meanC` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_heatstress_cotton_meanF` varchar(26) NOT NULL DEFAULT '',
  `obs_dyly_derived_wind_2min_spd_mean_mph` varchar(26) NOT NULL DEFAULT '-9999.0',
  `obs_dyly_derived_wind_2min_spd_max_mph` varchar(26) NOT NULL DEFAULT '-9999.0',
  PRIMARY KEY (`station_id`,`obs_datetime`,`obs_version`),
  KEY `station_id` (`station_id`),
  KEY `obs_year` (`obs_year`),
  KEY `station_year` (`station_id`,`obs_year`),
  KEY `station_day` (`station_id`,`obs_year`,`obs_doy`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_hrly`
--

DROP TABLE IF EXISTS `obs_hrly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_hrly` (
  `station_id` varchar(5) NOT NULL,
  `station_number` varchar(3) NOT NULL DEFAULT '',
  `obs_year` char(4) NOT NULL,
  `obs_doy` varchar(3) NOT NULL,
  `obs_datetime` datetime NOT NULL,
  `obs_hour` varchar(4) NOT NULL,
  `obs_seconds` varchar(11) NOT NULL DEFAULT '',
  `obs_version` int unsigned NOT NULL DEFAULT '0',
  `obs_creation_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `obs_creation_reason` varchar(100) DEFAULT '',
  `obs_needs_review` tinyint(1) DEFAULT '0',
  `obs_prg_code` varchar(4) NOT NULL DEFAULT '',
  `obs_hrly_temp_air` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_relative_humidity` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_vpd` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_sol_rad_total` varchar(18) NOT NULL DEFAULT '',
  `obs_hrly_precip_total` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_temp_soil_10cm` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_temp_soil_50cm` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_wind_spd` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_wind_vector_magnitude` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_wind_vector_dir` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_wind_vector_dir_stand_dev` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_wind_spd_max` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_wind_2min_vector_dir` varchar(11) NOT NULL DEFAULT '-99999',
  `obs_hrly_wind_2min_spd_max` varchar(11) NOT NULL DEFAULT '-9999.0',
  `obs_hrly_wind_2min_spd_mean` varchar(11) NOT NULL DEFAULT '-9999.0',
  `obs_hrly_wind_2min_timestamp` varchar(25) NOT NULL DEFAULT '-99999',
  `obs_hrly_actual_vp` varchar(11) NOT NULL DEFAULT '',
  `obs_hrly_bat_volt` varchar(11) NOT NULL DEFAULT '',
  PRIMARY KEY (`station_id`,`obs_datetime`,`obs_version`),
  KEY `station_id` (`station_id`),
  KEY `obs_year` (`obs_year`),
  KEY `station_year` (`station_id`,`obs_year`),
  KEY `station_day` (`station_id`,`obs_year`,`obs_doy`),
  KEY `station_hour` (`station_id`,`obs_year`,`obs_doy`,`obs_hour`),
  KEY `station_date_version_review` (`station_id`,`obs_datetime`,`obs_version`,`obs_needs_review`),
  KEY `version_review` (`obs_version`,`obs_needs_review`),
  KEY `version_date_review` (`obs_version`,`obs_datetime`,`obs_needs_review`),
  KEY `date_version_review` (`obs_datetime`,`obs_version`,`obs_needs_review`),
  KEY `version_review_station_date` (`obs_version`,`obs_needs_review`,`station_id`,`obs_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_hrly_derived`
--

DROP TABLE IF EXISTS `obs_hrly_derived`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_hrly_derived` (
  `station_id` varchar(5) NOT NULL,
  `obs_year` char(4) NOT NULL,
  `obs_doy` varchar(3) NOT NULL,
  `obs_hour` varchar(4) NOT NULL,
  `obs_seconds` varchar(11) NOT NULL DEFAULT '',
  `obs_datetime` datetime NOT NULL,
  `obs_version` int unsigned NOT NULL DEFAULT '0',
  `obs_creation_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `obs_creation_reason` varchar(100) DEFAULT '',
  `obs_hrly_derived_temp_airF` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_sol_rad_total_ly` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_precip_total_in` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_temp_soil_10cmF` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_temp_soil_50cmF` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_wind_spd_mph` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_wind_vector_magnitude_mph` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_wind_spd_max_mph` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_wind_2min_spd_max_mph` varchar(26) NOT NULL DEFAULT '-9999.0',
  `obs_hrly_derived_wind_2min_spd_mean_mph` varchar(26) NOT NULL DEFAULT '-9999.0',
  `obs_hrly_derived_dwpt` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_dwptF` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_eto_azmet` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_eto_azmet_in` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_heatstress_cottonC` varchar(26) NOT NULL DEFAULT '',
  `obs_hrly_derived_heatstress_cottonF` varchar(26) NOT NULL DEFAULT '',
  PRIMARY KEY (`station_id`,`obs_datetime`,`obs_version`),
  KEY `station_id` (`station_id`),
  KEY `obs_year` (`obs_year`),
  KEY `station_year` (`station_id`,`obs_year`),
  KEY `station_day` (`station_id`,`obs_year`,`obs_doy`),
  KEY `station_hour` (`station_id`,`obs_year`,`obs_doy`,`obs_hour`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_lw_15min`
--

DROP TABLE IF EXISTS `obs_lw_15min`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_lw_15min` (
  `station_id` varchar(5) NOT NULL,
  `station_number` varchar(3) NOT NULL DEFAULT '',
  `obs_year` char(4) NOT NULL,
  `obs_doy` varchar(3) NOT NULL,
  `obs_datetime` datetime NOT NULL,
  `obs_hour` varchar(4) NOT NULL DEFAULT '',
  `obs_seconds` varchar(11) NOT NULL DEFAULT '',
  `obs_version` int unsigned NOT NULL DEFAULT '0',
  `obs_creation_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `obs_creation_reason` varchar(100) DEFAULT '',
  `obs_needs_review` tinyint(1) DEFAULT '0',
  `obs_lw_15min_temp_air_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_relative_humidity_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_temp_air_30cm_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_relative_humidity_30cm_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_dwpt_30cm_mean` varchar(26) NOT NULL DEFAULT '',
  `obs_lw_15min_leaf_wet_1_mv` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_leaf_wet_1_mins_dry` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_leaf_wet_1_mins_con` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_leaf_wet_1_mins_wet` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_leaf_wet_2_mv` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_leaf_wet_2_mins_dry` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_leaf_wet_2_mins_con` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_leaf_wet_2_mins_wet` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_temp_wetbulb_mean` varchar(26) NOT NULL DEFAULT '',
  `obs_lw_15min_wind_spd_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_wind_spd_max` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_15min_wind_spd_min` varchar(11) NOT NULL DEFAULT '',
  PRIMARY KEY (`station_id`,`obs_datetime`,`obs_version`),
  KEY `station_id` (`station_id`),
  KEY `obs_year` (`obs_year`),
  KEY `station_year` (`station_id`,`obs_year`),
  KEY `station_day` (`station_id`,`obs_year`,`obs_doy`),
  KEY `version_review` (`obs_version`,`obs_needs_review`),
  KEY `station_date` (`station_id`,`obs_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_lw_dyly`
--

DROP TABLE IF EXISTS `obs_lw_dyly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_lw_dyly` (
  `station_id` varchar(5) NOT NULL,
  `station_number` varchar(3) NOT NULL DEFAULT '',
  `obs_year` char(4) NOT NULL,
  `obs_doy` varchar(3) NOT NULL,
  `obs_datetime` datetime NOT NULL,
  `obs_hour` varchar(4) NOT NULL DEFAULT '',
  `obs_seconds` varchar(11) NOT NULL DEFAULT '',
  `obs_version` int unsigned NOT NULL DEFAULT '0',
  `obs_creation_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `obs_creation_reason` varchar(100) DEFAULT '',
  `obs_needs_review` tinyint(1) DEFAULT '0',
  `obs_lw_dyly_temp_air_30cm_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_temp_air_30cm_max` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_temp_air_30cm_min` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_relative_humidity_30cm_mean` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_relative_humidity_30cm_max` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_relative_humidity_30cm_min` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_dwpt_30cm_mean` varchar(26) NOT NULL DEFAULT '',
  `obs_lw_dyly_dwpt_30cm_max` varchar(26) NOT NULL DEFAULT '',
  `obs_lw_dyly_dwpt_30cm_min` varchar(26) NOT NULL DEFAULT '',
  `obs_lw_dyly_leaf_wet_1_mv` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_leaf_wet_1_mins_dry` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_leaf_wet_1_mins_con` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_leaf_wet_1_mins_wet` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_leaf_wet_2_mv` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_leaf_wet_2_mins_dry` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_leaf_wet_2_mins_con` varchar(11) NOT NULL DEFAULT '',
  `obs_lw_dyly_leaf_wet_2_mins_wet` varchar(11) NOT NULL DEFAULT '',
  PRIMARY KEY (`station_id`,`obs_datetime`,`obs_version`),
  KEY `station_id` (`station_id`),
  KEY `obs_year` (`obs_year`),
  KEY `station_year` (`station_id`,`obs_year`),
  KEY `station_day` (`station_id`,`obs_year`,`obs_doy`),
  KEY `version_review` (`obs_version`,`obs_needs_review`),
  KEY `station_date` (`station_id`,`obs_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_valid_range`
--

DROP TABLE IF EXISTS `obs_valid_range`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_valid_range` (
  `station_id` varchar(5) NOT NULL,
  `obs_field_name_db` varchar(50) NOT NULL DEFAULT '',
  `obs_valid_type` char(1) NOT NULL DEFAULT '',
  `obs_valid_max` varchar(17) NOT NULL DEFAULT '',
  `obs_valid_min` varchar(17) NOT NULL DEFAULT '',
  `obs_valid_missing` text NOT NULL,
  `obs_valid_placeholder` varchar(17) NOT NULL DEFAULT '',
  `obs_valid_float` tinyint(1) NOT NULL DEFAULT '0',
  `obs_valid_decimal_places` int NOT NULL DEFAULT '0',
  `obs_valid_report_out_of_range` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`station_id`,`obs_field_name_db`,`obs_valid_type`),
  KEY `station_id` (`station_id`),
  KEY `obs_valid_type` (`obs_valid_type`),
  KEY `obs_field_name_db` (`obs_field_name_db`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station`
--

DROP TABLE IF EXISTS `station`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `station` (
  `station_id` varchar(5) NOT NULL,
  `station_number` varchar(3) NOT NULL DEFAULT '',
  `station_name` varchar(64) NOT NULL DEFAULT '',
  `station_abbrev` varchar(4) NOT NULL,
  `station_active` tinyint(1) NOT NULL,
  `station_online` tinyint(1) NOT NULL DEFAULT '1',
  `station_date_install` char(10) NOT NULL DEFAULT '',
  `station_date_removal` char(10) NOT NULL DEFAULT '',
  `station_source_15min` tinyint(1) NOT NULL DEFAULT '1',
  `station_source_daily` tinyint(1) NOT NULL DEFAULT '1',
  `station_source_hourly` tinyint(1) NOT NULL DEFAULT '1',
  `station_source_lw15min` tinyint(1) NOT NULL DEFAULT '0',
  `station_source_lwdaily` tinyint(1) NOT NULL DEFAULT '0',
  `station_desc` text,
  PRIMARY KEY (`station_id`),
  KEY `station_abbrev` (`station_abbrev`),
  KEY `station_active` (`station_active`),
  KEY `station_source_15min` (`station_source_15min`),
  KEY `station_source_daily` (`station_source_daily`),
  KEY `station_source_hourly` (`station_source_hourly`),
  KEY `station_source_lw15min` (`station_source_lw15min`),
  KEY `station_source_lwdaily` (`station_source_lwdaily`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_loc`
--

DROP TABLE IF EXISTS `station_loc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_loc` (
  `station_id` varchar(5) NOT NULL,
  `station_loc_date_start` char(10) NOT NULL,
  `station_loc_date_end` char(10) NOT NULL DEFAULT '',
  `station_loc_lat` varchar(11) NOT NULL DEFAULT '',
  `station_loc_lon` varchar(11) NOT NULL DEFAULT '',
  `station_loc_elev` varchar(11) NOT NULL DEFAULT '',
  `station_loc_atm_pressure` varchar(11) NOT NULL DEFAULT '',
  PRIMARY KEY (`station_id`,`station_loc_date_start`),
  KEY `station_id` (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_visit`
--

DROP TABLE IF EXISTS `station_visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_visit` (
  `station_id` varchar(5) NOT NULL,
  `technician_netid` varchar(64) NOT NULL,
  `station_visit_start` datetime NOT NULL,
  `station_visit_end` datetime NOT NULL,
  `station_visit_description` text,
  PRIMARY KEY (`station_id`,`technician_netid`,`station_visit_start`),
  KEY `visit_start_end` (`station_id`,`station_visit_start`,`station_visit_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `technician`
--

DROP TABLE IF EXISTS `technician`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician` (
  `technician_netid` varchar(64) NOT NULL,
  `technician_name` varchar(64) NOT NULL DEFAULT '',
  `technician_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`technician_netid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-05-16 12:23:25
