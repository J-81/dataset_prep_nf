#! /usr/bin/env python
#
# This script is formatted to work on TSV cluster listings output by mmseqs2
######
import sys


import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.graph_objects as go



#clustersFile = "/home/joribello/Documents/OneDrive/Research/Spring_2020_Research/dataset_prep_nf/work/ab/3172762650b79ea83e70c95ff92638/cluster_cluster.tsv"
clustersFile = sys.argv[1] ## INPUT

## Load dataset
df = pd.read_csv(clustersFile,
                 delimiter='\t',
                 names=["ClusterRep","ClusterMember"])

## Preprocessing
clusterRepList = df.ClusterRep.unique()
clusterSizeDf = df.pivot_table(index=["ClusterRep"], aggfunc=[len])
clusterSizeDf = clusterSizeDf.sort_values(by=[('len', 'ClusterMember')], ascending=False)
clusterSizeDf.columns = clusterSizeDf.columns.get_level_values(0)

## MASKS
mask_no_singletons = (clusterSizeDf['len'] > 1)

mask_dummy = (clusterSizeDf['len'] != -1) # all true
##


## Raw Graphs
#%matplotlib inline
maskToUse = mask_dummy
graphDf = clusterSizeDf.loc[maskToUse]

fig, (ax1, ax2) = plt.subplots(2, 1);

sns.boxplot(data=graphDf, y=['len'], ax=ax1);
ax1.set_ylabel('# of Cluster Members')
sns.distplot(a=graphDf['len'], kde=False, ax=ax2);
fig.tight_layout(rect=[0, 0.03, 1, 0.95])
fig.suptitle("Cluster Member Sizes")
#fig
fig.savefig("Cluster-Member-Sizes.png"); ## OUTPUT


## Graphs with singletons excluded
maskToUse = mask_no_singletons
graphDf = clusterSizeDf.loc[maskToUse]

fig, (ax1, ax2) = plt.subplots(2, 1);

sns.boxplot(data=graphDf, y=['len'], ax=ax1);
ax1.set_ylabel('# of Cluster Members');
sns.distplot(a=graphDf['len'], kde=False, ax=ax2);
fig.tight_layout(rect=[0, 0.03, 1, 0.95])
fig.suptitle("Cluster Member Sizes, exclude singletons");
#fig
fig.savefig("Cluster-Member-Sizes-exclude-singletons.png"); ## OUTPUT


## Plotly Graph
# Create figure
fig = go.Figure()

for step in range(0,11,1):
    graphDf = clusterSizeDf['len'].loc[(clusterSizeDf['len'] > step)]
    fig.add_trace(
        go.Histogram(x=graphDf,
                     visible=False,
                     name=f"Min Cluster Size = {step}")
    )
# Make last trace visible
fig.data[-1].visible = True

# Create and add slider
steps = []
for i in range(len(fig.data)):
    total_members = len(clusterSizeDf['len'].loc[(clusterSizeDf['len'] > i)])
    step = dict(
        method="update",
        args=[{"visible": [False] * len(fig.data)},
              {"title": f"Cluster Size Distribution,excluding Clusters with less than: {i+1} members ({total_members} total)"}],  # layout attribute
    )
    step["args"][0]["visible"][i] = True  # Toggle i'th trace to "visible"
    steps.append(step)

sliders = [dict(
    active=10,
    currentvalue={"prefix": "Minimum Cluster Size: "},
    pad={"t": 50},
    steps=steps
)]

fig.update_layout(
    sliders=sliders
)
fig.write_html('interactive.html', include_plotlyjs='cdn') ## OUTPUT
