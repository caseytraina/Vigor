import pandas as pd
import numpy as np
from datetime import datetime, timedelta, timezone
from sklearn.cluster import DBSCAN
import math
from geopy.distance import distance
import firebase_admin
from firebase_admin import credentials, firestore
import numpy as np
#utility
from dateutil import parser
import pytz
firebase_admin.initialize_app()
db = firestore.client()
user_id = "PRRRkOFxB3NLrvKTgRmC9gLzzzg2"

def enumerate_days():
    # Get today's date
    today = datetime.today().date()
    # Generate dates for today plus the previous 8 days
    dates = pd.date_range(end=today, periods=8, freq='D')
    return dates

def call_firebase(date):
    cred = credentials.Certificate("vigor-f7d30-firebase-adminsdk-11ggd-de068a2273.json")
    if not firebase_admin._apps:  # Check if not initialized to avoid reinitialization error
        firebase_admin.initialize_app(cred)

    # Fetch data from Firestore
    gpsRef = db.collection("users").document(user_id).collection("scores").document(date).collection("gps")
    docs1 = gpsRef.get()
    gpsRef2 = db.collection("users").document(user_id).collection("scores").document(date).collection("sleep")
    docs2 = gpsRef2.get()
    gpsRef3 = db.collection("users").document(user_id).collection("scores").document(date).collection("phone")
    docs3 = gpsRef3.get()

    data_list, sleep, phone = [], [], []
    for doc in docs1:
        doc_data = doc.to_dict()
        if 'location' in doc_data and 'timestamp' in doc_data:
            latitude = doc_data['location'].latitude
            longitude = doc_data['location'].longitude
            timestamp = doc_data['timestamp']
            data_list.append([longitude, latitude, timestamp])

    for doc in docs2:
        doc_data = doc.to_dict()
        if 'hours slept' in doc_data:
            sleep.append(doc_data['hours slept'])

    for doc in docs3:
        doc_data = doc.to_dict()
        if 'seconds' in doc_data:
            phone.append(doc_data['seconds'])
    
    return data_list, sleep, phone

def eight_day_firebase_call():
    dfs, sleeps, phones, times = [], [], [], []
    for day in enumerate_days()[0:-1]:
        times.append(day.strftime("%Y-%m-%d"))
        data_list, sleep, phone = call_firebase(day.strftime("%Y-%m-%d"))
        sleeps.extend(sleep)
        phones.extend(phone)
        if data_list:
            dfs.append(pd.DataFrame(data_list, columns=['longitude', 'latitude', 'timestamp']))
    
    # Creating DataFrames for sleeps and phones with correct structure
    sleep_df = pd.DataFrame({'timestamp': times, 'sleep': sleeps})
    phone_df = pd.DataFrame({'timestamp': times, 'seconds': phones})
    sleep_df['timestamp'] = pd.to_datetime(sleep_df['timestamp'], utc=True)
    phone_df['timestamp'] = pd.to_datetime(phone_df['timestamp'], utc=True)
    gps_df = pd.concat(dfs, ignore_index=True) if dfs else pd.DataFrame()
    return sleep_df, phone_df, gps_df
def parse_timestamp(timestamp_str):
    return timestamp_str
def get_time_spent(times):
    time_spent = []
    for i in range(0, len(times)):
        if i == (len(times)-1):
            time_spent.append(0)
        else:
            time_spent.append(float((parse_timestamp(times[i+1]) -
                              parse_timestamp(times[i])).total_seconds()))
    return time_spent

def load_data():
  return pd.read_csv("sample_geodata.csv").head(2000)

def load_data_preprocessed(df):
  lats, longs, times = (df["latitude"].astype(float).to_list(),
                        df["longitude"].astype(float).to_list(),
                        df["timestamp"].to_list())
  xyz_data = [lat_lon_to_xyz_earth(lat,lon) for lat,lon in zip(lats, longs)]
  x_list, y_list, z_list = (zip(*xyz_data))
  time_spent = get_time_spent(times)
  array = np.array([lats, longs, list(x_list), list(y_list), list(z_list), time_spent, times]).T
  df =  pd.DataFrame(array, columns = ["latitude", "longitude", "x", "y", "z", "time-spent", "timestamp"])
  df["latitude"] = df['latitude'].astype("float")
  df["longitude"] = df['longitude'].astype("float")
  #df['timestamp'] = df['timestamp'].apply(datetime.fromisoformat)
  df['timestamp'] = pd.to_datetime(df['timestamp'])
  df["time-spent"] = df["time-spent"].astype(float)
  return df

