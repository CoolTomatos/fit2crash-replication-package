# LANG-51b
Both [__IA__] and [__IA-control__] have a reproduction rate of 100% with crash __LANG-51b__, however our proposed method performs significantly more efficient, with A<sub>12</sub> = _0.3356_ while _p = 0.02847_.
The input stack trace of it consists of one frame, as shown in __[Listing 1](#listing-1-stack-trace-of-lang-51b)__.

#### Listing 1: Stack Trace of LANG-51b
``` log
java.lang.StringIndexOutOfBoundsException: String index out of range: 3
  at org.apache.commons.lang.BooleanUtils.toBoolean(BooleanUtils.java:686)
```

The method `toBoolean` converts a `String` object to a `boolean` value.
The bug of the method lies in line 682 of __[Listing 2](#listing-2-bug-of-lang-51b)__ as there is no `break` to the switch clause.
For example, `"tru"` is of length 3.
After failing the check for `case 3`, `false` should have already been returned.
However, it continues into the check for `case 4` and there a `StringIndexOutOfBoundsException` is thrown at line 686 when accessing `charAt(3)`.

#### Listing 2: Bug of LANG-51b
``` java
649 | public static boolean toBoolean(String str) {
    | // ...
662 |     switch (str.length()) {
    |     // ...
670 |         case 3: {
671 |             char ch = str.charAt(0);
672 |             if (ch == 'y') {
673 |                 return
674 |                     (str.charAt(1) == 'e' || str.charAt(1) == 'E') &&
675 |                     (str.charAt(2) == 's' || str.charAt(2) == 'S');
676 |             }
677 |             if (ch == 'Y') {
678 |                 return
679 |                     (str.charAt(1) == 'E' || str.charAt(1) == 'e') &&
680 |                     (str.charAt(2) == 'S' || str.charAt(2) == 's');
681 |             }
682 |         }
683 |         case 4: {
684 |             char ch = str.charAt(0);
685 |             if (ch == 't') {
686 |                 return
687 |                     (str.charAt(1) == 'r' || str.charAt(1) == 'R') &&
688 |                     (str.charAt(2) == 'u' || str.charAt(2) == 'U') &&
689 |                     (str.charAt(3) == 'e' || str.charAt(3) == 'E');
690 |             }
691 |             if (ch == 'T') {
692 |                 return
693 |                     (str.charAt(1) == 'R' || str.charAt(1) == 'r') &&
694 |                     (str.charAt(2) == 'U' || str.charAt(2) == 'u') &&
695 |                     (str.charAt(3) == 'E' || str.charAt(3) == 'e');
696 |             }
697 |         }
698 |     }
699 |     return false;
700 | }
```

Any `String` of size 3 not starting with `'y'` or `'Y'` and any `String` of size 4 starting with `'t'` or `'T'` can reach line 686 easily.
The original integration testing function cannot provide any further guidance after reaching the line.
However, with our proposed fitness function outputting a more granular fitness value based on later accessed indices, it guides the search process to compose a `String` starting with `'t'`, then to `"tR"` or `"tr"`, and eventually to `"tRU"`, `"tRu"`, `"trU"`, or `"tru"` and triggering the exception being thrown.