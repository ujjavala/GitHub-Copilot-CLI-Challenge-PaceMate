// Elm is loaded globally from dist/elm.js
const app = Elm.Main.init({ node: document.getElementById('app') });

// Theme management
function updateTheme(isDark) {
  if (isDark) {
    document.documentElement.classList.add('dark-mode');
    document.body.classList.add('dark-mode');
  } else {
    document.documentElement.classList.remove('dark-mode');
    document.body.classList.remove('dark-mode');
  }
}

// Set initial theme (Light mode by default)
updateTheme(false);

// Listen for theme changes from Elm
if (app.ports && app.ports.themeChanged) {
  app.ports.themeChanged.subscribe(function(theme) {
    updateTheme(theme === 'Dark');
  });
}

// WebSocket connection
let socket = null;
let channel = null;

// Speech recognition setup
let recognition = null;
let recognizedText = '';
let isRecognizing = false;
let speechTimestamps = [];
let speechStartTime = null;

// Initialize Web Speech API
function initSpeechRecognition() {
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

  if (!SpeechRecognition) {
    console.error('[Speech] Web Speech API not supported in this browser');
    return null;
  }

  recognition = new SpeechRecognition();
  recognition.continuous = true;
  recognition.interimResults = true;
  recognition.lang = 'en-US';

  recognition.onstart = function() {
    console.log('[Speech] Recognition started');
    console.log('[Speech] Make sure microphone permission is granted!');
    isRecognizing = true;
    recognizedText = '';
    speechTimestamps = [];
    speechStartTime = Date.now();
  };

  recognition.onresult = function(event) {
    let interimTranscript = '';
    let finalTranscript = '';

    for (let i = event.resultIndex; i < event.results.length; i++) {
      const transcript = event.results[i][0].transcript;
      if (event.results[i].isFinal) {
        finalTranscript += transcript + ' ';
        console.log('[Speech] Final result:', transcript);
        // Track timing for each word
        speechTimestamps.push({
          text: transcript,
          timestamp: Date.now()
        });
      } else {
        interimTranscript += transcript;
        console.log('[Speech] Interim result:', transcript);
      }
    }

    if (finalTranscript) {
      recognizedText += finalTranscript;
      console.log('[Speech] Total recognized text so far:', recognizedText);
    }
  };

  recognition.onerror = function(event) {
    console.error('[Speech] Recognition error:', event.error);
    if (event.error === 'no-speech') {
      console.log('[Speech] No speech detected, continuing...');
    } else if (event.error === 'not-allowed' || event.error === 'permission-denied') {
      console.error('[Speech] ⚠️ MICROPHONE PERMISSION DENIED! Please allow microphone access.');
      alert('Microphone permission denied. Please allow microphone access in your browser settings and try again.');
    } else if (event.error === 'audio-capture') {
      console.error('[Speech] ⚠️ NO MICROPHONE FOUND! Please connect a microphone.');
      alert('No microphone found. Please connect a microphone and try again.');
    } else {
      console.error('[Speech] Unexpected error:', event.error);
    }
  };

  recognition.onend = function() {
    console.log('[Speech] Recognition ended');
    isRecognizing = false;
  };

  return recognition;
}

function connectToChannel() {
  // Auto-detect WebSocket URL based on environment
  const getWebSocketUrl = () => {
    // Check if we're in production (not localhost)
    const isProduction = window.location.hostname !== 'localhost' &&
                        window.location.hostname !== '127.0.0.1';

    if (isProduction) {
      // Use secure WebSocket in production
      const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
      // You can set this via environment variable or use default
      const backendHost = window.BACKEND_URL || 'pacemate-backend.fly.dev';
      return `${protocol}//${backendHost}/socket/websocket`;
    } else {
      // Use local development server
      return 'ws://localhost:4000/socket/websocket';
    }
  };

  const wsUrl = getWebSocketUrl();
  console.log('[WebSocket] Connecting to:', wsUrl);
  socket = new WebSocket(wsUrl);

  socket.onopen = function () {
    console.log('[WebSocket] Connected to server');

    // Join the channel
    const joinMsg = {
      topic: 'session:user_session',
      event: 'phx_join',
      payload: {},
      ref: '1'
    };
    socket.send(JSON.stringify(joinMsg));
    channel = 'session:user_session';
  };

  socket.onmessage = function (event) {
    try {
      const msg = JSON.parse(event.data);

      // Check if it's a response to our finished_speaking message
      if (msg.topic === 'session:user_session' && msg.event === 'phx_reply') {
        if (msg.payload && msg.payload.response) {
          // Send the detailed feedback to Elm
          app.ports.recv.send(msg.payload.response);
        }
      }
    } catch (e) {
      console.error('[WebSocket] Error parsing message:', e);
    }
  };

  socket.onerror = function (error) {
    console.error('[WebSocket] Error:', error);
  };

  socket.onclose = function () {
    console.log('[WebSocket] Disconnected from server');
  };
}

