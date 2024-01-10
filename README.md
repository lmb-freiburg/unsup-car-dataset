Code for the paper "Unsupervised Generation of a Viewpoint Annotated Car Dataset from Videos", ICCV 2015

Terms of use
------------

The code is provided for research purposes only. Any commercial
use is prohibited. If you are interested in a commercial use, please 
contact the copyright holder. 

Please cite the following paper if you use this code or its parts in your research:

	@InProceedings{SB15,
  	author       = "N. Sedaghat and T. Brox",
  	title        = "Unsupervised Generation of a Viewpoint Annotated Car Dataset from Videos",
	booktitle    = "IEEE International Conference on Computer Vision (ICCV)",
  	year         = "2015",
  	url          = "http://lmb.informatik.uni-freiburg.de//Publications/2015/SB15"
	}

Please report bugs and problems to Nima Sedaghat ( nima@cs.uni-freiburg.de )

Installation Requirements
--------------------------

External software/libraries -- not included:
   * VisualSFM (http://ccwu.me/vsfm/) + SiftGPU (http://www.cs.unc.edu/~ccwu/siftgpu/)
   * SSD (http://mesh.brown.edu/ssd/)

External software/libraries -- included in the 'extern' directory:
   * Compute mesh normals (http://de.mathworks.com/matlabcentral/fileexchange/29585-compute-mesh-normals)
   * ransac (http://www.peterkovesi.com/matlabfns/index.html)  
	only these files are necessary: ransac.m fitplane.m ransacfitplane.m iscolinear.m

Data
-----
Download input car videos from [here](https://lmb.informatik.uni-freiburg.de/resources/datasets/FreiburgStaticCars52/freiburg_static_car_vids.tar.gz) -- videos of 52 static cars, covering almost the whole 360 degrees around the car. 
Download resulting dataset from [here](https://lmb.informatik.uni-freiburg.de/resources/datasets/FreiburgStaticCars52/freiburg_static_cars_52_v1.1.tar.gz) -- viewpoint- and bounding box-annotated car images. 


(Non-)Deterministic Behaviour
------------------------------

Some external components show random behaviour, which result in non-deterministic results that cannot be exactly reproduced 
across multiple runs.
The closest you can get to a deterministic behaviour is by:
1. setting 'settings.deterministic = 1' in the file setup.m
2. setting 'param_deterministic_behaviour 1' in the file [VisualSFM Path]/bin/nv.ini

However, the results can still vary noticeably -- unless you use another SFM package, where you can control its behaviour completely.

