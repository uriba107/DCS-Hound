import math
import random


def gaussianRand(mean,sigma):
    rand = math.sqrt(-2 * sigma * math.log(random.random())) * math.cos(2 * math.pi * random.random()) + mean
    return rand

def angularErr(sigma):
    epsilon = {
        "az": 0,
        "el": 0
    }
    MAG = gaussianRand(0, sigma/2)
    ROT = random.random() * math.pi
    epsilon['az'] = -MAG*math.sin(ROT)
    epsilon['el'] = MAG*math.cos(ROT)
    print(MAG,ROT,epsilon)
    return epsilon

def NormalAngularErr(sigma=1):
        # https://en.m.wikipedia.org/wiki/Box%E2%80%93Muller_transform
    U1 = random.random()
    U2 = random.random()
    mag = math.sqrt( -2 * math.log(U1) ) * sigma/2
    Theta = 2 * math.pi * U2
    Z0 = mag * math.cos(Theta)
    Z1 = mag * math.sin(Theta)
    epsilon = {
        "az": Z0,
        "el": Z1
    }
    # if abs(epsilon["az"]) > abs(sigma) or abs(epsilon["el"]) > abs(sigma):
    # print(mag,math.degrees(Theta),math.degrees(epsilon["az"]),math.degrees(epsilon["el"]))
    return Z0

# for i in range(10000):
size = 10000
data = [NormalAngularErr(15) for c in range(size)]
mn = sum(data)/size
sd = (sum(x*x for x in data) / size - (sum(data)/size) ** 2) ** 0.5

print("mean = %g; stddev = %g" % (mn,sd))

