import math

bands = {
    "A": {"Freq": 175000000.0},
    "B": {"Freq": 375000000.0},
    "C": {"Freq": 750000000.0},
    "D": {"Freq": 1500000000.0},
    "E": {"Freq": 2500000000.0},
    "F": {"Freq": 3500000000.0},
    "G": {"Freq": 5000000000.0},
    "H": {"Freq": 7000000000.0},
    "I": {"Freq": 9000000000.0},
    "J": {"Freq": 15000000000.0},
    "K": {"Freq": 30000000000.0},
    "L": {"Freq": 50000000000.0}
}

platforms = {
            "Comms tower M": {"category": 0, "antenna":{"size":80, "factor":1}},
            # -- Ground Units
            "MLRS FDDM": {"category": 0, "antenna":{"size":15, "factor":1}},
            "SPK-11": {"category": 0, "antenna":{"size":15, "factor":1}},
            # -- Helicopters
            "CH-47D": {"category": 1, "antenna":{"size":12, "factor":1}},
            "CH-53E": {"category": 1, "antenna":{"size":10, "factor":1}},
            "MIL-26": {"category": 1, "antenna":{"size":20, "factor":1}},
            "SH-60B": {"category": 1, "antenna":{"size":8, "factor":1}},
            "UH-60A": {"category": 1, "antenna":{"size":8, "factor":1}},
            "Mi-8MT": {"category": 1, "antenna":{"size":8, "factor":1}},
            "UH-1H": {"category": 1, "antenna":{"size":4, "factor":1}},
            "KA-27": {"category": 1, "antenna":{"size":4, "factor":1}},
            # -- Airplanes
            "C-130": {"category": 2, "antenna":{"size":35, "factor":1}},
            "C-17A": {"category": 2, "antenna":{"size":50, "factor":1}},
            "S-3B": {"category": 2, "antenna":{"size":18, "factor":0.8}},
            "E-3A": {"category": 2, "antenna":{"size":9, "factor":0.5}},
            "E-2D": {"category": 2, "antenna":{"size":7, "factor":0.5}},
            "Tu-95MS": {"category": 2, "antenna":{"size":50, "factor":1}},
            "Tu-142": {"category": 2, "antenna":{"size":50, "factor":1}},
            "IL-76MD": {"category": 2, "antenna":{"size":48, "factor":0.8}},
            "H-6J": {"category": 2, "antenna":{"size":3.5, "factor":1}},
            "An-30M": {"category": 2, "antenna":{"size":25, "factor":1}},
            "A-50": {"category": 2, "antenna":{"size":9, "factor":0.5}},
            "An-26B": {"category": 2, "antenna":{"size":26, "factor":0.9}},
            "Su-25T": {"category": 2, "antenna":{"size":3.5, "factor":1}},
            "AJS37": {"category": 2, "antenna":{"size":4.5, "factor":1}},
            "F-16C": {"category": 2, "antenna":{"size":1.45, "factor":1}},
            "JF-17": {"category": 2, "antenna":{"size":3.25, "factor":1}},
            "EA-6B": {"category": 2, "antenna":{"size":9, "factor":1}},
            "C-47": {"category": 2, "antenna":{"size":12, "factor":1}},
            "RC135RJ": {"category": 2, "antenna":{"size":40, "factor": 1}},
        }

def genBandTable():
    print("HOUND.DB.Bands = {")
    for band in sorted(bands):
        bands[band]["wavelength"] = (299792458.0/bands[band]["Freq"])
        print("    [\"%s\"] = %f,"%(band,bands[band]["wavelength"]))
    print("}")

def calcResolution(wavelength,antenna):
    return math.degrees(wavelength/antenna)

def calcMinBand(antenna):
    for band in sorted(bands):
        val = calcResolution(bands[band]["wavelength"],antenna)
        if val < 10:
            return band

def genResolutionTable():
    for platform in sorted(platforms,key=lambda  item:  (platforms[item]['category'],item)):
        antenna = platforms[platform]["antenna"]["size"]*platforms[platform]["antenna"]["factor"]
        Hband = calcResolution(bands["H"]["wavelength"],antenna)
        CBand = calcResolution(bands["C"]["wavelength"],antenna)
        MinBand = calcMinBand(antenna)
        print ("| %s   |  %.2f / %.2f  | %s |"%(platform,CBand,Hband,MinBand))

def getAntennaSize(resDeg,band):
    resRad = math.radians(resDeg)
    print("for %.1f degrees on %s Band you need %fm sensor"%(resDeg,band,bands[band]["wavelength"]/resRad)) 
    return bands[band]["wavelength"]/resRad

def showRes(band,antenna):
    wavelength = bands[band]["wavelength"]
    print("%.2f antenna on %s Band resolution is %f deg"%(antenna,band,calcResolution(wavelength,antenna)))
    return calcResolution(wavelength,antenna)

print("=== Band wavelength data ===")
genBandTable()
print("\n=== ReadMe resolution data ===")
genResolutionTable()

print("\n=== Other stuff ===")


showRes("H",getAntennaSize(14.9,"C"))
showRes("C",1.6)
showRes("C",0.22*3.2)
showRes("F",0.5)
showRes("F",0.75)
