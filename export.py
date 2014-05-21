#!/usr/bin/env python

import bson
import pickle
import json

with open('/Users/kcarnold/Data/kcarnold/kernlearn/latest/kernlearn1/mles.bson', 'rb') as f:
    models = bson.decode_all(f.read())
    models = [model for model in models if model['group'] == 'sampled_ideas50']

with open('/Users/kcarnold/Data/kcarnold/kernlearn/latest/kernlearn1/items.bson', 'rb') as f:
    items = [item for item in bson.decode_all(f.read()) if item['group'] == 'sampled_ideas50']
    items.sort(key=lambda item: item['idx'])
    items = [item['data'] for item in items]

latest = sorted(models, key=lambda model: model['createdAt'], reverse=True)[0]
mle = pickle.loads(latest['object'], encoding='latin1') # Silly encoding!

with open('export.json', 'w') as f:
    embedding = mle['embedding'].tolist()
    comparisons = mle['comparisons']
    json.dump(dict(embedding=embedding, comparisons=comparisons, items=items), f)
