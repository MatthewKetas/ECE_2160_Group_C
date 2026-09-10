# Background

The Critter is an embedded system used to monitor a single machine room.

A Critter device operates independently for this prototype. Its primary purpose is to perform unattended temperature monitoring and support the identification of potential HVAC issues in that room.

The Critter product is functionally divided into three major components:

- **I/O** — collects temperature data at a high sampling rate.
- **Memory** — processes collected data by reducing unnecessary information, removing outliers, and summarizing results for offline analysis.
- **Computation** — performs more computationally intensive analysis to evaluate collected data and make predictions about HVAC behavior.

Prototype implementations should consider the different processing and resource characteristics of these components when designing the system.