```python
from scipy import spatial

vec1 = [1, 2, 3, 4]
vec2 = [5, 6, 7, 8]

cos_sim = 1 - spatial.distance.cosine(vec1, vec2)

print(cos_sim)
```

    0.9688639316269664
    


```python
import numpy as np
vec1 = np.array([1, 2, 3, 4])
vec2 = np.array([5, 6, 7, 8])

cos_sim = vec1.dot(vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2))
print(cos_sim)
```

    0.9688639316269662
    


```python
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
vec1 = np.array([1, 2, 3, 4])
vec2 = np.array([5, 6, 7, 8])

cos_sim = cosine_similarity(vec1.reshape(1, -1), vec2.reshape(1, -1))
print(cos_sim[0][0])
```

    0.9688639316269663
    


```python
import torch
import torch.nn.functional as F

vec1 = torch.FloatTensor([1, 2, 3, 4])
vec2 = torch.FloatTensor([5, 6, 7, 8])

cos_sim = F.cosine_similarity(vec1, vec2, dim=0)
print(cos_sim) 
```

    tensor(0.9689)
    
