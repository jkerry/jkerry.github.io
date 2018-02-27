---
layout: post
title:  "Habitat Architecture Part 0: Motivation"
date:   2018-2-27 00:00:00 -0500
categories: 
  - habitat
---

A year ago my team at NCR evaluated [Habitat](https://habitat.sh) as a delivery technology.  The construction and deployment of a critical internal solution for communication management was a part of that evaluation. The results so far have been impressive. The collection of NodeJS api microservices have been operational with functional uptime of 100% since our first production release in May 2017. This availability persisted through multiple application upgrades and configuration updates.

I'm excited to take a deeper look at Habitat this year as we continue to onboard new products. If we're going to be serious about service deployment with habitat there are several things we need to demonstrate for full production workload readiness:

- Fault tolerant architecture
- Multi-region Disaster Recovery
- A generic, post-human, cloud deployment model

It's amusing that I never knew to care about these before I switched teams to focus on operations concerns directly. My understanding of Habitat as a platform leads me to believe that the blend of development and operations concerns are handled in an powerfully elegant way.

I'm going to release a series of posts in the coming weeks covering deployment of habitat services to Azure and hone in on these requirements. [William Stewart](https://twitter.com/williamthedev) and I will be distilling all of it into a digestible 40 minutes for ChefConf 2018 and we're both stoked. Here's the blog release plan understanding that things will probably change as ideas meet messy reality.

- Part 1: Fault Tolerance in One Region
- Part 2: Deploying Habitat Services to Azure IaaS instances
- Part 3: Fault Tolerance Between Regions
- Part 4: Secure Ring Construction in Azure
- Part 5: Geo-Loadbalancing and Global Data Storage
- Part 6: What's Missing and What's Next

These will link out to completed posts when they are live and I expect we'll be adding a few posts on the developer experience side of the equation from William and/or [Grant Tuttle](https://twitter.com/JGrantTuttle) as we go so keep an eye out for updates!
