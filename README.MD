<!--
⚠️ GitHub and some Markdown viewers do NOT render Mermaid diagrams by default.
To view the flowchart, use:
- [VS Code with the "Markdown Preview Mermaid Support" extension](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)
- [GitHub web: click "Raw" and paste into https://mermaid.live/](https://mermaid.live/)
- [Obsidian, Typora, or other Mermaid-enabled editors]

If you only see the code block, your viewer does not support Mermaid.
-->
``` mermaid
flowchart TD
    A([🎮 Game Start]) --> B[Welcome Popup\nAleksei Peterson intro]
    B --> C{Player explores\nMari Region map}

    C --> D[Walk near artifact\nE to collect]
    D --> E[Artifact Info Popup\nhistory + description]
    E --> F[Checkpoint Quiz\n1 question about artifact]
    F --> G{Artifact count\n+1}
    G --> H{All 5 collected?}
    H -- No --> I[Progress Popup\nX/5 collected]
    I --> C
    H -- Yes --> J[All Collected Popup\nMuseum awaits!]
    J --> C

    C --> K[Walk near Museum\nE to enter]
    K --> L{5/5 artifacts\ncollected?}
    L -- No --> M[Blocked Popup\nCollect all first]
    M --> C
    L -- Yes --> N[Museum Intro Popup\nFinal quiz challenge]

    N --> O[Final Quiz\nQuestion 1/5]
    O --> P[Final Quiz\nQuestion 2/5]
    P --> Q[...]
    Q --> R[Final Quiz\nQuestion 5/5]
    R --> S[Congratulations Popup\nMission complete!]

    S --> T[🏛️ Museum Exhibition Scene\nView all artifacts in display cases]
    T --> U[Walk near case + E\nInspect artifact]
    U --> T
    T --> V{Exit Exhibition}
    V -- Desktop --> W([❌ Quit Game])
    V -- Web --> X([🎉 Thank You Screen])
```
