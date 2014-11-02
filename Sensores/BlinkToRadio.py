#! /usr/bin/python
from TOSSIM import *
import sys
t = Tossim([])
r = t.radio()

r.add(1, 2, 54.0)
r.add(2, 1, 10.0)

t.addChannel("BlinkC", sys.stdout);

t.getNode(1).bootAtTime(100001);
t.getNode(2).bootAtTime(800008);


for i in range(150):
    t.runNextEvent()