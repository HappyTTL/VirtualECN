import pandas as pd
import random 
import numpy as np
from sklearn import svm
import matplotlib.pyplot as plt
import math
from mpl_toolkits.mplot3d import Axes3D
from sklearn import tree
from sklearn.ensemble import RandomForestClassifier
# read send.txt and receive.txt files for node 1 (NewReno)
data1 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_NewReno_S1_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
data2 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_Cubic_S1_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
#data3 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_NewRenoVSUDPExp_S1_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
#data4 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_CubicVSUDPExp_S1_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
#data5 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_CubicVSUDPPareto_S1_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
#data6 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_NewRenoVSUDPCBR_S1_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
#data7 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_NewReno_S1_OnOff_Det_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
#data8 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_NewReno_S1_OnOff_Exp_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
#data9 = pd.read_csv("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/5features_dataSet_Cubic_S1_OnOff_Exp_1.txt", sep = ' ', names = ['send_diff', 'receive_diff', 'send_ewma', 'receive_ewma', 'rtt_ratio', 'ecn'])
frames = [data1, data2]
DATA = pd.concat(frames)

send_diff = DATA['send_diff'].values.tolist()
receive_diff = DATA['receive_diff'].values.tolist()
send_ewma = DATA['send_ewma'].values.tolist()
receive_ewma = DATA['receive_ewma'].values.tolist()
rtt_ratio = DATA['rtt_ratio'].values.tolist()
ecn = DATA['ecn'].values.tolist()

full_data = []
for row in DATA.iterrows():
    index,data = row
    full_data.append(data.tolist())
    
random.shuffle(full_data)
full_data = np.asarray(full_data)
from sklearn import linear_model
from sklearn import cross_validation as cv
from sklearn.metrics import roc_curve, auc
import pylab as pl


print "train test set split..."

# X_train,X_test,y_train,y_test=cv.train_test_split(train,y,test_size=0.2, random_state=0)
X_train = full_data[:int(full_data.shape[0]*0.7),:5]
X_test = full_data[int(full_data.shape[0]*0.7)+1:,:5]
y_train = full_data[:int(full_data.shape[0]*0.7),5]
y_test =  full_data[int(full_data.shape[0]*0.7)+1:,5]
print "spliting complete."



#np.savetxt('/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/train_test_data/S1_1_X_train.txt',X_train)
#np.savetxt('/Users/tingtinglu/Desktop/Dumbbell/train_test_data/S1_1_y_train.txt',y_train)
#np.savetxt('/Users/tingtinglu/Desktop/Dumbbell/train_test_data/S1_1_X_test.txt',X_test)
#np.savetxt('/Users/tingtinglu/Desktop/Dumbbell/train_test_data/S1_1_y_test.txt',y_test)


pos = np.where(y_train == 1)[0].tolist()
neg = np.where(y_train == 0)[0].tolist()
X_train11 = []
X_train12 = []
X_train13 = []
X_train21 = []
X_train22 = []
X_train23 = []
for item in X_train[pos]:
    X_train11.append(item[0])
    X_train12.append(item[1])
    X_train13.append(item[2])
for item in X_train[neg]:
    X_train21.append(item[0])
    X_train22.append(item[1])
    X_train23.append(item[2])
#for ii, jj in zip(X_train[pos], X_train[neg])
# plt.plot(X_train11, X_train12, 'r+', label = 'ecn=1')
# plt.plot(X_train21, X_train22, 'y*', label = 'ecn=0')
# plt.xlabel('send_ewma')
# plt.ylabel('ack_ewma')
# plt.legend(loc=1)
# plt.title('ECN distribuction with using NewReno')
# plt.show()
#fig = plt.figure(1)
#ax = fig.add_subplot(111,projection = '3d')
#ax.scatter(X_train11,X_train12,X_train13, c='r', marker = 'o', label = 'ecn = 1')
#ax.scatter(X_train21,X_train22,X_train23, c='y', marker = '+', label = 'ecn = 0')
#
#ax.set_xlabel('RTT Ratio')
#ax.set_ylabel('send_ewma')
#ax.set_zlabel('ack_ewma')
#plt.show()
#
#for c_val in [1]: #,2.5,5.0,10.0]:
c_val = 1
clf = linear_model.LogisticRegressionCV(penalty='l2')
#clf = tree.DecisionTreeClassifier(max_depth = 5, min_samples_leaf = 10000)
#clf = RandomForestClassifier(n_estimators=10)
#clf = svm.SVC()
clf.fit(X_train,y_train)
#from sklearn.externals.six import StringIO
#with open("/Users/tingtinglu/Desktop/Dumbbell_ServerDataProcess/tree.dot", 'w') as f:
#    f = tree.export_graphviz(clf,out_file=f)

probas_ = clf.predict_proba(X_test)
#predict_ = clf.predict(X_test)
#params_ = clf.get_params(deep = True)
fpr, tpr, thresholds = roc_curve(y_test, probas_[:,1])
print clf.score(X_test, y_test)
roc_auc = auc(fpr, tpr)
#auc_list.append(roc_auc)
print(clf.coef_)
print(clf.intercept_)
print("Area under the ROC curve : %f" % roc_auc)
#print(clf.feature_importances_)
plt.figure(2)
plt.plot(fpr, tpr, label='ROC (area = %0.2f)' % (roc_auc))
plt.plot([0, 1], [0, 1], 'k--')
    
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.0])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ECN Prediction ROC')
plt.legend(loc="lower right")
plt.show()