// Client-side speech analysis (fallback when backend is unavailable)
function analyzeClientSide(speechText, timestamps, startTime) {
  const words = speechText.trim().split(/\s+/).filter(word => word.length > 0);
  const totalDurationSeconds = (Date.now() - startTime) / 1000;
  const wordCount = words.length;
  const wordsPerMinute = wordCount > 0 ? Math.round((wordCount / totalDurationSeconds) * 60) : 0;

  // Detect potential repetitions (consecutive duplicate words)
  const detectedRepetitions = [];
  for (let wordIndex = 0; wordIndex < words.length - 1; wordIndex++) {
    const currentWord = words[wordIndex].toLowerCase();
    const nextWord = words[wordIndex + 1].toLowerCase();

    if (currentWord === nextWord) {
      detectedRepetitions.push(words[wordIndex]);
    }
  }

  // Analyze pacing and provide advice
  let pacingAdvice = '';
  if (wordsPerMinute < 100) {
    pacingAdvice = 'Great pacing! Your speed is comfortable and easy to follow.';
  } else if (wordsPerMinute < 140) {
    pacingAdvice = 'Good pace. You might want to slow down slightly for clarity.';
  } else {
    pacingAdvice = 'Try slowing down. Speaking more slowly can help reduce stuttering.';
  }

  let repetitionAdvice = '';
  const repetitionCount = detectedRepetitions.length;
  if (repetitionCount > 0) {
    repetitionAdvice = `Noticed ${repetitionCount} repetition(s). Take a breath before difficult words.`;
  } else {
    repetitionAdvice = 'No repetitions detected. Well done!';
  }

  return {
    wpm: wordsPerMinute,
    word_count: wordCount,
    duration: totalDurationSeconds.toFixed(1),
    pace_advice: pacingAdvice,
    repetition_advice: repetitionAdvice,
    detected_repetitions: detectedRepetitions.slice(0, 3),
    feedback: `${pacingAdvice} ${repetitionAdvice}`,
    source: 'client-side'
  };
}

// Initialize speech recognition
initSpeechRecognition();

// Connect when app is ready
setTimeout(connectToChannel, 100);

// Handle outgoing messages from Elm
app.ports.send.subscribe(function (msg) {
  if (msg.event === 'start_speaking') {
    // Start speech recognition
    if (recognition && !isRecognizing) {
      recognizedText = '';
      try {
        recognition.start();
        console.log('[Speech] Starting recognition...');
      } catch (e) {
        console.error('[Speech] Failed to start recognition:', e);
      }
    }
  } else if (msg.event === 'finished_speaking') {
    // Stop speech recognition and send the text
    if (recognition && isRecognizing) {
      recognition.stop();
      console.log('[Speech] Stopped recognition');
    }

    // Wait longer for any final results to come in (speech recognition is async)
    setTimeout(function() {
      console.log('[Speech] Final recognized text to send:', recognizedText);
      console.log('[Speech] Text length:', recognizedText.length);

      if (!recognizedText || recognizedText.trim().length === 0) {
        console.warn('[Speech] ⚠️ No speech was captured! Check microphone permissions and make sure you are speaking.');
        console.warn('[Speech] Browser:', navigator.userAgent);
        console.warn('[Speech] Has microphone permission?', 'Check browser permissions');
      }

      // Send the recognized speech to backend OR use client-side analysis as fallback
      if (socket && socket.readyState === WebSocket.OPEN) {
        const speechToSend = recognizedText.trim() || 'No speech detected';
        const message = {
          topic: msg.topic,
          event: msg.event,
          payload: { speech: speechToSend },
          ref: Math.random().toString().substring(2)
        };

        console.log('[WebSocket] Sending message:', message);
        socket.send(JSON.stringify(message));
      } else {
        console.warn('[WebSocket] Backend not available, using client-side analysis');
        // Use client-side analysis as fallback
        const analysis = analyzeClientSide(recognizedText, speechTimestamps, speechStartTime);
        console.log('[Client] Analysis result:', analysis);

        // Send analysis result to Elm app
        if (app.ports && app.ports.recv) {
          app.ports.recv.send(analysis);
        }
      }
    }, 1500);
  } else {
    // Handle other messages normally
    if (socket && socket.readyState === WebSocket.OPEN) {
      const message = {
        topic: msg.topic,
        event: msg.event,
        payload: msg.payload,
        ref: Math.random().toString().substring(2)
      };
      socket.send(JSON.stringify(message));
    }
  }
});
