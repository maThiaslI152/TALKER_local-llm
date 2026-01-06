# TALKER (Local LLM Fork)
A LLM powered dialogue generator for STALKER Anomaly. This fork is for my own uses because I want to implement my own tweaks and use a localhosted LLM.

![TALKER](images/talker.png)

## Overview
This version of TALKER has been refactored to remove all dependencies on paid APIs (OpenAI, OpenRouter, etc.), voice features, and proxies. It is designed to be a lightweight, privacy-focused, and free alternative that runs entirely on your own hardware.

### Key Features
*   **100% Local**: No API keys, no internet connection required. Works with **Ollama** and **LM Studio**.
*   **Dual-Model Architecture**:
    *   **Smart Model**: Used for writing the actual high-quality dialogue (e.g., `llama3.2`).
    *   **Fast Model**: A smaller, faster model (e.g., `llama3.2:1b`) handles background logic like choosing the next speaker, making gameplay significantly smoother.
*   **Optimized Performance**: Stripped of bloat from unused features (voice, proxies).
*   **Universal Compatibility**: Supports both Ollama native API (`/api/chat`) and OpenAI-compatible endpoints (`/v1/chat/completions`) out of the box.

## 📖 New to AI?
**[👉 Click here for the Complete Beginner's Guide & Hardware Recommendations](USER_MANUAL.md)**
*(Contains VRAM tiers and step-by-step setup instructions)*

## Installation

### Prerequisites
1.  **STALKER Anomaly** (1.5.2 or newer)
2.  **A Local LLM Host**:
    *   [Ollama](https://ollama.ai/) (Recommended for ease of use)
    *   [LM Studio](https://lmstudio.ai/) (Good for Windows GUI users)

### Step 1: Install the Mod
1.  Download this repository.
2.  Install via **Mod Organizer 2** (recommended) or drag the `gamedata` folder into your Anomaly directory.

### Step 2: Set Up Local AI
#### Option A: Ollama (Recommended)
1.  Install Ollama.
2.  Pull the recommended models:
    ```bash
    ollama pull llama3.2       # Main "Smart" Model
    ollama pull llama3.2:1b    # Secondary "Fast" Model
    ```
3.  Run the server: `ollama serve`

#### Option B: LM Studio
1.  Install LM Studio.
2.  Download a model (e.g., Llama 3.2 3B Instruct).
3.  Go to the **Developer (Server)** tab.
4.  Start the Local Server on port `1234`.

### Step 3: In-Game Configuration
1.  Launch Anomaly and go to **Settings > MCM > T.A.L.K.E.R.**
2.  **Local LLM Settings**:
    *   **Main Model URL**: 
        *   Ollama: `http://localhost:11434/api/chat`
        *   LM Studio: `http://localhost:1234/v1/chat/completions`
    *   **Main Model Name**: Enter the exact name of your model (e.g., `llama3.2` or `llama-3.2-3b-instruct`).
3.  **Fast Model (Optional but Recommended)**:
    *   Check "Enable Separate Fast Model".
    *   Enter the URL and Name for your small, fast model (e.g., `llama3.2:1b`).
4.  **Language**: Select your preferred language for dialogue.

**Done!** When you see "All TALKER modules loaded" and "TALKER Connection: Both Models Connection OK!" on your HUD, you are ready to play.

---

## How It Works
TALKER monitors in-game events (combat, looting, weather changes). When appropriate, it sends this context to your local LLM to generate unique, character-specific dialogue.

*   **Contextual**: NPCs react to what's actually happening (e.g., "Reloading!", "I see a bandit!").
*   **Unique Personalities**: A Duty veteran speaks differently from a Freedom rookie.

### Recent Update (v1.1)
*   **Improved Trigger Logic**:
    *   **Safe Zone Fix**: Companions now intelligently holster their "combat chatter" when their weapon is strapped, preventing spam in bases.
    *   **Responsive Combat**: "Kill Confirmations" from companions are no longer blocked by previous callouts (reduced cooldown to 2s).
    *   **Better Reloads**: Reload comments now happen more frequently (25% chance) to add combat flavor.
*   **MCM Overhaul**:
    *   Cleaned up UI with tooltips for descriptions.
    *   Added **Token Estimates** for Context Profile settings (Low/Medium/High) to help with performance tuning.
    *   Fixed "Context Profile" selection bug.
*   **Optimization**:
    *   Internal code cleanup and query optimization for better performance.

## Credits
This mod is a fork of the original **TALKER** by **Danclave**.

*   **Original Author**: [Danclave](https://github.com/danclave/TALKER) - for the incredible concept and base codebase.
*   **Original Contributors**:
    *   [balls of pure diamond](https://www.youtube.com/@BallsOfPureDiamond)
    *   ThorsDecree
    *   [Cheeki Breeki](https://www.youtube.com/@CheekiBreekiTv)
    *   Mirrowel (API Proxy)
    *   And the entire Anomaly modding community.

*   **Fork Modifications**: Adaptation for exclusive local LLM support, removal of paid API code/voice/proxy features, codebase optimization.

## Developer Guide

### Architecture Overview

TALKER follows a simple event-driven architecture:

1.  **Triggers (`gamedata/scripts/talker_trigger_*.script`)**:
    *   Listen for in-game callbacks (e.g., `actor_on_feeling_anomaly`, `npc_on_death`).
    *   Validate the event (cooldowns, distances).
    *   If valid, dispatch an event to the LLM interface.

2.  **Core Utilities (`gamedata/scripts/talker_game_queries.script`)**:
    *   Provides a safe abstraction layer over the raw X-Ray Engine API.
    *   Handles common tasks like checking distances, getting object names, and describing the world state.

3.  **Interface (`gamedata/scripts/talker_interface.script`)**:
    *   Manages the connection to the Local LLM.
    *   Constructs the prompt based on the event and game state.

### Key Scripts

*   `talker_game_queries.script`: The central library for all game state queries. Contains:
    *   `get_player()`: Returns the actor object.
    *   `describe_world(speaker, listener)`: Generates a natural language description of the current weather, time, and location.
    *   `get_nearby_characters(center, distance)`: Finds valid conversation partners.

*   `talker_mcm.script`: Handles the Mod Configuration Menu (MCM) settings.
    *   `local_url`: The endpoint for the main "Smart" model.
    *   `local_url_fast`: The endpoint for the secondary "Fast" model.
