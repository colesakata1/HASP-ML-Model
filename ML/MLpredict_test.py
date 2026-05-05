from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import pandas as pd
import numpy as np
from joblib import dump, load, parallel_backend
import matplotlib.pyplot as plt

df = pd.read_excel("newmodelValidation.xlsx")   
arr = df.to_numpy()
arr = np.delete(arr, 0, axis=0)
X_test = np.delete(arr,5,axis=1) 

y = (arr[:, [5]])
y_test = (np.ravel(y))
with parallel_backend('threading', n_jobs=2): 
    clf = load("mlclf29.joblib")

    y_pred = clf.predict(X_test)

    # 1. Basic accuracy score
    print("Accuracy Score:", accuracy_score(y_test, y_pred))
    print("=" * 50)

    # 2. Detailed classification report (precision, recall, F1-score)
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    print("=" * 50)

    # 3. Confusion Matrix
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    print("=" * 50)

    # 4. Show some individual predictions vs actual values
    print("\nSample Predictions (first 20):")
    comparison = pd.DataFrame({
        'Actual': y_test[:20].flatten(),
        'Predicted': y_pred[:20].flatten()
    })
    print(comparison)

    # 5. Count correct vs incorrect predictions
    correct = (y_pred == y_test).sum()
    total = len(y_test)
    print(f"\nCorrect predictions: {correct}/{total} ({100*correct/total:.2f}%)")
    loss_sum = np.zeros(total)
    accuracy_values = []
    for i in range(total):
        loss_sum[i] = (abs(y_test[i] - y_pred[i]))/2
        if(i > 0):
            loss_sum[i] = loss_sum[i-1] + loss_sum[i]
            accuracy_values.append(1-loss_sum[i]/i)
    
slope, intercept = np.polyfit(list(range(len(accuracy_values))), accuracy_values, 1)
#powerrange = [x**2 for x in list(range(len(accuracy_values)))]
y_fit = slope * np.array(list(range(len(accuracy_values)))) + intercept

plt.plot(list(range(len(accuracy_values))), accuracy_values, marker='o', linestyle='', alpha=0.5)
plt.plot(list(range(len(accuracy_values))), y_fit, color='red', label='Linear Fit')
plt.ylabel('Cumulative Accuracy')
plt.xlabel('Sample Index')
print(slope, intercept)
plt.title(f'Prediction Accuracy Over Time, with Linear Fit {slope}*index + {intercept:.4f}')
plt.legend()
plt.show()