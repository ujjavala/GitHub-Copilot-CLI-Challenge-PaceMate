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

// LocalStorage-based analytics for offline/Netlify deployment
function getLocalStorageAnalytics() {
  try {
    const sessions = JSON.parse(localStorage.getItem('pacemate_sessions') || '[]');

    if (sessions.length === 0) {
      return {
        totalSessions: 0,
        totalWords: 0,
        averageWpm: 0,
        currentStreak: 0
      };
    }

    const totalSessions = sessions.length;
    const totalWords = sessions.reduce((sum, s) => sum + (s.words || 0), 0);
    const totalWpm = sessions.reduce((sum, s) => sum + (s.wpm || 0), 0);
    const averageWpm = totalSessions > 0 ? totalWpm / totalSessions : 0;

    // Calculate streak (consecutive days of practice)
    const today = new Date().toDateString();
    const sortedDates = sessions
      .map(s => new Date(s.date).toDateString())
      .filter((date, index, self) => self.indexOf(date) === index)
      .sort((a, b) => new Date(b) - new Date(a));

    let currentStreak = 0;
    if (sortedDates.length > 0 && sortedDates[0] === today) {
      currentStreak = 1;
      for (let i = 1; i < sortedDates.length; i++) {
        const currentDate = new Date(sortedDates[i]);
        const previousDate = new Date(sortedDates[i - 1]);
        const diffDays = Math.floor((previousDate - currentDate) / (1000 * 60 * 60 * 24));

        if (diffDays === 1) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    return {
      totalSessions,
      totalWords,
      averageWpm: Math.round(averageWpm * 10) / 10,
      currentStreak
    };
  } catch (error) {
    console.error('[LocalStorage] Error reading analytics:', error);
    return {
      totalSessions: 0,
      totalWords: 0,
      averageWpm: 0,
      currentStreak: 0
    };
  }
}

function saveSessionToLocalStorage(feedback) {
  try {
    const sessions = JSON.parse(localStorage.getItem('pacemate_sessions') || '[]');
    const newSession = {
      date: new Date().toISOString(),
      words: feedback.metrics?.words || 0,
      wpm: feedback.metrics?.estimated_wpm || 0,
      timestamp: Date.now()
    };

    sessions.push(newSession);

    // Keep only last 100 sessions to avoid storage issues
    if (sessions.length > 100) {
      sessions.splice(0, sessions.length - 100);
    }

    localStorage.setItem('pacemate_sessions', JSON.stringify(sessions));
    console.log('[LocalStorage] Session saved:', newSession);
  } catch (error) {
    console.error('[LocalStorage] Error saving session:', error);
  }
}

// Listen for analytics fetch requests from Elm
if (app.ports && app.ports.fetchAnalytics) {
  app.ports.fetchAnalytics.subscribe(function() {
    // Always use localStorage analytics (works offline and on Netlify)
    const localAnalytics = getLocalStorageAnalytics();

    if (app.ports && app.ports.recvAnalytics) {
      app.ports.recvAnalytics.send(localAnalytics);
    }

    // Optionally try to sync with backend if available (enhancement only)
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      fetch('http://localhost:4000/api/analytics/summary')
        .then(response => response.json())
        .then(data => {
          // Backend data available, but we already sent localStorage data
          console.log('[Analytics] Backend data also available:', data);
        })
        .catch(error => {
          console.log('[Analytics] Backend not available, using localStorage only');
        });
    }
  });
}

// Listen for session history fetch requests from Elm
if (app.ports && app.ports.fetchSessionHistory) {
  app.ports.fetchSessionHistory.subscribe(function() {
    // Get session history from localStorage
    const sessions = JSON.parse(localStorage.getItem('pacemate_sessions') || '[]');

    // Aggregate by date
    const aggregatedByDate = {};
    sessions.forEach(session => {
      const date = new Date(session.date).toISOString().split('T')[0];
      if (!aggregatedByDate[date]) {
        aggregatedByDate[date] = {
          date: date,
          sessions: 0,
          words: 0,
          avgWpm: 0,
          totalWpm: 0
        };
      }
      aggregatedByDate[date].sessions += 1;
      aggregatedByDate[date].words += session.words || 0;
      aggregatedByDate[date].totalWpm += session.wpm || 0;
    });

    // Calculate averages and convert to array
    const historyArray = Object.values(aggregatedByDate).map(day => ({
      date: day.date,
      sessions: day.sessions,
      words: day.words,
      avgWpm: day.sessions > 0 ? day.totalWpm / day.sessions : 0
    })).sort((a, b) => a.date.localeCompare(b.date));

    // Send to Elm
    if (app.ports && app.ports.recvSessionHistory) {
      app.ports.recvSessionHistory.send(historyArray);
      console.log('[SessionHistory] Sent history:', historyArray);
    }

    // Optionally try to fetch from backend if available
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      fetch('http://localhost:4000/api/sessions/history')
        .then(response => response.json())
        .then(data => {
          console.log('[SessionHistory] Backend data also available:', data);
          // Could merge or replace localStorage data here if desired
        })
        .catch(error => {
          console.log('[SessionHistory] Backend not available, using localStorage only');
        });
    }
  });
}

