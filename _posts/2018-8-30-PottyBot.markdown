---
layout: post
title:  "PottyBot"
date:   2018-8-30 00:00:00 -0500
categories: development AIY making
---

I'm the father of two young boys ages four and two. Potty training is not fun by any means of measurement. Current wisdom says that no matter the situation or circumstances you are not to punish a child for accidents. Instead you should reward and encourage successes. This totally makes sense and I get it, but after a while this can seriously stress the boundaries of your parental creativity. I have run out of things to promise. I've watched reward charts go unfilled and unwanted. There has to be a way to make all of this more engaging or I'm going to run out of resources to up the ante. Our second kid is starting to get interested in learning to kick the diapers so it's time to do it right.

# The AIY Voice Kit

I picked up the [Google AIY Voice Kit](https://www.target.com/p/google-voice-kit-aiy/-/A-53416295) while cruising through target because it looked like it would be interesting to fiddle with. The kit is a Pi Zero with supporting audio devices, an activation button, and a cardboard enclosure. When I first set it up my older son had a blast asking google questions. It was pretty impressive on the technical side. The AIY project has all the python code that drives the audio and video devices together [here](https://github.com/google/aiyprojects-raspbian).

![AIY Voice Kit at rest]({{ site.url }}/assets/images/AIYVoiceKit_Assembled.jpg)

I've had this thing sitting on the desk for a while and I've finally got a good problem to leverage it for.

# Project Plan

The project will run in a few phases

0. Planning and MVP: push button voice event logging
2. Potty Timer and Failure Logging
3. Project Box construction
4. Visual reward tracking: Arduino + NeoPixels

These can each represent large projects on their own so each phase will be released independently. The MVP is a voice activated reward chart. My toddler QA team will interract with the box after thuroughly washing their hands by pressing the activation button and logging... _an event_. The main application loop will look something like this:

<div id="diagram"></div>
<script src="{{ site.url }}/assets/js/raphael.min.js"></script>
<script src="{{ site.url }}/assets/js/flowchart.min.js"></script>
<script src="{{ site.url }}/assets/js/pottybot_flowchart.js"></script>
