# LANG-54b and ES-21975

Frame __LANG-54b-1__ and __ES-21974-5__ are the only two frames with _p_-value less than _0.05_ in the VD.A analyses between [__BV__] and [__BV-control__].

Frame __LANG-54b-1__ is straightforward to reproduce as both configurations have a reproduction rate of 100% for frame __LANG-54b-1__.
However, it has seen a significant efficiency drop with our proposed method.
On average, it takes 344.33 fitness evaluations for [__BV__] to cover the target frame.
However, fairly early in the search process (7.3 fitness evaluations on average), 11 out of the 24 diversity objectives are already covered.
Afterwards, new diversity objectives are rarely covered.
Frame __ES-21974-5__ has seen a significant improvement in efficiency.
One observation is that new diversity objectives have been covered throughout the search process.