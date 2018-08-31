var diagram = flowchart.parse(
`st=>start: Start
play_audio=>operation: Play Audio
op1=>operation: Button Press
sub1=>subroutine: GCloud:
Text to Speech

sub2=>subroutine: Fuzzy String Matcher

cond1=>condition: "I went pee
in the potty"?

cond2=>condition: "I went poo
in the potty"?

congrats=>subroutine: GCloud:
Dad joke
text to speech

op3=>operation: Weighted Increment
Reward Count

cond3=>condition: "How am 
I doing"?

status=>subroutine: GCloud:
Delta to reward
text to speech

e=>end: term
st->op1->sub1->sub2->cond1
cond1(yes, right)->op3(bottom)->congrats(right)->op1
cond1(no)->cond2
cond2(yes, right)->op3(right)->congrats(right)->op1
cond2(no)->cond3
cond3(yes,right)->status(top)->op1
cond3(no)->e`);
diagram.drawSVG('diagram');
