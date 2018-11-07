Quadruples
==========

| State | Tape    | Action  |NewState|
|-------|---------|---------|--------|
| A_1   | (b,/,b) | (b,+,b) | A_1'   |
| A_1'  | (/,b,/) | (+,1,0) | A_2    |
| A_2   | ($,/,b) | (b,+,b) | A_2'   |
| A_2'  | (/,b,/) | (0,2,0) | A_4    |
| A_2   | (1,/,b) | (b,+,b) | A_3'   |
| A_3'  | (/,b,/) | (+,3,0) | A_3    |
| A_3   | (1,/,b) | (1,+,b) | A_4'   |
| A_4'  | (/,b,/) | (+,4,0) | A_3    |
| A_3   | ($,/,b) | (1,+,b) | A_5'   |
| A_5'  | (/,b,/) | (-,5,0) | A_4    |
| A_4   | (1,/,b) | (1,+,b) | A_6'   |
| A_6'  | (/,b,/) | (-,6,0) | A_4    |
| A_4   | (b,/,b) | (b,+,b) | A_7'   |
| A_7'  | (/,b,/) | (0,7,0) | A_5    |
| A_5   | (b,7,b) | (b,7,b) | B_1'   |
| B_1'  | (/,/,/) | (+,0,+) | B_1    |
| B_2'  | (/,/,/) | (-,0,-) | B_2    |
| B_1   | (1,7,b) | (1,7,1) | B_1'   |
| B_1   | ($,7,b) | ($,7,$) | B_1'   |
| B_2   | (1,7,1) | (1,7,1) | B_2'   |
| B_2   | ($,7,$) | ($,7,$) | B_2'   |
| B_1   | (b,7,b) | (b,7,b) | B_2'   |
| B_2   | (b,7,b) | (b,7,b) | C_5    |
| C_5   | (/,7,/) | (0,b,0) | C_7'   |
| C_7'  | (b,/,b) | (b,-,b) | C_4    |
| C_4   | (/,6,/) | (+,b,0) | C_6'   |
| C_6'  | (1,/,b) | (1,-,b) | C_4    |
| C_4   | (/,5,/) | (+,b,0) | C_5'   |
| C_5'  | (1,/,b) | ($,-,b) | C_3    |
| C_3   | (/,4,/) | (-,b,0) | C_4'   |
| C_4'  | (1,/,b) | (1,-,b) | C_3    |
| C_3   | (/,3,/) | (-,b,0) | C_3'   |
| C_3'  | (b,/,b) | (1,-,b) | C_2    |
| C_4   | (/,2,/) | (0,b,0) | C_2'   |
| C_2'  | (b,/,b) | ($,-,b) | C_2    |
| C_2   | (/,1,/) | (-,b,0) | C_1'   |
| C_1'  | (b,/,b) | (b,-,b) | C_1    |

Is it reversible?
=================

Yes. If we inspect each rule, we see that each (State, Tape) tuple appears only
once in the table, so the rules are disjoint in their domains. Furthermore, all
normal computation steps (not marked prime) in the first stage have exclusive
ranges, by virtue of writing their unique rule number to the history tape.
Similary, all steps in the last stage are invertible, as they all invert a rule
in the first stage. Lastly, the copy operation is reversible, since it will
start at the beginning of the output on the first tape, and copy each symbol
while moving forward, switching between the B_1 and B_1' states. Only when
reaching the very end does it switch to the B_2' state, and then remains only in
B_2' and B_2. It is thus clear at every instance whether the machine is copying,
moving left to right, or going back to the beginning, moving right to left, and
there is no ambiguity as to what the reverse operation is. 

Computation
===========

| State | Standard  | History   | Output      | 
|-------|-----------|-----------|-------------| 
| A_1   | `b>b11$1` | `b>b`     | `b>b`       |
| A_1'  | `b>b11$1` | `b>b`     | `b>b`       |
| A_2   | `b>11$1`  | `b>1`     | `b>b`       |
| A_3'  | `b>b1$1`  | `1>b`     | `b>b`       |
| A_3   | `b>1$1`   | `1>3`     | `b>b`       |
| A_4'  | `b>1$1`   | `13>b`    | `b>b`       |
| A_3   | `1>$1`    | `13>4`    | `b>b`       |
| A_5'  | `1>11`    | `134>b`   | `b>b`       |
| A_4   | `b>111`   | `134>5`   | `b>b`       |
| A_6'  | `b>111`   | `1345>b`  | `b>b`       |
| A_4   | `b>b111`  | `1345>6`  | `b>b`       |
| A_7'  | `b>b111`  | `13456>b` | `b>b`       |
| A_5   | `b>b111`  | `13456>7` | `b>b`       |
| B_1'  | `b>b111`  | `13456>7` | `b>b`       |
| B_1   | `b>111`   | `13456>7` | `b>b`       |
| B_1'  | `b>111`   | `13456>7` | `b>1`       |
| B_1   | `1>11`    | `13456>7` | `1>b`       |
| B_1'  | `1>11`    | `13456>7` | `1>1`       |
| B_1   | `11>1`    | `13456>7` | `11>b`      |
| B_1'  | `11>1`    | `13456>7` | `11>1`      |
| B_1   | `111>b`   | `13456>7` | `111>b`     |
| B_2'  | `111>b`   | `13456>7` | `111>b`     |
| B_2   | `11>1`    | `13456>7` | `11>1`      |
| B_2'  | `11>1`    | `13456>7` | `11>1`      |
| B_2   | `1>11`    | `13456>7` | `1>11`      |
| B_2'  | `1>11`    | `13456>7` | `1>11`      |
| B_2   | `b>111`   | `13456>7` | `b>111`     |
| B_2'  | `b>111`   | `13456>7` | `b>111`     |
| B_2   | `b>b111`  | `13456>7` | `b>b111`    |
| C_5   | `b>b111`  | `13456>7` | `b>b111`    |
| C_7'  | `b>b111`  | `13456>b` | `b>b111`    |
| C_4   | `b>b111`  | `1345>6`  | `b>b111`    |
| C_6'  | `b>111`   | `1345>b`  | `b>b111`    |
| C_4   | `b>111`   | `134>5`   | `b>b111`    |
| C_5'  | `1>11`    | `134>b`   | `b>b111`    |
| C_3   | `1>$1`    | `13>4`    | `b>b111`    |
| C_4'  | `b>1$1`   | `13>b`    | `b>b111`    |
| C_3   | `b>1$1`   | `1>3`     | `b>b111`    |
| C_3'  | `b>b1$1`  | `1>b`     | `b>b111`    |
| C_2   | `b>11$1`  | `b>1`     | `b>b111`    |
| C_1'  | `b>b11$1` | `b>b`     | `b>b111`    |
