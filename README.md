## The code to decompose eye motifs using modified Behavior Atlas (BeA)

The raw code is [https://github.com/huangkang314/Behavior-Atlas](https://github.com/huangkang314/Behavior-Atlas)

The reference papers for the modification of BeA are  
[A hierarchical 3D-motion learning framework for animal spontaneous behavior mapping](https://www.nature.com/articles/s41467-021-22970-y)  
[Multi-animal 3D social pose estimation, identification and behaviour embedding with a few-shot learning framework](https://www.nature.com/articles/s42256-023-00776-5)  
[MouseVenue3D: A markerless three-dimension behavioral tracking system for matching two-photon brain imaging in free-moving mice](https://link.springer.com/article/10.1007/s12264-021-00778-6)  
[Objective and comprehensive re-evaluation of anxiety-like behaviors in mice using the Behavior Atlas](https://www.sciencedirect.com/science/article/abs/pii/S0006291X21005283)  
[S-ketamine exposure in early postnatal period induces social deficit mediated by excessive microglial synaptic pruning](https://www.nature.com/articles/s41380-025-02949-7)  

### step1: step1_sep_data_eye.m
Split raw eye data into temporal series
### step2: step2_run_batch_eye.m
Using modified BeA to decmopose the eye motifs
### step3: step3_multi_cluster_eye.m
Using multiple step clustering to cluster eye motifs
