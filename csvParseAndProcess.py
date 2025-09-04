# author: Matt Harmon
# modified by: Eric Scott

import csv
import decimal
from decimal import Decimal, ROUND_HALF_UP, ROUND_HALF_DOWN
import math
import re


def convertCelsiusToFahrenheit(strDegCelsius=""):
    # convert degrees Celsius to degrees Fahrenheit
    decDegCelsius = decimal.Decimal(strDegCelsius)
    fltDegF = float(decDegCelsius) * 1.8 + 32.0

    return fltDegF


def roundValue(valueToRound=0, strExp="1", strReturnType="dec"):
    decReturnValue = decimal.Decimal(valueToRound).quantize(
        decimal.Decimal(strExp), rounding=ROUND_HALF_UP
    )

    if strReturnType == "flt":
        returnValue = float(decReturnValue)
    elif strReturnType == "int":
        returnValue = int(decReturnValue)
    elif strReturnType == "str":
        returnValue = format(decReturnValue, "f")
    else:
        returnValue = decReturnValue

    return returnValue


def calculateHeatStressCotton(
    strTempAir="", strRelativeHumdity="", strVaporPressureDeficit="", strSolarRad=""
):
    # Calculate Heat Stress Values for Cotton
    dictReturn = {}
    fltHeatStressCottonC = 0.000
    fltHeatStressCottonF = 0.000
    if (
        (
            (strTempAir != "-7999")
            and (strTempAir != "-6999")
            and (strTempAir != "-9999.0")
        )
        and (
            (strRelativeHumdity != "-7999")
            and (strRelativeHumdity != "-6999")
            and (strRelativeHumdity != "-9999.0")
        )
        and (
            (strVaporPressureDeficit != "-7999")
            and (strVaporPressureDeficit != "-6999")
            and (strVaporPressureDeficit != "-9999.0")
        )
        and (
            (strSolarRad != "-7999")
            and (strSolarRad != "-6999")
            and (strSolarRad != "-9999.0")
        )
    ):
        fltTempAir = float(decimal.Decimal(strTempAir))
        fltSolarRad = float(decimal.Decimal(strSolarRad))
        fltRelativeHumdity = float(decimal.Decimal(strRelativeHumdity))
        fltVaporPressureDeficit = float(decimal.Decimal(strVaporPressureDeficit))

        fltEx = math.exp((17.27 * fltTempAir) / (237.2 + fltTempAir))
        fltEa = fltRelativeHumdity / 100 * 0.6108 * fltEx

        if fltSolarRad > 0:
            fltHeatStressCottonC = 0.53 + fltTempAir - 1.43 * fltVaporPressureDeficit
        else:
            fltHeatStressCottonC = -5.93 + fltTempAir + 1.95 * fltEa

        dictReturn["heatStressCottonC"] = roundValue(
            fltHeatStressCottonC, "000.0000000"
        )
        fltHeatStressCottonF = convertCelsiusToFahrenheit(
            dictReturn["heatStressCottonC"]
        )
        dictReturn["heatStressCottonF"] = roundValue(
            fltHeatStressCottonF, "000.0000000"
        )
    else:
        dictReturn = {"heatStressCottonC": "-9999.0", "heatStressCottonF": "-9999.0"}

    return dictReturn


def convertHeatUnitCelsiusToHeatUnitFahrenheit(strHUCelsius=""):
    ## convert Celsius heat units to Fahrenheit heat units
    decHUCelsius = decimal.Decimal(strHUCelsius)
    fltHUF = float(decHUCelsius) * 1.8

    return fltHUF


