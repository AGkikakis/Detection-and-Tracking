# Detection-and-Tracking
Detection and tracking of dancers

The main goal is to reliably detect and track several interacting individuals, as observed in a video acquired
from an overhead camera. The algorithm is used in sequence of images of 4 people dancing, as
seen by an overhead camera.

The tasks of this algorithm are:

  1. Detect the moving people,
  2. Compute a trajectory for each person through all frames (taking account of interactions),and
  3. Evaluate the correctness of the detections and tracking against a ground truth dataset.
