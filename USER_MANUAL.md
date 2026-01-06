# TALKER: The Complete Beginner's Guide to Local AI

Welcome to **TALKER**. This mod allows characters in S.T.A.L.K.E.R. Anomaly to speak to you dynamically, reacting to the world, weather, and combat. 

Unlike Main Branch, This mod focusing on Local AI does not use the internet. It uses a **Local Large Language Model (LLM)**—an artificial intelligence that runs entirely on your own graphics card (GPU).

## ⚠️ The Golden Rules of Local AI

Before you start, there are two critical things you must understand:

1.  **"Smaller Brains Dream More" (Hallucinations)**
    *   AI models are like brains. A small brain (little VRAM usage) is fast but can get confused.
    *   It might make things up (hallucinate), confuse names, or speak gibberish if the situation is complex.
    *   If the AI says something weird, it's usually because the model is too small for the task.

2.  **Hardware Matters**
    *   Running AI requires video memory (VRAM). If you try to run a model that is too big for your card, it will run on your standard RAM (system memory), which is **extremely slow**.
    *   Always choose a model that fits your GPU.

---

## 🖥️ Hardware Recommendations (VRAM Tiers)

Choose the tier that matches your Graphics Card's VRAM.

### Tier 1: Entry Level (8GB VRAM)
*Best for: RTX 3060 / 4060, RX 6600*
*   **Stability**: Good. Occasional confusion.
*   **Recommended Models**:
    *   **Smart Model** (Dialogue): `llama3.1:8b` (Standard, reliable)
    *   **Fast Model** (Logic): `llama3.2:1b` (Very fast, strictly for background checks)

### Tier 2: Mid Range (12GB - 16GB VRAM)
*Best for: RTX 3080 / 4070 / 4080, RX 7800 XT*
*   **Stability**: Excellent. Richer vocabulary and better roleplay.
*   **Recommended Models**:
    *   **Smart Model**: `mistral-nemo` (12B) or `gemma2:9b` (Very high quality prose)
    *   **Fast Model**: `llama3.2:3b` (Smarter background logic)

### Tier 3: Enthusiast (24GB+ VRAM)
*Best for: RTX 3090 / 4090*
*   **Stability**: Perfection. Deep understanding of lore and complex interactions.
*   **Recommended Models**:
    *   **Smart Model**: `qwen2.5:14b` or `gemma2:27b` (Heavy, but incredibly smart)
    *   **Fast Model**: `llama3.1:8b`

---

## 🛠️ Step-by-Step Setup Guide

We recommend using **Ollama** because it is the easiest to set up.

### Step 1: Install Ollama
1.  Go to [ollama.com](https://ollama.com/).
2.  Download and install Ollama for Windows.
3.  Once installed, open your **Command Prompt** (press `Win + R`, type `cmd`, press Enter).

### Step 2: "Pull" (Download) Your Models
Type the command for your tier into the black Command Prompt window and press Enter.

**For Tier 1 (8GB VRAM):**
```bash
ollama pull llama3.1:8b
ollama pull llama3.2:1b
```

**For Tier 2 (12GB - 16GB VRAM):**
```bash
ollama pull mistral-nemo
ollama pull llama3.2:3b
```

**For Tier 3 (24GB+ VRAM):**
```bash
ollama pull qwen2.5:14b
ollama pull llama3.1:8b
```

*Wait for the download bars to reach 100%.*

### Step 3: Configure the Mod
1.  Launch **S.T.A.L.K.E.R. Anomaly**.
2.  Go to **Settings** -> **MCM** -> **TALKER**.
3.  Set **Local URL** to: `http://localhost:11434/api/chat` (This is the default for Ollama).
4.  **Important**: Type the *exact* name of the model you downloaded into the **Main Model Name** box.
    *   Example: `llama3.1:8b`
5.  Enable **"Separate Fast Model"**.
6.  Type the *exact* name of your smaller model into the **Fast Model Name** box.
    *   Example: `llama3.2:1b`

### Step 4: Play
Load your save. You should see a message on the HUD:
> "TALKER Connection: Both Models Connection OK!"

If you see this, you is ready to enter the Zone.

---

## ❓ Troubleshooting

**Q: The game freezes when someone talks!**
A: Your model is too big for your VRAM and is using your hard drive/RAM. Switch to a smaller model (Tier 1).

**Q: NPCs are speaking gibberish or repeating themselves.**
A: This is a "hallucination". The model confusing the context.
*   **Fix**: Increase the "Context Profile" in MCM to "High" (if your PC can handle it).
*   **Fix**: Switch to a smarter model (e.g., from `llama3.2`:1b` to `llama3.1:8b` for the main model).

**Q: I don't get a connection message.**
A: Make sure Ollama is running. Look for the little llama icon in your Windows taskbar tray.
