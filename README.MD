# Finno-Ugric Heritage Expedition

**Finno-Ugric Heritage Expedition** is a small educational game created in Godot.  
The player explores a Mari-region inspired environment, collects cultural artifacts, answers quiz questions, and finally enters a museum exhibition after completing the mission.

## Project Overview

In this game, the player takes the role of **Aleksei Peterson**, an ethnographer exploring the Mari region. The main goal is to collect five cultural artifacts, learn about them, answer quiz questions, and bring the collected artifacts to the museum.

The game includes:

- An explorable map
- Five collectible cultural artifacts
- Artifact information popups
- Quiz questions after each collected artifact
- A final quiz before entering the museum
- A museum exhibition scene showing the collected artifacts
- Estonian-language user interface text

## Game Flow

The game follows this structure:

1. The player starts with an introduction popup.
2. The player explores the map and finds artifacts.
3. When the player is near an artifact, they can press **E** to interact.
4. After collecting an artifact, an information popup is shown.
5. The player answers a quiz question about the artifact.
6. After collecting all five artifacts, the player can enter the museum.
7. Before entering the final museum exhibition, the player completes a final quiz.
8. The game ends with the museum exhibition scene.

## Controls

| Action | Key |
|---|---|
| Move | Arrow keys |
| Interact / Collect / Inspect | E |
| Select quiz answer | 1, 2, 3, or 4 |
| Continue / Confirm | Enter or Space |

## Main Files and Folders

Important project files include:

```text
Scenes/
  Player.tscn
  QuestItem.tscn
  Museum.tscn
  UI/
    ArtifactInfoUI.tscn
    QuizUI.tscn
    PopupUI.tscn

Scripts/
  ArtifactManager.gd
  QuizUI.gd
  ArtifactInfoUI.gd
  PopupUI.gd
  Player.gd

Resources/
  artifact_data.json

Assets/
  Images/
  Icons/
  kenney_isometric-miniature-library/
```

The file `artifact_data.json` contains the artifact details, image paths, quiz questions, answer options, and final quiz questions.

## Requirements

To open or edit the project, you need:

- Godot Engine 4.x
- A desktop computer capable of running Godot
- The full project folder, including all scenes, scripts, resources, and assets

The project may not work correctly if only some files are shared. Make sure the full folder structure is included.

## How to Run the Project in Godot

1. Download or copy the full project folder.
2. Open **Godot Engine**.
3. Click **Import**.
4. Select the project's `project.godot` file.
5. Open the project.
6. Click the **Play** button in Godot.

## How to Share the Project Files

If you want to share the editable Godot project with others:

1. Compress the full project folder into a `.zip` file.
2. Make sure the `.zip` file includes:
   - `project.godot`
   - `Scenes/`
   - `Scripts/`
   - `Resources/`
   - `Assets/`
3. Send the `.zip` file to others.
4. They can open it using Godot.

Do not share only the `.gd` script files, because the game also depends on scenes, images, resources, and project settings.

## How to Export the Game for Web

Exporting for Web is useful if you want others to play the game in a browser.

### Step 1: Install Export Templates

In Godot:

```text
Editor → Manage Export Templates → Download and Install
```

### Step 2: Add a Web Export Preset

Go to:

```text
Project → Export
```

Then:

1. Click **Add...**
2. Select **Web**
3. Set the export path to something like:

```text
exports/web/index.html
```

The main file should be named `index.html`.

### Step 3: Export the Project

Click:

```text
Export Project
```

Godot will create files similar to:

```text
index.html
index.js
index.wasm
index.pck
```

All of these files must stay together.

## How to Test the Web Build Locally

Do not just double-click `index.html`. A web build should be tested using a local server.

Inside the exported web folder, run:

```bash
python -m http.server 8000
```

Then open this in a browser:

```text
http://localhost:8000
```

## How to Upload to itch.io

1. Create an account on itch.io.
2. Create a new project.
3. Set the project type to **HTML**.
4. Zip the exported web files.
5. Make sure the ZIP contains the files directly:

```text
index.html
index.js
index.wasm
index.pck
```

Avoid putting them inside an extra folder inside the ZIP.

6. Upload the ZIP file.
7. Enable the option that says the file should be played in the browser.
8. Save and publish the project.
9. Share the itch.io link with others.

## How to Export for Windows

If you want to share a Windows version:

1. Go to:

```text
Project → Export
```

2. Add a **Windows Desktop** preset.
3. Export the project.
4. Godot may generate files such as:

```text
FinnoUgricHeritageExpedition.exe
FinnoUgricHeritageExpedition.pck
```

Share both files together in one ZIP file.

## Notes for Players

This game is designed as a short educational experience. It introduces selected cultural artifacts through exploration, object collection, and quiz-based learning.

The current version uses Estonian interface text.

## Credits

Created as part of a digital heritage / museum-style game project.

Assets include isometric visual resources and custom artifact images used for educational presentation.

## Troubleshooting

### The game does not open in the browser

Make sure you are running the exported files through a local server or a web hosting platform. Opening `index.html` directly may not work.

### Images are missing

Check that the `Assets/Images/` folder is included and that image paths in `artifact_data.json` are correct.

### The quiz text is still in English

Check the `artifact_data.json` file and make sure the artifact names, descriptions, quiz questions, and answer options are translated.

### The game does not open in Godot

Make sure the full project folder is shared and that the `project.godot` file is included.

## Suggested Sharing Format

For editable project sharing:

```text
Finno-Ugric-Heritage-Expedition-Project.zip
```

For browser play:

```text
Finno-Ugric-Heritage-Expedition-Web.zip
```

For Windows play:

```text
Finno-Ugric-Heritage-Expedition-Windows.zip
```

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
