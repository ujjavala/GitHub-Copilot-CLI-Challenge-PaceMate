# AI-Powered Speech Analysis

## Overview

The PaceMate-Accessibility POC now includes AI-powered speech analysis using **Ollama** for personalized feedback on pacing, speaking clarity, and pacemate tips.

## Features

### Automatic Analysis

When a user completes speaking:
1. **Pacing Analysis** - Calculates estimated WPM and sentence structure
2. **AI Feedback** - Uses Llama2 via Ollama to generate personalized tips
3. **Metrics Display** - Shows detailed speech metrics
4. **Encouragement** - Provides warm, supportive feedback

### Detailed Feedback Display

The UI shows four categories of feedback:

```
💬 Encouragement      - Warm, supportive message
⏱️ Pacing Analysis    - Specific feedback on speaking rate
💡 Tips for Improvement - Actionable suggestions
📊 Speech Metrics     - Quantified speaking data
```

## Architecture

### Backend Flow

```
User speaks → Send speech text → SessionChannel
  ↓
AI.SpeechAnalysis.analyze_speech(text)
  ↓
Parse metrics → Query Ollama → Generate feedback
  ↓
Return structured feedback to frontend
```

### Metrics Calculated

- **Words** - Total word count
- **Sentences** - Number of sentences detected
- **Avg Sentence Length** - Words per sentence
- **Estimated WPM** - Words per minute speaking rate

### Pacing Analysis

```
< 80 WPM:  "Speaking quite slowly - pick up pace slightly"
80-160 WPM: "Your pacing is good - maintain steady rhythm"
> 160 WPM: "Speaking quickly - try slowing down"
```

## Ollama Integration

### What is Ollama?

Ollama is a simple way to run large language models (LLMs) locally:
- **No cloud** - Everything runs on your machine
- **Private** - No data leaves your computer
- **Fast** - Near-instant responses
- **Models** - Pre-built models (Llama2, Mistral, etc.)

### Setup

**Option 1: Docker (Recommended)**

```bash
docker-compose --profile ai up
```

This includes Ollama service. Models are automatically downloaded on first use.

**Option 2: Manual Installation**

```bash
# Install Ollama from https://ollama.ai
ollama serve

# In another terminal, pull model
ollama pull llama2
```

### Configuration

**Environment Variable:**
```bash
OLLAMA_HOST=http://localhost:11434
```

**Docker Compose:**
```yaml
environment:
  - OLLAMA_HOST=http://ollama:11434
```

## Frontend Display

### Feedback Card Layout

```
┌─────────────────────────────────────┐
│ Great job! 🎉                       │
├─────────────────────────────────────┤
│ 💬 Encouragement                    │
│ "You're doing great!"               │
├─────────────────────────────────────┤
│ ⏱️ Pacing Analysis                  │
│ "Your pacing is good..."            │
├─────────────────────────────────────┤
│ 💡 Tips for Improvement             │
│ "Try speaking more slowly..."       │
├─────────────────────────────────────┤
│ 📊 Speech Metrics                   │
│ Words: 42 | WPM: 84                 │
├─────────────────────────────────────┤
│ [Practice again]                    │
└─────────────────────────────────────┘
```

### Responsive Design

- **Desktop:** 4-column grid layout
- **Tablet:** 2-column layout
- **Mobile:** Single column
- **Dark mode:** Gradient backgrounds with adjusted colors

## Feedback Generation

### AI Prompt

```
Analyze this speech for someone with a speech pacemate and provide brief, 
encouraging feedback.

Speech: "[user's speech]"

Metrics:
- Words: [count]
- Sentences: [count]
- Avg words per sentence: [average]
- Estimated WPM: [rate]

Provide feedback in this exact format:
TIPS: [2-3 specific tips]
ENCOURAGEMENT: [brief encouragement]
```

### Fallback Strategy

If Ollama is unavailable:
1. Metrics-based analysis continues
2. Rule-based tips generated from metrics
3. Standard encouragement used
4. No user-facing errors

### Example Output

```
TIPS: Try speaking a bit more slowly. Break sentences into shorter phrases.
ENCOURAGEMENT: You're making great progress with your clarity!

Metrics:
- Words: 45
- Sentences: 3
- Avg length: 15 words/sentence
- WPM: 90
```

## Implementation Details

### Speech Analysis Module

**File:** `backend/lib/backend/ai/speech_analysis.ex`

**Key Functions:**
- `analyze_speech/1` - Main entry point
- `parse_speech_metrics/1` - Extract metrics
- `query_ollama/2` - Call Ollama API
- `format_pacing_feedback/1` - Format metrics feedback
- `rule_based_tips/1` - Fallback tips