def calculateHeatUnits(
    strTempAirMax="", strTempAirMin="", strTempAirUpper="", strTempAirLower=""
):
    dictReturn = {}
    aryFltSine = [
        1.000,
        0.981,
        0.962,
        0.944,
        0.927,
        0.910,
        0.893,
        0.876,
        0.859,
        0.843,
        0.827,
        0.811,
        0.796,
        0.780,
        0.765,
        0.750,
        0.735,
        0.721,
        0.706,
        0.692,
        0.678,
        0.664,
        0.650,
        0.636,
        0.622,
        0.609,
        0.596,
        0.583,
        0.570,
        0.557,
        0.544,
        0.532,
        0.519,
        0.507,
        0.495,
        0.483,
        0.471,
        0.459,
        0.448,
        0.436,
        0.425,
        0.413,
        0.402,
        0.391,
        0.381,
        0.370,
        0.359,
        0.349,
        0.339,
        0.328,
        0.318,
        0.308,
        0.299,
        0.289,
        0.279,
        0.270,
        0.261,
        0.251,
        0.242,
        0.233,
        0.225,
        0.216,
        0.208,
        0.199,
        0.191,
        0.183,
        0.175,
        0.167,
        0.159,
        0.152,
        0.144,
        0.137,
        0.130,
        0.123,
        0.116,
        0.109,
        0.102,
        0.096,
        0.090,
        0.084,
        0.078,
        0.072,
        0.066,
        0.061,
        0.055,
        0.050,
        0.045,
        0.040,
        0.036,
        0.031,
        0.027,
        0.023,
        0.019,
        0.016,
        0.013,
        0.010,
        0.007,
        0.004,
        0.002,
        0.001,
        0.000,
    ]

    if (
        (
            (strTempAirMax != "-7999")
            and (strTempAirMax != "-6999")
            and (strTempAirMax != "-9999.0")
        )
        and (
            (strTempAirMin != "-7999")
            and (strTempAirMin != "-6999")
            and (strTempAirMin != "-9999.0")
        )
        and (
            (strTempAirUpper != "-7999")
            and (strTempAirUpper != "-6999")
            and (strTempAirUpper != "-9999.0")
        )
        and (
            (strTempAirLower != "-7999")
            and (strTempAirLower != "-6999")
            and (strTempAirLower != "-9999.0")
        )
    ):
        fltTempAirMax = float(decimal.Decimal(strTempAirMax))
        fltTempAirMin = float(decimal.Decimal(strTempAirMin))
        fltTempAirUpper = float(decimal.Decimal(strTempAirUpper))
        fltTempAirLower = float(decimal.Decimal(strTempAirLower))
        fltHeatUnits = 0.0
        intSineWavePoint1 = 0
        intSineWavePoint2 = 0
        fltTempAirAlpha = 0.0

        # 15020 TM = (X + N) / 2
        fltTempAirMean = (fltTempAirMax + fltTempAirMin) / 2.0
        #           fltTempAirSum = (fltTempAirMax + fltTempAirMin)

        # 15040 A = (X - N) / 2
        fltTempAirAlpha = (fltTempAirMax - fltTempAirMin) / 2.0

        #           print("calculateHeatUnits fltTempAirMax: ", fltTempAirMax, " fltTempAirUpper: " , fltTempAirUpper)
        #           print("calculateHeatUnits fltTempAirMin: ", fltTempAirMin, " fltTempAirLower: ", fltTempAirLower)

        # OK 15060 IF X > TU GOTO 15200
        # OK 15080 IF N > TL THEN H = TM - TL: RETURN
        # OK 15100 R = CINT(((TL - N) / (X - N)) * 100)
        # OK 15110 IF R > 100 THEN R = 100
        # OK 15120 H = A * SI(R): RETURN
        # OK 15200 IF N < TL GOTO 15300
        # OK 15220 R = CINT(((TU - N) / (X - N)) * 100)
        # OK 15230 IF R < 0 THEN H = TU - TL: RETURN
        # OK 15240 H = (TM - TL) - SI(R) * A: RETURN
        # OK 15300 R1 = CINT(((TL - N) / (X - N)) * 100)
        # OK 15320 R2 = CINT(((TU - N) / (X - N)) * 100)
        # OK 15340 H = A * (SI(R1) - SI(R2)): RETURN
        # OK 15500
        # RETURN

        # 15060 IF X > TU GOTO 15200
        if fltTempAirMax > fltTempAirUpper:
            # 15200 IF N < TL GOTO 15300
            if fltTempAirMin < fltTempAirLower:
                # 15300 R1 = CINT(((TL - N) / (X - N)) * 100)
                fltSineWavePoint1 = (
                    (fltTempAirLower - fltTempAirMin)
                    / (fltTempAirMax - fltTempAirMin)
                    * 100
                )
                intSineWavePoint1 = roundValue(fltSineWavePoint1, "1", "int")
                # 15320 R2 = CINT(((TU - N) / (X - N)) * 100)
                fltSineWavePoint2 = (
                    (fltTempAirUpper - fltTempAirMin)
                    / (fltTempAirMax - fltTempAirMin)
                    * 100
                )
                intSineWavePoint2 = roundValue(fltSineWavePoint2, "1", "int")
                # 15340 H = A * (SI(R1) - SI(R2)): RETURN
                #                   print("calculateHeatUnits intSineWavePoint1: ", intSineWavePoint1, "intSineWavePoint2: " , intSineWavePoint2)
                fltHeatUnits = fltTempAirAlpha * (
                    aryFltSine[intSineWavePoint1] - aryFltSine[intSineWavePoint2]
                )
            else:
                # 15220 R = CINT(((TU - N) / (X - N)) * 100)
                fltSineWavePoint1 = (
                    (fltTempAirUpper - fltTempAirMin)
                    / (fltTempAirMax - fltTempAirMin)
                    * 100
                )
                # 15230 IF R < 0 THEN H = TU - TL: RETURN
                if fltSineWavePoint1 < 0.0:
                    fltHeatUnits = fltTempAirUpper - fltTempAirLower
                else:
                    # 15240 H = (TM - TL) - SI(R) * A: RETURN
                    intSineWavePoint1 = roundValue(fltSineWavePoint1, "1", "int")
                    if intSineWavePoint1 > 100:
                        intSineWavePoint1 = 100
                    fltHeatUnits = (fltTempAirMean - fltTempAirLower) - aryFltSine[
                        intSineWavePoint1
                    ] * fltTempAirAlpha
        else:
            # 15080 IF N > TL THEN H = TM - TL: RETURN
            if fltTempAirMin > fltTempAirLower:
                fltHeatUnits = fltTempAirMean - fltTempAirLower
            else:
                # 15100 R = CINT(((TL - N) / (X - N)) * 100)
                fltSineWavePoint1 = (
                    (fltTempAirLower - fltTempAirMin) / (fltTempAirMax - fltTempAirMin)
                ) * 100
                intSineWavePoint1 = roundValue(fltSineWavePoint1, "1", "int")
                # 15110 IF R > 100 THEN R = 100
                if intSineWavePoint1 > 100:
                    intSineWavePoint1 = 100

                if intSineWavePoint1 < 0:
                    intSineWavePoint1 = 0
                # 15120 H = A * SI(R): RETURN
                #               print("calculateHeatUnits intSineWavePoint1: ", intSineWavePoint1, "intSineWavePoint2: " , intSineWavePoint2)
                fltHeatUnits = fltTempAirAlpha * aryFltSine[intSineWavePoint1]

        dictReturn = {
            "fltHeatUnits": fltHeatUnits,
            "decHeatUnits": (roundValue(fltHeatUnits, "1.00", "dec")),
        }
    else:
        dictReturn = {"fltHeatUnits": -9999.0, "decHeatUnits": -9999.0}

    return dictReturn


