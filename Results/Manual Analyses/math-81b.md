# MATH-81b
Crash __MATH-81b__ has seen an improvement in reproduction rate, but a decrease in efficiency.
Shown in __[Listing 1](#listing-1-stack-trace-of-math-81b)__ is the input stack trace of it.

#### Listing 1: Stack Trace of MATH-81b
``` log
java.lang.ArrayIndexOutOfBoundsException: -1
  at org.apache.commons.math.linear.EigenDecompositionImpl.computeShiftIncrement(EigenDecompositionImpl.java:1544)
  at org.apache.commons.math.linear.EigenDecompositionImpl.goodStep(EigenDecompositionImpl.java:1071)
  at org.apache.commons.math.linear.EigenDecompositionImpl.processGeneralBlock(EigenDecompositionImpl.java:893)
  at org.apache.commons.math.linear.EigenDecompositionImpl.findEigenvalues(EigenDecompositionImpl.java:657)
  at org.apache.commons.math.linear.EigenDecompositionImpl.decompose(EigenDecompositionImpl.java:246)
  at org.apache.commons.math.linear.EigenDecompositionImpl.<init>(EigenDecompositionImpl.java:205)
```

The interface `EigenDecomposition` defines methods to calculate the eigen decomposition of a real matrix.
The provided implementation of it, `EigenDecompositionImpl`, translates an algorithm from a Fortran library [LAPACK](http://performance.netlib.org/lapack/) to fulfill the interface.
During the translation, a number of mistakes were made, resulting in the bug.

All inner five frames point to private methods and the constructor `<init>` at frame 6 is the only public method in the stack trace.
The GGA can only target frames of public or protected methods.
When the target method is private, it tries to invoke that method indirectly with public or protected methods.
In the source code, the methods from the inner five frames have only one public indirect caller, which is the constructor from frame 6.
Setting the _target frame_ to any one of the inner five frames is in effect the same as setting it to the sixth frame.
Therefore, all the 180 executions are grouped together for our evaluation.

Because of the fact that the exception is thrown after several complicated mathematical computations and it is buried six frames deep, to reproduce the crash, one needs to provide two sophisticatedly composed `double` arrays to the constructor.
With `IntegrationTestingFF`, no guidance regarding how the two arrays should be mutated is provided.
With `ITFFForIndexedAccess`, the distance of how far the accessed index is away from being out of bounds, indeed leads the search process to the optimal test case more often, as supported by the results.
However, the increment in reproduction rate, with an odds ratio of _1.5212_, comes with a decrement in efficiency, with A<sub>12</sub> = _0.6194_.