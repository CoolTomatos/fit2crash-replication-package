# LANG-19b
Crash __LANG-19b__ has seen differences in both the reproduction rate and the efficiency.
The input stack trace of it contains 3 frames, as shown in __[Listing 1](#listing-1-stack-trace-of-lang-19b)__.
And the VD.A measures of all 3 frames is shown in __[Table 1](#table-1-effect-size-of-lang-19b)__.

#### Listing 1: Stack Trace of LANG-19b
``` log
java.lang.StringIndexOutOfBoundsException: String index out of range: 19
  at org.apache.commons.lang3.text.translate.NumericEntityUnescaper.translate(NumericEntityUnescaper.java:54)
  at org.apache.commons.lang3.text.translate.CharSequenceTranslator.translate(CharSequenceTranslator.java:86)
  at org.apache.commons.lang3.text.translate.CharSequenceTranslator.translate(CharSequenceTranslator.java:59)
```

#### Table 1: Effect Size of Lang-19b
| Frame | A<sub>12</sub> | _p_-value | Magnitude |
| :---: | -------------: | --------: | :-------: |
|   3   |         0.1771 |   0.00191 |   large   |
|   2   |         0.2969 |   0.23737 |  medium   |
|   1   |         0.3229 |   0.04552 |  medium   |

The `NumericEntityUnescaper` extends the `CharSequenceTranslator` and overwrites the `translate` method to translate a XML formatted numeric entity into a codepoint in a `String`.
For example, "Coke \&#174;" is translated into "Coke <a>&#174;</a>".
Each numeric entity ends with a `;` and `NumericEntityUnescaper` locates the semi-column with the loop shown in __[Listing 2](#listing-2-bug-of-lang-19b)__.

#### Listing 2: Bug of LANG-19b
``` java
52 | int end = start;
53 | // Comment
54 | while(input.charAt(end) != ';')
55 | {
56 |     end++;
57 | }
```

However, when a numeric entity is mal-formatted in the way that the closing semi-column is missing, the loop continues increasing the local variable `end` till it is equal to the `length` of the `input` when a `StringIndexOutOfBoundsException` is thrown at line 54.
Therefore, to reproduce the crash, one needs to call the `translate` method with a mal-formatted XML numerical entity.

Taking the example of `&#174;` again, one straightforward way that Botsing uses to mutate it is to append another valid numeric entity to it, which results in `&#174;&#173;` for example.
During Botsing's search process, with the original `IntegrationTestingFF`, the two strings result in a fitness value of _1.0_ as there is no exception thrown.
Botsing keeps mutating the `input`.
Chances are that the ending `;` will be removed and the crash will be reproduced.

With `ITFFForIndexedAccess`, the `length` of `&#174;` is _6_ and the last visited index is _5_, which results in a fitness value of _0.2857_.
As for `&#174;&#173;`, it gets a `length` of _12_ and the last visited index _11_.
The fitness value is then reduced to _0.1538_.
The decrement in the fitness value is heavily favoured by the selection process and Botsing tends to append the well-formatted numeric entities longer and longer as the fitness value keeps decreasing.
In the end, the search process is lead to a local optima, with fitness values as small as _3.202e<sup>-4</sup>_, and may never try the correct mutation of removing the ending `;`.

When the search process is not trapped, VD.A measures in __[Table 1](#table-1-effect-size-of-lang-19b)__ show a significant improvement for both the first frame and the third frame in terms of efficiency to reduce fitness value from _1.0_ to _0.0_.