// WebSocket connection
let socket = null;

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
  };

  socket.onmessage = function (event) {
    try {
      const msg = JSON.parse(event.data);

      // Check if it's a response to our finished_speaking message
      if (msg.topic === 'session:user_session' && msg.event === 'phx_reply') {
        if (msg.payload && msg.payload.response) {
          // Save session to localStorage for offline analytics
          saveSessionToLocalStorage(msg.payload.response);

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

  // Analyze pacing and provide therapeutic advice
  const pacingOptions = {
    slow: [
      'Your pacing feels comfortable and relaxed. This gentler pace gives you time to think and breathe naturally.',
      'What a nice, steady pace. Speaking at this rate can help you feel more in control and at ease.',
      'You\'re taking your time beautifully. This allows for relaxed breathing and reduces any pressure you might feel.'
    ],
    moderate: [
      'Your pace feels natural and conversational. If you ever feel tension, you might try slowing down just a touch.',
      'Lovely rhythm. When you\'re ready, you could explore adding a few gentle pauses between thoughts.',
      'This is a comfortable pace. Remember, you can always slow down whenever it feels right for you.'
    ],
    fast: [
      'It seems like you might be speaking a bit quickly. There\'s no rush—pauses can be your gentle friend.',
      'You might find it helpful to slow down a little. Many people discover that a gentler pace helps them feel more relaxed.',
      'If it feels comfortable, try speaking a bit more slowly. A slower pace often gives more time for breathing and reduces tension.'
    ]
  };

  let pacingCategory;
  if (wordsPerMinute < 100) {
    pacingCategory = 'slow';
  } else if (wordsPerMinute < 140) {
    pacingCategory = 'moderate';
  } else {
    pacingCategory = 'fast';
  }
  let pacingAdvice = pacingOptions[pacingCategory][Math.floor(Math.random() * 3)];

  // Provide comprehensive therapeutic tips
  const therapeuticTips = [
    'You might try using gentle onsets—starting words softly can feel more comfortable than pushing them out.',
    'When you\'re ready, explore light articulatory contacts: let your lips and tongue touch softly, without any pressure.',
    'If you feel stuck on a word, it\'s perfectly okay to pause, take a calm breath, and restart gently.',
    'You could build confidence by practicing in comfortable, low-pressure moments, like reading aloud to yourself.',
    'Remember, communication matters more than perfection. What\'s important is expressing yourself in a way that feels right.',
    'Consider trying breathing techniques: take a relaxed breath before speaking, then let the words flow on the exhale.',
    'Gentle pauses between phrases can help you feel more relaxed and maintain a comfortable rhythm.'
  ];

  // Select 2-3 random tips for variety
  const selectedTips = [];
  const tipIndices = new Set();
  while (tipIndices.size < 3) {
    tipIndices.add(Math.floor(Math.random() * therapeuticTips.length));
  }
  tipIndices.forEach(index => selectedTips.push(therapeuticTips[index]));

  const repetitionCount = detectedRepetitions.length;
  let tipsText = selectedTips.join(' ');

  // Add repetition-specific advice if detected
  if (repetitionCount > 0) {
    tipsText = `I noticed ${repetitionCount} repetition${repetitionCount > 1 ? 's' : ''}. That's completely normal. When this happens, you might gently pause and take a breath before continuing. ${selectedTips[0]} ${selectedTips[1]}`;
  }

  // Format response to match Elm's expected structure
  return {
    encouragement: "You're doing wonderfully. Remember, what matters most is communication and feeling comfortable expressing yourself. Every practice session is progress, no matter how it feels.",
    pacing: pacingAdvice,
    tips: tipsText,
    metrics: {
      words: wordCount,
      sentences: Math.max(1, Math.ceil(wordCount / 15)), // Rough estimate
      avg_sentence_length: Math.min(wordCount, 15),
      estimated_wpm: wordsPerMinute
    }
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

        // Save session to localStorage for offline analytics
        saveSessionToLocalStorage(analysis);

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