def lat_lon_to_xyz_earth(lat, lon, radius=6371):

    lat_rad = math.radians(lat)
    lon_rad = math.radians(lon)

    # Calculate x, y, z
    x = radius * math.cos(lat_rad) * math.cos(lon_rad)
    y = radius * math.cos(lat_rad) * math.sin(lon_rad)
    z = radius * math.sin(lat_rad)

    return x, y, z

# clustering
def geodesic_distance(row1, row2):
  return distance((row1[0], row1[1]), (row2[0],row2[1])).miles

def cluster(lat_lon_data, eps=0.02, min_samples = 2, metric = "euclidean"):
  db = DBSCAN(eps = eps, min_samples = min_samples, metric = metric)
  labels = db.fit_predict(lat_lon_data)
  return labels

def get_clusters(df):
  cluster_labels = cluster(df[["x", "y", "z"]].to_numpy())
  df["label"] = cluster_labels
  return df

def time_spent_at_cluster():
  pass

def mean_time_at_cluster():
  pass

def get_cluster_data(time_spents, times, clusters):
  clusters_unique = np.unique(clusters)
  num_clusters = len(clusters_unique)
  cluster_visits = []
  total_cluster_times = [0 for i in range(num_clusters)]

  prev_label = -2
  cluster_idx_adjustment = 1 if -1 in clusters_unique else 0
  for time, time_spent, cluster in zip(times, time_spents, clusters):
    time_spent = float(time_spent)
    cluster_index = cluster + cluster_idx_adjustment
    total_cluster_times[cluster_index] += float(time_spent)
    if cluster == prev_label:
      cluster_visits[-1][-1] += float(time_spent)
    else:
      if prev_label != -2:
        cluster_visits[-1][2] = time
      cluster_visits.append([cluster, time, None, float(time_spent)])
      prev_label = cluster

  return cluster_visits, total_cluster_times

def get_df_by_date_range(df, end_date, start_date):
  return df[(df['timestamp'] >= start_date) & (df['timestamp'] <= end_date)]

def today():
  today_utc = datetime.now(timezone.utc)
  return today_utc

class ClusterAnalysis():

  def __init__(self, df):
    self.cluster_occurences, self.total_cluster_times = get_cluster_data(df["time-spent"].to_list(),
                                           df["timestamp"].to_list(),
                                           df["label"].to_list())

  def num_clusters(self):
    n = len(self.total_cluster_times)
    if self._has_outliers():
      return n-1
    else:
      return n

  def mean_length_stay_at_clusters(self):
    time_total = 0
    num_stays = 0
    for data in self.cluster_occurences:
      cluster, time_spent = data[0], data[-1]
      if cluster != -1:
        num_stays += 1
        time_total += time_spent
    return time_total/num_stays

  def std_length_stay_at_clusters(self):
    stays = []
    for data in self.cluster_occurences:
      cluster, time_spent = data[0], data[-1]
      if cluster != -1:
        stays.append(time_spent)
    return np.std(stays)

  def num_transitions(self):
    return len([co for co in self.cluster_occurences if co[0]!=-1])

  def _has_outliers(self):
    for oc in self.cluster_occurences:
      if oc[0]==-1:
        return True
    return False

  def location_entropy(self):
    start_idx = 0
    if self._has_outliers():
      start_idx = 1
    entropy = 0
    total_time = np.sum(self.total_cluster_times[start_idx:])
    for cluster_idx, cluster_time in enumerate(self.total_cluster_times[start_idx:]):
      cluster = cluster_idx - start_idx
      p = cluster_time/total_time
      entropy += p * math.log(p)
    return -1*entropy

  def normalized_location_entropy(self):
    return self.location_entropy()/(math.log(self.num_clusters()))
  
  # properties
def total_time_slept(df):
  return np.sum(df["sleep"].to_numpy())

def location_variance(data):
  lat_var = np.var(data["latitude"].to_numpy())
  long_var = np.var(data["longitude"].to_numpy())
  return math.log(math.pow(lat_var, 2), math.pow(long_var, 2))

