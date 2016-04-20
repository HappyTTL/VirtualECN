import numpy as np
from sklearn.svm import SVC
import matplotlib.pyplot as plt
import math
from mpl_toolkits.mplot3d import Axes3D
#'Server0_cnwd.txt'
def mean(values):
    sum = 0
    for i in values:
        sum += i
    return sum /len(values)
# data importing... 
print "load set 1 ....."
data1 = []
for filename in ['/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/receive_NewReno_S3_1.txt',
                 '/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/send_NewReno_S3_1.txt', 
                 '/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/ecn_NewReno_S3_1.txt',
                 '/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/rttRatio_NewReno_S3_1.txt']:
    print "importing..."+filename
    data1.append(np.genfromtxt(filename))
    print "importing done for "+filename

send1 = data1[1]
send1= np.around(send1, decimals = 6)
send_diff1 = np.diff(data1[1])
ack1 = data1[0]
ack1 = np.around(ack1, decimals = 6)
ack_diff1 = np.diff(data1[0])
ecn1 = np.asarray(data1[2])
rttRatio1 = data1[3]
rttRatio1 = np.around(rttRatio1, decimals = 6)
def ExpMovingAverage(values, window):
    weights = np.exp(np.linspace(-1., 0., window))
    weights /= weights.sum()

    # Here, we will just allow the default since it is an EMA
    a =  np.convolve(values, weights)[:len(values)]
    a[:window] = a[window]
    return a #again, as a numpy array.

print "computing EWMA..."
ack_ewma1 = ExpMovingAverage(ack_diff1,10)
send_ewma1 = ExpMovingAverage(send_diff1,10)

print "size of send, ack, ecn, ack_ewma and send_ewma"
print len(send1)
print len(ack1)
print len(ecn1)
print len(ack_ewma1)
print len(send_ewma1)


#data2 = []
#for filename in ['/Users/tingtinglu/Desktop/Dumbbell/receive_S1_Cubic.txt',
#                 '/Users/tingtinglu/Desktop/Dumbbell/send_S1_Cubic.txt', 
#                 '/Users/tingtinglu/Desktop/Dumbbell/ecn_S1_Cubic.txt',
#                 '/Users/tingtinglu/Desktop/Dumbbell/rttRatio_S1_Cubic.txt']:
#    print "importing..."+filename
#    data2.append(np.genfromtxt(filename))
#    print "importing done for "+filename
#
#send2 = data2[1]
#send2= np.around(send2, decimals = 6)
#send_diff2 = np.diff(data2[1])
#ack2 = data2[0]
#ack2 = np.around(ack2, decimals = 6)
#ack_diff2 = np.diff(data2[0])
#ecn2 = np.asarray(data2[2])
#rttRatio2 = data2[3]
#rttRatio2 = np.around(rttRatio2, decimals = 6)
##def ExpMovingAverage(values, window):
##    weights = np.exp(np.linspace(-1., 0., window))
##    weights /= weights.sum()
##
##    # Here, we will just allow the default since it is an EMA
##    a =  np.convolve(values, weights)[:len(values)]
##    a[:window] = a[window]
##    return a #again, as a numpy array.
#
#print "computing EWMA..."
#ack_ewma2 = ExpMovingAverage(ack_diff2,10)
#send_ewma2 = ExpMovingAverage(send_diff2,10)
#
#print "size of send, ack, ecn, ack_ewma and send_ewma"
#print len(send2)
#print len(ack2)
#print len(ecn2)
#print len(ack_ewma2)
#print len(send_ewma2)


print "construct train set..."
train = []

for i in range(1,len(ack1)):
    train.append([send_diff1[i-1], ack_diff1[i-1],send_ewma1[i-1], ack_ewma1[i-1], rttRatio1[i], ecn1[i]])
    #train.append([send_ewma2[i-1], ack_ewma2[i-1], rttRatio2[i]])
print "train set constructiong done!"

train = np.asarray(train)

y = []
for i in range(len(train)/2):
    y.append(ecn1[i+1])
    #y.append(ecn2[i+1])

y = np.asarray(y)


count = 0
for i in y:
    if i == 1:
        count += 1
print "ECN count is:"
print count


np.savetxt('/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_NewReno_S3_1.txt',train)