### Types & Decoders

**Types:**
```elm
type alias Feedback =
    { encouragement : String
    , pacing : String
    , tips : String
    , metrics : Maybe Metrics
    }

type alias Metrics =
    { words : Int
    , sentences : Int
    , avgSentenceLength : Float
    , estimatedWpm : Float
    }
```

## Running with AI

### Option 1: Docker Compose (All-in-one)

```bash
docker-compose --profile ai up
open http://localhost:3000
```

Services start in order:
1. Ollama (downloads llama2 model on first start)
2. Backend (waits for Ollama healthy)
3. Frontend (waits for backend healthy)

### Option 2: Manual Setup

**Terminal 1 - Ollama:**
```bash
ollama serve
# Wait for "listening on 127.0.0.1:11434"
```

**Terminal 2 - Backend:**
```bash
cd backend
export OLLAMA_HOST=http://localhost:11434
mix phx.server
```

**Terminal 3 - Frontend:**
```bash
cd frontend
python3 -m http.server 3000
```

## Testing

### Backend Tests

```bash
cd backend
mix test test/backend/ai/
```

Tests include:
- Speech analysis with valid text
- Metrics calculation accuracy
- Ollama integration (mocked)
- Fallback behavior
- Edge cases

### Frontend Tests

```bash
cd frontend
npx elm-test
```

Tests include:
- Feedback decoding
- Metrics display
- Card rendering
- Responsive layout

## Performance

### Response Times

- **Metrics parsing:** <1ms
- **Ollama query:** 1-3 seconds (model dependent)
- **Fallback tips:** <1ms
- **Frontend rendering:** <100ms

### Optimization Tips

1. **Model selection:** Smaller models = faster (try `mistral` or `neural-chat`)
2. **Caching:** Could cache similar feedback
3. **Batching:** Analyze multiple sessions in batch
4. **Quantization:** Use quantized models for speed

## Customization

### Change Speaking Prompt

Edit `frontend/src/View.elm`:
```elm
div [ class "prompt-text" ]
    [ text "Tell me about a time you overcame a challenge." ]
```

### Add More Feedback Categories

Add to Elm `Feedback` type:
```elm
type alias Feedback =
    { encouragement : String
    , pacing : String
    , tips : String
    , breath_work : String  -- New!
    , metrics : Maybe Metrics
    }
```

### Custom AI Prompts

Edit `backend/lib/backend/ai/speech_analysis.ex`:
```elixir
prompt = """
[Your custom prompt here]
"""
```

## Troubleshooting

### Ollama Not Found

**Error:** `Ollama unavailable`

**Solution:**
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# If fails, start Ollama
ollama serve

# Verify in Docker
docker logs $(docker ps | grep ollama | awk '{print $1}')
```

### Slow Responses

**Cause:** Large model or slow machine

**Solutions:**
1. Use smaller model: `ollama pull mistral`
2. Increase system memory
3. Lower batch size
4. Consider cloud inference (Hugging Face, Together.ai)

### Model Not Downloading

**Docker:** Models download automatically with health check
**Manual:** Explicitly pull before starting:
```bash
ollama pull llama2
```

## Future Enhancements

### Potential Improvements

1. **Real Speech Recognition** - Use Web Audio API + STT (Whisper)
2. **Advanced Metrics** - Filler words, clarity score, stress level
3. **Personalized Models** - User-specific model fine-tuning
4. **Multi-language** - Support for 10+ languages
5. **Progress Tracking** - Compare sessions over time
6. **Coaching** - Adaptive prompts based on performance
7. **Community** - Share tips and progress
8. **Mobile App** - Native iOS/Android with real-time audio

## Privacy & Security

### Data Handling

- **Local Processing:** All LLM inference runs locally (Ollama)
- **No Uploads:** Speech text stays on your machine
- **No Logging:** Responses not stored by default
- **Encrypted:** Optional TLS for WebSocket

### Production Considerations

1. Add authentication if sharing instances
2. Use HTTPS/WSS in production
3. Consider audit logging for medical/research use
4. Implement rate limiting
5. Regular model updates

## References

- [Ollama Documentation](https://ollama.ai)
- [Llama2 Model Card](https://huggingface.co/meta-llama/Llama-2-7b)
- [PaceMate Speech Resources](https://www.pacemateinghelp.org)
- [Speech Pacing Research](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4940387/)

---

**AI makes personalized feedback possible at scale! 🤖**