def log_location_variance(df):
  return math.log(location_variance(df))

def screen_avg_duration(df):
  return np.mean(df["seconds"].to_numpy())

class Metric():
  dp_mu = 0
  non_dp_mu = 0 # a weight of 1 indicates correlation between metric and good mental health
            # weight of -1 indicates that a decrease in metric should increase score

  def __init__(self, df):
   self.df = df
   self.new = None

  def new_df(self):
    return get_df_by_date_range(self.df, today(), today() - timedelta(days=7))

  def past_df(self):
    return get_df_by_date_range(self.df, today() - timedelta(days=1), today() - timedelta(days=7))

  def percent_change(self):
    self.new = self._compute(self.new_df())
    prev = self._compute(self.past_df())
    delta = self.new - prev
    return delta*self.weight()/prev

  def weight(self):
    if self.non_dp_mu > self.dp_mu:
      return 1
    else:
      return -1

  def _compute(self, data):
    return 0

  def distance(self, num1, num2):
    dist = abs(num2-num1)
    return dist

  def depression_indicator(self):
    if self.new is None:
      self.new = self.new_df()

    if self.distance(self.new, self.non_dp_mu) > self.distance(self.new, self.dp_mu):
      return 1
    else:
      return 0

class Log_Location_Variance(Metric):
  dp_mu = -5.628
  non_dp_mu = -4.552

  def _compute(self,data):
    return log_location_variance(data)

class Mean_Length_Stay_At_Clusters(Metric):
  dp_mu = 282.678
  non_dp_mu = 154.272

  def _compute(self, data):
    ca = ClusterAnalysis(data)
    return ca.mean_length_stay_at_clusters()

class Num_Transitions(Metric):
  dp_mu = 11.367
  non_dp_mu = 19.362

  def _compute(self, data):
    ca = ClusterAnalysis(data)
    return ca.num_transitions()


class Num_Significant_Locations(Metric):
  dp_mu = 5.07
  non_dp_mu = 7.931

  def _compute(self, data):
    ca = ClusterAnalysis(data)
    return ca.num_clusters()

class Location_Entropy(Metric):
  dp_mu = 0.338
  non_dp_mu = 0.575

  def _compute(self, data):
    ca = ClusterAnalysis(data)
    return ca.location_entropy()

class Normalized_Location_Entropy(Metric):
  dp_mu = 0.176
  non_dp_mu = 0.283

  def _compute(self, data):
    ca = ClusterAnalysis(data)
    return ca.normalized_location_entropy()

class Total_Time_Slept(Metric):
  dp_mu = 26552.725
  non_dp_mu = 25636.348

  def _compute(self, data):
    return total_time_slept(data)


class Screen_Avg_Duration(Metric):

  def _compute(self, data):
    return screen_avg_duration(data)

  def depression_indicator(self):
    if self.new is None:
      self.new = self.new_df()

    if self.new > 6*60:
      return 1
    else:
      return 0
    
def habit_score(percent_changes):
  num_metrics = len(percent_changes)
  sum = 0
  for pc in percent_changes:
    sum+=(50/num_metrics)*(1+pc)
  return sum

def get_scores():
    sleep, phone, df = eight_day_firebase_call()
    df = df.sort_values(by='timestamp', ascending=True) 
    df = load_data_preprocessed(df)
    df = get_clusters(df)

    metrics = [
    Log_Location_Variance,
    Mean_Length_Stay_At_Clusters,
    Num_Transitions,
    Num_Significant_Locations,
    Location_Entropy,
    Normalized_Location_Entropy,
    Total_Time_Slept,
    Screen_Avg_Duration
    ]

    percent_changes = []
    indications = []
    for metric in metrics[0:-2]:
        instance = metric(df)
        percent_changes.append(instance.percent_change())
        indications.append(instance.depression_indicator())
    for df, metric in zip([sleep, phone], metrics[-2:]):
        instance = metric(df)
        percent_changes.append(instance.percent_change())
        indications.append(instance.depression_indicator())

    h_score = int(habit_score(percent_changes))
    indication_score = int(np.sum(indications)/len(indications))

    ref = db.collection("users").document(user_id).collection("scores").document(today().strftime("%Y-%m-%d"))
    data = {
        "comparison": h_score,
        "depression": indication_score
    }
    ref.set(data)
