# Critter Development Workspace

This repository contains the development environment for the ECE 2160 Critter product.

The Critter is an embedded system for monitoring a single machine room, collecting environmental data, processing that data, and supporting HVAC-related analysis.

Development targets the Raspberry Pi 5 using C.

## Project Structure

```text
.
├── Development
│   ├── CritterProduct
│   ├── Data
│   ├── Metrics
│   └── Tooling
│       ├── Agents
│       ├── Instructions
│       └── Skills
├── Resources
├── Utils
│   └── SenseHat
│       ├── sense_hat_environment.c
│       └── sense_hat_environment.h
└── Workspaces
```

## Directory Purpose

### `Development/`

Contains active Critter development work.

#### `Development/CritterProduct/`

Contains Critter implementations, prototypes, and project iterations.

Example:

```text
CritterProduct/
├── Pilot/
├── Iteration2/
└── Iteration3/
```

Each project should contain its own source code, build configuration, and project-specific tests.

#### `Development/Data/`

Contains data generated or used during development.

Examples include:

- Raw sensor data
- Processed data
- Test datasets
- Experimental results

#### `Development/Metrics/`

Contains measurements used to evaluate software and system performance.

Examples include:

- CPU utilization
- Memory utilization
- Execution timing
- Sampling rates
- Storage usage

#### `Development/Tooling/`

Contains development support files.

```text
Tooling/
├── Agents
├── Instructions
└── Skills
```

`Agents/` contains specialized agent definitions.

`Instructions/` contains persistent development and project rules.

`Skills/` contains reusable procedures for common development tasks.

## `Resources/`

Contains reference material used by the project.

Examples include:

- Product background
- Requirements
- Architecture documentation
- Hardware documentation
- Datasheets
- Course material

Production source code should not be placed in this directory.

## `Utils/`

Contains reusable utilities that are not specific to a single Critter implementation.

Current utilities include:

```text
Utils/
└── SenseHat/
    ├── sense_hat_environment.c
    └── sense_hat_environment.h
```

The Sense HAT utility provides a reusable C interface for environmental measurements such as:

- Temperature
- Humidity
- Pressure

Utilities should remain independent of Critter-specific application logic.

## `Workspaces/`

Contains IDE and editor workspace configuration files.

Workspace files may define:

- Project folders
- Development tooling
- File exclusions
- Agent visibility
- Editor configuration

## Development Guidelines

- Use C for Critter embedded software.
- Target the Raspberry Pi 5.
- Keep hardware access separate from application logic.
- Keep reusable utilities independent of individual Critter projects.
- Keep generated data separate from source code.
- Keep performance measurements in `Development/Metrics`.
- Keep project documentation and reference material in `Resources`.
- Keep project-specific source code under `Development/CritterProduct`.
- Avoid committing generated build artifacts when practical.

## Dependency Direction

The intended dependency direction is:

```text
Critter Application
        │
        ▼
Reusable Utilities
        │
        ▼
Operating System / Hardware
```

Utilities should not depend on individual Critter applications.

## Adding New Development Work

New Critter implementations should be created under:

```text
Development/CritterProduct/
```

Reusable hardware or software support should be placed under:

```text
Utils/
```

Reference material should be placed under:

```text
Resources/
```

Generated datasets and performance results should be kept outside the application source directories.