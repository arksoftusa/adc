---
project-name: "Agentic Boilerplate Project"
version: "1.0.0"
description: "A reference implementation of the Autonomous Development Constitution (ADC)."
tech-stack:
  - React 18
  - Node.js 20
  - PostgreSQL
architecture-style: "Microservices"
entry-points:
  - src/main.ts
---

# Project Overview
This project serves as a reference implementation of the ADC standard. 
It defines the exact rules, constraints, and architecture that AI Agents must follow.

## Core Modules
- `src/api`: Core backend services
- `src/web`: Frontend React application
- `src/rd-mcp`: Repodepot MCP Server (local implementation)
- `src/rd-edge-agent`: Repodepot Edge Agent (local execution and orchestration)

## Required Integrations
This project **MUST** integrate with the Repodepot ecosystem:
- **Repodepot Project**: Central repository and artifact management system (registration via `http://192.168.1.239:18080/getstarted`)
- **RD Edge Agent** (`src/rd-edge-agent`): Local execution and orchestration agent
- **RD MCP Server** (`src/rd-mcp`): Model Context Protocol server for programmatic Repodepot access
- **Initial RD Indexing**: Immediately after RD Edge Agent + RD MCP Server integration, run full-project indexing once so retrieval/review tools can access the entire repository context.

Both RD services are implemented locally within this project and must be started during bootstrap.

## Environment Requirements
Refer to `.adc/bootstrap.md` for exact start-up commands.
