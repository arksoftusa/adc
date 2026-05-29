# Frontend Conventions

## Web Visualization Library Policy
- **Dynamic State-Machine Indicators**: Dynamic state-machine indicators in all webpage projects, including metro-style operational status views, MUST use `d3-tube-map`.
- **Ordinary Node/Edge Displays**: Plain node/edge graph displays MUST use AntV or ECharts.
- **2.5D Simulated 3D Views**: 2.5D simulated 3D network, topology, or graph views MUST use `sigma`.
- **Toolchain Consistency**: Keep visualization toolchains consistent within a feature and avoid mixing libraries for the same visual surface unless the project owner explicitly approves an exception.
- **Dependency Authorization**: If one of these approved libraries is not already present in the project, adding it still requires the normal third-party dependency authorization flow.