def updateDerived(path_obs_hrly, path_derived_hrly, path_obs_dyly, path_derived_dyly):
    data = []
    dataHourly = {}
    dataDaily = {}
    dataHourlyOutput = []
    dataDailyDerived = {}
    dataHourlyDerived = {}
    datDailyDerivedOutput = []
    with open(path_obs_hrly, "r", newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            strDailyOutputKey = row["obs_year"] + "." + row["obs_doy"]

            if strDailyOutputKey not in dataDailyDerived:
                dataDailyDerived[strDailyOutputKey] = {
                    "obs_dyly_derived_chill_hours_0C": 0,
                    "obs_dyly_derived_chill_hours_7C": 0,
                    "obs_dyly_derived_chill_hours_20C": 0,
                    "intHoursHeatStressCotton": 0,
                    "fltAccumHeatStressC": 0.00,
                    "fltAccumHeatStressF": 0.00,
                    "obs_dyly_derived_heatstress_cotton_meanC": 0.00,
                    "obs_dyly_derived_heatstress_cotton_meanF": 0.00,
                }

            dictHeatStress = calculateHeatStressCotton(
                row["obs_hrly_temp_air"],
                row["obs_hrly_relative_humidity"],
                row["obs_hrly_vpd"],
                row["obs_hrly_sol_rad_total"],
            )

            dataHourlyDerived[
                row["obs_year"] + "." + row["obs_doy"] + "." + row["obs_hour"]
            ] = {
                "obs_hrly_derived_heatstress_cottonC": dictHeatStress[
                    "heatStressCottonC"
                ],
                "obs_hrly_derived_heatstress_cottonF": dictHeatStress[
                    "heatStressCottonF"
                ],
            }

            dataDailyDerived[strDailyOutputKey]["intHoursHeatStressCotton"] = (
                dataDailyDerived[strDailyOutputKey]["intHoursHeatStressCotton"] + 1
            )
            dataDailyDerived[strDailyOutputKey]["fltAccumHeatStressC"] = (
                decimal.Decimal(
                    dataDailyDerived[strDailyOutputKey]["fltAccumHeatStressC"]
                )
                + decimal.Decimal(dictHeatStress["heatStressCottonC"])
            )
            dataDailyDerived[strDailyOutputKey]["fltAccumHeatStressF"] = (
                decimal.Decimal(
                    dataDailyDerived[strDailyOutputKey]["fltAccumHeatStressF"]
                )
                + decimal.Decimal(dictHeatStress["heatStressCottonF"])
            )

            if (
                (row["obs_hrly_temp_air"] != "-7999")
                and (row["obs_hrly_temp_air"] != "-6999")
                and (row["obs_hrly_temp_air"] != "-9999.0")
            ):
                if float(row["obs_hrly_temp_air"]) < 0.00000:
                    dataDailyDerived[strDailyOutputKey][
                        "obs_dyly_derived_chill_hours_0C"
                    ] = (
                        dataDailyDerived[strDailyOutputKey][
                            "obs_dyly_derived_chill_hours_0C"
                        ]
                        + 1
                    )
                if float(row["obs_hrly_temp_air"]) < 7.22222:
                    dataDailyDerived[strDailyOutputKey][
                        "obs_dyly_derived_chill_hours_7C"
                    ] = (
                        dataDailyDerived[strDailyOutputKey][
                            "obs_dyly_derived_chill_hours_7C"
                        ]
                        + 1
                    )
                if float(row["obs_hrly_temp_air"]) > 20.00000:
                    dataDailyDerived[strDailyOutputKey][
                        "obs_dyly_derived_chill_hours_20C"
                    ] = (
                        dataDailyDerived[strDailyOutputKey][
                            "obs_dyly_derived_chill_hours_20C"
                        ]
                        + 1
                    )

            if strDailyOutputKey not in dataHourly:
                dataHourly[strDailyOutputKey] = []

            dataHourly[strDailyOutputKey].append(row)

    csvfile.close()

    dataHourlyOutputFields = []

    with open(path_derived_hrly, "r", newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            strAccessKey = (
                row["obs_year"] + "." + row["obs_doy"] + "." + row["obs_hour"]
            )
            dataHourlyOutputFields = list(row.keys())
            if strAccessKey in dataHourlyDerived:
                row["obs_hrly_derived_heatstress_cottonC"] = roundValue(
                    dataHourlyDerived[strAccessKey][
                        "obs_hrly_derived_heatstress_cottonC"
                    ],
                    "000.0",
                )
                row["obs_hrly_derived_heatstress_cottonF"] = roundValue(
                    dataHourlyDerived[strAccessKey][
                        "obs_hrly_derived_heatstress_cottonF"
                    ],
                    "000.0",
                )

            dataHourlyOutput.append(row)
    csvfile.close()

    out_hrly = re.sub(r"(.+)(\.\w+$)", r"\1_updated\2", path_derived_hrly)
    with open(out_hrly, "w", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=dataHourlyOutputFields)
        writer.writeheader()
        writer.writerows(dataHourlyOutput)

    csvfile.close()

    with open(path_obs_dyly, "r", newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            strOutputKey = row["obs_year"] + "." + row["obs_doy"]

            dictHeatStress = calculateHeatStressCotton(
                row["obs_dyly_temp_air_mean"],
                row["obs_dyly_relative_humidity_mean"],
                row["obs_dyly_vpd_mean"],
                row["obs_dyly_sol_rad_total"],
            )

            dataDailyDerived[strOutputKey][
                "obs_dyly_derived_heatstress_cotton_meanC"
            ] = dictHeatStress["heatStressCottonC"]
            dataDailyDerived[strOutputKey][
                "obs_dyly_derived_heatstress_cotton_meanF"
            ] = dictHeatStress["heatStressCottonF"]

            dictHeatUnits = calculateHeatUnits(
                row["obs_dyly_temp_air_max"],
                row["obs_dyly_temp_air_min"],
                "30.0",
                "12.7778",
            )
            dataDailyDerived[strOutputKey]["obs_dyly_derived_heat_units_13C"] = (
                roundValue(dictHeatUnits["fltHeatUnits"], "000.0")
            )
            #
            dictHeatUnits = calculateHeatUnits(
                row["obs_dyly_temp_air_max"],
                row["obs_dyly_temp_air_min"],
                "30.0",
                "10.0",
            )
            dataDailyDerived[strOutputKey]["obs_dyly_derived_heat_units_10C"] = (
                roundValue(dictHeatUnits["fltHeatUnits"], "000.0")
            )
            #
            dictHeatUnits = calculateHeatUnits(
                row["obs_dyly_temp_air_max"],
                row["obs_dyly_temp_air_min"],
                "30.0",
                "7.22222",
            )
            dataDailyDerived[strOutputKey]["obs_dyly_derived_heat_units_7C"] = (
                roundValue(dictHeatUnits["fltHeatUnits"], "000.0")
            )
            #
            dictHeatUnits = calculateHeatUnits(
                row["obs_dyly_temp_air_max"],
                row["obs_dyly_temp_air_min"],
                "34.4444",
                "12.7778",
            )
            dataDailyDerived[strOutputKey]["obs_dyly_derived_heat_units_3413C"] = (
                roundValue(dictHeatUnits["fltHeatUnits"], "000.0")
            )

    csvfile.close()

    with open(path_derived_dyly, "r", newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            strAccessKey = row["obs_year"] + "." + row["obs_doy"]
            dataDailyDerivedOutputFields = list(row.keys())
            if strAccessKey in dataDailyDerived:
                row["obs_dyly_derived_heatstress_cotton_meanC"] = roundValue(
                    (
                        dataDailyDerived[strAccessKey]["fltAccumHeatStressC"]
                        / dataDailyDerived[strAccessKey]["intHoursHeatStressCotton"]
                    ),
                    "000.0",
                )
                row["obs_dyly_derived_heatstress_cotton_meanF"] = roundValue(
                    (
                        dataDailyDerived[strAccessKey]["fltAccumHeatStressF"]
                        / dataDailyDerived[strAccessKey]["intHoursHeatStressCotton"]
                    ),
                    "000.0",
                )
                #
                row["obs_dyly_derived_chill_hours_0C"] = dataDailyDerived[strAccessKey][
                    "obs_dyly_derived_chill_hours_0C"
                ]
                row["obs_dyly_derived_chill_hours_7C"] = dataDailyDerived[strAccessKey][
                    "obs_dyly_derived_chill_hours_7C"
                ]
                row["obs_dyly_derived_chill_hours_20C"] = dataDailyDerived[
                    strAccessKey
                ]["obs_dyly_derived_chill_hours_20C"]
                #
                row["obs_dyly_derived_chill_hours_32F"] = dataDailyDerived[
                    strAccessKey
                ]["obs_dyly_derived_chill_hours_0C"]
                row["obs_dyly_derived_chill_hours_45F"] = dataDailyDerived[
                    strAccessKey
                ]["obs_dyly_derived_chill_hours_7C"]
                row["obs_dyly_derived_chill_hours_68F"] = dataDailyDerived[
                    strAccessKey
                ]["obs_dyly_derived_chill_hours_20C"]

                row["obs_dyly_derived_heat_units_7C"] = dataDailyDerived[strAccessKey][
                    "obs_dyly_derived_heat_units_7C"
                ]
                row["obs_dyly_derived_heat_units_10C"] = dataDailyDerived[strAccessKey][
                    "obs_dyly_derived_heat_units_10C"
                ]
                row["obs_dyly_derived_heat_units_13C"] = dataDailyDerived[strAccessKey][
                    "obs_dyly_derived_heat_units_13C"
                ]
                row["obs_dyly_derived_heat_units_3413C"] = dataDailyDerived[
                    strAccessKey
                ]["obs_dyly_derived_heat_units_3413C"]

                row["obs_dyly_derived_heat_units_45F"] = roundValue(
                    (
                        convertHeatUnitCelsiusToHeatUnitFahrenheit(
                            dataDailyDerived[strAccessKey][
                                "obs_dyly_derived_heat_units_7C"
                            ]
                        )
                    ),
                    "000.0",
                )
                row["obs_dyly_derived_heat_units_50F"] = roundValue(
                    (
                        convertHeatUnitCelsiusToHeatUnitFahrenheit(
                            dataDailyDerived[strAccessKey][
                                "obs_dyly_derived_heat_units_10C"
                            ]
                        )
                    ),
                    "000.0",
                )
                row["obs_dyly_derived_heat_units_55F"] = roundValue(
                    (
                        convertHeatUnitCelsiusToHeatUnitFahrenheit(
                            dataDailyDerived[strAccessKey][
                                "obs_dyly_derived_heat_units_13C"
                            ]
                        )
                    ),
                    "000.0",
                )
                row["obs_dyly_derived_heat_units_9455F"] = roundValue(
                    (
                        convertHeatUnitCelsiusToHeatUnitFahrenheit(
                            dataDailyDerived[strAccessKey][
                                "obs_dyly_derived_heat_units_3413C"
                            ]
                        )
                    ),
                    "000.0",
                )

            datDailyDerivedOutput.append(row)
    csvfile.close()
    out_dyly = re.sub(r"(.+)(\.\w+$)", r"\1_updated\2", path_derived_dyly)
    with open(out_dyly, "w", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=dataDailyDerivedOutputFields)
        writer.writeheader()
        writer.writerows(datDailyDerivedOutput)

    csvfile.close()
